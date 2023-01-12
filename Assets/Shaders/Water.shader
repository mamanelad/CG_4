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
                    float3 normal    : TEXCOORD2;
                    float3 worldPos : TEXCOORD3;
                    float4 tangent : TEXCOORD4;
                };

                // Returns the value of a noise function simulating water, at coordinates uv and time t
                float waterNoise(float2 uv, float t)
                {
                    return perlin3d(float3(0.5*uv.x, 0.5*uv.y, 0.5*t)) +
                        0.5 * perlin3d(float3(uv.x, uv.y, t)) +
                        0.2 * perlin3d(float3(2*uv.x, 2*uv.y, 3*t));
                }

                // Returns the world-space bump-mapped normal for the given bumpMapData and time t
                float3 getWaterBumpMappedNormal(bumpMapData i, float t)
                {
                    float3 f_p = waterNoise(i.uv,t);
                    
                    float2 p_du = i.uv;
                    float2 p_dv = i.uv;
                    p_du.x += i.du;
                    p_dv.y += i.dv;
                    
                    float3 f_du = waterNoise(p_du,t);
                    float3 f_dv = waterNoise(p_dv,t);
                    
                    float der_u = (f_du - f_p) / i.du;
                    float der_v = (f_dv - f_p) / i.dv;

                    float3 nt = float3((-1 * der_u * i.bumpScale) , (-1 * der_v * i.bumpScale) , 1);
                    nt = normalize(nt);

                    float3 b = normalize(cross(i.tangent,i.normal));
                    
                    return (normalize((i.tangent* nt.x) + (i.normal * nt.z) + (b * nt.y)));
                }


                v2f vert (appdata input)
                {
                    v2f output;

                    float noise = waterNoise(input.uv*_NoiseScale,1);
                    noise = _BumpScale* noise;
                    
                    output.tangent = mul(unity_ObjectToWorld,input.tangent);
                    output.pos = UnityObjectToClipPos(input.vertex + (noise * input.normal));
                    output.uv = input.uv;
                    output.normal = mul(unity_ObjectToWorld,input.normal);
                    output.worldPos = mul(unity_ObjectToWorld,(input.vertex + noise * input.normal));
                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    bumpMapData bumpData;
                    bumpData.normal = normalize(input.normal);
                    bumpData.tangent = normalize(input.tangent);
                    bumpData.uv = input.uv * _NoiseScale;
                    bumpData.bumpScale = _BumpScale;
                    bumpData.du =  DELTA;
                    bumpData.dv = DELTA;
                    
                    float3 n = normalize(getWaterBumpMappedNormal(bumpData,_Time.y*_TimeScale));
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
