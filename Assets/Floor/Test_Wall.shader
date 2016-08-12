// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_LightmapInd', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D
// Upgrade NOTE: replaced tex2D unity_LightmapInd with UNITY_SAMPLE_TEX2D_SAMPLER

// Shader created with Shader Forge v1.02 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge


Shader "Test /Test_Wall"
{
	Properties
	{
		[Enum(Off, 0, On, 2)] _Cull("Cull Mode", Float) = 2
		_Color("Color", Color) = (0.5,0.5,0.5,1)
		_MainTex("MainTex", 2D) = "white" {}
		_AOTex("AOTex", 2D) = "white" {}
		_AO("AO", Range(0, 1)) = 1
		[Toggle] _UseSpecular("Use Specular", Float) = 0
		_Specular("Specular", 2D) = "white" {}
		_SpecularColor("SpecularColor", Color) = (1,1,1,1)
		_F0("F0", Range(0, 1)) = 0
		_RoughnessRG("Roughness (RG)", 2D) = "white" {}
		_RoughnessX("Roughness X", Range(0, 1)) = 0.3042201
		_RoughnessY("Roughness Y", Range(0, 1)) = 0.236613
		[PowerSlider(2.0)] _RoughnessPower("RoughessPower", Range(1, 100)) = 20
		_DetailNormal("DetailNormal", 2D) = "bump" {}
		_DetailIntensity("Detail Intensity", Range(0, 1)) = 1
		[Toggle] _Doubleincominglight("Double incoming light", Float) = 1
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Cull[_Cull]

		Pass
		{
			Name "ForwardBase"
			Tags{ "LightMode" = "ForwardBase" }

			Fog{ Mode Off }
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag 
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#pragma multi_compile_fwdbase_fullshadows
			#pragma target 3.0
			#pragma glsl

			uniform half4 _Color;
			uniform half _F0;
			uniform half _RoughnessY;
			uniform half _RoughnessX;
			uniform half _RoughnessPower;
			uniform half4 _SpecularColor;
			uniform sampler2D _AOTex; uniform half4 _AOTex_ST;
			uniform sampler2D _DetailNormal; uniform half4 _DetailNormal_ST;
			uniform sampler2D _MainTex; uniform half4 _MainTex_ST;
			uniform half _DetailIntensity;

			half3 ProbeLighting(half3 wN , half NdotL , half3 atten)
			{
				return ShadeSH9(half4(wN.xyz/**unity_Scale.w*/,1.0))*0.5;// + NdotL * atten;
			}

			half3 DynamicStatic(half3 SH , half3 atten , half NdotL)
			{
				half3 Light = 0;
				Light = SH;
				return Light;
			}

			uniform fixed _Doubleincominglight;
			uniform sampler2D _Specular; uniform half4 _Specular_ST;
			uniform sampler2D _RoughnessRG; uniform half4 _RoughnessRG_ST;
			uniform fixed _UseSpecular;
			half V(half NdotL , half specPow , half NdotV)
			{
				//half alpha = 1.0/(sqrt((3.1416/4.0)*specPow+6.283));
				half alpha = 1.0 / (((3.1416 / 4.0)*specPow + 6.283) / 3);
				return (NdotL*(1.0 - alpha) + alpha)*(NdotV*(1.0 - alpha) + alpha);
			}

			half normTerm(half specPow)
			{
				return (specPow + 8.0) / (8.0*3.1416);
			}

			uniform half _AO;
			struct VertexInput
			{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				half4 tangent : TANGENT;
				half2 texcoord0 : TEXCOORD0;
				half2 texcoord1 : TEXCOORD1;
			};
			struct VertexOutput
			{
				half4 pos : SV_POSITION;
				half2 uv0 : TEXCOORD0;
				half4 posWorld : TEXCOORD2;
				half3 normalDir : TEXCOORD3;
				half3 tangentDir : TEXCOORD4;
				half3 binormalDir : TEXCOORD5;
				LIGHTING_COORDS(6,7)
			};
			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.uv0 = v.texcoord0;
				o.normalDir = mul(unity_ObjectToWorld, half4(v.normal,0)).xyz;
				o.tangentDir = normalize(mul(unity_ObjectToWorld, half4(v.tangent.xyz, 0.0)).xyz);
				o.binormalDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				half3 lightColor = _LightColor0.rgb;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(o)
				return o;
			}
			fixed4 frag(VertexOutput i) : SV_Target
			{
				i.normalDir = normalize(i.normalDir);
				half3x3 tangentTransform = half3x3(i.tangentDir, i.binormalDir, i.normalDir);
				/////// Vectors:
				half3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				half3 node_1844 = half3(0,0,1);
				half3 _DetailNormal_var = UnpackNormal(tex2D(_DetailNormal,TRANSFORM_TEX(i.uv0, _DetailNormal)));
				half3 node_1847 = lerp(node_1844,_DetailNormal_var.rgb,_DetailIntensity);
				half3 node_1797 = half3(node_1847.rg,node_1847.b);
				half3 normalLocal = node_1797;
				half3 normalDirection = normalize(mul(normalLocal, tangentTransform)); // Perturbed normals
				half3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				half3 lightColor = _LightColor0.rgb;
				////// Lighting:
				half attenuation = LIGHT_ATTENUATION(i);
				////// Emissive:
				half node_3602 = 1.0;
				half4 _AOTex_var = tex2D(_AOTex,TRANSFORM_TEX(i.uv0, _AOTex));
				half3 node_3600 = lerp(half3(node_3602,node_3602,node_3602),_AOTex_var.rgb,_AO);
				half4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
				half4 _Specular_var = tex2D(_Specular,TRANSFORM_TEX(i.uv0, _Specular));
				half3 node_2868 = (_Specular_var.rgb*_F0*_SpecularColor.rgb);
				half3 node_9165 = node_2868.rgb;
				half3 node_1778 = (node_3600*_Color.rgb*_MainTex_var.rgb*(1.0 - ((node_9165.r + node_9165.g + node_9165.b)*0.3333333)));
				half node_11 = max(0,dot(lightDirection,normalDirection)); // NdotL
				half _Doubleincominglight_var = lerp(1.0, 2.0, _Doubleincominglight);
				half3 node_2036 = (_LightColor0.rgb*_Doubleincominglight_var*attenuation);
				half3 node_2276 = DynamicStatic(ProbeLighting(i.normalDir , node_11 , node_2036) , node_2036 , node_11); // GI
				half node_56 = max(0,dot(normalDirection,viewDirection)); // NdotV
				half3 emissive = ((UNITY_LIGHTMODEL_AMBIENT.rgb*node_1778) + (node_2276*node_1778*_Doubleincominglight_var));
				half3 node_2401 = (node_2036*node_11); // atten
				half3 node_1289 = (node_1778*node_2401); // Dynamic Diffuse
				half3 node_101 = normalize((lightDirection + viewDirection)); // H
				half3 node_610 = normalize(cross(normalDirection,mul(half3(1,0,0), tangentTransform).xyz.rgb)); // tangent
				half4 _RoughnessRG_var = tex2D(_RoughnessRG,TRANSFORM_TEX(i.uv0, _RoughnessRG));
				half node_2558 = (_RoughnessRG_var.r*_RoughnessY);
				half node_643 = (dot(node_101,node_610) / node_2558);
				half node_2567 = (_RoughnessX*_RoughnessRG_var.g);
				half node_644 = (dot(node_101,normalize(cross(node_610,normalDirection))) / node_2567);
				half node_96 = dot(normalDirection,node_101); // HdotN
				half node_3246 = V(node_11, (node_2558 + node_2567) * _RoughnessPower * _RoughnessPower, node_56);
				half node_1138 = max(0,dot(node_101,lightDirection)); // HdotL
				half node_111 = (1.0 - node_1138);
				half3 node_116 = (node_2868 + ((node_111*node_111*node_111*node_111*node_111)*(1.0 - node_2868))); // Fresnel Term
				half3 finalColor = emissive + lerp((node_1289), (((node_11*(exp((-1 * (((node_643*node_643) + (node_644*node_644)) / (node_96*node_96))))*normTerm(node_3246))*(1.0 / node_3246)*node_116*3.141592654)*node_2036*_RoughnessRG_var.b*_SpecularColor.a) + node_1289), _UseSpecular);
				return fixed4(finalColor,1);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
