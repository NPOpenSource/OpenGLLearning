//
//  ViewController.m
//  OpenGL_ES_demo(9)_地球月亮太阳
//
//  Created by 温杰 on 2018/1/31.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "ShaderManager.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "sphere.h"

@interface ViewController ()
@property (nonatomic ,strong) EAGLContext * eagcontext;
@property (nonatomic ,assign) GLuint  program;

@property (nonatomic ,strong) GLKBaseEffect * baseEffect;

@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;
@property (nonatomic) GLKMatrixStackRef modelviewMatrixStack;
@property (strong, nonatomic) GLKTextureInfo *earthTextureInfo;
@property (strong, nonatomic) GLKTextureInfo *moonTextureInfo;
@property (strong, nonatomic) GLKTextureInfo *sunTextureInfo;

@end

@implementation ViewController
-(void)createEagContext{
    self.eagcontext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.eagcontext];
    glEnable(GL_DEPTH_TEST);

}

-(void)configure{
    GLKView *view = (GLKView*)self.view;
    view.context = self.eagcontext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
}

-(void)createShader{
//    [ShaderManager CompileLinkSuccessProgram:&_program shaderName:@"Shader" glBindAttribLocationBlock:^(GLuint program) {
//        glBindAttribLocation(program, 0, "position");  // 0代表枚举位置
//    } GetUniformLocationBlock:^(GLuint program) {
//        _vertexcolor =  glGetUniformLocation(program, "color");
//    }];
}

//太阳光
- (void)configureLight
{
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(
                                                         1.0f, // Red
                                                         1.0f, //
                                                         1.0f, // Blue
                                                         1.0f);//
    ///光源位置
    self.baseEffect.light0.position = GLKVector4Make(
                                                     1.0f,
                                                     0.0f,
                                                     1.0f,
                                                     0.0f);
    
    self.baseEffect.light0.ambientColor = GLKVector4Make(
                                                         0.0f, // Red
                                                         1.0f, // Green
                                                         0.0f, // Blue
                                                         1.0f);// Alpha
    GLfloat   aspectRatio =
    (self.view.bounds.size.width) /
    (self.view.bounds.size.height);
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), aspectRatio, 1, 10);//    self.baseEffect.transform.projectionMatrix =
//    GLKMatrix4MakeOrtho(
//                        -1.0 * aspectRatio,
//                        1.0 * aspectRatio,
//                        -1.0,
//                        1.0,
//                        1.0,
//                        120.0);
//
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0);
    
}
- (void)bufferData{
    self.modelviewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    
    //顶点数据缓存
    self.vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                 initWithAttribStride:(3 * sizeof(GLfloat))
                                 numberOfVertices:sizeof(sphereVerts) / (3 * sizeof(GLfloat))
                                 bytes:sphereVerts
                                 usage:GL_STATIC_DRAW];
    self.vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                               initWithAttribStride:(3 * sizeof(GLfloat))
                               numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat))
                               bytes:sphereNormals
                               usage:GL_STATIC_DRAW];
    self.vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                     initWithAttribStride:(2 * sizeof(GLfloat))
                                     numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat))
                                     bytes:sphereTexCoords
                                     usage:GL_STATIC_DRAW];
    
    
    //地球纹理
    CGImageRef earthImageRef =
    [[UIImage imageNamed:@"Earth512x256.jpg"] CGImage];
    
    self.earthTextureInfo = [GLKTextureLoader
                             textureWithCGImage:earthImageRef
                             options:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithBool:YES],
                                      GLKTextureLoaderOriginBottomLeft, nil]
                             error:NULL];
    
    //月球纹理
    CGImageRef moonImageRef =
    [[UIImage imageNamed:@"Moon256x128.png"] CGImage];
    
    self.moonTextureInfo = [GLKTextureLoader
                            textureWithCGImage:moonImageRef
                            options:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:YES],
                                     GLKTextureLoaderOriginBottomLeft, nil]
                            error:NULL];
    CGImageRef sunref =
    [[UIImage imageNamed:@"sun.png"] CGImage];
    
    self.sunTextureInfo = [GLKTextureLoader
                            textureWithCGImage:sunref
                            options:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:YES],
                                     GLKTextureLoaderOriginBottomLeft, nil]
                            error:NULL];
    //矩阵堆
    GLKMatrixStackLoadMatrix4(
                              self.modelviewMatrixStack,
                              self.baseEffect.transform.modelviewMatrix);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createEagContext];
    [self configure];
    [self configureLight];
    [self bufferData];

}


