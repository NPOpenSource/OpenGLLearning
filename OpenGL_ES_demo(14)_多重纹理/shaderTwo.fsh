varying lowp vec2 varyTextCoord;

uniform lowp float greenColor;
uniform sampler2D myTexture0;

void main()
{
    lowp vec4 source = texture2D(myTexture0, varyTextCoord);
    gl_FragColor = vec4(source.x,greenColor,source.z,1.0);

}
