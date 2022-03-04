

Shader "Custom/MaskShader" {
Properties {
}

CGINCLUDE

    #pragma vertex vert
    #pragma fragment frag
    #pragma target 2.0
    #pragma multi_compile_instancing

    #include "UnityCG.cginc"

    struct appdata_t {
        float4 vertex : POSITION;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct v2f {
        float4 vertex : SV_POSITION;
        float3 worldPos : TEXCOORD0;
        float4 screenPosition : TEXCOORD1;
        float depth : TEXCOORD2;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    UNITY_INSTANCING_BUFFER_START (MyProperties)
    UNITY_INSTANCING_BUFFER_END(MyProperties)

    float _yClip;
    float _Direction;

    uniform sampler2D_float _CameraDepthTexture;

    v2f vert (appdata_t v)
    {
        v2f o;
        UNITY_SETUP_INSTANCE_ID(v);
        //UNITY_TRANSFER_INSTANCE_ID (v, o);
        o.worldPos = mul (unity_ObjectToWorld, v.vertex);
        
        o.vertex = UnityObjectToClipPos(v.vertex);// + float4(0,0,0.1001,0);
        o.screenPosition = ComputeScreenPos(o.vertex);
        o.depth = COMPUTE_DEPTH_01;

        
        return o;
    }

ENDCG

SubShader {  
    Tags { "RenderType"="Opaque" }

    ZTest LEqual Cull Off ZWrite On 


    Pass {
        CGPROGRAM
    
            fixed4 frag (v2f i) : COLOR
            {
                float2 textureCoordinate = i.screenPosition.xy / i.screenPosition.w;
                float rawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, textureCoordinate);
		        float dpth = Linear01Depth(rawDepth) + 0.0000001;
                float diff = dpth - i.depth;
                clip(diff);

                return fixed4(1,0,0,1);
            }

        ENDCG
    }

    Pass {
        CGPROGRAM
    
            fixed4 frag (v2f i) : COLOR
            {
                float2 textureCoordinate = i.screenPosition.xy / i.screenPosition.w;
                float rawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, textureCoordinate);
		        float dpth = Linear01Depth(rawDepth) + 0.0000001;
                float diff = dpth - i.depth;
                clip(diff);

                return fixed4(0,1,0,1);
            }

        ENDCG
    }

    Pass {
        CGPROGRAM
    
            fixed4 frag (v2f i) : COLOR
            {
                float2 textureCoordinate = i.screenPosition.xy / i.screenPosition.w;
                float rawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, textureCoordinate);
		        float dpth = Linear01Depth(rawDepth) + 0.0000001;
                float diff = dpth - i.depth;
                clip(diff);

                return fixed4(0,0,1,1);
            }

        ENDCG
    }
}
}