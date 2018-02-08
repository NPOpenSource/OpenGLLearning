//
//  TestShaderView.m
//  OpenGL_ES_Demo(7)_shader
//
//  Created by 温杰 on 2018/1/31.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "TestShaderView.h"
#import "ShaderManager.h"
#import <GLKit/GLKit.h>
#import "AGLKVertexAttribArrayBuffer.h"
@interface TestShaderView(){
    GLuint _framebuffer; // 帧缓存标示
    GLuint _colorRenderbuffer;// 颜色缓存标示
    
    GLuint _positionbuffer; // 顶点坐标标示;
    GLuint _colorbuffer; // 顶点对应的颜色渲染缓冲区标示
    
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
    
}
@property(nonatomic,strong)EAGLContext *eagContext;
@property (nonatomic ,strong) ShaderManager * shaderManger;
@property(nonatomic ,strong) AGLKVertexAttribArrayBuffer * vertexsbuffer;
@end

@implementation TestShaderView

+(Class)layerClass{
    
    return [CAEAGLLayer class];
}
-(void)configure{
    CAEAGLLayer *eagLayer = (CAEAGLLayer *)self.layer;
    eagLayer.opaque = YES; // 提高渲染质量 但会消耗内存
    eagLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @(false),kEAGLColorFormatRGBA8:@(true)};
    //self.baseEffect = [[GLKBaseEffect alloc]init];
    
}


-(void)createEAGContext{
    self.eagContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.eagContext];
}

-(void)createFramebuffer{
    glGenFramebuffers(1, &_framebuffer); // 为帧缓存申请一个内存标示，唯一的 1.代表一个帧缓存
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);// 把这个内存标示绑定到帧缓存上
}

- (void)createColorRenderbuffer{
    glGenRenderbuffers(1, &_colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    [self.eagContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,GL_RENDERBUFFER, _colorRenderbuffer);
    
}

- (void)clear{
    CGFloat scale = [[UIScreen mainScreen] scale]; //获取视图放大倍数，可以把scale设置为1试试
    scale=1;
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale); //设置视口大小
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
}

GLfloat verticeArr [6*5] =  {-1,1,1,0,0, // 左上
    -1,-1,0,0,1, // 左下
    1,-1, 0,1,0}; // 右下

-(void) createVertexBufferAndColorBuffer{
    self.vertexsbuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*5 numberOfVertices:3 bytes:verticeArr usage:GL_STATIC_DRAW];
    [self.vertexsbuffer prepareToDrawWithAttrib:0 numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
    [self.vertexsbuffer prepareToDrawWithAttrib:1 numberOfCoordinates:3 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES];
    [self.vertexsbuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:3];
   
}

// MARK: 步骤八 将渲染缓存中的内容呈现到视图中去
-(void)showRenderbuffer{
    [self.eagContext  presentRenderbuffer:GL_RENDERBUFFER];
}

// 执行步骤
-(void)setupGL{
    [self configure];
    [self createEAGContext];// 2
    [self createFramebuffer];// 3
    [self createColorRenderbuffer];//4
    [self clear];//5
    [self loadShaders];//6
    [self createVertexBufferAndColorBuffer]; // 7
    [self showRenderbuffer];  //8
}




// 导入渲染器
- (void)loadShaders{
    self.shaderManger =[[ShaderManager alloc]init];
    [self.shaderManger CompileLinkSuccessShaderName:@"Shader" glBindAttribLocationBlock:^(GLuint program) {
        glBindAttribLocation(program, 0, "Position");
        glBindAttribLocation(program, 1, "SourceColor");
    } GetUniformLocationBlock:^(GLuint program) {
        
    }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    [self setupGL];
}


@end
