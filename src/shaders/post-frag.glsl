#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;

in vec2 fs_Pos;
out vec4 out_Col;

const int MAX_RAY_STEPS = 100;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float EPSILON = 0.0001;

// returns the vector belonging to the lowest x value
vec3 getMinVec(vec3 a, vec3 b){
    if (a.x < b.x){
        return a;
    }

    return b;
}
// Sphere
float sphereSDF(vec3 point, float r){
  return length(point) - r;
}


// Ellipsoid
float ellipsoidSDF(in vec3 p, in vec3 r)
{
  float k0 = length(p/r);
  float k1 = length(p/(r*r));
  return k0 * (k0 - 1.0) / k1;
}


vec3 sceneSDF(vec3 point) {

  float testShape = sphereSDF(point, 2.0);

  /*
    //vec3 offsetAstro = vec3(0.0, 8.0, 0.0) + u_AstroOffset;
    vec3 offsetAstro = vec3(0.0, 16.0, 0.0) + u_AstroOffset;
    vec3 ufoOffset = vec3(0.0, -1.50, 0.0);
    float scaleAstro = 0.25;

    float animControl = u_Animate; // either 0 or 1, on/off
    float rotateControl = u_Time * 0.2 * animControl; // to control rotation
    // to controll movement
    float x0 = sawtoothWave(sin(u_Time*.05), 2.0, 3.0) * animControl;
    float x01 = squareWave(sin(u_Time*.05), 2.0, 3.0) * animControl;
    float x = 1.0 - (sin(u_Time* 0.05) + 1.0) * animControl; //reg speed
    float x2 = 1.0 - (sin(u_Time* 0.025) + 1.0) * animControl; // slower
    float x3 = 1.0 - (sin(u_Time* 0.045) + 0.25) * animControl;
    float ufoSpin = u_UFORotate * rotateControl * 0.15;
    
   // point to be modified for UFO
    vec3 p = point + ufoOffset;
    p.x = p.x + x2 * u_Animate;
    p.xz = rotateFunc(p.xz, ufoSpin); // rotate on y axis
    // make UFO
    // make sphere for top
    float ufoTop = sphereSDF(p + ufoOffset + vec3(0.0, -0.8, 0.0), 1.75);
    float ufoDisk = ellipsoidSDF(p + ufoOffset, vec3(4.0, 1.0, 4.0));
    float ufoFinal = unionOp(ufoTop, ufoDisk);

    //UFO lights
    float ufoLights = sphereSDF(p - vec3(1.55, 1.25, 0.0)  + ufoOffset, 0.375);// left light
    ufoLights = min(ufoLights, sphereSDF(p - vec3(-1.55, 1.25, 0.0)  + ufoOffset, 0.375)); //right light
    ufoLights = min(ufoLights, sphereSDF(p - vec3(0.0, 1.25, -1.55)  + ufoOffset, 0.375)); //front light
    ufoLights = min(ufoLights, sphereSDF(p - vec3(0.0, 1.25, 1.55)  + ufoOffset, 0.375)); //back light


    // make astronaut
    vec3 p1 = point;
    p1.y = p1.y + x3;
    p1.xz = rotateFunc(p1.xz, rotateControl * 0.15);
        
    float astroHead = sphereSDF(p1 - vec3(0.0, 16.55, 0.0) + offsetAstro, 3.0 * scaleAstro) ; // Head
    float astroMask = sphereSDF(p1 - vec3(0.0, 16.55, -0.1) + offsetAstro, 2.75 * scaleAstro) ; // Head
    float astro = ellipsoidSDF(p1 - vec3(0.0, 15.0, 0.0) + offsetAstro, vec3(2.0, 4.0, 2.0) * scaleAstro); // Body
    astro = unionOp(astro, sphereSDF(p1 - vec3(0.0, 16.55, 0.0) + offsetAstro, 3.0 * scaleAstro) ); // Head
    astro = unionOp(astro, sphereSDF(p1 - vec3(0.8, 15.25, 0.0) + offsetAstro, 1.0 * scaleAstro)); // left arm middle
    astro = unionOp(astro, sphereSDF(p1 - vec3(0.60, 15.5, 0.0) + offsetAstro, 1.0 * scaleAstro)); // left arm top
    astro = unionOp(astro, sphereSDF(p1 - vec3(-0.8, 15.25, 0.0) + offsetAstro, 1.0 * scaleAstro)); // right arm middle
    astro = unionOp(astro, sphereSDF(p1 - vec3(-0.60, 15.5, 0.0) + offsetAstro, 1.0 * scaleAstro)); // right arm top
    astro = unionOp(astro, sphereSDF(p1 - vec3(1.15, 14.85, 0.0) + offsetAstro, 1.5 * scaleAstro)); // left hand
    astro = unionOp(astro, sphereSDF(p1 - vec3(-1.15,14.85, 0.0) + offsetAstro, 1.5 * scaleAstro)); // right hand
    astro = unionOp(astro, sphereSDF(p1 - vec3(0.50, 13.65, 0.0) + offsetAstro, 1.0 * scaleAstro)); // left leg bottom
    astro = unionOp(astro, sphereSDF(p1 - vec3(0.30, 14.0, 0.0) + offsetAstro, 1.0 * scaleAstro)); // left leg top
    astro = unionOp(astro, sphereSDF(p1 - vec3(-0.5, 13.65, 0.0) + offsetAstro, 1.0 * scaleAstro)); // right leg bottom
    astro = unionOp(astro, sphereSDF(p1 - vec3(-0.30, 14.0, 0.0) + offsetAstro, 1.0 * scaleAstro)); // right leg top
    float astroFeet =  ellipsoidSDF(p1 - vec3(0.65, 13.25, -0.175) + offsetAstro, vec3(1.5, 1.0, 2.0) * scaleAstro); // left foot
    astroFeet = min(astroFeet, ellipsoidSDF(p1 - vec3(-0.65, 13.25, -0.175) + offsetAstro, vec3(1.5, 1.0, 2.0) * scaleAstro)); // right foot
    
    // make asteroids
    vec3 p2 = point;
    p2.xy = rotateFunc(p2.xy, rotateControl * 0.15);
    float a = ellipsoidSDF(p2 - vec3(8.0, -3.0, 0.0), vec3(2.4,2.0,1.8));
    float sub = sphereSDF(p2- vec3(6.5, -3.0, 0.0), 1.25);// shape to subtract from asteroid
    float sub2 = sphereSDF(p2 - vec3(7.2, -2.3, -.75), 1.25);// shape to subtract from asteroid
    float sub3 = sphereSDF(p2 - vec3(7.2, -1.8, .25), 1.5);// shape to subtract from asteroid
    a = subtractionOp(sub, a);
    a = subtractionOp(sub2, a);
    a = subtractionOp(sub3, a);
    point.y = point.y + x0;
    point.x = point.x + x01;
    float i = ellipsoidSDF(point - vec3(-8.0, 5.0, 1.0), vec3(2.0,0.75,1.8));
    float b = sphereSDF(point - vec3(-8.0, 5.0, 0.0), 1.0);
    b = intersectionOp(i, b);
    float asteroids = min(a,b);

// all seperate parts that have different colors
// ufoFinal, astro, asteroids, astroHead, astroFeet
    vec3 returnVec = vec3(asteroids, 2.0, 0.0);
    returnVec = getMinVec(returnVec, vec3(ufoFinal, 4.0, 0.0));
    returnVec = getMinVec(returnVec, vec3(astro, 1.0, 0.0));
    returnVec = getMinVec(returnVec, vec3(astroHead, 1.0, 0.0));
    returnVec = getMinVec(returnVec, vec3(astroFeet, 0.0, 0.0));
    returnVec = getMinVec(returnVec, vec3(astroMask, 0.0, 0.0));
    returnVec = getMinVec(returnVec, vec3(ufoLights, 5.0, 0.0));
*/
    vec3 returnVec = vec3(testShape, 2.0, 0.0);

    return returnVec;
}

