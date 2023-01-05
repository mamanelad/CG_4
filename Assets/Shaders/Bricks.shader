Shader "CG/Bricks"
{
    Properties
    {
        [NoScaleOffset] _AlbedoMap ("Albedo Map", 2D) = "defaulttexture" {}
        _Ambient ("Ambient", Range(0, 1)) = 0.15
        [NoScaleOffset] _SpecularMap ("Specular Map", 2D) = "defaulttexture" {}
        _Shininess ("Shininess", Range(0.1, 100)) = 50
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "defaulttexture" {}
        _BumpScale ("Bump Scale", Range(-100, 100)) = 40
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
                uniform float _Ambient;
                uniform sampler2D _SpecularMap;
                uniform float _Shininess;
                uniform sampler2D _HeightMap;
                uniform float4 _HeightMap_TexelSize;
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
                    float4 pos : SV_POSITION;
                    float3 normal : TEXCOORD1;
                    float2 uv : TEXCOORD2;
                    float3 worldPos : TEXCOORD3;
                    float4 tangent : TEXCOORD4;
                };

                v2f vert (appdata input)
                {
                    v2f output;
                    output.worldPos = mul(unity_ObjectToWorld,input.vertex);
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.uv = input.uv;
                    output.normal = input.normal;
                    output.tangent = input.tangent;
                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    bumpMapData bumpData;
                    bumpData.normal = input.normal;
                    bumpData.tangent = input.tangent;
                    bumpData.uv = input.uv;
                    bumpData.heightMap = _HeightMap;
                    bumpData.bumpScale = _BumpScale / 10000;
                    bumpData.du =  _HeightMap_TexelSize.x;
                    bumpData.dv = _HeightMap_TexelSize.y;
                    
                    float3 v = normalize(_WorldSpaceCameraPos - input.worldPos);
                    float3 l = normalize(_WorldSpaceLightPos0);
                    float3 n = getBumpMappedNormal(bumpData);
                    
                    fixed4 albedo = tex2D(_AlbedoMap, input.uv);
                    fixed4 specularity = tex2D(_SpecularMap, input.uv);
                    
                    fixed3 blingPhong = blinnPhong(n,v,l,_Shininess,albedo,specularity,_Ambient);
                    
                    fixed4 col = fixed4(blingPhong,1);
                    return col;
                }

            ENDCG
        }
    }
}
