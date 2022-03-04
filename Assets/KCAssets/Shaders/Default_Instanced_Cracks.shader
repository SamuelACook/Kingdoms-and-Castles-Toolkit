// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "Fog/SurfFogDarkSnowInstancedWithCracks" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_SnowColor("SnowColor", Color) = (0.933, 0.933, 0.909,1)
		_Snow("Snow", Range(0,1)) = 0
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_BreakStrength("Break Point", Range(0, .5)) = 0
		_Dim("Dim",Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		// And generate the shadow pass with instancing support
		#pragma surface surf Standard fullforwardshadows addshadow

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldNormal;
			float3 worldPos;
		};

		sampler2D _Fog;

		fixed _Width;
		fixed _Height;

		half _Glossiness;
		half _Metallic;

			fixed4 _Color;

		fixed4 _SnowColor;
		float _Snow;

		half _BreakStrength;
		half _Dim;

		float3 xUnitVec3 = float3(1.0, 0.0, 0.0);
		float3 yUnitVec3 = float3(0.0, 1.0, 0.0);

		float PI = 3.1415926535897932384626433832795;

		float4 setAxisAngle(float3 axis, float rad) {
			rad = rad * 0.5;
			float s = sin(rad);
			return float4(s * axis[0], s * axis[1], s * axis[2], cos(rad));
		}

		float when_gt(float x, float y) {
			return max(sign(x - y), 0.0);
		}

		float rand(float3 co)
		{
			return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 45.5432))) * 43758.5453);
		}

		float hash(float n) {
			return frac(sin(n)*43758.5453);
		}

		float noise(float3 x) {

			float3 p = floor(x);
			float3 f = frac(x);

			f = f * f*(3.0 - 2.0*f);
			float n = p.x + p.y*57.0 + 113.0*p.z;

			return lerp(lerp(lerp(hash(n + 0.0), hash(n + 1.0), f.x),
				lerp(hash(n + 57.0), hash(n + 58.0), f.x), f.y),
				lerp(lerp(hash(n + 113.0), hash(n + 114.0), f.x),
					lerp(hash(n + 170.0), hash(n + 171.0), f.x), f.y), f.z);
		}

		float4 voronoi(in float3 x)
		{
			int3 p = int3(floor(x));
			float3 f = frac(x);

			int3 mb = int3(0, 0, 0);
			float3 mr = float3(0.0, 0.0, 0.0);
			float3 mg = float3(0.0, 0.0, 0.0);

			float md = 8.0;
			for (int j = -1; j <= 1; ++j)
				for (int i = -1; i <= 1; ++i)
				{
					for (int h = -1; h <= 1; ++h)
					{
						int3 b = int3(i, j, h);
						float3  r = float3(b)+noise(float3(p + b)) - f;
						float3 g = float3(float(i), float(j), float(h));
						float n = noise(float3(p)+g);
						float3 o = float3(n, n, n);
						float d = length(r);

						if (d < md)
						{
							md = d;
							mr = r;
							mg = g;
						}
					}
				}

			md = 8.0;
			for (int j = -2; j <= 2; ++j)
				for (int i = -2; i <= 2; ++i)
					for (int h = -2; h <= 2; ++h)
					{
						int3 b = float3(i, j, h);
						float3 r = float3(b)+noise(float3(p + b)) - f;


						if (length(r - mr) > 0.00001)
							md = min(md, dot(0.5*(mr + r), normalize(r - mr)));
					}

			return float4(md, mr);
		}

		float when_lt(float x, float y) {
			return max(sign(y - x), 0.0);
		}

		float4 multQuat(float4 q1, float4 q2) {
			return float4(
				q1.w * q2.x + q1.x * q2.w + q1.z * q2.y - q1.y * q2.z,
				q1.w * q2.y + q1.y * q2.w + q1.x * q2.z - q1.z * q2.x,
				q1.w * q2.z + q1.z * q2.w + q1.y * q2.x - q1.x * q2.y,
				q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z
				);
		}

		float3 rotateVector(float4 quat, float3 vec) {
			// https://twistedpairdevelopment.wordpress.com/2013/02/11/rotating-a-vector-by-a-quaternion-in-glsl/
			float4 qv = multQuat(quat, float4(vec, 0.0));
			return multQuat(qv, float4(-quat.x, -quat.y, -quat.z, quat.w)).xyz;
		}

		float4 rotationTo(float3 a, float3 b) {
			float vecDot = dot(a, b);
			float3 tmpvec3 = float3(0, 0, 0);
			if (vecDot < -0.999999) {
				tmpvec3 = cross(xUnitVec3, a);
				if (length(tmpvec3) < 0.000001) {
					tmpvec3 = cross(yUnitVec3, a);
				}
				tmpvec3 = normalize(tmpvec3);
				return setAxisAngle(tmpvec3, PI);
			}
			else if (vecDot > 0.999999) {
				return float4(0, 0, 0, 1);
			}
			else {
				tmpvec3 = cross(a, b);
				float4 _out = float4(tmpvec3[0], tmpvec3[1], tmpvec3[2], 1.0 + vecDot);
				return normalize(_out);
			}
		}

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 texCol = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed4 fogPixel = tex2D (_Fog, IN.worldPos.xz / float2(_Width, _Height));

			
			fixed4 lerpedSnow = lerp(texCol,
								_SnowColor,
								_Snow);

			float useSnow = when_gt(dot(IN.worldNormal, fixed3(0, 1, 0)), 0.5f);
			useSnow *= when_gt(IN.worldPos.y,0.02f);

			fixed3 c = lerp(texCol, lerpedSnow, useSnow * 0.875f);

			fixed3 fadedgray = lerp(c, dot(c.rgb, float3(0.2, 0.39, 0.05)), 0.75);
			c = lerp(c.rgb, fadedgray, 1-fogPixel.a);

			float3 worldWithOffset = IN.worldPos;
			float4 quaternion = rotationTo(float3(0.5773, 0.5773, 0.5773), float3(0, 1, 0)); // normal = forward, in this case.
			float3 fc = rotateVector(quaternion, worldWithOffset);

			float vor = voronoi(fc / 0.45).x;
			float radius = _BreakStrength;

			float isCrack = smoothstep(0.0,
					0.04 * radius,
					vor);

			o.Albedo = lerp(c.rgb,
				float3(0, 0, 0),
				when_lt(isCrack, 0.95)) * (1 - _Dim);

			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 1.0f;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
