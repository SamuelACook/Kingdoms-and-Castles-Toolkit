// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "Instanced/Army_InstancedFogUnlit" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		ZWrite On

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			// And generate the shadow pass with instancing support
			#pragma surface surf NoLighting noforwardadd vertex:vert
			

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

			void surf (Input IN, inout SurfaceOutput o) {
				// Albedo comes from a texture tinted by color
				fixed4 texCol = tex2D (_MainTex, IN.uv_MainTex);

				//Start fog clip
				fixed4 fogPixel = tex2D (_Fog, IN.worldPos.xz / float2(_Width, _Height));
				clip(fogPixel.a-.501);
				//End fog clip
			
				fixed4 c = texCol * _colorMul;

				o.Albedo = c.rgb;
				o.Alpha = 1.0f;
			} 

			fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten)
			{
				return fixed4(0,0,0,0);
			}

			ENDCG		
	}
	//FallBack "Diffuse"
}
