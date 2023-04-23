Shader "Unlit/BloodTest"
{
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Tint ("Tint", Color) = (1,0,0,1)
        _Speed ("Speed", Range(0, 10)) = 1
    }
    SubShader {
        Tags {"Queue"="Transparent" "RenderType"="Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
     
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
     
            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
     
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Tint;
            float _Speed;
    
     
            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
     
            fixed4 frag (v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv + _Time.y * _Speed);
                col.rgb *= _Tint.rgb;
                col.a *= _Tint.a;
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
