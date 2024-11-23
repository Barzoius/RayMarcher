#version 330 core


layout (location = 0) out vec4 FragColor;

uniform vec2 uResolution;
uniform vec2 uDirection;

const float FOV = 1.0f;
const int STEPS = 256;
const float DISTANCE = 500;
const float EPSILON = 0.001;

#define PI 3.14159265

vec2 UNION(vec2 CSG_1, vec2 CSG_2)
{
    return (CSG_1.x < CSG_2.x) ? CSG_1 : CSG_2;
}

vec2 INTERSECTION(vec2 CSG_1, vec2 CSG_2)
{
    return (CSG_1.x > CSG_2.x) ? CSG_1 : CSG_2;
}

vec2 DIFFERENCE(vec2 CSG_1, vec2 CSG_2)
{
    return (CSG_1.x > -CSG_2.x) ? CSG_1 : vec2(-CSG_2.x, CSG_2.y);
}


float vmax(vec3 v) {
    return max(max(v.x, v.y), v.z);
}

float planeSDF(vec3 p, vec3 n, float distance)
{
    return dot(p,n) + distance;
}

float cylinderSDF(vec3 p, float r, float height) {
    float d = length(p.xz) - r;
    d = max(d, abs(p.y) - height);
    return d;
}

float rectangleSDF(vec3 p, vec3 b) {
    vec3 d = abs(p) - b;
    return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
}

void rotate(inout vec2 p, float a) {
    p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}


vec2 sample(vec3 p)
{

    float sphereSDF = length(p) - 1.2;
    float sphereID = 1.0;
    vec2 sphere = vec2(sphereSDF, sphereID);

    float planeSDF = planeSDF(p, vec3(0,1,0), 14.0);
    float planeID = 2.0;
    vec2  plane = vec2(planeSDF, planeID);


    float cylinderSDF = cylinderSDF(p, 0.7, 2.0);
    float cylinderID = 3.0;
    vec2 cylinder = vec2(cylinderSDF, cylinderID);

    float cubeSDF = rectangleSDF(p, vec3(1,1,1));
    float cubeID = 3.0;
    vec2 cube = vec2(cubeSDF, cubeID);


    //vec2 result = UNION(UNION(DIFFERENCE(cube,sphere), cylinder), plane);
    vec2 result = UNION(DIFFERENCE(UNION(cube, cylinder),sphere), plane);
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


vec2 RayMarching(vec3 rayOrigin, vec3 rayDir)
{
    vec2 hit, obj;

    for(int i = 0; i < STEPS; i++)
    {
        vec3 p = rayOrigin + obj.x * rayDir;
        hit = sample(p);
                
        obj.x += hit.x;

        if(abs(hit.x) < EPSILON || obj.x > DISTANCE)
        {
            obj.y += hit.y;
            break;
        }
    }

    return obj;
}

mat3 cameraComponent(vec3 rayOrigin, vec3 lookAt)
{
    vec3 forward = normalize(vec3(lookAt - rayOrigin));
    vec3 right = normalize(cross(vec3(0, 1, 0), forward));
    vec3 up = cross(forward, right);

    return mat3(right, up, forward);
}

vec3 lightComponent(vec3 p, vec3 rd, vec3 color)
{
    vec3 sourcePos = vec3(20.0, 40.0, -30.0);
    vec3 lightRay = normalize(sourcePos - p);
    vec3 surfaceNormal = getNormal(p);
    vec3 reflectedRay = reflect(-lightRay, surfaceNormal);
    vec3 rayDir = -rd;


    vec3 specularColor = vec3(0.43);
    vec3 specular = specularColor * pow(clamp(dot(reflectedRay, rayDir), 0.0, 1.0), 10.0);
    vec3 diffuse = color * clamp(dot(lightRay, surfaceNormal), 0.0, 1.0);
    vec3 ambient = color * 0.05;

    float shadowCastDistance = RayMarching(p + surfaceNormal * 0.02, normalize(sourcePos)).x;

    if(shadowCastDistance < length(sourcePos - p)) 
    {
        return ambient;
    }

    return diffuse + ambient + specular;
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
        case 3:
            color = vec3(0.91, 0.64, 0.09);
            break;
    }

    return color;

}

void mouseRotation(inout vec3 rayOrigin)
{
    vec2 m = uDirection / uResolution;
    rotate(rayOrigin.yz, m.y * PI * 0.5 - 0.5);
    rotate(rayOrigin.xz, m.x * (2 * PI));
}

void render(inout vec3 color, in vec2 uv)
{
    vec3 rayOrigin = vec3(3.0f, 3.0f, -3.0f);
    mouseRotation(rayOrigin);
    vec3 lookAt = vec3(0, 0, 0);
    vec3 rayDirection = cameraComponent(rayOrigin, lookAt) * normalize(vec3(uv, FOV));

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

    color = pow(color, vec3(0.4545));

    FragColor = vec4(color, 1.0f);
}