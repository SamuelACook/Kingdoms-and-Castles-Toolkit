Shader "Custom/Terrain" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SnowTex ("SnowTexture (RGB)", 2D) = "white" {}
		_OverlayTex ("Overlay (RGB)", 2D) = "white" {}
		_OverlayAlpha ("Overlay Alpha", Range(0,1)) = 0
		_SnowAlpha ("Snow Alpha", Range(0,1)) = 0
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Cursor("Cursor", Vector) = (0,0,0,0)
		_CursorColor("Cursor Color (RGB)", Color) = (1,1,1,1)
		_TerrainDimensions("Terrain Dimensions", Vector) = (0,0,0,0)
		_TerritoryTexOld("Old Territory Texture", 2D) = "black" {}
		_TerritoryTexNew("New Territory Texture", 2D) = "black" {}
		_FOWTex("Fog Of War Texture ", 2D) = "black" {}
		_TerritoryBlend("Territory Blend", Range(0,1)) = 0.0
		_TerritoryPulse("Territory Pulse", Range(0,1)) = 0.0
		_TerritoryFade("Territory Fade", Range(0,1)) = 0.0
		_UnscaledTime("Unscaled Time", float) = 0.0
	    _TerritoryYCutoff("Territory Y Cutoff", float) = 0.0
		_CheckerSize("Checker Size", float) = 8.0
		_CheckerOpacityHigh("Checker Opacity High", float) = 0.9
		_CheckerOpacityLow("Checker Opacity Low", float) = 0.65
		_GridLinesThickness("GridLinesThickness", float) = 0.01
		_GridFade("Grid Fade", float) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _SnowTex;
		sampler2D _OverlayTex;
		sampler2D _TerritoryTexOld;
		sampler2D _TerritoryTexNew;
		sampler2D _FOWTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		half _SnowAlpha;
		half _OverlayAlpha;
		half _TerritoryBlend;
		half _TerritoryPulse;
		half _TerritoryFade;
		float _UnscaledTime;
		float4 _Cursor;
		fixed4 _CursorColor;
		float _TerritoryYCutoff;
		float _CheckerSize;
		float _CheckerOpacityHigh;
		float _CheckerOpacityLow;
		float _GridLinesThickness;
		float _GridFade;

		//x: x, y: z, z: width, w: height
		fixed4 _TerrainDimensions;

		//When first(x) is less than second(y) equal 1, otherwise 0
		float when_lt(float x, float y) {
			return max(sign(y - x), 0.0);
		}

		float when_gt(float x, float y) {
			return max(sign(x - y), 0.0);
		}

		float easeInQuad(float t, float b, float c, float d) {
			t /= d;
			return c*t*t + b;
		}

		float2 terrainUV(float3 worldPos) {
			return float2(worldPos.x / (_TerrainDimensions.z - _TerrainDimensions.x), worldPos.z / (_TerrainDimensions.w - _TerrainDimensions.y));
		}

		float4 TerritoryNow(float3 worldPos) {
			return lerp(tex2D(_TerritoryTexOld, terrainUV(worldPos)), tex2D(_TerritoryTexNew, terrainUV(worldPos)), _TerritoryBlend);
		}

		float inOverlay(float3 worldPos) {
			float4 color = tex2D(_OverlayTex, terrainUV(worldPos));
			return when_gt(color.a, 0.01);
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color

			float4 c = tex2D (_MainTex, IN.uv_MainTex);
			float3 unchanged = c.rgb;
			
			float alphaOverride = 1;
			float alphaMoveTimeScale = 0.5;

			//Checker
			float squareSize = _CheckerSize;
			alphaOverride = lerp(_CheckerOpacityLow, _CheckerOpacityHigh, when_gt(int(floor(IN.worldPos.x * squareSize + _UnscaledTime * alphaMoveTimeScale) + floor(IN.worldPos.z * squareSize + _UnscaledTime * alphaMoveTimeScale))%2, 0.5f));

			//Lines
			float lineThickness = 0.3;
			//alphaOverride = lerp(0, 1, when_gt(fmod(IN.worldPos.x + IN.worldPos.z + _UnscaledTime* alphaMoveTimeScale, 1), lineThickness));

			float4 overlayColor = tex2D(_OverlayTex, terrainUV(IN.worldPos));

			float overlayDensity = inOverlay(IN.worldPos + float3(0.05, 0, 0.05)) +
								  inOverlay(IN.worldPos + float3(-0.05, 0, 0.05)) +
								  inOverlay(IN.worldPos + float3(-0.05, 0, -0.05)) +
								  inOverlay(IN.worldPos + float3(0.05, 0, -0.05));

			float useOverlayBorder = when_gt(when_gt(overlayDensity, 0.01) + when_lt(overlayDensity, 3.99), 1.01) * ceil(overlayColor.a);

			float distFromCursor = distance(_Cursor.xy, IN.worldPos.xz);

			float4 territoryNow = TerritoryNow(IN.worldPos);
			float territoryActive = territoryNow.r;
			float territoryGrey = territoryNow.g;

			 
			float scaledSnowAlpha = _SnowAlpha;
			float4 snow = c * (1 - scaledSnowAlpha) + (tex2D (_SnowTex, IN.uv_MainTex) * scaledSnowAlpha);


			c = lerp(snow, c.rgba, clamp((territoryActive) * _TerritoryFade + (inOverlay(IN.worldPos)), 0, 1));
			float4 overlayBorder = ( when_gt(fmod(IN.worldPos.x + IN.worldPos.z + _UnscaledTime, 1), 0.5));
			c = lerp(c,overlayColor,_OverlayAlpha * overlayColor[3] * alphaOverride);
			
			float4 borderColor = lerp(overlayColor, lerp(float4(1, 1, 1, 1), float4(0.5, 0.5, 0.5, 1), 0), overlayBorder);
			float4 fadedBorder = lerp(borderColor, c, 0.5);
			c = lerp(c, fadedBorder, useOverlayBorder * _OverlayAlpha);

			float border = TerritoryNow(IN.worldPos + float3(0.1, 0, 0.1)).r +
						   TerritoryNow(IN.worldPos + float3(-0.1, 0, 0.1)).r +
						   TerritoryNow(IN.worldPos + float3(-0.1, 0, -0.1)).r +
						   TerritoryNow(IN.worldPos + float3(0.1, 0, -0.1)).r;

			float useBorder = when_gt(when_gt(border, 0.01) + when_lt(border, 3.99), 1.01);

			float gray = dot(c.rgb, float3(0.2, 0.39, 0.05));
			float3 bw = float3(gray, gray, gray);

			float3 dimmed = lerp(c, bw, territoryGrey);


			float3 combined = lerp(dimmed, lerp(float3(1,1,1), float3(0.5, 0.5, 1.0), scaledSnowAlpha), useBorder);
			combined = lerp(combined,combined + float4(_TerritoryPulse,_TerritoryPulse,_TerritoryPulse,0),territoryActive);

			float3 territoryAndOverlay = lerp(c.rgb, combined, _TerritoryFade);

			float3 color = lerp(unchanged, territoryAndOverlay , when_gt(IN.worldPos.y, _TerritoryYCutoff));

			float isGrid = clamp(when_lt(abs(round(IN.worldPos.x) - IN.worldPos.x), _GridLinesThickness) +
							when_lt(abs(round(IN.worldPos.z) - IN.worldPos.z), _GridLinesThickness), 0, 1);

			color = lerp(color, lerp(color, lerp(color * 0.65f, color, 0.5), _GridFade), isGrid); 

			o.Albedo = color;
			o.Metallic = 0;
			o.Smoothness = 0;
			o.Alpha = 1;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
