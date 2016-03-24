//
//  OpenGLView.m
//  03-VBO
//
//  Created by peironggao on 16/3/22.
//  Copyright © 2016年 gaopeirong. All rights reserved.
//

#import "OpenGLView.h"
#import <GLESTool/GLESTool.h>

@interface OpenGLView ()
{
    EAGLContext *_context;
    
    CAEAGLLayer* _eaglLayer;
    
    GLuint      _program;
    
    GLuint      _aColor;
    GLuint      _aPosition;
    
    GLuint      _vao;
    
    GLuint      _indexBuffer;
    
    GLuint      _frameBuffer;
    GLuint      _colorRenderBuffer;
    
    GLint           _renderWidth;
    GLint           _renderHeight;

}

@end

@implementation OpenGLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] )
    {
        [self setUp];
        [self setUpBuffer];
    }
    return self;
}

- (void)setUp
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
    
    // Set drawable properties
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
    
    NSString *vShaderString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vertexShader.glsl" ofType:nil] encoding:NSUTF8StringEncoding error:NULL];
    NSString *fShaderString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fragmentShader.glsl" ofType:nil] encoding:NSUTF8StringEncoding error:NULL];
    
    _program = gl_tool_build_program([vShaderString cStringUsingEncoding:NSUTF8StringEncoding], [fShaderString cStringUsingEncoding:NSUTF8StringEncoding]);
    glUseProgram(_program);
    
    _aColor = glGetAttribLocation(_program, "aColor");
    _aPosition = glGetAttribLocation(_program, "aPosition");
}

- (void)setUpBuffer
{
    
    GLfloat vertex[] = {
        0.0f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f
    };
    
    GLfloat colors[] = {
        1.0, 0.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
    };
    
    GLuint vertexBuffer = 0;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertex), vertex, GL_STATIC_DRAW);
    
    GLuint colorBuffer = 0;
    glGenBuffers(1, &colorBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, colorBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(colors), colors, GL_STATIC_DRAW);
    
    glGenVertexArraysOES(1, &_vao);
    glBindVertexArrayOES(_vao);
    
//    GLint indexes[] = {
//        0, 1, 2
//    };
//    
//    glGenBuffers(1, &_indexBuffer);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexes), indexes, GL_STATIC_DRAW);
//    
    glEnableVertexAttribArray(_aPosition);
    glEnableVertexAttribArray(_aColor);
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glVertexAttribPointer(_aPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    
    glBindBuffer(GL_ARRAY_BUFFER, colorBuffer);
    glVertexAttribPointer(_aColor, 4, GL_FLOAT, GL_FALSE, 0, NULL);
    
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_context];
    [self destroyVBO];
    [self setUpVBO];
    [self render];
}

- (void)setUpVBO
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)destroyVBO
{
    if ( _frameBuffer ) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if ( _colorRenderBuffer ) {
        glDeleteRenderbuffers(1, &_colorRenderBuffer);
        _colorRenderBuffer = 0;
    }
}

- (void)render
{
    glUseProgram(_program);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBindVertexArrayOES(_vao);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
//    glDrawElements(GL_TRIANGLES, 3, GL_INT, (void *)0);
    glBindVertexArrayOES(0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
