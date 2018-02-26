varying lowp vec2 varyTextCoord;

uniform sampler2D myTexture0;
uniform lowp float temperature;

void main()
{
    lowp vec4 source = texture2D(myTexture0, varyTextCoord);

    gl_FragColor = vec4(0.0,temperature,0.0,1.0);

}
