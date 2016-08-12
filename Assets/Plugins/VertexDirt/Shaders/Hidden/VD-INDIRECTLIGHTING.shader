
Shader "Hidden/VD-INDIRECTLIGHTING" {

	Properties {
	
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Illum ("Illumin (A)", 2D) = "white" {}
		
	}
			
	SubShader {
		
		cull off 
		fog {mode off}
		Lighting Off
		LOD 200
		Tags { "RenderType" = "Opaque" }
		
		CGPROGRAM
		#pragma surface surf Lambert addshadow
		half _VDIndirectIntensity;
		half _VDIndirectContrast;			
		sampler _MainTex;
		sampler2D _Illum;
		half4 _Color;
	
		struct Input {
			half2 uv_MainTex;
			half2 uv_Illum;
		};
		
		void surf (Input IN, inout SurfaceOutput o) {

			half4 t = tex2D(_MainTex, IN.uv_MainTex);
			half4 c = t * _Color;
			o.Albedo = c * 0.1;
			half4 e = tex2D(_Illum, IN.uv_Illum);
			o.Emission = t.rgb * e.a * _VDIndirectIntensity;
			o.Alpha = 1.0;
			
		}
		
		ENDCG
	
	}
	
}
