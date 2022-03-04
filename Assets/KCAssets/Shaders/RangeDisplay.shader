Shader "Custom/RangeDisplay" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_MinRadius ("Min Radius", float)  = 1
		_CurrRadius ("Curr Radius", float)  = 2
		_MaxRadius ("Max Radius", float)  = 3
		_Position ("Position", Vector) = (0,0,0,0)
		_RadiusMultiplier ("Radius Multiplier", float) = 0
		_EdgeWidth ("Edge Width", float) = 0.15
		_UnscaleTime ("Edge Width", float) = 0
		_Snow ("Edge Width", float) = 0
	}
	SubShader {
		Tags {"Queue" = "Transparent" "RenderType"="Transparent" "ForceNoShadowCasting"="True"}
		LOD 200
		ZWrite Off
		ZTest Always

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows alpha:fade

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		//When first(x) is less than second(y) equal 1, otherwise 0
        float when_lt(float x, float y) {
            return max(sign(y - x), 0.0);
        }
        
		//When first(x) is greater than second(y) equal 1, otherwise 0
        float when_gt(float x, float y) {
            return max(sign(x - y), 0.0);
        }

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
			float4 screenPos;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed4 _RimColor;

		float _MinRadius;
		float _MaxRadius;
		float3 _Position;
		float _RadiusMultiplier;
		float _EdgeWidth;
		float _CurrRadius;
		float _UnscaledTime;
		float _Snow;

		void surf (Input IN, inout SurfaceOutputStandard o) {

			// Albedo comes from a texture tinted by color
			fixed4 c = _Color;

			c = _RimColor;	

			fixed4 mask = tex2D (_MainTex, IN.screenPos.xy / IN.screenPos.w);
			//c = mask;
			
			//Clip out the profile of the building
			clip(lerp(-1,1, when_lt(mask.a, 0.01)));

			float scaledMin = _MinRadius * _RadiusMultiplier;
			float scaledMax = _MaxRadius * _RadiusMultiplier;
			float scaledCurrent = _CurrRadius * _RadiusMultiplier;
			
			float d = distance(IN.worldPos.xz, _Position.xz);
			
			//Make dashed lines for max line
			float showLine = sign(sin(3*_UnscaledTime +50 * atan2(IN.worldPos.z - _Position.z, IN.worldPos.x - _Position.x)));
			
			//More transparent above curr and below min
			c.a = lerp(c.a, 0, when_gt(d, scaledCurrent));
			c.a = lerp(c.a, 0, when_lt(d, scaledMin));
	
			//Radial checker
			int gradients = 6;
			float gradient = ((d - scaledMin) / (scaledCurrent - scaledMin));
			c.a *= (floor(gradient * gradients) / gradients) * 0.8;

			//Visibility in snow
			//c.rgb = lerp(c.rgb, float3(0.2, 0.2, 0.2), _Snow);

			//Max edge
			c = lerp(c, _RimColor, clamp(when_gt(d, scaledMax) + when_lt(d, scaledMax+_EdgeWidth) - 1, 0, 1) * showLine);
			
			//Min edge
			c = lerp(c, _RimColor, when_gt(d, _EdgeWidth) * clamp(when_gt(d, scaledMin) + when_lt(d, scaledMin+_EdgeWidth) - 1, 0, 1));
			
			//Curr edge
			c = lerp(c, _RimColor, clamp(when_gt(d, scaledCurrent) + when_lt(d, scaledCurrent+_EdgeWidth) - 1, 0, 1));

			o.Albedo = c.rgb;
			o.Alpha = c.a;
			o.Metallic = 0;
			o.Smoothness = 0;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
