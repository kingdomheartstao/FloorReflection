// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Test /FastGlass" {
	Properties{
		_Color ("Color", Color) = (1, 1, 1, 0.5)
		_Alpha ("Alpha", Range(0, 1)) = 0.1
		_BaseAlpha ("BaseAlpha", Range(0, 1)) = 0.3
		_Reflection ("Reflection", Range(0, 20)) = 2
		_SpecularAlpha ("_SpecularAlpha", Range(0, 1)) = 0.3
		_MaxSpecularValue ("_MaxSpecularValue", Range(0, 1)) = 0.7
	}
	SubShader {
		Tags { "Queue" = "Transparent" }

		Pass {
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			uniform float4 _Color;
			uniform float _Reflection;
			uniform float _Alpha;
			uniform float _BaseAlpha;
			uniform float _SpecularAlpha;
			uniform float _MaxSpecularValue;

			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float3 normal : TEXCOORD;
				float3 viewDir : TEXCOORD1;	
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				float4x4 modelMatrix = unity_ObjectToWorld;
				float4x4 modelMatrixInverse  = unity_WorldToObject;

				output.normal = normalize(
					mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);

				output.viewDir = normalize(_WorldSpaceCameraPos
					- mul(modelMatrix, input.vertex).xyz); // get vertex in WORLDSPACE

				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);

				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				//float powY = 1;
				float3 normalDirection = normalize(input.normal);
				float3 viewDirection = normalize(input.viewDir);
				float refection = dot(viewDirection, normalDirection);

				float newOpacity = min(_MaxSpecularValue, max((_Alpha
					/ abs(pow(refection, _Reflection))), _BaseAlpha));

				return float4(_Color.rgb + _Color.rgb * (1/refection) * _SpecularAlpha, newOpacity);
			}

			ENDCG
		}
	}
}
