Shader "Custom/Blur" {
	Properties{
		_BlurSize ("BlurSize", Float) = 1.0
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		[HideInInspector] _MetTex("", 2D) = "white" {}
	}
	SubShader{
		//Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
					// Use shader model 3.0 target, to get nicer looking lighting
			//#pragma target 3.0

			sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform float _BlurSize;

			struct v2f {
				float4 pos : SV_POSITION;
				half2 uva[5] : TEXCOORD1;
				float4 refl : TEXCOORD0;
			};

			v2f vert (float4 pos : POSITION, half2 uv : TEXCOORD0) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, pos);
				o.refl = ComputeScreenPos(o.pos);
				o.uva[0] = o.refl.xy;
				o.uva[1] = o.refl.xy + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
				o.uva[2] = o.refl.xy - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
				o.uva[3] = o.refl.xy + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
				o.uva[4] = o.refl.xy - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
				
				return o;
			}

			fixed4 frag (v2f i) : SV_Target{
				return tex2D(_MainTex, i.uva[0] / i.refl.w);
			}

			ENDCG
		}
		//Pass
		//{
		//	CGPROGRAM
		//	// Physically based Standard lighting model, and enable shadows on all light types
		//	#pragma vertex vert
		//	#pragma fragment frag
		//	#include "UnityCG.cginc"
		//	// Use shader model 3.0 target, to get nicer looking lighting
		//	//#pragma target 3.0

		//	sampler2D _MainTex;
		//	uniform half4 _MainTex_TexelSize;
		//	uniform float _BlurSize;

		//	struct v2f {
		//		float4 pos : SV_POSITION;
		//		half2 uva[5] : TEXCOORD1;
		//		float4 refl : TEXCOORD0;
		//	};

		//	v2f vert(float4 pos : POSITION, half2 uv : TEXCOORD0) {
		//		v2f o;
		//		o.pos = mul(UNITY_MATRIX_MVP, pos);
		//		o.refl = ComputeScreenPos(o.pos);
		//		o.uva[0] = o.refl.xy;
		//		o.uva[1] = o.refl.xy + float2(_MainTex_TexelSize.y * 1.0, 0.0) * _BlurSize;
		//		o.uva[2] = o.refl.xy - float2(_MainTex_TexelSize.y * 1.0, 0.0) * _BlurSize;
		//		o.uva[3] = o.refl.xy + float2(_MainTex_TexelSize.y * 2.0, 0.0) * _BlurSize;
		//		o.uva[4] = o.refl.xy - float2(_MainTex_TexelSize.y * 2.0, 0.0) * _BlurSize;

		//		return o;
		//	}

		//	fixed4 frag(v2f i) : SV_Target{
		//		float weight[3] = { 0.4026, 0.2442, 0.0545 };

		//		fixed3 sum = tex2D(_MainTex, i.uva[0] / i.refl.w).rgb * weight[0];

		//		for (int it = 1; it < 3; it++)
		//		{
		//			sum += tex2D(_MainTex, i.uva[it] / i.refl.w).rgb * weight[it];
		//			sum += tex2D(_MainTex, i.uva[2 * it] / i.refl.w).rgb * weight[it];
		//		}

		//		//return tex2D(_MainTex, i.uva[0]);
		//		return fixed4(sum, 1.0);
		//	}
		//	ENDCG
		//}
	}
	FallBack "Diffuse"
}