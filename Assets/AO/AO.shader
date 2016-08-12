// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'

// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'
// Upgrade NOTE: replaced 'texRECT' with 'tex2D'

// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'
// Upgrade NOTE: replaced 'texRECT' with 'tex2D'

Shader "Test /AO" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
			//_EmitterIndex()
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 100
			
			Pass
			{
				CGPROGRAM
				#pragma vertex AmbientOcclusion
				//#pragma fragment FormFactor
				#include "UnityCG.cginc"
				#pragma glsl
				#pragma target 3.0
				uniform float4 emitterIndex;
				uniform float4 emitterNormal;
				uniform float emitterArea;

				uniform sampler2D   lastResultMap;

				uniform sampler2D positionMap;

				uniform sampler2D elementNormalMap;

				uniform sampler2D indexMap;


				float FormFactor(float3 v, float d2, float3 receiverNormal,

					float3 emitterNormal, float emitterArea)

				{

				  // assume that emitterArea has been divided by PI



					return emitterArea * saturate(dot(emitterNormal, v)) *

						saturate(dot(receiverNormal, v)) / (d2 + emitterArea);

				}	

				float4 AmbientOcclusion(

					float4 position : SV_POSITION,

					float4 normOffset : TEXCOORD0

				)	 : COLOR
				{

					float eArea;      // emitter area

					float4 ePosition; // emitter position

					float4 eNormal;   // emitter normal



					float3 rPosition = tex2Dlod (positionMap, position).xyz;

					float3 rNormal = tex2Dlod(elementNormalMap, position).xyz;

					float3 v;         // vector from receiver to emitter

					float total = 0;  // used to calculate accessibility



					float4 eIndex = float4(0.5, 0.5, 0, 0); // index of current emitter

					float3 bentNormal = rNormal;      // initialize with receiver normal

					float value;

					float d2;         // distance from receiver to emitter squared



					while (emitterIndex.x != 0) { // while not finished traversal

						ePosition = tex2Dlod(positionMap, emitterIndex);

						eNormal = tex2Dlod(elementNormalMap, emitterIndex);

						eArea = emitterNormal.w;

						eIndex = tex2D(indexMap, emitterIndex.xy); // get next index



						v = ePosition.xyz - rPosition; // vector to emitter

						d2 = dot(v, v) + 0.0000001;   // calc distance squared, avoid 0

													// is receiver close to parent element?

						if (d2 < -4 * emitterArea) 
						{  // (parents have negative area)

							eIndex.xy = eIndex.zw;    // go down hierarchy

							emitterArea = 0;          // ignore this element

						}

						v *= rsqrt(d2);             // normalize v

						value = FormFactor(v, d2, rNormal, eNormal.xyz, abs(eArea)) *

							tex2Dlod(lastResultMap, position).w; // modulate by last result

						bentNormal -= value * v;    // update bent normal

						total += value;

					}
				//if (!lastPass)                // only need bent normal for last pass

				return saturate(1 - total); // return accessibility only
				//else return float4(normalize(bentNormal), 1 Ð total);
			}
			ENDCG
		}

	}
	FallBack "Diffuse"
}
