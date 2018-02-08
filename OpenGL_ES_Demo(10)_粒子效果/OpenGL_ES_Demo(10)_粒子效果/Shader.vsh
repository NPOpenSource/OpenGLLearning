attribute vec3 beginPostion;///起始位置
attribute vec3 beginVelocity;///起始速度
attribute vec3 force;///力
attribute vec2 a_size;  //大小 和 Fade持续时间  size = GLKVector2Make(aSize, aDuration);
attribute float beginTime; ///开始时间
attribute float endTime; ///介绍时间



uniform highp float     currentTime; //当前时间
uniform highp mat4      u_mvpMatrix; //变换矩阵
uniform sampler2D       u_samplers2D[1]; //纹理
uniform highp vec3 u_gravity; //变换矩阵

varying lowp float      v_particleOpacity; //粒子 不透明度

void main(){
    
    highp float elapsedTime = currentTime - beginTime;///持续时间

    //力与加速度的关系 f=ma; 这里假设质量都是是1 。a  = f;

    ///加速度  时间  和速度的关系 v= v0+at; 这里加速度是恒定的值。
    ///所以距离是 s = s0+(v+v0)/2*t= s0+(vo+at+v0)/2*t = s0+(2v0+at)/2*t
    ///= s0+vot+at^2/2

    highp vec3 currentPostion = beginPostion+beginVelocity * elapsedTime +(force + u_gravity)*elapsedTime*elapsedTime*0.5;
    ///经过mvp变化
    gl_Position = u_mvpMatrix * vec4(currentPostion, 1.0);

    gl_PointSize = a_size.x / gl_Position.w;

    // 消失时间减去当前时间，得到当前的寿命； 除以Fade持续时间，当剩余时间小于Fade时间后，得到一个从1到0变化的值
    // 如果这个值小于0，则取0
    v_particleOpacity = max(0.0, min(1.0,
                                     (endTime - currentTime) /
                                     max(a_size.y, 0.00001)));
    
    
}
