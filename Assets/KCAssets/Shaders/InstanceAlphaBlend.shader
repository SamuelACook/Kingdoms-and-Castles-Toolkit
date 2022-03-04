// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "Fog/AlphaBlendFog" 
{
	Properties
	{
		
		_MainTex("Texture", 2D) = "white" {}
	}
		
	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			AlphaToMask On

			CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#pragma multi_compile_instancing

	#include "UnityCG.cginc"

			

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 worldPos : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Fog;

			fixed _Width;
			fixed _Height;

			UNITY_INSTANCING_BUFFER_START(Props)
				
				UNITY_INSTANCING_BUFFER_END(Props)

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);

				//Start fog clip
				fixed4 fogPixel = tex2D (_Fog, i.worldPos.xz / float2(_Width, _Height));
				clip(fogPixel.a-.501);
				//End fog clip

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				
				return  col;
			}
			ENDCG
		}
	}
}



//	Properties{
//		_Color("Color", Color) = (1,1,1,1)
//		_MainTex("Albedo (RGB)", 2D) = "white" {}
//		_Glossiness("Smoothness", Range(0,1)) = 0.5
//		_Metallic("Metallic", Range(0,1)) = 0.0
//	}
//		SubShader{
//			Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
//			LOD 200
//
//			CGPROGRAM
//			// Physically based Standard lighting model, and enable shadows on all light types
//			// And generate the shadow pass with instancing support
//			#pragma surface surf NoLighting alpha:fade
//
//			// Use shader model 3.0 target, to get nicer looking lighting
//			#pragma target 2.0
//
//			sampler2D _MainTex;
//
//			struct Input {
//				float2 uv_MainTex;
//			};
//
//			half _Glossiness;
//			half _Metallic;
//
//			fixed4 _Color;
//
//
//			// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
//			// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
//			// #pragma instancing_options assumeuniformscaling
//			UNITY_INSTANCING_BUFFER_START(Props)
//				// put more per-instance properties here
//			UNITY_INSTANCING_BUFFER_END(Props)
//
//			fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten)
//			{
//				fixed4 c;
//				c.rgb = s.Albedo;
//				c.a = s.Alpha;
//				return c;
//			}
//
//			//void surf(Input IN, inout SurfaceOutputStandard o) {
//			//	// Albedo comes from a texture tinted by color
//			//	fixed4 texCol = tex2D(_MainTex, IN.uv_MainTex) * _Color;
//			//	o.Albedo = texCol.rgb;
//			//	o.Metallic = _Metallic;
//			//	o.Smoothness = _Glossiness;
//			//	o.Alpha = texCol.a;
//			//}
//			ENDCG
//		}
//			FallBack "Diffuse"
//}
