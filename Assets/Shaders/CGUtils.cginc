#ifndef CG_UTILS_INCLUDED
#define CG_UTILS_INCLUDED

#define PI 3.141592653

// A struct containing all the data needed for bump-mapping
struct bumpMapData
{ 
    float3 normal;       // Mesh surface normal at the point
    float3 tangent;      // Mesh surface tangent at the point
    float2 uv;           // UV coordinates of the point
    sampler2D heightMap; // Heightmap texture to use for bump mapping
    float du;            // Increment size for u partial derivative approximation
    float dv;            // Increment size for v partial derivative approximation
    float bumpScale;     // Bump scaling factor
};


// Receives pos in 3D cartesian coordinates (x, y, z)
// Returns UV coordinates corresponding to pos using spherical texture mapping
float2 getSphericalUV(float3 pos)
{
    // sphericalCords
    float r = sqrt( (pow(pos.x,2)) + (pow(pos.y,2)) + (pow(pos.z,2)) );
    float t = atan2(pos.z,pos.x);
    float f = acos(pos.y/r);

    // project 
    float u = 0.5 + (t / (2*PI));
    float v = 1 - (f/PI);
    float2 projectedCords = float2(u,v);
    
    return projectedCords;
}

// Implements an adjusted version of the Blinn-Phong lighting model
fixed3 blinnPhong(float3 n, float3 v, float3 l, float shininess, fixed4 albedo, fixed4 specularity, float ambientIntensity)
{
    float3 h = normalize(l+v);
    
    fixed4 Ambient = ambientIntensity * albedo;
    fixed4 Diffuse = max(0, dot(n,l)) * albedo;
    fixed4 Specular = pow(max(0, dot(n,h)),shininess) * specularity;
    return Ambient + Diffuse + Specular;
}

// Returns the world-space bump-mapped normal for the given bumpMapData
float3 getBumpMappedNormal(bumpMapData i)
{
    float3 f_p = tex2D(i.heightMap,i.uv);
    
    float2 p_du = i.uv;
    float2 p_dv = i.uv;
    p_du.x += i.du;
    p_dv.y += i.dv;
    
    float3 f_du = tex2D(i.heightMap,p_du);
    float3 f_dv = tex2D(i.heightMap,p_dv);
    
    float der_u = (f_du - f_p) / i.du;
    float der_v = (f_dv - f_p) / i.dv;

    float3 nt = float3((-1 * der_u * i.bumpScale) , (-1 * der_v * i.bumpScale) , 1);
    nt = normalize(nt);

    float3 b = normalize(cross(i.tangent,i.normal));
    
    return (normalize((i.tangent* nt.x) + (i.normal * nt.z) + (b * nt.y)));
}


#endif // CG_UTILS_INCLUDED
