Shader "Unlit/NewTextureShader"
{
    Properties
    {
        _ColorMap("Color", 2D) = "white" {}
        _ColorTint("Tint", Color) = (1, 1, 1, 1)
        _Smootness("Smootness", Float) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Name "ForwardP" // debugging
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM

            #define _SPECULAR_COLOR

#if UNITY_VERSION >= 202120
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
#else
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
#endif

            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #pragma vertex Vert
            #pragma fragment Frag

            // include our hlsl file
            #include "ShaderForwardPass.hlsl"

            ENDHLSL
        }

        Pass 
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }


            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag

            #include "ShaderForwardPass.hlsl"

            ENDHLSL
        }
    }
}
