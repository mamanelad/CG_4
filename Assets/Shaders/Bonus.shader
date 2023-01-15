Shader "CG/Bonus"
{
    Properties
    {
        _Color ("Color", Color) = (1,0.4860411,0.1179245,1)
        [NoScaleOffset] _AlbedoMap ("Albedo Map", 2D) = "defaulttexture" {}
        [NoScaleOffset] _NoiseMap ("Noise Map", 2D) = "defaulttexture" {}
        _Cutoff ("Cut off", Range(0, 1)) = 0.25
        _EdgeWidth ("Edge Width", Range(0, 1)) = 0.05
        _EdgeColor ("Edge Color", Color) = (0.4656461,0.7059904,0.9056604,1)
        _Speed ("Speed", Range(0, 2)) = 1
        
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members worldPos)
#pragma exclude_renderers d3d11

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "CGUtils.cginc"

                // Declare used properties
                uniform sampler2D _AlbedoMap;
                uniform sampler2D _NoiseMap;
                float _Speed;
                half _Cutoff;
                half _EdgeWidth;
                fixed4 _Color;
                fixed4 _EdgeColor;


                struct appdata
                { 
                    float4 vertex   : POSITION;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float2 uv       : TEXCOORD0;
                };
            
                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv : TEXCOORD2;
                };

                v2f vert (appdata input)
                {
                    v2f output;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.uv = input.uv;
                    return output;
                }
            
                fixed4 frag (v2f input) : SV_Target
                {
                    fixed4 albedo = tex2D(_AlbedoMap, input.uv) * _Color;
                    fixed4 noisePixel = tex2D (_NoiseMap, input.uv);
                    float cutoff = sin(float(_Time.y * _Speed));
                    if (noisePixel.r <= cutoff)
                    {
                        clip(-1);
                    }

                    if (noisePixel.r >= (cutoff * (_EdgeWidth + 1.0)))
                    {
                        return albedo;
                    }
                    return _EdgeColor;
                }

            ENDCG
        }
    }
}
