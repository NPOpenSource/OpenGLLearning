attribute vec3 postion;
attribute vec2 textCoordinate;

varying lowp vec2 varyTextCoord;



void main()
{
    varyTextCoord = textCoordinate;

    gl_Position =vec4(postion,1.0);
}

