//
//  GLESUtil.m
//  GLESTool
//
//  Created by peironggao on 16/3/16.
//  Copyright © 2016年 gaopeirong. All rights reserved.
//

#import "GLESUtil.h"

GLuint gl_tool_compile_shader(GLuint type, const char * source)
{
    
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    GLint compiled;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
#ifdef DEBUG
    if (!compiled) {
        GLint length;
        char *log;
        
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &length);
        
        log = (char*)malloc((size_t)(length));
        glGetShaderInfoLog(shader, length, &length, &log[0]);
        NSLog(@"%s compilation error: %s\n", (type == GL_VERTEX_SHADER ? "GL_VERTEX_SHADER" : "GL_FRAGMENT_SHADER"), log);
        free(log);
        
        return 0;
    }
#endif
    return shader;
}

GLuint gl_tool_build_program(const char * vertex, const char * fragment)
{
    GLuint  vshad,
    fshad,
    p;
    
    GLint   len;
#ifdef DEBUG
    char*   log;
#endif
    
    vshad = gl_tool_compile_shader(GL_VERTEX_SHADER, vertex);
    fshad = gl_tool_compile_shader(GL_FRAGMENT_SHADER, fragment);
    
    p = glCreateProgram();
    glAttachShader(p, vshad);
    glAttachShader(p, fshad);
    glLinkProgram(p);
    glGetProgramiv(p,GL_INFO_LOG_LENGTH, &len);
    
    
#ifdef DEBUG
    if(len) {
        log = (char*)malloc ( (size_t)(len) ) ;
        
        glGetProgramInfoLog(p, len, &len, log);
        
        NSLog(@"program log: %s\n", log);
        free(log);
    }
#endif
    
    
    glDeleteShader(vshad);
    glDeleteShader(fshad);
    return p;
}

