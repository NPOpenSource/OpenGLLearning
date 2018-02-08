//
//  ViewController.m
//  Open_GL_ES_Demo(2)
//
//  Created by 温杰 on 2018/1/29.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "ShaderManager.h"
@interface ViewController ()
{
    GLfloat *_vertexArray;
    GLint  m_count;
    GLfloat *_colorsArray;

  
}
@property(nonatomic,strong)EAGLContext *eagContext;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (strong ,nonatomic) AGLKVertexAttribArrayBuffer *vertexColorBuffer;
@property (nonatomic ,strong) GLKBaseEffect * effect;
@end

@implementation ViewController

-(void)createBG{
    UIImageView *imageView =  [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg.jpg"]];
    imageView.frame = self.view.bounds;
    [self.view addSubview:imageView];
    imageView.alpha = 0.5;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self  createBG];
    [self createEagContext];
    [self configure];
    [self calculate];
    [self loadVertex];
    [self loadColorBuffer];
    
}
-(GLKMatrix4 )initModelViewMatrix{
    GLKMatrix4 modelViewMatrix;
    modelViewMatrix = GLKMatrix4Identity;
    static BOOL isScale = YES;
    static GLfloat spinY=0;
    static BOOL isY=YES;
    static GLfloat scale = 1;
  modelViewMatrix =  GLKMatrix4Translate(modelViewMatrix, 0.0, spinY , 0);
    modelViewMatrix=GLKMatrix4Scale(modelViewMatrix, scale, scale, 0.7);
   
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

//{0,0,x1,y1,x2,y2}

-(void)calculate{
    m_count = 360*3;
    float  width = 0.5;
    _vertexArray =
    (GLfloat*)malloc(sizeof(GLfloat) * 2*m_count);
    for (int i=0; i<180; i++) {
        float m = M_PI*i/180.0;
        float n = M_PI*(i+1)/180.0;
        _vertexArray[6*i]=0;
        _vertexArray[6*i+1]=0;
        _vertexArray[6*i+2]=width*cosf(m);
        _vertexArray[6*i+3]=width*sinf(m);
        _vertexArray[6*i+4]=width*cosf(n);
        _vertexArray[6*i+5]=width*sinf(n);
        _vertexArray[360*3+6*i]=0;
        _vertexArray[360*3+6*i+1]=0;
        _vertexArray[360*3+6*i+2]=-width*cosf(m);
        _vertexArray[360*3+6*i+3]=-width*sinf(m);
        _vertexArray[360*3+6*i+4]=-width*cosf(n);
        _vertexArray[360*3+6*i+5]=-width*sinf(n);
    }
    _colorsArray = (GLfloat*)malloc(sizeof(GLfloat) * 4*m_count);
    
    for (int i=0; i<m_count; i++) {
        _colorsArray[4*i]=1.0;
        _colorsArray[4*i+1]=1.0;
        _colorsArray[4*i+2]=0.0;
        _colorsArray[4*i+3]=1.0;
        
    }
}
-(void)loadVertex{
    self.vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:(2 * sizeof(GLfloat)) numberOfVertices:m_count bytes:_vertexArray usage:GL_STATIC_DRAW];
    [self.vertexPositionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self shader];
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    [self.effect prepareToDraw];
    
    [self.vertexPositionBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:m_count];
    [self.vertexColorBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:m_count];

}

- (void)loadColorBuffer{

    self.vertexColorBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:(4 * sizeof(GLfloat)) numberOfVertices:m_count bytes:_colorsArray usage:GL_STATIC_DRAW];
    [self.vertexColorBuffer prepareToDrawWithAttrib:GLKVertexAttribColor numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
