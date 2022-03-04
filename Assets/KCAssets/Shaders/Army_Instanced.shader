﻿// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "Instanced/Army_Instanced" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		// And generate the shadow pass with instancing support
		#pragma surface surf Standard fullforwardshadows addshadow vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldNormal;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;

		float _camScale;
		float _colorMul;


		void vert(inout appdata_full v) 
		{
			
			v.vertex.xyz *= _camScale;
		
		}


		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
				fixed4 texCol = tex2D (_MainTex, IN.uv_MainTex);
			
			fixed4 c = texCol * _colorMul;

			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 1.0f;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
