// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "Fog/SurfFogClipSnowInstanced" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_SnowColor("SnowColor", Color) = (0.933, 0.933, 0.909,1)
		_Snow("Snow", Range(0,1)) = 0
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Cull Off
		
		CGPROGRAM

		// Physically based Standard lighting model, and enable shadows on all light types
		// And generate the shadow pass with instancing support
		#pragma surface surf Standard fullforwardshadows addshadow
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _Fog;

		fixed _Width;
		fixed _Height;

		struct Input {
			float2 uv_MainTex;
			float3 worldNormal;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		

		fixed4 _Color;

		fixed4 _SnowColor;
		float _Snow;

		float when_gt(float x, float y) {
			return max(sign(x - y), 0.0);
		}

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			//Start fog clip
			fixed4 fogPixel = tex2D (_Fog, IN.worldPos.xz / float2(_Width, _Height));
			clip(fogPixel.a-.501);
			//End fog clip

			// Albedo comes from a texture tinted by color
			fixed4 texCol = tex2D (_MainTex, IN.uv_MainTex) * _Color; 

			
			fixed4 lerpedSnow = lerp(texCol,
								_SnowColor,
								_Snow); 

			float useSnow = when_gt(dot(IN.worldNormal, fixed3(0, 1, 0)), 0.5f);
			useSnow *= when_gt(IN.worldPos.y,0.02f);

			fixed4 c = lerp(texCol, lerpedSnow, useSnow * 0.875f);

			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG


	}
	FallBack "Diffuse"
}
