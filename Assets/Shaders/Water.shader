Shader "CG/Water"
{
    Properties
    {
        _CubeMap("Reflection Cube Map", Cube) = "" {}
        _NoiseScale("Texture Scale", Range(1, 100)) = 10 
        _TimeScale("Time Scale", Range(0.1, 5)) = 3 
        _BumpScale("Bump Scale", Range(0, 0.5)) = 0.05
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "CGUtils.cginc"
                #include "CGRandom.cginc"

                #define DELTA 0.01

                // Declare used properties
                uniform samplerCUBE _CubeMap;
                uniform float _NoiseScale;
                uniform float _TimeScale;
                uniform float _BumpScale;

                struct appdata
                { 
                    float4 vertex   : POSITION;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float2 uv       : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos      : SV_POSITION;
                    float2 uv       : TEXCOORD1;
                    float normal    : TEXCOORD2;
                    float3 worldPos : TEXCOORD3;
                };

                // Returns the value of a noise function simulating water, at coordinates uv and time t
                float waterNoise(float2 uv, float t)
                {
                    float noise = perlin2d(uv);
                    return noise; 
                }

                // Returns the world-space bump-mapped normal for the given bumpMapData and time t
                float3 getWaterBumpMappedNormal(bumpMapData i, float t)
                {
                    // Your implementation
                    return 0;
                }


                v2f vert (appdata input)
                {
                    input.vertex.xyz = input.vertex.xyz + _BumpScale *(input.normal*waterNoise(input.uv * _NoiseScale ,0));
                    
                    v2f output;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.uv = input.uv;
                    output.normal = mul(unity_ObjectToWorld,input.normal);
                    output.worldPos = mul(unity_ObjectToWorld,input.vertex);
                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    float3 n = input.normal;
                    float3 v = normalize(_WorldSpaceCameraPos - input.worldPos);
                    float3 r = 2 * dot(v,n) * n - v;
                    
                    float4 reflectedColor = texCUBE(_CubeMap,r);
                    float4 color = (1 - max(0, dot(n,v)) + 0.2) * reflectedColor;
                    
                    return color;
                }

            ENDCG
        }
    }
}