-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    // 清除颜色缓冲区
    glClearColor(1, 1, 1, 1);
    glClear(GL_DEPTH_BUFFER_BIT|GL_COLOR_BUFFER_BIT);
    
    [self.vertexPositionBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [self.vertexNormalBuffer
     prepareToDrawWithAttrib:GLKVertexAttribNormal
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [self.vertexTextureCoordBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
     numberOfCoordinates:2
     attribOffset:0
     shouldEnable:YES];
    
    [self drawSun];
    [self drawEarth];
    [self drawMoon];

}



-(void)drawSun{
    static GLfloat angle=0;
    angle++;
    self.baseEffect.texture2d0.name = self.sunTextureInfo.name;
    self.baseEffect.texture2d0.target = self.sunTextureInfo.target;
    self.baseEffect.light0.ambientColor = GLKVector4Make(
                                                         0.0f, // Red
                                                         0.0f, // Green
                                                         1.0f, // Blue
                                                         1.0f);//
    GLKMatrixStackPush(self.modelviewMatrixStack);
    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         angle*M_PI/180,
                         0.0, 1.0, 0.0);
    GLKMatrixStackScale(self.modelviewMatrixStack, 0.4, 0.4, .4);
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    [self.baseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:sphereNumVerts];
    GLKMatrixStackPop(self.modelviewMatrixStack);
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    self.baseEffect.light0.ambientColor = GLKVector4Make(
                                                         0.0f, // Red
                                                         1.0f, // Green
                                                         0.0f, // Blue
                                                         1.0f);//
}

static GLfloat angleY= 0;
static GLfloat banjign=1;
- (void)drawMoon
{
    static GLfloat moonAngleY=0;
    static GLfloat moonAngleYZ=0;
    moonAngleY+=20;
    moonAngleYZ+=2;
    self.baseEffect.texture2d0.name = self.moonTextureInfo.name;
    self.baseEffect.texture2d0.target = self.moonTextureInfo.target;
    self.baseEffect.light0.ambientColor = GLKVector4Make(
                                                         1.0f, // Red
                                                         0.0f, // Green
                                                         0.0f, // Blue
                                                         1.0f);//
    GLKMatrixStackPush(self.modelviewMatrixStack);
    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         angleY*M_PI/180,
                         0.0, 1.0, 0.0);
    GLKMatrixStackTranslate(self.modelviewMatrixStack, banjign, 0, 0);
    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         moonAngleY*M_PI/180,
                         0.0, 1.0, 0.0);
    GLKMatrixStackTranslate(self.modelviewMatrixStack, .3, 0, 0);
    
    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         moonAngleYZ*M_PI/180, 0.0,1.0, 0.0);
    GLKMatrixStackScale(self.modelviewMatrixStack, 0.1, 0.1, 0.1);

    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    
    [self.baseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:sphereNumVerts];
    
    GLKMatrixStackPop(self.modelviewMatrixStack);
    
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    self.baseEffect.light0.ambientColor = GLKVector4Make(
                                                         0.0f, // Red
                                                         1.0f, // Green
                                                         0.0f, // Blue
                                                         1.0f);//
}


- (void)drawEarth
{

    static GLfloat angleYG=0;
    angleY++;
    angleYG+=2;
    self.baseEffect.texture2d0.name = self.earthTextureInfo.name;
    self.baseEffect.texture2d0.target = self.earthTextureInfo.target;
    GLKMatrixStackPush(self.modelviewMatrixStack);
    
    ///坐标轴 旋转
    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         angleY*M_PI/180,
                         0.0, 1.0, 0.0);
    ///移动 到指定点
    GLKMatrixStackTranslate(self.modelviewMatrixStack, banjign, 0, 0);
    
    ///再旋转
    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         angleYG*M_PI/180, 0.0,1.0, 0.0);
    GLKMatrixStackScale(self.modelviewMatrixStack, 0.2, 0.2, .2);

    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    self.baseEffect.light0.ambientColor = GLKVector4Make(
                                                         1.0f, // Red
                                                         1.0f, // Green
                                                         0.0f, // Blue
                                                         1.0f);//
    [self.baseEffect prepareToDraw];
    
    
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:sphereNumVerts];
    
    GLKMatrixStackPop(self.modelviewMatrixStack);

    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    self.baseEffect.light0.ambientColor = GLKVector4Make(
                                                         0.0f, // Red
                                                         1.0f, // Green
                                                         0.0f, // Blue
                                                         1.0f);//
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
