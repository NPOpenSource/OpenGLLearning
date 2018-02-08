//
//  LearningView.m
//  OpenGL_ES_demo(14)_多重纹理
//
//  Created by 温杰 on 2018/2/8.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "LearningView.h"

enum{
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};
enum
{
    UNIFORM_TEXTURE0,
    UNIFORM_TEXTURE1,
    UNIFORM_LEFTBOTTOM,
    UNIFORM_RIGHTTOP,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];


static GLfloat attrArr[] =
{
    0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
    -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
    -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
    0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
    -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
    0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
};


@interface LearningView()
@property (nonatomic ,strong) TextureFrame * textureOne;
@property (nonatomic ,strong) TextureFrame * textureTwo;
@end

@implementation LearningView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!self.context || ![EAGLContext setCurrentContext:self.context] || ![self loadShaders]) {
            return nil;
        }
        [EAGLContext setCurrentContext:self.context];
        
        [self initVertex];
        [self initFrameRender];
        [self setImage];
        [self setShader];
        [self render];
    }
    return self;
}
-(void)setImage{
    self.textureOne = [[TextureFrame alloc]init];
    [self.textureOne setupTexture:@"for_test"];
    self.textureTwo=[[TextureFrame alloc]init];
    self.textureTwo.location = GL_TEXTURE1;
    [self.textureTwo setupTexture:@"abc"];
    [self.textureTwo build];
    [self.textureOne build];
}
-(void)setShader{
    glUseProgram(self.shadermanager.program);
    glUniform1i(uniforms[UNIFORM_TEXTURE0], 0);
    glUniform1i(uniforms[UNIFORM_TEXTURE1], 1);
    glUniform2f(uniforms[UNIFORM_LEFTBOTTOM], -0.15, -0.15);
    glUniform2f(uniforms[UNIFORM_RIGHTTOP], 0.3, 0.3);

}

- (BOOL)loadShaders{
    
    self.shadermanager =[[ShaderManager alloc]init];
    return  [self.shadermanager CompileLinkSuccessShaderName:@"shader" glBindAttribLocationBlock:^(GLuint program) {
        glBindAttribLocation(program, ATTRIB_VERTEX, "postion");
        glBindAttribLocation(program, ATTRIB_TEXCOORD, "textCoordinate");
    } GetUniformLocationBlock:^(GLuint program) {
        uniforms[UNIFORM_TEXTURE0] =glGetUniformLocation(program, "myTexture0");
        uniforms[UNIFORM_TEXTURE1] = glGetUniformLocation(program, "myTexture1");
        uniforms[UNIFORM_LEFTBOTTOM] = glGetUniformLocation(program, "leftBottom");
        uniforms[UNIFORM_RIGHTTOP] = glGetUniformLocation(program, "rightTop");
    }];
}

-(void)initVertex{
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*5 numberOfVertices:6 bytes:attrArr usage:GL_STATIC_DRAW];
    [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_VERTEX numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_TEXCOORD numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES];
}



-(void)render{
    glClearColor(1.0,.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:6];
    [self.frameManager layerRender:^{
        [self.context presentRenderbuffer:GL_RENDERBUFFER];

    }];
    
}




@end
