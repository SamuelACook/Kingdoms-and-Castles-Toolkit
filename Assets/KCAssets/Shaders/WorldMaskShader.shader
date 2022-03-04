// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/WorldMask" {
Properties {
	_Source ("Source", 2D) = "black" {}
	_Mask ("Mask", 2D) = "black" {}
	_Fade ("Fade", float) = 0
	_Selector ("Selector", int) = 0
	_UnscaledTime ("Unscaled time", float) = 0
}

CGINCLUDE

	#include "UnityCG.cginc"

	uniform sampler2D _Source;
	uniform sampler2D _Mask;

	float _Fade;
	int _Selector = 0;
	float _UnscaledTime;

	float when_gt(float x, float y) {
		return max(sign(x - y), 0.0);
	}

	//When first(x) is less than second(y) equal 1, otherwise 0
	float when_lt(float x, float y) {
		return max(sign(y - x), 0.0);
	}

	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	v2f vert (appdata_img v)
	{
		v2f o;
		half index = v.vertex.z;
		v.vertex.z = 0.1;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		
		return o;
	}

	half4 frag(v2f i) : SV_Target  
	{
		float4 source = tex2D(_Source, i.uv);
		
		float gray = 0.45f;
		float4 dehighlightVector = lerp(float4(gray, gray, gray, 1.0), source, 0.4f);

		
		float4 highlightVector = lerp(source, source * 2.5f + float4(0.1f, 0.1f, 0.1f, 0.0), (sin(_UnscaledTime*6)+1) /8);

		half4 sceneColor = half4(0,0,0,1);

		source = source * 1.1f;

		sceneColor = sceneColor + lerp(float4(0,0,0,0), dehighlightVector, when_gt(tex2D(_Mask, i.uv).r, 0.5));
		sceneColor = sceneColor + lerp(float4(0,0,0,0), source, when_gt(tex2D(_Mask, i.uv).g, 0.5));
		sceneColor = sceneColor + lerp(float4(0,0,0,0), highlightVector, when_gt(tex2D(_Mask, i.uv).b, 0.5));
		sceneColor = sceneColor + lerp(float4(0,0,0,0), dehighlightVector, when_lt(tex2D(_Mask, i.uv).r + tex2D(_Mask, i.uv).g + tex2D(_Mask, i.uv).b, 0.01)); //Default

		return lerp(source, sceneColor, _Fade);
    }

	

ENDCG

SubShader
{
	Tags { "Queue" = "Transparent" } 
	Blend SrcAlpha OneMinusSrcAlpha
	
	ZTest Always Cull Off ZWrite Off

	Pass
	{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
	}
}

Fallback off

}
