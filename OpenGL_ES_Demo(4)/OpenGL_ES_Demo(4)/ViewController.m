//
//  ViewController.m
//  OpenGL_ES_Demo(4)
//
//  Created by 温杰 on 2018/1/30.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "os_cube.h"

@interface ViewController ()
{
    float _rotation;

}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (nonatomic ,strong) AGLKVertexAttribArrayBuffer * vertexBuffer;
@property (nonatomic ,strong) AGLKVertexAttribArrayBuffer * vertexNormalBuffer;

@end

@implementation ViewController

// MARK: - 配置
-(void) configure{
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
}
// MARK: - 第一步: 创建一个EAGLContext

-(void)createEAGContext{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"手机不支持opengl es2");
    }
    
    [EAGLContext setCurrentContext:self.context]; // 设置为当前上下文
    
}

// MARK: - 第二步: 创建GLKBaseEffect 对象
-(void)createBaseEffect{
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(0.5f, 0.1f, 0.4f, 1.0f);
}
// MARK: - 第三步:
- (void)addVertexAndNormal{
    glEnable(GL_DEPTH_TEST); // 开启深度测试 让被挡住的像素隐藏
    

    self.vertexBuffer=[[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*6 numberOfVertices:36 bytes:gCubeVertexData usage:GL_STATIC_DRAW];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    // 开启绘制命令 GLKVertexAttribPosition(位置)
    // 开启绘制命令 GLKVertexAttribPosition(法线)
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createEAGContext];
    [self configure];
    [self createBaseEffect];
    [self addVertexAndNormal];
    // Do any additional setup after loading the view, typically from a nib.
}

// MARK: - 第四步: 清屏
- (void)clearScreen{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}
// MARK: - 第五步: 绘制
- (void)draw{
    [self.effect prepareToDraw];
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:36];
    [self.vertexNormalBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:36];
 }

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self clearScreen];
    [self draw];
}



- (void)changeMoveTrack{
    // 获取一个屏幕比例值
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    
    //  GLKMatrix4MakePerspective(float fovyRadians, float aspect, float nearZ, float farZ)
    /*
     * 透视转换
     */
//    GLKMatrix4 projectionMatrix=    GLKMatrix4MakeFrustum(-1.0, 1.0, -1.0, 1.0, 10, 100);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -10.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    // 计算自身的坐标和旋转状态
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)update
{
    [self changeMoveTrack]; // 7.移动
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