vec3 calcNormal(vec3 pos) {
    vec3 eps = vec3(0.001, 0.0, 0.0);
    float epsFloat = 0.0001;
    vec3 normal =  normalize(vec3(
        sceneSDF(vec3(pos.x + epsFloat, pos.y, pos.z)).x - sceneSDF(vec3(pos.x - epsFloat, pos.y, pos.z)).x,
        sceneSDF(vec3(pos.x, pos.y + epsFloat, pos.z)).x - sceneSDF(vec3(pos.x, pos.y - epsFloat, pos.z)).x,
        sceneSDF(vec3(pos.x, pos.y, pos.z + epsFloat)).x - sceneSDF(vec3(pos.x, pos.y, pos.z - epsFloat)).x
    ));

    return normal;
}

vec3 getColors(float c, float lightTerm, float spec, vec3 point){
    
     
    vec3 theColor = vec3(0.0);
    // Black for helmet lense
    if (c == 0.0){
        theColor = vec3(0.1608, 0.1529, 0.1529) * lightTerm + spec ;
        return theColor;
    }
    // spacesuit color
    if (c == 1.0){
        theColor = vec3(1.0,1.0,0.9) * lightTerm;  
        return theColor;
    }
    // 
    if (c == 2.0){
        theColor = vec3(0.54, 0.27, 0.075) * lightTerm;

        return theColor;
    }
  
    
    return vec3(c / 10.0) * lightTerm;
}

