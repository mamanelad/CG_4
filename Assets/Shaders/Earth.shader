Shader "CG/Earth"
{
    Properties
    {
        [NoScaleOffset] _AlbedoMap ("Albedo Map", 2D) = "defaulttexture" {}
        _Ambient ("Ambient", Range(0, 1)) = 0.15
        [NoScaleOffset] _SpecularMap ("Specular Map", 2D) = "defaulttexture" {}
        _Shininess ("Shininess", Range(0.1, 100)) = 50
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "defaulttexture" {}
        _BumpScale ("Bump Scale", Range(1, 100)) = 30
        [NoScaleOffset] _CloudMap ("Cloud Map", 2D) = "black" {}
        _AtmosphereColor ("Atmosphere Color", Color) = (0.8, 0.85, 1, 1)
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

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
                uniform sampler2D _CloudMap;
                uniform fixed4 _AtmosphereColor;

                struct appdata
                { 
                    float4 vertex : POSITION;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float3 obj_pos : TEXCOORD0;
                    float3 normal : TEXCOORD1;
                };

                v2f vert (appdata input)
                {
                    v2f output;
                    output.obj_pos = input.vertex;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.normal = normalize(float3(input.vertex.xyz));
                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    float2 uv = getSphericalUV(input.obj_pos);
                    float3 tangent = normalize(cross(input.normal, float3(0,1,0)));
                    float3 n = normalize(input.normal);
                    
                    bumpMapData bumpData;
                    bumpData.normal = n;
                    bumpData.tangent = tangent;
                    bumpData.uv = uv;
                    bumpData.heightMap = _HeightMap;
                    bumpData.bumpScale = _BumpScale / 10000;
                    bumpData.du =  _HeightMap_TexelSize.x;
                    bumpData.dv = _HeightMap_TexelSize.y;

                    float3 bump_n = getBumpMappedNormal(bumpData);
                    float3 final_n = ((1 - tex2D(_SpecularMap, uv)) * bump_n) + (tex2D(_SpecularMap, uv) * bumpData.normal);
                    
                    float3 v = normalize(_WorldSpaceCameraPos - input.obj_pos);
                    float3 l = normalize(_WorldSpaceLightPos0);

                    float lambert = max(0 , dot(n,l));
                    float sqrt_lambert = sqrt(lambert);
                    
                    float4 atmosphere = (1 - max(0,dot(n,v))) * sqrt_lambert * _AtmosphereColor;
                    float4 clouds = tex2D(_CloudMap, uv) * (sqrt_lambert + _Ambient);
                    
                    fixed4 albedo = tex2D(_AlbedoMap, uv);
                    fixed4 specularity = tex2D(_SpecularMap, uv);

                    fixed3 blingPhong = blinnPhong(final_n,v,l,_Shininess,albedo,specularity,_Ambient);
                    
                    fixed4 col = fixed4(blingPhong + atmosphere + clouds,1);
                    return col;
                }

            ENDCG
        }
    }
}
