// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/FogOfWarShader" {
	Properties
	{
		_TintColor("Tint Color", Color) = (1, 1, 1, 1)
		
		_Darken("Darken", Range(0.0, 1.0)) = 0.0
		_MainTex("MainTex", 2D) = "white" {}
	}

		//-------------------------------------------------------------------------------------------------------------------------------------------------------------
		CGINCLUDE

		// Pragmas --------------------------------------------------------------------------------------------------------------------------------------------------
//#pragma target 5.0
//#pragma only_renderers d3d11 vulkan
//#pragma exclude_renderers gles
#pragma multi_compile_instancing
		// Includes -------------------------------------------------------------------------------------------------------------------------------------------------
#include "UnityCG.cginc"

		// Structs --------------------------------------------------------------------------------------------------------------------------------------------------
		struct VertexInput
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		fixed4 color : COLOR;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	struct VertexOutput
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
		fixed4 color : COLOR;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};

	UNITY_INSTANCING_BUFFER_START(Props)
	
	UNITY_INSTANCING_BUFFER_END(Props)

	// Globals --------------------------------------------------------------------------------------------------------------------------------------------------
	sampler2D _MainTex;
	float4 _MainTex_ST;
	float4 _TintColor;
	float _SeeThru;
	float _Darken;

	// MainVs ---------------------------------------------------------------------------------------------------------------------------------------------------
	VertexOutput MainVS(VertexInput i)
	{
		VertexOutput o;

		UNITY_SETUP_INSTANCE_ID(i);

		int idx = ((int)i.vertex.z * 100 + (int)i.vertex.x);

#if UNITY_VERSION >= 540
		o.vertex = UnityObjectToClipPos(i.vertex);
#else
		o.vertex = UnityObjectToClipPos(i.vertex);
#endif
		o.uv = TRANSFORM_TEX(i.uv, _MainTex);
		o.color = i.color;

		return o;
	}

	// MainPs ---------------------------------------------------------------------------------------------------------------------------------------------------
	float4 MainPS(VertexOutput i) : SV_Target
	{
		UNITY_SETUP_INSTANCE_ID(i);

		float4 vTexel = tex2D(_MainTex, i.uv).rgba;

		float4 vColor = float4(0, 0, 0, 0.5f);

		return vColor.rgba; 
	}

		ENDCG

	SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
			LOD 100

		Pass{
			ColorMask 0
						CGPROGRAM
			#pragma vertex MainVS
			#pragma fragment MainPS
						ENDCG
		}
			// Render normally
			Pass{
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha
				ColorMask RGB
				
				
			CGPROGRAM
			#pragma vertex MainVS
			#pragma fragment MainPS
			ENDCG
		}
	}
}
