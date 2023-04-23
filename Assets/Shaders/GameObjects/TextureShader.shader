Shader "Unlit/TextureShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _NormalTex ("Normal Texture", 2D) = "bump" {}

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
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float2 normalTex : TEXCOORD1;
                float4 pos2 : TEXCOORD2;
                float3 worldNormal : TEXCOORD3;
                
                float3 worldPosition : normal;
                SHADOW_COORDS(5)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NormalTex;
            float4 _NormalTex_ST;

            float4 _SpecularColor;

            float _Shininess;

            uniform float3 _LightColor0;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normalTex = TRANSFORM_TEX(v.uv, _NormalTex);

                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject));

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed shadow = SHADOW_ATTENUATION(i);

                // Texture
                fixed4 col = tex2D(_MainTex, i.uv);

                // Normal map
                float3  normalMap = 2.0 * tex2D(_NormalTex, i.normalTex).rgb - 1.0;

                // Phong-Blinn specular
                // ambient
                float3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb * col.rgb;

                // diffuse
                float3 l = normalize(_WorldSpaceLightPos0.xyz - i.worldPosition * _WorldSpaceLightPos0.w);
                float3 n = normalize(i.worldNormal + normalMap);
                float dotN1 = dot(l, n);
                //float maxDotN1 = max(dotN1, 0);
                float3 diffuseD = max(dot(l, n), 0);
                float3 diffuse = col.rgb * _LightColor0.rgb * diffuseD * shadow;

                // Specular
                float3 v = normalize(_WorldSpaceCameraPos - i.worldPosition);
                float3 h = normalize((l + v)/length(l + v));

                float specular = pow(max(dot(n, h), 0), _Shininess);
                float3 specularColor = _LightColor0.rgb * specular * _SpecularColor;

                float3 combinedLight = ambientColor + diffuse + specularColor;

                return fixed4(combinedLight, col.a);
            }
            ENDCG
        }

        Pass
        {
            Tags { "LigthMode"="ForwardAdd" } // other lights, one running once per light
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
        Pass
        {
            Tags { "LigthMode"="ShadowCaster" }

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
}
