varying lowp vec2 varyTextCoord;

uniform lowp float redColor;
uniform sampler2D myTexture0;

void main()
{
    lowp vec4 source = texture2D(myTexture0, varyTextCoord);
    gl_FragColor = vec4(redColor,0.0,0.0,1.0);

}
