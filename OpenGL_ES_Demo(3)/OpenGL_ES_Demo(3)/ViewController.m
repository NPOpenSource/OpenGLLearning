//
//  ViewController.m
//  OpenGL_ES_Demo(3)
//
//  Created by 温杰 on 2018/1/29.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "os_cube.h"
#import "AGLKElementIndexArrayBuffer.h"
@interface ViewController ()
@property(nonatomic,strong)EAGLContext *eagContext;
@property (nonatomic ,strong)AGLKVertexAttribArrayBuffer * vertexBuffer;
@property (nonatomic,strong)AGLKVertexAttribArrayBuffer * vertexColorBuffer;
@property (nonatomic ,strong) GLKBaseEffect * effect;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createEagContext];
    [self configure];
    [self loadVertex];
    [self loadVertexColor];
    
}


-(void)loadVertex{
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:(3*sizeof(GLfloat)) numberOfVertices:(sizeof(cubeVertices)/(3 * sizeof(GLfloat))) bytes:cubeVertices usage:GL_STATIC_DRAW];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
}


-(void)loadVertexColor{
    
    self.vertexColorBuffer =[[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:(3*sizeof(GLfloat)) numberOfVertices:(sizeof(cubeColors)/(3 * sizeof(GLfloat))) bytes:cubeColors usage:GL_STATIC_DRAW];
    [self.vertexColorBuffer prepareToDrawWithAttrib:GLKVertexAttribColor numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
}

-(GLKMatrix4 )initModelViewMatrix{
    GLKMatrix4 modelViewMatrix;
    modelViewMatrix = GLKMatrix4Identity;
    static BOOL isScale = YES;
    static GLfloat spinY=0;
    static BOOL isY=YES;
    static GLfloat scale = 1;
    static GLfloat angle = 1;
//    modelViewMatrix =  GLKMatrix4Translate(modelViewMatrix, 0.0, spinY , 0);
//    modelViewMatrix=GLKMatrix4Scale(modelViewMatrix, scale, scale, 0.7);
    
    angle +=1;
    
    modelViewMatrix= GLKMatrix4Rotate(modelViewMatrix, M_PI/180.0*angle, 0.0, 1.0, 0.0);
    if (isScale) {
        scale-=0.01;
    }else{
        scale+=0.01;
    }
    if (scale>1) {
        isScale = YES;
    }
    if (scale<0.5) {
        isScale=NO;
    }
    
    if (isY) {
        spinY+=0.01;
    }else   {
        spinY-=0.01;
        
    }
    if (spinY>0.75) {
        isY = NO;
    }
    if (spinY<-0.75) {
        isY = YES;
    }
    
    
    return modelViewMatrix;
}


-(void)shader{
    self.effect = [[GLKBaseEffect alloc] init];
    GLfloat   aspectRatio =
    (float)((GLKView *)self.view).drawableWidth /
    (float)((GLKView *)self.view).drawableHeight;
    self.effect.transform.modelviewMatrix = GLKMatrix4Scale([self initModelViewMatrix], 1, aspectRatio, 1);
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self clear];
    [self loadVertex];
    [self loadVertexColor];
    [self shader];
    [self.effect prepareToDraw];
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:(sizeof(cubeVertices)/(3 * sizeof(GLfloat)))];
    [self.vertexColorBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:(sizeof(cubeColors)/(3 * sizeof(GLfloat)))];
    
    [AGLKElementIndexArrayBuffer drawElementIndexWithMode:GL_TRIANGLES indexCount:sizeof(tfan1)/sizeof(tfan1[0]) indexArr:tfan1];
//    [AGLKElementIndexArrayBuffer drawElementIndexWithMode:GL_TRIANGLES indexCount:sizeof(tfan2)/sizeof(tfan2[0]) indexArr:tfan2];

    
}
-(void)clear{
    glEnable(GL_DEPTH_TEST);
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
}
/**
 *  创建EAGContext 跟踪所有状态,命令和资源
 */
- (void)createEagContext{
    self.eagContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.eagContext];
}
/**
 *  配置view
 */

- (void)configure{
    GLKView *view = (GLKView*)self.view;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.context = self.eagContext;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
