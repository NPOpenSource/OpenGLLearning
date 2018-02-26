//
//  LearningColorView.m
//  OpenGL_ES_Demo(16)_多滤镜
//
//  Created by 温杰 on 2018/2/26.
//  Copyright © 2018年 温杰. All rights reserved.
//



#import "LearningColorView.h"

enum{
    ATTRIB_VERTEX_ONE,
    ATTRIB_TEXTCODE_ONE,
    ATTRIB_ONE_NUM,
};

enum
{
    UNIFORM_TEXTURE0_COLOR,
    UNIFORM_TEXTURE_GREEN_COLOR,
    UNIFORM_TEXTURE_ONE,
    UNIFORM_TEXTURE_TWO,
    NUM_UNIFORMS
};


GLint uniforms_one[NUM_UNIFORMS];

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

@interface LearningColorView()
@property (nonatomic ,strong) TextureFrame * textureOne;
@property (nonatomic ,strong) ShaderManager * shaderOne;
@property (nonatomic ,assign) float redColor;
@property (nonatomic ,assign) float greenColor;
@property (nonatomic ,strong) FrameBufferManger  *offBuffer;

@end

@implementation LearningColorView

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

- (BOOL)loadShaders{
    self.shaderOne = [[ShaderManager alloc]init];
    [self.shaderOne CompileLinkSuccessShaderName:@"shaderOne" glBindAttribLocationBlock:^(GLuint program) {
        glBindAttribLocation(program, ATTRIB_VERTEX_ONE, "postion");
        glBindAttribLocation(program, ATTRIB_TEXTCODE_ONE, "textCoordinate");
    } GetUniformLocationBlock:^(GLuint program) {
        uniforms_one[UNIFORM_TEXTURE_ONE] =glGetUniformLocation(program, "myTexture0");
        uniforms_one[UNIFORM_TEXTURE0_COLOR] =glGetUniformLocation(program, "redColor");
    }];
    
    self.shadermanager =[[ShaderManager alloc]init];
    return  [self.shadermanager CompileLinkSuccessShaderName:@"shaderTwo" glBindAttribLocationBlock:^(GLuint program) {
        glBindAttribLocation(program, ATTRIB_VERTEX_ONE, "postion");
        glBindAttribLocation(program, ATTRIB_TEXTCODE_ONE, "textCoordinate");
    } GetUniformLocationBlock:^(GLuint program) {
        uniforms_one[UNIFORM_TEXTURE_TWO] =glGetUniformLocation(program, "myTexture0");
        uniforms_one[UNIFORM_TEXTURE_GREEN_COLOR] =glGetUniformLocation(program, "greenColor");
    }];
    
}


-(void)render{
    [self.offBuffer offScreenRender:^{
        [self.shaderOne useProgram:^{
            glUniform1i(uniforms_one[UNIFORM_TEXTURE_ONE], 1);
        glUniform1f(uniforms_one[UNIFORM_TEXTURE0_COLOR],self.redColor);
        }];
        glClearColor(0.0,0.0, 0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_VERTEX_ONE numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
        [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_TEXTCODE_ONE numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES];
        [self.vertexBuffer drawArrayWithMode:GL_TRIANGLE_FAN startVertexIndex:0 numberOfVertices:4];
    }];

    
    [self.frameManager layerRender:^{
       
        [self.shadermanager useProgram:^{
            glUniform1i(uniforms_one[UNIFORM_TEXTURE_TWO], 0);
        glUniform1f(uniforms_one[UNIFORM_TEXTURE_GREEN_COLOR],self.greenColor);

        }];
        glClearColor(0.0,.0, 0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_VERTEX_ONE numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
        [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_TEXTCODE_ONE numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES];
        [self.vertexBuffer drawArrayWithMode:GL_TRIANGLE_FAN startVertexIndex:0 numberOfVertices:4];
        
        [self.context presentRenderbuffer:GL_RENDERBUFFER];
    }];
    
}


-(void)setImage{
    self.textureOne = [[TextureFrame alloc]init];
    self.textureOne.location = GL_TEXTURE1;
    [self.textureOne setupTexture:@"Lena"];
    [self.textureOne build];
}

-(void)initVertex{
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*5 numberOfVertices:4 bytes:vertices usage:GL_STATIC_DRAW];
    [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_VERTEX_ONE numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_TEXTCODE_ONE numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES];
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
    self.redColor = satu;
    satu+=0.05;
    if (satu>=1.0) {
        satu=0;
    }
    [self render];
}
-(void)buttonONE:(UIButton *)sender{
    static float satu = 0.0;
    self.greenColor = satu;
    satu+=0.05;
    if (satu>=1.0) {
        satu=0;
    }
    [self render];
}

@end
