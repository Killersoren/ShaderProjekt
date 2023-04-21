#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

// This is a neat trick to work around a bug in the shader graph when enabling shadow keywords. Created by @cyanilux
// https://github.com/Cyanilux/URP_ShaderGraphCustomLighting
#ifndef SHADERGRAPH_PREVIEW
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
    #if (SHADERPASS != SHADERPASS_FORWARD)
        #undef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
    #endif
#endif

struct CustomLightingData
{
    // position and orientation
    float3 positionWS;
    float3 normalWS;
    float3 viewDirectionWS;
    float4 shadowCoord;

    // surface attribute
    float3 albedo;
    float smoothness;
    float metallic;
    float3 emission;
};

// Translate a [0, 1] smoothness value to an exponent 
float GetSmoothnessPower(float rawSmoothness) 
{
    return exp2(10 * rawSmoothness + 1);
}

#ifndef SHADERGRAPH_PREVIEW
float3 CustomLightHandling(CustomLightingData d, Light light)
{
    float3 radiance = light.color * (light.distanceAttenuation * light.shadowAttenuation);

    float3 reflected = reflect(-light.direction, d.normalWS);

    float diffuse = saturate(dot(d.normalWS, light.direction));

    //float specularDot = saturate(dot(d.normalWS, normalize(light.direction + d.viewDirectionWS)));
    float specularDot = saturate(dot(reflected, d.viewDirectionWS));
    float specular = pow(specularDot, GetSmoothnessPower(d.smoothness)) * diffuse;

    float3 color = d.albedo * radiance * (diffuse + specular * (1.0 - d.metallic));
    color += d.emission * radiance * d.metallic * saturate(dot(reflected, d.viewDirectionWS));

    return color;
}
#endif

float3 CalculateCustomLighting(CustomLightingData d)
{
    #ifdef SHADERGRAPH_PREVIEW
        // In preview, estimate diffuse + specular
        float3 lightDir = float3(0.5, 0.5, 0);
        float intensity = saturate(dot(d.normalWS, lightDir)) + 
            pow(saturate(dot(d.normalWS, normalize(d.viewDirectionWS + lightDir))), GetSmoothnessPower(d.smoothness));

        return d.albedo * intensity;

    #else
        // Get main light. (Found in URP/ShaderLibrary/Lighting.hlsl)
        Light mainLight = GetMainLight(d.shadowCoord, d.positionWS, 1);

        float3 color = 0;

        // shade main light
        color += CustomLightHandling(d, mainLight);

        #ifdef _ADDITIONAL_LIGHTS
            // Shade additional cone and point lights. Functions in URP/ShaderLibrary/Lighting.hlsl
            uint numAdditionalLights = GetAdditionalLightsCount();

            for (uint lightIndx = 0; lightIndx < numAdditionalLights; lightIndx++)
            {
                Light light = GetAdditionalLight(lightIndx, d.positionWS, 1);
                color += CustomLightHandling(d, light);
            }
        #endif

        return color;
    #endif
}

// custom wrapper function
void CalculateCustomLighting_float(float3 Position, float3 Normal, float3 ViewDirection, float3 Albedo, float Smoothness, float Metallic, float3 Emission, out float3 Color)
{
    CustomLightingData d;
    d.positionWS = Position;
    d.normalWS = Normal;
    d.viewDirectionWS = ViewDirection;
    d.albedo = Albedo;
    d.smoothness = Smoothness;
    d.metallic = Metallic;
    d.emission = Emission;

    #ifdef SHADERGRAPH_PREVIEW
        // In preview there're no shadows or bakedGI
        d.shadowCoord = 0;
    #else
        // Calculate main light shadow coord
        // There're 2 types depending on if cascades are enabled
        float4 positionCS = TransformWorldToHClip(Position);
        #if SHADOWS_SCREEN
            d.shadowCoord = ComputeScreenPos(positionCS);
        #else
            d.shadowCoord = TransformWorldToShadowCoord(Position);
        #endif
    #endif

    Color = CalculateCustomLighting(d);
}

#endif