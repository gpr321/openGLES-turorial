//
//  GLView.m
//  02-Animation
//
//  Created by peironggao on 16/3/16.
//  Copyright © 2016年 gaopeirong. All rights reserved.
//

#import "GLView.h"
#import <GLESTool/GLESTool.h>
#import <GLKit/GLKit.h>

@interface GLView ()
{
    EAGLContext         *_ctx;
    CAEAGLLayer         *_eaglLayer;
    GLuint              _program;
    
    GLuint              _renderBuffer;
    GLuint              _frameBuffer;
    
    GLint               _backWidth;
    GLint               _backHeight;
    
    GLuint              _aPosition;
    GLuint              _aColor;
    
    GLuint              _uModelMat;
    GLKMatrix4          _modelMatrix;

    GLuint              _uProjection;
    GLKMatrix4          _projectionMatrix;
    
    CADisplayLink       *_link;
}

@end

@implementation GLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] )
    {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ( self = [super initWithCoder:aDecoder] )
    {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    _ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    assert(_ctx);
    [EAGLContext setCurrentContext:_ctx];
    _program = gl_tool_build_program_from_file(@"VertexShader.glsl", @"FragmentShader.glsl");
    glUseProgram(_program);
    
    _aPosition = glGetAttribLocation(_program, "aPosition");
    _aColor = glGetAttribLocation(_program, "aColor");
    
    _uModelMat = glGetUniformLocation(_program, "uModelMat");
    _modelMatrix = GLKMatrix4Identity;
    
    _modelZ = -5.5f;
    _height = -1.0f;
    _uProjection = glGetUniformLocation(_program, "uProjection");

}

- (void)layoutSubviews
{
    [self destroyFBO];
    [self createFBO];
    [self updateTransform];
    [self render];
}

- (void)createFBO
{
    [EAGLContext setCurrentContext:_ctx];
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_ctx renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backHeight);
    
//    float aspect = (float)_backWidth / (float) _backHeight;
    float aspect = self.bounds.size.width / self.bounds.size.height;
//    NSLog(@"%@", NSStringFromCGRect(self.bounds));
//    float aspect = 320.0 / 360.0;
    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.f), aspect, 1, 15.0f);
    glUniformMatrix4fv(_uProjection, 1, 0, _projectionMatrix.m);
    
}

- (void)destroyFBO
{
    [EAGLContext setCurrentContext:_ctx];
    if ( _frameBuffer )
    {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if ( _renderBuffer )
    {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
}

- (void)render
{
    [EAGLContext setCurrentContext:_ctx];
    
    glUseProgram(_program);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glClearColor(0.f, 0.5f, 0.3f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, _backWidth, _backHeight);
    
    GLfloat vertexes[] =
    {
        0.7f, 0.7f, 0.0f,       // 1
        0.7f, -0.7f, 0.0f,      // 2
        -0.7f, -0.7f, 0.0f,     // 3
        -0.7f, 0.7f, 0.0f,      // 4
        0.0f, 0.0f, _height        // 5
    };
    
    
    static GLfloat  colors[] =
    {
        1.0f, 0.0f, 0.0f, 1.0f,
        0.0f, 1.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f, 1.0f,
        1.0f, 0.0f, 0.0f, 1.0f,
        0.0f, 1.0f, 0.0f, 1.0f,
    };
    
    GLubyte indicates[] = {
        0, 1, 1, 2, 2, 3, 3, 0,
        4, 0, 4, 1, 4, 2, 4, 3
    };
    
    glEnableVertexAttribArray(_aPosition);
    glVertexAttribPointer(_aPosition, 3, GL_FLOAT, 0, 0, vertexes);
    
    glEnableVertexAttribArray(_aColor);
    glVertexAttribPointer(_aColor, 4, GL_FLOAT, 0, 0, colors);
    
    glUniformMatrix4fv(_uModelMat, 1, 0, _modelMatrix.m);
    
    glDrawElements(GL_LINES, sizeof(indicates) / sizeof(indicates[0]), GL_UNSIGNED_BYTE, indicates);
    
    [_ctx presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setModelX:(float)modelX
{
    _modelX = modelX;
    [self updateTransform];
    [self render];
}

- (void)setModelY:(float)modelY
{
    _modelY = modelY;
    [self updateTransform];
    [self render];
}

- (void)setModelZ:(float)modelZ
{
    _modelZ = modelZ;
    [self updateTransform];
    [self render];
}

- (void)setRotateZ:(float)rotateZ
{
    _rotateZ = rotateZ;
    [self updateTransform];
    [self render];
}

- (void)setRotateY:(float)rotateY
{
    _rotateY = rotateY;
    [self updateTransform];
    [self render];
}

- (void)setRotateX:(float)rotateX
{
    _rotateX = rotateX;
    [self updateTransform];
    [self render];
}

- (void)setHeight:(float)height
{
    _height = height;
    [self updateTransform];
    [self render];
}

- (void)updateTransform
{
    _modelMatrix = GLKMatrix4Identity;
    
    _modelMatrix = GLKMatrix4Translate(_modelMatrix, _modelX, _modelY, _modelZ);

    _modelMatrix = GLKMatrix4Rotate(_modelMatrix, _rotateZ, 0, 0, 1);
    
    _modelMatrix = GLKMatrix4Scale(_modelMatrix, 1, 1, _scaleZ);
    
    _modelMatrix = GLKMatrix4Rotate(_modelMatrix, _rotateZ, 0, 0, 1);
    
    _modelMatrix = GLKMatrix4Rotate(_modelMatrix, _rotateY, 0, 1, 0);
    
    _modelMatrix = GLKMatrix4Rotate(_modelMatrix, _rotateX, 1, 0, 0);
    
//    _modelMatrix = GLKMatrix4Rotate(_modelMatrix, _rotateX, 1.0f, 0.f, 0.f);
//    _modelMatrix = GLKMatrix4Rotate(_modelMatrix, _rotateY, 0.0f, 1.f, 0.f);
//    _modelMatrix = GLKMatrix4Rotate(_modelMatrix, _rotateZ, 0.0f, 0.f, 1.f);
//    
//    _modelMatrix = GLKMatrix4Scale(_modelMatrix, _scaleX, _scaleY, _scaleZ);
}

- (void)resetTransform
{
    _modelX = 0;
    _modelY = 0;
    _modelZ = 5.5;
    
    _scaleZ = 1;
    
    _rotateZ = 0;
    
    _modelMatrix = GLKMatrix4Identity;
    [self updateTransform];
}

- (void)toggleDisplayLink
{
    if ( _link == nil )
    {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(disPlayLinkCallBack:)];
        [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else
    {
        [_link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _link = nil;
    }
}

- (void)disPlayLinkCallBack:(CADisplayLink *)link
{
//    if ( _rotateY > 1.0 )
//    {
//        _rotateY = -1.0;
//    }
    self.rotateY += link.duration;
}

@end
