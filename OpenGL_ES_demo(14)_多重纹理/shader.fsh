varying lowp vec2 varyTextCoord;


uniform sampler2D myTexture0;
uniform lowp float saturation;

const mediump mat3 RGBtoYIQ = mat3(0.299, 0.587, 0.114, 0.596, -0.274, -0.322, 0.212, -0.523, 0.311);

const mediump mat3 YIQtoRGB = mat3(1.0, 0.956, 0.621, 1.0, -0.272, -0.647, 1.0, -1.105, 1.702);

const mediump vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);

void main()
{
    lowp vec4 source = texture2D(myTexture0, varyTextCoord);
    ///点成饱和度
    lowp float luminance = dot(source.rgb, luminanceWeighting);
    
    lowp vec3 greyScaleColor = vec3(luminance);
    
    gl_FragColor = vec4(mix(greyScaleColor, source.rgb, saturation), source.w);
}
