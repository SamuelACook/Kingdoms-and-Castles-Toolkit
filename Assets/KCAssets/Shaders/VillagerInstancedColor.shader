Shader "Custom/VillagerInstancedColor" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		[Toggle] _FogClip("Apply Fog Clip", Float) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard vertex:vert
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _Fog;

		fixed _Width;
		fixed _Height;

		struct Input {
			float2 uv_MainTex;
			float4 vertColor : COLOR;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		float _FogClip;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			UNITY_DEFINE_INSTANCED_PROP(fixed4, _HeadColor)
			UNITY_DEFINE_INSTANCED_PROP(fixed4, _BodyColor)
		UNITY_INSTANCING_BUFFER_END(Props)


		void vert(inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.vertColor = v.color;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color

			//Start fog clip
			if (_FogClip == 1) // PersonUI Villager Clipping in UI - Able to Disable / Enable
			{
				fixed4 fogPixel = tex2D(_Fog, IN.worldPos.xz / float2(_Width, _Height));
				clip(fogPixel.a - .501);
			}
			//End fog clip

			fixed4 c = fixed4(0,0,0,1);
			c += tex2D(_MainTex, IN.uv_MainTex) * clamp(1 - (IN.vertColor.r + IN.vertColor.g), 0, 1);
			c += UNITY_ACCESS_INSTANCED_PROP(Props, _HeadColor) * IN.vertColor.g;
			c += UNITY_ACCESS_INSTANCED_PROP(Props, _BodyColor) * IN.vertColor.r;
			
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
