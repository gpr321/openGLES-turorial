attribute vec4 aPosition;
attribute vec4 aColor;
uniform mat4 uModelMat;
uniform mat4 uProjection;

varying vec4 vColor;

void main()
{
    vColor = aColor;
    gl_Position = uProjection * uModelMat * aPosition;
}