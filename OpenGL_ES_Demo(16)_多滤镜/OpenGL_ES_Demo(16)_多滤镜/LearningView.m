//
//  LearningView.m
//  OpenGL_ES_Demo(16)_多滤镜
//
//  Created by 温杰 on 2018/2/8.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "LearningView.h"
#import "OPenGLManger.h"


enum{
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    ATTRIB_TEMP_VERTEX,
    ATTRIB_TEMP_TEXCOORD,
    NUM_ATTRIBUTES
};

enum
{
    UNIFORM_TEXTURE0,
    UNIFORM_TEXTURE1,
    UNIFORM_SATURATION,
    UNIFORM_TEMPERTURE,
    NUM_UNIFORMS
};


GLint uniforms[NUM_UNIFORMS];

typedef struct
{
    float position[3];
    float textureCoordinate[2];
} CustomVertex;
static const CustomVertex vertices[] =
{
    { .position = { -1.0, -1.0, 0 }, .textureCoordinate = { 0.0, 0.0 } },
    { .position = {  1.0, -1.0, 0}, .textureCoordinate = { 1.0, 0.0 } },
    { .position = {  1.0,  1.0, 0 }, .textureCoordinate = { 1.0, 1.0 }},
    { .position = { -1.0,  1.0, 0}, .textureCoordinate = { 0.0, 1.0 }
        
    }

};

@interface LearningView()
@property (nonatomic ,strong) TextureFrame * textureOne;
@property (nonatomic, assign) CGFloat temperture;

@property (nonatomic, assign) CGFloat saturation;
@property (nonatomic ,strong) FrameBufferManger  *offBuffer;

@property(nonatomic ,strong) ShaderManager * testShader;
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
        [self setOffBuffer];
        [self render];
        [self createUI];

    }
    return self;
}

-(void)setOffBuffer{
    self.offBuffer = [[FrameBufferManger alloc]init];
    self.offBuffer.width = self.frame.size.width * self.contentScaleFactor;
    self.offBuffer.height = self.frame.size.height * self.contentScaleFactor;
    [self.offBuffer build];
}

-(void)createUI{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 100, 50);
    button.backgroundColor = [UIColor redColor];
    button.alpha = 0.5;
    [button addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:button];
   button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(200, 0, 100, 50);
    button.backgroundColor = [UIColor redColor];
    button.alpha = 0.5;
    [button addTarget:self action:@selector(buttonONE:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:button];
}
- (void)button:(UIButton *)sender {
    static float satu = 0.0;
    satu+=0.05;
    if (satu>=1.0) {
        satu=0;
    }
    self.saturation = satu;
    [self render];
}
-(void)buttonONE:(UIButton *)sender{
    static float satu = 0.0;
    satu+=0.05;
    if (satu>=1.0) {
        satu=0;
    }
    self.temperture = satu;
    [self render];
}

-(void)setImage{
    self.textureOne = [[TextureFrame alloc]init];
    self.textureOne.location = GL_TEXTURE1;
    [self.textureOne setupTexture:@"Lena"];
    [self.textureOne build];
}

///离屏渲染图片成绿色

- (BOOL)loadShaders{
    self.testShader = [[ShaderManager alloc]init];
    [self.testShader CompileLinkSuccessShaderName:@"shader" glBindAttribLocationBlock:^(GLuint program) {
        glBindAttribLocation(program, ATTRIB_VERTEX, "postion");
        glBindAttribLocation(program, ATTRIB_TEXCOORD, "textCoordinate");
    
    } GetUniformLocationBlock:^(GLuint program) {
    
        uniforms[UNIFORM_TEXTURE0] =glGetUniformLocation(program, "myTexture0");
        uniforms[UNIFORM_SATURATION]=glGetUniformLocation(program, "saturation");
        
        
    }];
    
    self.shadermanager =[[ShaderManager alloc]init];
    return  [self.shadermanager CompileLinkSuccessShaderName:@"shader1" glBindAttribLocationBlock:^(GLuint program) {
        glBindAttribLocation(program, ATTRIB_VERTEX, "postion");
        glBindAttribLocation(program, ATTRIB_TEXCOORD, "textCoordinate");
        
    } GetUniformLocationBlock:^(GLuint program) {
        uniforms[UNIFORM_TEXTURE1] =glGetUniformLocation(program, "myTexture0");
        uniforms[UNIFORM_TEMPERTURE] =glGetUniformLocation(program, "temperature");
    }];
        
}

-(void)initVertex{
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*5 numberOfVertices:4 bytes:vertices usage:GL_STATIC_DRAW];
    [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_VERTEX numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_TEXCOORD numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES];
}




-(void)render{
    [self.offBuffer offScreenRender:^{
        [self.testShader useProgram:^{
            glUniform1i(uniforms[UNIFORM_TEXTURE0], 1);
            glUniform1f(uniforms[UNIFORM_SATURATION], self.saturation);
        }];
        glClearColor(0.0,0.0, 0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_VERTEX numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
        [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_TEXCOORD numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES];
        [self.vertexBuffer drawArrayWithMode:GL_TRIANGLE_FAN startVertexIndex:0 numberOfVertices:4];
    }];
    

   
    [self.frameManager layerRender:^{
        glClearColor(0.0,.0, 0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        [self.shadermanager useProgram:^{
            glUniform1i(uniforms[UNIFORM_TEXTURE1], 0);
            glUniform1f(uniforms[UNIFORM_TEMPERTURE], self.temperture);
        }];
        [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_VERTEX numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
        [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_TEXCOORD numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES];
        [self.vertexBuffer drawArrayWithMode:GL_TRIANGLE_FAN startVertexIndex:0 numberOfVertices:4];

        [self.context presentRenderbuffer:GL_RENDERBUFFER];
    }];
    
}





@end