// return vec3
// .x is float, .y is colorID
vec3 rayMarch(vec3 pos, vec3 marchingDirection, float start, float end) {
 
    float depth = start;
    float dist = 0.0;
    float col= 0.0;

  vec3 temp = vec3(0.0);

    for (int i = 0; i < MAX_RAY_STEPS; i++) {
      temp = sceneSDF(pos + depth * marchingDirection);
        dist = temp.x;
        col = temp.y;    

        if (dist < EPSILON) {
            return vec3(depth, col, 0.0);
        }
        depth += dist;
        if (depth >= end) {
            return vec3(end, col, 0.0);
        }
    }
    return vec3(end, col, 0.0);
}

void main() {

// raymarching vars
vec3 rightVec = normalize(cross((u_Ref - u_Eye), u_Up));
float aspectRatio = (u_Dimensions.x / u_Dimensions.y);
float FOV = 45.0;
float len = length(u_Ref - u_Eye);
vec3 V = tan(FOV/2.0) * u_Up * len;
vec3 H = tan(FOV/2.0) * rightVec * aspectRatio * len;

vec3 p = u_Ref + (H*fs_Pos.x) + (fs_Pos.y * V);
vec3 dir = normalize(p - u_Eye);

vec3 marchInfo = vec3(0.0);

// to draw shapes------------------------------------------------
// .x is the float distance from raymarching, .y is the color ID
marchInfo = rayMarch(u_Eye, dir, MIN_DIST, MAX_DIST);
  // float dist = rayMarch(u_Eye, dir, MIN_DIST, MAX_DIST);
  float dist = marchInfo.x;
  float colorTerm = marchInfo.y;
    
    if (dist > MAX_DIST - EPSILON) {
        // Didn't hit anything, draw background
        //out_Col = vec4(0.5 * (dir + vec3(1.0, 1.0, 1.0)),1);
        
       out_Col =  vec4(0.5 * (dir + vec3(1.0, 1.0, 1.0)),1.0);
            //out_Col = vec4(color,1.0);
        
        
		return;
    }

 
// Lighting
vec3 n = calcNormal(u_Eye + marchInfo.x * dir);
vec3 lightVector = vec3(0.0 , 1.0, 0.0);//normalize(u_Eye - p);
// h is the average of the view and light vectors
vec3 h = (u_Eye + lightVector) / 2.0;
// specular intensity
float specularInt = max(pow(dot(normalize(h), normalize(n)), 23.0) , 0.0);  
// dot between normals and light direction
float diffuseTerm = dot(normalize(n), normalize(lightVector));  
// Avoid negative lighting values
diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);    
float ambientTerm = 0.2;
float lightIntensity = diffuseTerm + ambientTerm;

out_Col = vec4( getColors(colorTerm, lightIntensity, specularInt,u_Eye + marchInfo.x * dir) , 1.0);;//vec4(0.5 * (dir + vec3(1.0, 1.0, 1.0)),1.0);

//out_Col = vec4(0.5* (n + vec3(1.0)), 1.0); // normals for debugging
  //out_Col = vec4(0.5 * (fs_Pos + vec2(1.0)), 0.5 * (sin(u_Time * 3.14159 * 0.01) + 1.0), 1.0);
}
