Shader "Custom/ButtonHighlight2"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1) 
		_TextureWidth("TextureWidth", float) = .0
		_TextureHeight("TextureHeight", float) = .0
		_Thickness("Thickness", float) = 1
		_Speed("Speed", float) = 1000
		_Segments("Segments", int) = 20
		_HighlightColor ("HighlightColor", Color) = (1,1,0,1) 
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
			};

			sampler2D _MainTex; 
			float4 _MainTex_ST;
			float4 _Color;
			float4 _HighlightColor;
			float _TextureWidth;
			float _TextureHeight;
			float _Thickness; 
			float _Speed;
			int _Segments;

			//When first(x) is less than second(y) equal 1, otherwise 0
			float when_lt(float x, float y) {
				return max(sign(y - x), 0.0);
			}
        
			//When first(x) is greater than second(y) equal 1, otherwise 0
			float when_gt(float x, float y) {
				return max(sign(x - y), 0.0);
			}

			float atan2degs(float x, float y) {
				return atan2(y, x) * 180 / 3.1459;
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul (unity_ObjectToWorld, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) * _Color;

				float texelX = i.uv.x * _TextureWidth;
				float texelY = i.uv.y * _TextureHeight;

			    float validX = when_gt((texelX < _Thickness) + (texelX >= _TextureWidth - _Thickness), 0.5);
				float validY = when_gt((texelY < _Thickness) + (texelY >= _TextureHeight - _Thickness), 0.5);
				float validBorder = when_gt(validX + validY, 0.5);

				//float4 debugColor = fixed4(1,1,1,1);
				float totalDist = _TextureHeight*2 + _TextureWidth*2 - _Thickness * 4;
				float distanceAroundRect = 0;
				float segmentLength = totalDist / _Segments;				

				if(texelY < _Thickness){
					distanceAroundRect = texelX;
					//debugColor = fixed4(1, 0, 0, 1); //red
				}

				if(texelX > _TextureWidth - _Thickness && texelY > _Thickness){
					distanceAroundRect = (_TextureWidth - _Thickness) + texelY - _Thickness;
					//debugColor = fixed4(0, 0, 1, 1); //blue
				}

				if(texelY > _TextureHeight - _Thickness && texelX < _TextureWidth - _Thickness){
					distanceAroundRect = (_TextureWidth - _Thickness) + (_TextureHeight - _Thickness) + _TextureWidth - _Thickness - texelX;
					//debugColor = fixed4(0, 1, 0, 1); //green
				}

				if(texelX < _Thickness && texelY < _TextureHeight - _Thickness){
					distanceAroundRect = (_TextureWidth - _Thickness) + (_TextureHeight - _Thickness) + (_TextureWidth - _Thickness) + _TextureHeight - _Thickness - texelY;
					//debugColor = fixed4(0, 1, 1, 1); //teal
				}


				//debugColor = lerp(fixed4(1,0,0,1), fixed4(0,0,1,1), distanceAroundRect / totalDist);

				//debugColor = _HighlightColor;
				
				float validAngle = fmod(totalDist - distanceAroundRect + _Time * _Speed, segmentLength) > segmentLength/2;
			    //float validAngle = fmod(atan2degs(texelX - _TextureWidth /2, texelY - _TextureHeight / 2) + _Time * 2000, 30) > 15;
				
				float valid = when_gt(validBorder + validAngle, 1.5);
				fixed4 retcol = lerp(col, _HighlightColor, valid);

				//retcol = fixed4(i.uv.x, i.uv.y, 0, 1);

				retcol.a = _Color.a;

				return retcol;
			}
			ENDCG
		}
	}
}
