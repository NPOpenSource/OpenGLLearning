//
//  ShaderManager.m
//  OpenGL_ES_Demo(1)
//
//  Created by 温杰 on 2018/1/26.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ShaderManager.h"

@interface ShaderManager()
@property (nonatomic,readwrite ) GLuint program;
@end

@implementation ShaderManager

- (BOOL)loadShaderName:(NSString *)fileName  {
    GLuint verShader, fragShader;
    GLint program = glCreateProgram();
    //读取文件路径
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:fileName ofType:@"vsh"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:fileName ofType:@"fsh"];
    //编译
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vertFile];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragFile];

    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    glBindAttribLocation(program, 0, "position");
    glBindAttribLocation(program, 1, "textCoordinate");
    
    //释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    
    //链接
    glLinkProgram(program);
    GLint linkSuccess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) { //连接错误
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error%@", messageString);
        return NO;
    }
    else {
        NSLog(@"link ok");
        glUseProgram(program); //成功便使用，避免由于未使用导致的的bug
    }
    self.program = program;
    return YES;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    //读取字符串
    NSString* content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar* source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}

@end
