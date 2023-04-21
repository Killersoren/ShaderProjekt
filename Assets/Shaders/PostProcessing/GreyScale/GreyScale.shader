#include "UnityCG.cginc"

Shader "Custom/Greyscale" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader {
        Tags {"Queue"="Transparent" "RenderType"="Opaque"}
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // input texture and texture coordinates
            uniform sampler2D _MainTex;
            float4 _MainTex_ST;

            // vertex shader input
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;  
            };

            // vertex shader output
            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // vertex shader
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // fragment shader
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                float greyscale = dot(color.rgb, float3(0.299, 0.587, 0.114));
                return float4(greyscale, greyscale, greyscale, color.a);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
