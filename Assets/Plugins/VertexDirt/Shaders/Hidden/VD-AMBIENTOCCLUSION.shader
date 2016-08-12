
Shader "Hidden/VD-AMBIENTOCCLUSION" {

	SubShader {
		
		cull off 
		fog {mode off}
		Lighting Off
		LOD 200
		Tags { "RenderType" = "Opaque" }
		
		CGPROGRAM
		#pragma surface surf VDAO noambient novertexlights nolightmap nodirlightmap noforwardadd
		half4 _VDOccluderColor;
	
		fixed4 LightingVDAO (SurfaceOutput s, fixed3 lightDir, fixed atten) {
			fixed4 c;
			c.rgb = s.Albedo;
			c.a = s.Alpha;
			return c;
		}
	
		struct Input {
			half2 uv_MainTex;
		};
		
		void surf (Input IN, inout SurfaceOutput o) {
		
			o.Albedo = _VDOccluderColor;
			o.Alpha = 1.0;
			
		}
		
		ENDCG

	} 	
	
}
