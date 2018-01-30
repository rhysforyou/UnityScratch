Shader "Learning Shaders/Image Based Lighting"
{
    Properties
    {
        _MainTex ("Albedo Map", 2D) = "white" {}
        _NormalTex ("Normal Map", 2D) = "white" {}
        _EnvTex ("Environment Map", Cube) = "black" {}
        _SpecColor ("Specular Color", Color) = (1,1,1,1) 
        _Gloss ("Gloss", Range(0, 1)) = 0.5
        _Shininess ("Shininess", Range(0, 100)) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Tags { "LightMode"="ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #define DIFFUSE_MIP_LEVEL 11
            #define GLOSS_MIP_LEVEL 13

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
            };

            struct v2f 
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 eyeVec : TEXCOORD4;
                UNITY_FOG_COORDS(1)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalTex;
            samplerCUBE _EnvTex;
            float _Gloss;
            float _Shininess;


            half4 sampleTexCube(samplerCUBE cube, float3 normal, half mipLevel)
            {
                return texCUBElod(cube, half4(normal, mipLevel));
            }

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.tangent = mul(v.tangent, (float3x3)unity_WorldToObject);
                o.bitangent = cross(o.normal, o.tangent);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.eyeVec = normalize(worldPos - _WorldSpaceCameraPos);

                UNITY_TRANSFER_FOG(o,o.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 eyeVec = normalize(i.eyeVec);
                float3 normalTex = tex2D(_NormalTex, i.uv) * 2 - 1;
                fixed3 normal = (i.tangent * normalTex.r + i.bitangent * normalTex.g + i.normal * normalTex.b);
                fixed3 reflection = reflect(eyeVec, normal);

                fixed4 albedoColor = tex2D(_MainTex, i.uv);
                fixed4 directDiffuse = saturate(dot(i.normal, _WorldSpaceLightPos0) * _LightColor0) * (1 - _Gloss);
                fixed4 indirectDiffuse = sampleTexCube(_EnvTex, half3(normal), DIFFUSE_MIP_LEVEL);
                fixed4 directSpecular = _SpecColor.rgba * _LightColor0.rgba  * pow(max(0.0, dot(reflect(_WorldSpaceLightPos0, normal), eyeVec)), _Shininess);
                fixed4 indirectSpecular = sampleTexCube(_EnvTex, reflection, (1 - _Gloss) * GLOSS_MIP_LEVEL) * _Gloss;

                UNITY_APPLY_FOG(i.fogCoord, col);

                return albedoColor * (directDiffuse + indirectDiffuse) + directSpecular + indirectSpecular;
            }
            ENDCG
        }
    }
}
