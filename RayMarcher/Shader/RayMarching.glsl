#version 330 core

layout (location = 0) out vec4 FragColor;

uniform vec2 uResolution;

const float FOV = 1.0f;
const int STEPS = 256;
const float DISTANCE = 500;
const float EPSILON = 0.001f;

vec2 UNION(vec2 CSG_1, vec2 CSG_2)
{
    return (CSG_1.x < CSG_2.x) ? CSG_1 : CSG_2;
}

float planeSDF(vec3 p, vec3 n, float distance)
{
    return dot(p,n) + distance;
}

float sdCutSphere( vec3 p, float r, float h )
{
  // sampling independent computations (only depend on shape)
  float w = sqrt(r*r-h*h);

  // sampling dependant computations
  vec2 q = vec2( length(p.xz), p.y );
  float s = max( (h-r)*q.x*q.x+w*w*(h+r-2.0*q.y), h*q.x-w*q.y );
  return (s<0.0) ? length(q)-r :
         (q.x<w) ? h - q.y     :
                   length(q-vec2(w,h));
}

vec2 map(vec3 p)
{
   // p = mod(p, 4.0) - 4.0 * 0.5;

    float planeSDF = planeSDF(p, vec3(0,1,0), 1.0);
    float planeID = 2.0f;
    vec2  plane = vec2(planeSDF, planeID);

    float cutSphereSDF = sdCutSphere(p, 1.0f, 3.0f);
    float cutSphereID = 3.0f;
    vec2 cutSphere = vec2(cutSphereSDF, cutSphereID);

    float sphereSDF = length(p) - 1.0f;
    float sphereID = 1.0f;
    vec2 sphere = vec2(sphereSDF, sphereID);

    vec2 result = UNION(UNION(sphere, cutSphere), plane);
    
    return result;
}

vec2 RayMarching(vec3 rayOrigin, vec3 rayDir)
{
    vec2 hit, obj;

    for(int i = 0; i < STEPS; i++)
    {
        vec3 p = rayOrigin + obj.x * rayDir;
        hit = map(p);

        obj.x += hit.x;
        obj.y += hit.y;

        if(abs(hit.x) < EPSILON || obj.x > DISTANCE)
        {
            break;
        }
    }

    return obj;
}

void render(inout vec3 color, in vec2 uv)
{
    vec3 rayOrigin = vec3(0.0f, 0.0f, -3.0f);
    vec3 rayDirection = normalize(vec3(uv, FOV));

    vec2 obj = RayMarching(rayOrigin, rayDirection);

    if(obj.x  < DISTANCE)
    {
        color += 3.0f / obj.x;
    }
}


void main()
{
    vec2 uv = (2.0f * gl_FragCoord.xy - uResolution.xy) / uResolution.y;

    vec3 color;

    render(color, uv);

    FragColor = vec4(color, 1.0f);
}