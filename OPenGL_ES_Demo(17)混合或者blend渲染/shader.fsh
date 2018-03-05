
varying lowp vec2 varyTextCoord;
varying lowp vec2 varyOtherPostion;

uniform sampler2D myTexture1;

void main()
{
lowp vec4 text = texture2D(myTexture1, varyTextCoord);
text.a = 0.8;
gl_FragColor = text;
}
