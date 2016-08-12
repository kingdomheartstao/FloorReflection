// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Test /ONEP_MirrorReflection_GaussianBlur"
{
	Properties
	{
		_BlurSize("BlurSize", Range(0,0.1)) = 0.055
		_StepSize("StepSize", Range(0,10)) = 10
		[HideInInspector]_MainTex("", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Pass {
			CGPROGRAM
			//CGINCLUDE
			// Upgrade NOTE: excluded shader from DX11, Xbox360, OpenGL ES 2.0 because it uses unsized arrays
			//#pragma exclude_renderers d3d11 xbox360 gles
			#pragma vertex vert vertBlurVertical
			#pragma fragment frag fragBlur
			#include "UnityCG.cginc"
			uniform half _StepSize;
			uniform half _BlurSize;
			//uniform sampler2D intensityVol;

			struct v2f
			{
				half4 refl : TEXCOORD1;
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};
			float4 _MainTex_ST;
			v2f vert(float4 pos : POSITION, half2 uv : TEXCOORD2)
			{
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, pos);
				o.refl = ComputeScreenPos (o.pos);
				return o;
			}
			sampler2D _MainTex;
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 tex = tex2D(_MainTex, i.uv);
				
				fixed4 refl = tex2Dproj(_MainTex, UNITY_PROJ_COORD(i.refl));

				//
				half4 pixelCoord = UNITY_PROJ_COORD(i.refl);
				// starting position of the ray is stored in the texture coordinate
				half3 start = i.pos;
				half4 colorSample = half4 (0.0,0.0,0.0,0.0);
				half4 colAcc = half4 (0.0,0.0,0.0,0.0);
				float lengthAcc = 0.0;
				float opacityCorrection = _StepSize/ _BlurSize;
				half4 samplePos = pixelCoord;
				//offset to eight locations surround target: permute top/bottom, anterior/posterior, left/right
				float dx = 0.5; //distance from target voxel
				half4 vTAR = half4( dx, dx, dx, 0)*_BlurSize;
				half4 vTAL = half4( dx, dx,-dx, 0)*_BlurSize;
				half4 vTPR = half4( dx,-dx, dx, 0)*_BlurSize;
				half4 vTPL = half4( dx,-dx,-dx, 0)*_BlurSize;
				half4 vBAR = half4(-dx, dx, dx, 0)*_BlurSize;
				half4 vBAL = half4(-dx, dx,-dx, 0)*_BlurSize;
				half4 vBPR = half4(-dx,-dx, dx, 0)*_BlurSize;
				half4 vBPL = half4(-dx,-dx,-dx, 0)*_BlurSize;
				//intensityVol = _MainTex;
				for(int i = 0; i < 2; i++) {
					colorSample = tex2Dproj(_MainTex,samplePos+vTAR);
					colorSample += tex2Dproj(_MainTex,samplePos+vTAL);
					colorSample += tex2Dproj(_MainTex,samplePos+vTPR);
					colorSample += tex2Dproj(_MainTex,samplePos+vTPL);
					colorSample += tex2Dproj(_MainTex,samplePos+vBAR);
					colorSample += tex2Dproj(_MainTex,samplePos+vBAL);
					colorSample += tex2Dproj(_MainTex,samplePos+vBPR);
					colorSample += tex2Dproj(_MainTex,samplePos+vBPL);
					colorSample *= 0.125; //average of 8 sample locations
					colorSample.a = 1.0-pow((1.0 - colorSample.a), opacityCorrection);      
					colorSample.rgb *= colorSample.a; 
					//accumulate color
					colAcc = (1.0 - colAcc.a) * colorSample + colAcc;
					if ( colAcc.a > 0.95 ) break;
				}
				return colAcc;
			}
			ENDCG
	    }
	}
	FallBack "Diffuse"
}