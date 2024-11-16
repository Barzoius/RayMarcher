#version 330 core

layout (location = 0) out vec4 FragColor;

uniform vec2 uResolution;
uniform vec2 uDirection;

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




vec2 sample(vec3 p)
{
   // p = mod(p, 4.0) - 4.0 * 0.5;

    float planeSDF = planeSDF(p, vec3(0,1,0), 1.0);
    float planeID = 2.0;
    vec2  plane = vec2(planeSDF, planeID);

    float sphereSDF = length(p) - 1.0;
    float sphereID = 1.0;
    vec2 sphere = vec2(sphereSDF, sphereID);

    vec2 result = UNION(sphere, plane);
    
    return result;
}

vec3 getNormal(vec3 p)
{
    vec2 e = vec2(EPSILON, 0.0);

    vec3 normal = vec3(sample(p).x) - vec3(sample(p - e.xyy).x, 
                       sample(p - e.yxy).x, 
                       sample(p - e.yyx).x);

    return normalize(normal);
}

vec3 lightComponent(vec3 p, vec3 rd, vec3 color)
{
    vec3 sourcePos = vec3(20.0, 40.0, -30.0);
    vec3 lightRay = normalize(sourcePos - p);
    vec3 surfaceNormal = getNormal(p);

    vec3 diffuse = color * clamp(dot(lightRay, surfaceNormal), 0.0, 1.0);
    return diffuse;
}

vec3 colorComponent(vec3 p, float id)
{
    vec3 color;
    switch(int(id))
    {
        case 1:
            color = vec3(0.91, 0.64, 0.09);
            break;
        case 2:
            color = vec3(0.3, 0.94, 0.59);
            break;
    }

    return color;

}

vec2 RayMarching(vec3 rayOrigin, vec3 rayDir)
{
    vec2 hit, obj;

    for(int i = 0; i < STEPS; i++)
    {
        vec3 p = rayOrigin + obj.x * rayDir;
        hit = sample(p);


        if(abs(hit.x) < EPSILON || obj.x > DISTANCE)
        {
            obj.y += hit.y;
            break;
        }
        
        obj.x += hit.x;
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
        vec3 p = rayOrigin + obj.x * rayDirection;
        vec3 c =  colorComponent(p, obj.y);
        color += lightComponent(p, rayDirection, c);
    }
}


void main()
{
    vec2 uv = (2.0f * gl_FragCoord.xy - uResolution.xy) / uResolution.y;

    vec3 color;

    render(color, uv);

    FragColor = vec4(color, 1.0f);
}