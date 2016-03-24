//
//  GLView.m
//  01-helloworldtriangle
//
//  Created by peironggao on 16/3/16.
//  Copyright © 2016年 gaopeirong. All rights reserved.
//

#import "GLView.h"
#import <GLESTool/GLESTool.h>

@interface GLView ()
{
    GLuint          _renderBuffer;
    GLint           _renderWidth;
    GLint           _renderHeight;
    
    GLuint          _frameBuffer;
    
    GLuint          _program;
    
    EAGLContext     *_ctx;
    CAEAGLLayer     *_eaglLayer;
    
    GLuint          _aPosition;
    GLuint          _aColor;
    
    GLuint          _vao;
    
    GLuint          _vertexVBO;
    GLuint          _colorVBO;
}

@end

@implementation GLView

+ (Class)layerClass
{
    // 只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] )
    {
        [self setUpLayer];
        [self setUpGLContext];
        [self setUpProgram];
        [self setUpVBO];
    }
    return self;
}

- (void)setUpProgram
{
    NSString *vShaderString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VertexShader.glsl" ofType:nil] encoding:NSUTF8StringEncoding error:NULL];
    NSString *fShaderString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FragmentShader.glsl" ofType:nil] encoding:NSUTF8StringEncoding error:NULL];
    
    _program = gl_tool_build_program([vShaderString cStringUsingEncoding:NSUTF8StringEncoding], [fShaderString cStringUsingEncoding:NSUTF8StringEncoding]);
    glUseProgram(_program);
    
    // 获取 position slot
    _aPosition = glGetAttribLocation(_program, "aPosition");
    _aColor = glGetAttribLocation(_program, "aColor");
}

- (void)setUpLayer
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setUpVBO
{
    GLfloat vertices[] = {
        0.0f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f
    };
    
    GLfloat colors[] = {
        1.0, 0.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
    };
    
    glGenBuffers(1, &_vertexVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexVBO);
    glBufferData(GL_ARRAY_BUFFER, 9 * sizeof(GLfloat), vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_colorVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _colorVBO);
    glBufferData(GL_ARRAY_BUFFER, 9 * sizeof(GLfloat), colors, GL_STATIC_DRAW);
    
    glGenVertexArraysOES(1, &_vao);
    glBindVertexArrayOES(_vao);
    glEnableVertexAttribArray(_aPosition);
    glEnableVertexAttribArray(_aColor);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexVBO);
    glVertexAttribPointer(_aPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    
    glBindBuffer(GL_ARRAY_BUFFER, _colorVBO);
    glVertexAttribPointer(_aColor, 4, GL_FLOAT, GL_FALSE, 0, NULL);
}

- (void)setUpGLContext
{
    // 指定上下文, 一般 iOS 开发使用 api2
    _ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_ctx];
    NSAssert(_ctx, @"api2 context was fail");
}

- (void)layoutSubviews
{
    [self destroyFBO];
    [self setUpFBO];
    [self render];
}

- (void)destroyFBO
{
    [EAGLContext setCurrentContext:_ctx];
    if ( _renderBuffer )
    {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
}

- (void)setUpFBO
{
    [EAGLContext setCurrentContext:_ctx];
    
    // 初始化renderbufer 并指定为当前的 renderbuffer
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    // 为render buffer 分配内存
    [_ctx renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    // 初始化 frame buffer 并指定为当前的 framebuffer
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // 将 renderBuffer 挂载到 framebuffer 上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    // 获取render buffer的宽高
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderHeight);
}

- (void)render
{
    [EAGLContext setCurrentContext:_ctx];
    
    glUseProgram(_program);
    // 设定背景颜色
    glClearColor(0.f, 1.f, 0.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 设定帧的视口大小
    glViewport(0, 0, _renderWidth, _renderHeight);
    
//    GLfloat vertices[] = {
//        0.0f,  0.5f, 0.0f,
//        -0.5f, -0.5f, 0.0f,
//        0.5f,  -0.5f, 0.0f
//    };
//    
//    GLubyte colors[] = {
//        1.0, 0.0, 0.0, 1.0,
//        0.0, 1.0, 0.0, 1.0,
//        0.0, 0.0, 1.0, 1.0,
//    };
//    
//    // 导入顶点数据
//    glVertexAttribPointer(_aPosition, 3, GL_FLOAT, GL_FALSE, 0, vertices);
//    glEnableVertexAttribArray(_aPosition);
//    
//    glVertexAttribPointer(_aColor, 4, GL_UNSIGNED_BYTE, GL_FALSE, 0, colors);
//    glEnableVertexAttribArray(_aColor);
    
//    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    // VAO
    glBindVertexArrayOES(_vao);
    
    // 画三角形
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    glBindVertexArrayOES(0);
    
    // VBO
//    glEnableVertexAttribArray(_aPosition);
//    glEnableVertexAttribArray(_aColor);
//    glBindBuffer(GL_ARRAY_BUFFER, _vertexVBO);
//    glVertexAttribPointer(_aPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);
//    
//    glBindBuffer(GL_ARRAY_BUFFER, _colorVBO);
//    glVertexAttribPointer(_aColor, 4, GL_FLOAT, GL_FALSE, 0, NULL);
//    
//    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    // 渲染
    [_ctx presentRenderbuffer:GL_RENDERBUFFER];
}

@end
