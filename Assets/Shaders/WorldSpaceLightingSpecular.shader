// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Learning Shaders/World Space Lighting (Specular)" {
    Properties {
        _DiffuseColor ("Diffuse Color", Color) = (1, 1, 1, 1)
        _SpecularColor ("Speculr Color", Color) = (1, 1, 1, 1)
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _Shininess ("Shininess", Range(1, 1000)) = 10
        _SpecularIntensity ("Specular Intensity", Range(0, 1)) = 1
        _RimIntensity ("Rim Intensity", Range(0, 1)) = 0.5
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        Tags { "LightMode"="ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 viewDirection : TEXCOORD2;
            };

            uniform fixed4 _DiffuseColor;
            uniform fixed4 _SpecularColor;
            uniform fixed4 _RimColor;
            uniform fixed _Shininess;
            uniform fixed _SpecularIntensity;
            uniform fixed _RimIntensity;

            uniform float3 upVector = float3(0, 1, 0); // Normalized up vector

            // Calculate the ambient color of a world-space normal based on sky,
            // equator, and ground contributions
            fixed4 baseAmbient(float3 normal) {
                float ambientFactor = dot(upVector, normal);

                fixed4 skyContribution = ambientFactor * unity_AmbientSky;
                fixed4 equatorContribution = (1 - abs(ambientFactor)) * unity_AmbientEquator;
                fixed4 groundContribution = -ambientFactor * unity_AmbientGround;

                return skyContribution + equatorContribution + groundContribution;
            }
            
            v2f vert (appdata v) {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.viewDirection = normalize(mul(unity_ObjectToWorld, v.vertex).xyz - _WorldSpaceCameraPos);

                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target {
                float3 normal = normalize(i.normal);
                float3 viewDirection = normalize(i.viewDirection);

                fixed4 ambient = baseAmbient(normal);
                fixed4 diffuse = max(dot(normal, _WorldSpaceLightPos0), 0) * _DiffuseColor * _LightColor0;
                fixed4 specular = _SpecularColor  * _SpecularIntensity * _LightColor0 * pow(max(0.0, dot(reflect(_WorldSpaceLightPos0, normal), viewDirection)), _Shininess);
                fixed4 rimLight = _RimColor * _RimIntensity * pow((1 - abs(dot(normal, viewDirection))), 2);

                return ambient + diffuse + specular + rimLight;
            }
            ENDCG
        }
    }
}
