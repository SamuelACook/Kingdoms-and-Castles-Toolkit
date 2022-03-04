Shader "Custom/Flag" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_Speed ("Speed", float) = 1
		_Frequency ("Frequency", float) = 2
		_Amplitude("Amplitude", float) = 3
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldNormal;
		};

			  half _Speed;
	  half _Frequency;
	  half _Amplitude;

	  void vert (inout appdata_full v) {
		  
		  float idx = ((int)v.vertex.z * 100 + (int)v.vertex.x) * 10;
		v.vertex.x += cos(idx + v.color.r* _Frequency + (-_Time)* _Speed) * _Amplitude * v.color.r;
		   
           
      }



		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
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
