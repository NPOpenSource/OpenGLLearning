//
//  LearningCustomView.m
//  OPenGL_ES_Demo(17)混合或者blend渲染
//
//  Created by 温杰 on 2018/2/27.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "LearningCustomView.h"


@interface LearningCustomView()
@property (nonatomic ,strong) ShaderManager * bgShader;
@property (nonatomic ,strong) TextureFrame * textureOne;
@property (nonatomic ,strong) TextureFrame * textureZero;
@end

@implementation LearningCustomView

- (BOOL)loadShaders{
    self.bgShader = [[ShaderManager alloc]init];
    [self.bgShader CompileLinkSuccessShaderName:@"bgShader1" glBindAttribLocationBlock:^(GLuint program) {
        glBindAttribLocation(program, ATTRIB_VERTEX, "position");
        glBindAttribLocation(program, ATTRIB_TEXCOORD, "textCoordinate");
    } GetUniformLocationBlock:^(GLuint program) {
        uniforms[UNIFORM_TEXTURE0] =glGetUniformLocation(program, "myTexture0");
        uniforms[UNIFORM_TEXTURE_Mat_Scale_0] =glGetUniformLocation(program, "scale");
        
        
    }];
    
    self.shadermanager =[[ShaderManager alloc]init];
    return  [self.shadermanager CompileLinkSuccessShaderName:@"shader1" glBindAttribLocationBlock:^(GLuint program) {
        glBindAttribLocation(program, ATTRIB_VERTEX, "position");
        glBindAttribLocation(program, ATTRIB_TEXCOORD, "textCoordinate");
    } GetUniformLocationBlock:^(GLuint program) {
        uniforms[UNIFORM_TEXTURE1] =glGetUniformLocation(program, "myTexture1");
        uniforms[UNIFORM_TEXTURE_Mat_Scale_1] =glGetUniformLocation(program, "scale");
        
        uniforms[UNIFORM_TEXTURE_Mat] =glGetUniformLocation(program, "rotateMatrix");
        
        
        
    }];
    
}
-(void)initVertex{
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*5 numberOfVertices:4 bytes:vertices usage:GL_STATIC_DRAW];
    [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_VERTEX numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_TEXCOORD numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES];
}

-(void)setImage{
    
    self.textureZero = [[TextureFrame alloc]init];
    [self.textureZero setupTexture:@"for_test"];
    [self.textureZero build];
    
    self.textureOne = [[TextureFrame alloc]init];
    self.textureOne.location = GL_TEXTURE1;
    [self.textureOne setupTexture:@"abc"];
    [self.textureOne build];
}
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
        [self render];
    }
    return self;
}

-(void)render{
    [self.frameManager layerRender:^{
        glClearColor(1.0,1.0, 1.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        [self.bgShader useProgram:^{
            glUniform1i(uniforms[UNIFORM_TEXTURE0], 0);
            glUniformMatrix4fv(uniforms[UNIFORM_TEXTURE_Mat_Scale_0], 1, GL_FALSE, GLKMatrix4MakeScale(0.5,0.5,1).m);
        }];
        [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_VERTEX numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
        [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_TEXCOORD numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES];
        [self.vertexBuffer drawArrayWithMode:GL_TRIANGLE_FAN startVertexIndex:0 numberOfVertices:4];
        [self.context presentRenderbuffer:GL_RENDERBUFFER];
        
        [self.shadermanager useProgram:^{
            glUniform1i(uniforms[UNIFORM_TEXTURE1], 1);
            glUniformMatrix4fv(uniforms[UNIFORM_TEXTURE_Mat_Scale_1], 1, GL_FALSE, GLKMatrix4MakeScale(0.2,0.2,1).m);
            glUniformMatrix4fv(uniforms[UNIFORM_TEXTURE_Mat], 1, GL_FALSE, GLKMatrix4MakeZRotation(0).m);
            
        }];
//        glEnable(GL_BLEND);
//        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_VERTEX numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
        [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_TEXCOORD numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES];
        [self.vertexBuffer drawArrayWithMode:GL_TRIANGLE_FAN startVertexIndex:0 numberOfVertices:4];
        [self.context presentRenderbuffer:GL_RENDERBUFFER];
        
    }];
}

@end
