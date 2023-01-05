#ifndef CG_RANDOM_INCLUDED
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles
// Upgrade NOTE: excluded shader from DX11 because it uses wrong array syntax (type[size] name)
#pragma exclude_renderers d3d11
#define CG_RANDOM_INCLUDED

// Returns a psuedo-random float between -1 and 1 for a given float c
float random(float c)
{
    return -1.0 + 2.0 * frac(43758.5453123 * sin(c));
}

// Returns a psuedo-random float2 with componenets between -1 and 1 for a given float2 c 
float2 random2(float2 c)
{
    c = float2(dot(c, float2(127.1, 311.7)), dot(c, float2(269.5, 183.3)));

    float2 v = -1.0 + 2.0 * frac(43758.5453123 * sin(c));
    return v;
}

// Returns a psuedo-random float3 with componenets between -1 and 1 for a given float3 c 
float3 random3(float3 c)
{
    float j = 4096.0 * sin(dot(c, float3(17.0, 59.4, 15.0)));
    float3 r;
    r.z = frac(512.0*j);
    j *= .125;
    r.x = frac(512.0*j);
    j *= .125;
    r.y = frac(512.0*j);
    r = -1.0 + 2.0 * r;
    return r.yzx;
}

// Interpolates a given array v of 4 float values using bicubic interpolation
// at the given ratio t (a float2 with components between 0 and 1)
//
// [0]=====o==[1]
//         |
//         t
//         |
// [2]=====o==[3]
//
float bicubicInterpolation(float v[4], float2 t)
{
    float2 u = t * t * (3.0 - 2.0 * t); // Cubic interpolation

    // Interpolate in the x direction
    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);

    // Interpolate in the y direction and return
    return lerp(x1, x2, u.y);
}

// Interpolates a given array v of 4 float values using biquintic interpolation
// at the given ratio t (a float2 with components between 0 and 1)
float biquinticInterpolation(float v[4], float2 t)
{
    float2 u = t * t * t * ((6.0 * t * t) - (15 * t) + 10); // Cubic interpolation
    
    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);

    return lerp(x1, x2, u.y);
}

// Interpolates a given array v of 8 float values using triquintic interpolation
// at the given ratio t (a float3 with components between 0 and 1)
float triquinticInterpolation(float v[8], float3 t)
{
    // Your implementation
    return 0;
}

// Returns the value of a 2D value noise function at the given coordinates c
float value2d(float2 c)
{
    float2 cell = floor(c);

    float2 c00_value = random2(float2(cell.x, cell.y));
    float2 c01_value = random2(float2(cell.x + 1, cell.y));
    float2 c10_value = random2(float2(cell.x, cell.y + 1));
    float2 c11_value = random2(float2(cell.x + 1, cell.y + 1));

    float InterpolationArray[4] = {c00_value.x,c01_value.x,c10_value.x,c11_value.x};
    return bicubicInterpolation(InterpolationArray, frac(c));
}

// Returns the value of a 2D Perlin noise function at the given coordinates c
float perlin2d(float2 c)
{
    float2 cell = floor(c);

    float2 c00 = float2(cell.x, cell.y);
    float2 c01 = float2(cell.x + 1, cell.y);
    float2 c10 = float2(cell.x, cell.y + 1);
    float2 c11 = float2(cell.x + 1, cell.y + 1);

    float2 c00_to_c_vec = c - c00;
    float2 c01_to_c_vec = c - c01;
    float2 c10_to_c_vec = c - c10;
    float2 c11_to_c_vec = c - c11;

    float c00_dot = dot(random2(c00),c00_to_c_vec);
    float c01_dot = dot(random2(c01),c01_to_c_vec);
    float c10_dot = dot(random2(c10),c10_to_c_vec);
    float c11_dot = dot(random2(c11),c11_to_c_vec);

    float InterpolationArray[4] = {c00_dot,c01_dot,c10_dot,c11_dot};
    
    return biquinticInterpolation(InterpolationArray, frac(c));
    // TODO: check why not maching the photo on instructions
}

// Returns the value of a 3D Perlin noise function at the given coordinates c
float perlin3d(float3 c)
{                    
    // Your implementation
    return 0;
}


#endif // CG_RANDOM_INCLUDED
