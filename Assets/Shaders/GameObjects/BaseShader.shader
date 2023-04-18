Shader "Unlit/BaseShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (0.25, 0.25, 0.25, 1)

        _SpecularColor ("Spec Color", Color) = (1, 1, 1, 1)
        _Shininess ("Shininess", Float) = 20
    }
    SubShader
    {
        Tags { "LigthMode" = "ForwardBase" }
        //tags{"RenderType" = "Opaque" }
        LOD 200

        Pass
        {
            

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #pragma multi_compile_fwdbase
            //#pragma multi_compile_fwdadd
            #include "AutoLight.cginc"

            float3 reflect(float3 i, float3 n)
            {
                return i - 2.0 * n * dot(n,i);
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR;
                float4 pos2 : TEXCOORD1;
                float3 worldNormal : TEXCOORD0;
                
                float3 worldPosition : normal;
                SHADOW_COORDS(5)
            };

            float4 _Color;
            float4 _SpecularColor;

            float _Shininess;

            uniform float3 _LightColor0;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = _Color;

                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject));

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed shadow = SHADOW_ATTENUATION(i);

                // Phong-Blinn specular
                // ambient
                float3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;

                // diffuse
                float3 l = normalize(_WorldSpaceLightPos0.xyz - i.worldPosition * _WorldSpaceLightPos0.w);
                float3 n = normalize(i.worldNormal);
                float dotN1 = dot(l, n);
                //float maxDotN1 = max(dotN1, 0);
                float3 diffuseD = max(dot(l, n), 0);
                float3 diffuse = _Color * _LightColor0.rgb * diffuseD * shadow;

                // Specular
                float3 v = normalize(_WorldSpaceCameraPos - i.worldPosition);
                float3 h = normalize((l + v)/length(l + v));

                float specular = pow(max(dot(n, h), 0), _Shininess);
                float3 specularColor = _LightColor0.rgb * specular * _SpecularColor;

                float3 combinedLight = ambientColor + diffuse + specularColor;

                return fixed4(combinedLight, 1.0);


                /*
                // Phong calc
                // compute diffuse reflection
                float3 normalDirection = i.normal;
                // constants
                float attenuation = 1.0;
                // light direction
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

                // diffuse reflection
                float3 diffuseReflection = attenuation * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
                float3 diffuse = _DiffuseColor.rgb * diffuseReflection;

                // reflection / specular highlights
                float3 lightReflectDirection = reflect(-lightDirection, normalDirection);
                float3 viewDirection = normalize(float3(float4(_WorldSpaceCameraPos.xyz, 1.0) - i.posWorld.xyz));
                float3 lightSeeDirection = max(0.0, dot(lightReflectDirection, viewDirection));
                float3 shininessPower = pow(lightSeeDirection, _Shininess);

                float3 specularReflection = attenuation * _SpecularColor.rgb * shininessPower;
 
                float3 combinedLight = ambient + diffuse + specularReflection;

                return float4(combinedLight * _Color.rgb, 1.0);
                */
            }
            ENDCG
        }

        Pass
        {
            Tags { "LightMode"="ForwardAdd" } // other lights, one running once per light
            Blend One One // additive blending
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #pragma multi_compile_fwdadd
            #include "AutoLight.cginc"

            // frag returns ONLY diffuse + specular
            float3 reflect(float3 i, float3 n)
            {
                return i - 2.0 * n * dot(n,i);
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float4 pos : TEXCOORD0;
                float4 normalWorld : TEXCOORD1;
                SHADOW_COORDS(5)
            };

            float4 _Color;

            float4 _DiffuseColor;
            float4 _SpecularColor;

            float _Shininess;

            uniform float3 _LightColor0;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = _Color;

                o.pos = mul(unity_ObjectToWorld, v.vertex);
                o.normalWorld = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject));

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed shadow = SHADOW_ATTENUATION(i);

                // Phong-Blinn specular
                // diffuse
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz - i.pos * _WorldSpaceLightPos0.w);
                float3 normal = normalize(i.normalWorld);
                float diffuse = max(dot(lightDirection, normal), 0.0);
                float3 diffuseColor = _LightColor0.rgb * diffuse * shadow;

                float distance = length(_WorldSpaceLightPos0.xyz - i.pos.xyz);
                float attenuation = 1.0 / (1.0 + 0.1 * distance + 0.01 * distance * distance);

                // Specular
                float3 viewDirection = normalize(_WorldSpaceCameraPos - i.pos);
                float3 halfwayDirection = normalize(lightDirection + viewDirection);
                float specular = pow(max(dot(normal, halfwayDirection), 0.0), _Shininess);
                float3 specularColor = _LightColor0.rgb * specular * shadow;

                float3 combinedLight = diffuseColor * attenuation + specularColor * attenuation;

                return fixed4(combinedLight * _Color.rgb, 1.0);
            }

            ENDCG
        }
        //UsePass "legacy Shaders/vertexlit/SHADOWCASTER"
        Pass
        {
            Tags { "LightMode"="ShadowCaster" }

            CGPROGRAM
            #pragma target 3.0

            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
            };

            float4 vert(appdata v) : SV_POSITION
            {
                return UnityObjectToClipPos(v.vertex);
            }

            half4 frag() : SV_TARGET
            {
                return 0;
            }
            ENDCG
        }
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
    
        // Fallback "Diffuse"
}
