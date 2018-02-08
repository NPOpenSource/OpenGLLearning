//
//  GLTestViewController.m
//  OpenGL_ES_Demo(1)
//
//  Created by 温杰 on 2018/1/26.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "GLTestViewController.h"
#import "ShaderManager.h"
#import "AGLKVertexAttribArrayBuffer.h"

@interface GLTestViewController()
{
    GLfloat  *vertex;
    GLuint m_count;
}
@property (nonatomic ,strong) EAGLContext * eagcontext;
@property (nonatomic ,assign) GLuint  program;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (nonatomic ,assign) GLint vertexcolor;
@property (nonatomic ,assign) GLuint vertexBuffer;
@end

@implementation GLTestViewController

-(void)createEagContext{
    self.eagcontext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.eagcontext];
}

-(void)configure{
    GLKView *view = (GLKView*)self.view;
    view.context = self.eagcontext;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
}

-(void)createShader{
    [ShaderManager CompileLinkSuccessProgram:&_program shaderName:@"Shader" glBindAttribLocationBlock:^(GLuint program) {
        glBindAttribLocation(program, 0, "position");  // 0代表枚举位置
    } GetUniformLocationBlock:^(GLuint program) {
      _vertexcolor =  glGetUniformLocation(program, "color");
    }];
}



//static GLfloat vertex[6] = {
//    -1,-1,// 左下
//    -1,1, // 左上
//    1,1  // 右上
//};

-(void)calculate{
    m_count = 360;
    float  width = 0.5;
       vertex =
        (GLfloat*)malloc(sizeof(GLfloat) * 2*m_count);
    for (int i=0; i<180; i++) {
            float m = M_PI*i/180.0;
            vertex[2*i]=width*cosf(m);
            vertex[2*i+1]=width*sinf(m);
            vertex[360+2*i]=-width*cosf(m);
            vertex[360+2*i+1]=-width*sinf(m);
       
    }
    for (int i=0; i<180; i+=2) {
        NSLog(@"%f %f",vertex[i],vertex[i+1]);
    }

}
-(void)loadVertex{

    [self calculate];
    self.vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:(2 * sizeof(GLfloat)) numberOfVertices:m_count bytes:vertex usage:GL_STATIC_DRAW];
    [self.vertexPositionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
}




-(void)viewDidLoad{
    [super viewDidLoad];
    [self createEagContext];
    [self configure];
    [self createShader];
    [self loadVertex];
    
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    static NSInteger count = 0;
    // 清除颜色缓冲区
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    count ++;
    if (count > 50 ) {
        count = 0;
        // 根据颜色索引值,设置颜色数据，就是刚才我们从着色器程序中获取的颜色索引值
        glUniform4f(_vertexcolor,   arc4random_uniform(255)/225.0, arc4random_uniform(255)/225.0, arc4random_uniform(255)/225.0, 1);
    }
    // 使用着色器程序
    glUseProgram(_program);
    // 绘制
    [self.vertexPositionBuffer drawArrayWithMode:GL_TRIANGLE_FAN startVertexIndex:0 numberOfVertices:m_count];
}

@end
