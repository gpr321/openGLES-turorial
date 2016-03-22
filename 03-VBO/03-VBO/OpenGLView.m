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

@end
