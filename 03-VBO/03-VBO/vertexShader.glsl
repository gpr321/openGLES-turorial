attribute vec4 aPosition;
attribute vec4 aColor;

varying highp vec4 vColor;

void main()
{
    vColor = aColor;
    gl_Position = aPosition;
}