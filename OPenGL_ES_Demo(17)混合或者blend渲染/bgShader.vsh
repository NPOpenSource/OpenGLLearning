attribute vec4 position;
attribute vec2 textCoordinate;

uniform mat4 scale;
varying lowp vec2 varyTextCoord;

void main()
{
    varyTextCoord = textCoordinate;
    
    gl_Position =scale * position;
}


