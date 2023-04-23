Shader "Hidden/ChromaticAbberation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Distance("Distance", Float) = 0.01
        _RedOffset("RedOffset", Float) = 0.9
        _GreenOffset("GreenOffset", Float) = 0.06
        _BlueOffset("BlueOffset", Float) = -0.4

    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
			float _Distance;
            float _RedOffset;
            float _GreenOffset;
            float _BlueOffset;


            fixed4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);

                float redOffset = _RedOffset * _Distance * i.uv.x;
                float greenOffset = _GreenOffset * _Distance * i.uv.y;
                float blueOffset = _BlueOffset * _Distance * (i.uv.x + i.uv.y);

                float4 redColor = tex2D(_MainTex, i.uv + float2(redOffset, 0));
                float4 greenColor = tex2D(_MainTex, i.uv + float2(0, greenOffset));
                float4 blueColor = tex2D(_MainTex, i.uv + float2(blueOffset, blueOffset));

                float4 finalColor = (redColor * 0.35) + (greenColor * 0.45) + (blueColor * 0.2);

                return finalColor;
            }
            ENDCG
        }
    }
}
