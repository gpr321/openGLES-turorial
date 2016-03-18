//
//  GLESUtil.h
//  GLESTool
//
//  Created by peironggao on 16/3/16.
//  Copyright © 2016年 gaopeirong. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#define GL_FRAMEBUFFER_STATUS(line) { GLenum status; status = glCheckFramebufferStatus(GL_FRAMEBUFFER); {\
switch(status)\
{\
case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:\
NSLog(@"OGL(" __FILE__ "):: %d: Incomplete attachment\n", line);\
break;\
case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS:\
NSLog(@"OGL(" __FILE__ "):: %d: Incomplete dimensions\n", line);\
break;\
case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:\
NSLog(@"OGL(" __FILE__ "):: %d: Incomplete missing attachment\n", line);\
break;\
case GL_FRAMEBUFFER_UNSUPPORTED:\
NSLog(@"OGL(" __FILE__ "):: %d: Framebuffer combination unsupported\n",line);\
break;\
} } }

GLuint gl_tool_compile_shader(GLuint type, const char * source);
GLuint gl_tool_build_program(const char * vertex, const char * fragment);
GLuint gl_tool_build_program_from_file(NSString *vFileName, NSString *fFileName);
