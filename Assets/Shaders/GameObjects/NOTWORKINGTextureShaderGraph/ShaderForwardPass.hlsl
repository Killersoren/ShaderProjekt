// Pull in URP library functions and our own functions
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

TEXTURE2D(_ColorMap); SAMPLER(sampler_ColorMap);

float4 _ColorMap_ST;
float4 _ColorTint;
float _Smoothness;

struct Attributes
{
    float3 positionOS : POSITION; // position in object space
    float3 normalOS : NORMAL;
    float2 uv : TEXCOORD0;
};

struct Interpolators
{
    float4 positionCS : SV_POSITION;

    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 normalWS : TEXCOORD2;
};

Interpolators Vert(Attributes input)
{
    Interpolators output;

    // helper functions - found in URP/ShaderLib/ShaderVariablesFunctions.hlsl
    // transform object space values into world and clip space
    VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS);
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);

    // Pass position and orientation data to the fragment function
    output.positionCS = positionInputs.positionCS;
    output.uv = TRANSFORM_TEX(input.uv, _ColorMap);
    output.normalWS = normalInputs.normalWS;
    output.positionWS = positionInputs.positionWS;

    return output;
}

// Runs once per fragment (pixel on the screen). Must output final color of this pixel.
float4 Frag(Interpolators input) : SV_TARGET
{
    float2 uv = input.uv;

    float4 colorSample = SAMPLE_TEXTURE2D(_ColorMap, sampler_ColorMap, uv);

    // for lighting. create InputData struct which contains position and orientation data
    InputData lightingInput = (InputData)0; // Found in URP/ShaderLib/Input.hlsl
    lightingInput.positionWS = input.positionWS;
    lightingInput.normalWS = normalize(input.normalWS);
    lightingInput.viewDirectionWS = GetWorldSpaceNormalizeViewDir(input.positionWS); // In ShaderVariablesFunctions.hlsl
    lightingInput.shadowCoord = TransformWorldToShadowCoord(input.positionWS); // In Shadows.hlsl
    
    // Calculate surface data struct which contains data from the material textures
    SurfaceData surfaceInput = (SurfaceData)0;
    surfaceInput.albedo = colorSample.rgb * _ColorTint.rgb;
    surfaceInput.alpha = colorSample.rgb * _ColorTint.a;
    surfaceInput.specular = 1;
    surfaceInput.smoothness = _Smoothness;

    
#if UNITY_VERSION >= 202120
	return UniversalFragmentBlinnPhong(lightingInput, surfaceInput);
#else
	return UniversalFragmentBlinnPhong(lightingInput, surfaceInput.albedo, float4(surfaceInput.specular, 1), surfaceInput.smoothness, surfaceInput.emission, surfaceInput.alpha);
#endif
}