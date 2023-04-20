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

			//Modify the fragment function to apply a Chromatic Abberation effect.
			//See the reference image in the exercise folder.
            //sample using different values for r g and b
			//Use the "_Distance" variable to control the size of the effect.
			//Bonus points for enhancing the effect, for pixels further from the center of the screen.

            fixed4 frag (v2f i) : SV_Target
            {
                // float4 col = tex2D(_MainTex,i.uv);         
				// return col;

                    // Get the texture color at the current pixel
                float4 col = tex2D(_MainTex, i.uv);

                // Calculate the offset amounts for the red, green, and blue channels
                float redOffset = _RedOffset * _Distance * i.uv.x;
                float greenOffset = _GreenOffset * _Distance * i.uv.y;
                float blueOffset = _BlueOffset * _Distance * (i.uv.x + i.uv.y);

                // Apply the offset amounts to each channel of the texture color
                float4 redColor = tex2D(_MainTex, i.uv + float2(redOffset, 0));
                float4 greenColor = tex2D(_MainTex, i.uv + float2(0, greenOffset));
                float4 blueColor = tex2D(_MainTex, i.uv + float2(blueOffset, blueOffset));

                // Combine the offset colors with the original color using a weighted average
                float4 finalColor = (redColor * 0.35) + (greenColor * 0.45) + (blueColor * 0.2);

                return finalColor;
            }
            ENDCG
        }
    }
}
