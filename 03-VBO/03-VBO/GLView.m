//
//  GLView.m
//  03-VBO
//
//  Created by peironggao on 16/3/19.
//  Copyright © 2016年 gaopeirong. All rights reserved.
//

#import "GLView.h"
#import <GLESTool/GLESTool.h>

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

@interface GLView ()
{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    
    GLuint _positionSlot;
    GLuint _colorSlot;
}
@end

@implementation GLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupVBOs {
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}

- (void)render {
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 1
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // 2
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    
    // 3
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer {
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

// Replace initWithFrame with this
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
    }
    return self;
}

- (void)layoutSubviews
{
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self setupVBOs];
    [self render];
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}

- (void)compileShaders {
    
    // 1
    GLuint vertexShader = [self compileShader:@"SimpleVertex"
                                     withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment"
                                       withType:GL_FRAGMENT_SHADER];
    
    // 2
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // 3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(programHandle);
    
    // 5
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
}

@end

/*
static GLfloat vertex[] =
{
//    -0.5f, 0.5f, 0.5f,  // 0
//    -0.5f, -0.5f, 0.5f, // 1
//    0.5f, -0.5f, 0.5f,  // 2
//    0.5f, 0.5f, 0.5f,   // 3
//    
//    -0.5f, 0.5f, -0.5f,  // 4
//    -0.5f, -0.5f, -0.5f, // 5
//    0.5f, -0.5f, -0.5f,  // 6
//    0.5f, 0.5f, -0.5f   // 7
    
    0.0f,   1.0f, 0.0f,
    -1.0f, -1.0f, 0.0f,
    1.0f,  -1.0f, 0.0f
};

static GLushort indexes[] =
{
    0, 1, 2
//    0, 1, 2,   2, 3, 0,
//    4, 5, 6,   3, 7, 4,
//    1, 0, 4,   4, 5, 1,
//    6, 7, 3,   3, 2, 6,
//    0, 3, 4,   3, 7, 4,
//    2, 1, 5,   2, 5, 3
};

@interface GLView ()
{
    EAGLContext     *_ctx;
    CAEAGLLayer     *_eaglLayer;
    
    GLuint          _program;
    
    GLuint          _aColor;
    GLuint          _aPosition;
    
    GLuint          _fbo;
    GLuint          _renderBuffer;
    
    GLuint          _vbo;
    GLuint          _indexBuffer;
    
    GLint          _frameBufferWidth;
    GLint          _frameBufferHeight;
}

@end

@implementation GLView

- (void)dealloc
{
    [self destroyFBO];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] )
    {
        [self setUp];
    }
    return self;
}

+ (Class)layerClass
{
    // 只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。
    return [CAEAGLLayer class];
}

- (void)setUp
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    // context
    _ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_ctx];
    assert(_ctx);
    
    NSString *vShaderString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vertexShader.glsl" ofType:nil] encoding:NSUTF8StringEncoding error:NULL];
    NSString *fShaderString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fragmentShader.glsl" ofType:nil] encoding:NSUTF8StringEncoding error:NULL];
    
    _program = gl_tool_build_program([vShaderString cStringUsingEncoding:NSUTF8StringEncoding], [fShaderString cStringUsingEncoding:NSUTF8StringEncoding]);
    glUseProgram(_program);
    
    _aColor = glGetAttribLocation(_program, "aColor");
    _aPosition = glGetAttribLocation(_program, "aPosition");
    
    [self setUpBuffer];
}

- (void)render
{
    [EAGLContext setCurrentContext:_ctx];
    
    
    glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
    
    glViewport(0, 0, _frameBufferWidth, _frameBufferHeight);
    
    glClearColor(0.0, 1.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);

    glVertexAttribPointer(_aPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, 0);
    glEnableVertexAttribArray(_aPosition);
    
    glVertexAttrib4f(_aColor, 1.0f, 0.f, 0.f, 1.f);
    glEnableVertexAttribArray(_aColor);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_SHORT, 0);
    
    [_ctx presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)destroyBuffer
{
    [EAGLContext setCurrentContext:_ctx];
    
    if ( _vbo )
    {
        glDeleteBuffers(1, &_vbo);
        _vbo = 0;
    }
    
    if ( _indexBuffer )
    {
        glDeleteBuffers(1, &_indexBuffer);
        _indexBuffer = 0;
    }
}

- (void)setUpBuffer
{
    glGenBuffers(1, &_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * (sizeof(vertex) / sizeof(vertex[0])), vertex, GL_STATIC_DRAW);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertex), vertex, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexes) , indexes, GL_STATIC_DRAW);
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_ctx];
    [self destroyFBO];
    [self setUpFBO];
    [self render];
}

- (void)setUpFBO
{
    glGenFramebuffers(1, &_fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_ctx renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_frameBufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_frameBufferHeight);
}

- (void)destroyFBO
{
    if ( _fbo )
    {
        glDeleteFramebuffers(1, &_fbo);
        _fbo = 0;
    }
    
    if ( _renderBuffer )
    {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
}

@end

*/