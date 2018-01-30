// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Learning Shaders/Basic Unlit" {
	Properties {
        _DiffuseColor ("Diffuse Color", Color) = (1, 1, 1, 1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			float4 vert (float4 vertex : POSITION) : SV_POSITION {
                return UnityObjectToClipPos(vertex);
			}

            fixed4 _DiffuseColor;
			
			fixed4 frag () : SV_Target {
				// sample the texture
                return _DiffuseColor;
			}
			ENDCG
		}
	}
}
