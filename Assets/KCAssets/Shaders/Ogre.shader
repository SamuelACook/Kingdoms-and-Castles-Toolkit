Shader "Custom/Ogre" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_DamageAlpha ("DamageAlpha", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows addshadow

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _Fog;

		fixed _Width;
		fixed _Height;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		float _DamageAlpha;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			//Start fog clip
			fixed4 fogPixel = tex2D (_Fog, IN.worldPos.xz / float2(_Width, _Height));
			clip(fogPixel.a-.501);
			//End fog clip 

			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = lerp(c.rgb,fixed3(1,1,1), _DamageAlpha);
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
			o.Emission = lerp(float4(0,0,0,1),float4(1, 1, 1,1),_DamageAlpha);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
