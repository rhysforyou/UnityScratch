﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Learning Shaders/Object Space Lighting" {
    Properties {

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

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };
            
            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target {
                return saturate(dot(i.normal, _WorldSpaceLightPos0));
            }
            ENDCG
        }
    }
}
