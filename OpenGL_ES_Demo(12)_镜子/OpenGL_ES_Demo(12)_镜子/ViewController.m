//
//  ViewController.m
//  OpenGL_ES_Demo(12)_镜子
//
//  Created by 温杰 on 2018/2/7.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "FrameBufferManger.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKElementIndexArrayBuffer.h"
@interface ViewController ()
{
    dispatch_source_t timer;

}
@property (nonatomic , strong) EAGLContext* mContext;
@property (nonatomic , strong) GLKBaseEffect* mEffect;
@property (nonatomic , strong) GLKBaseEffect* mMirrorEffect;

@property (nonatomic , assign) float mDegreeX;
@property (nonatomic , assign) float mDegreeY;
@property (nonatomic , assign) float mDegreeZ;

@property (nonatomic ,strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (nonatomic ,strong) AGLKElementIndexArrayBuffer * elementsBuffer;
@property (nonatomic ,strong) AGLKVertexAttribArrayBuffer * mirrorBuffer;
@property (nonatomic ,strong) FrameBufferManger * frameManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //新建OpenGLES 上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView* view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.mContext];
    glEnable(GL_DEPTH_TEST);
    
    [self render];
    
    
}

GLfloat attrArr[] =
{
    -0.5f, 0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       0.0f, 1.0f,//左上
    0.5f, 0.5f, 0.0f,       0.0f, 0.5f, 0.0f,       1.0f, 1.0f,//右上
    -0.5f, -0.5f, 0.0f,     0.5f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
    0.5f, -0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       1.0f, 0.0f,//右下
    0.0f, 0.0f, 1.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点
};
//顶点索引
GLuint indices[] =
{
    0, 3, 2,
    0, 1, 3,
    0, 2, 4,
    0, 4, 1,
    2, 3, 4,
    1, 4, 3,
};
GLfloat mirrorAttr[] =
{
    -1.0f, -1.0f, 1.0f,             1.0f, 1.0f,
    1.0f, -1.0f, 1.0f,              0.0f, 1.0f,
    -1.0f, -1.0f, -1.0f,             1.0f, 0.0f,
    1.0f, -1.0f, -1.0f,              0.0f, 0.0f,
};

-(void)render{
    
    self.mirrorBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*5 numberOfVertices:4 bytes:mirrorAttr usage:GL_STATIC_DRAW];
    
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat) *8 numberOfVertices:5 bytes:attrArr usage:GL_STATIC_DRAW];
    self.elementsBuffer = [[AGLKElementIndexArrayBuffer alloc]initWithAttribIndexCount:6*3 bytes:indices];

    
    //纹理
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"png"];
    
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    //着色器
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = textureInfo.name;
    
    self.mMirrorEffect = [[GLKBaseEffect alloc] init];
    self.mMirrorEffect.texture2d0.enabled = GL_TRUE;
    self.mMirrorEffect.texture2d0.name = textureInfo.name;
    
    //初始的投影
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1f, 10.f);
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f, 1.0f, 1.0f);
    self.mEffect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -4.0f);
    self.mEffect.transform.modelviewMatrix = modelViewMatrix;
    
    self.mMirrorEffect.transform.projectionMatrix = projectionMatrix;
    modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, 0.0f);
    self.mMirrorEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(0.0, 3.0, 2.0,
                                                                        0.0, 0.0, -1.0,
                                                                        0, 0, 1);
    //    self.mMirrorEffect.transform.modelviewMatrix = GLKMatrix4Translate(self.mMirrorEffect.transform.modelviewMatrix, 0, 0.5, 0);
    
    //定时器
    double delayInSeconds = 0.1;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC, 0.0);
    dispatch_source_set_event_handler(timer, ^{
        self.mDegreeX += 0.1  * 1;
        self.mDegreeY += 0.1 * 1;
        self.mDegreeZ += 0.1 * 1;
        
    });
    dispatch_resume(timer);
    
    
    int width, height;
    width = self.view.bounds.size.width * self.view.contentScaleFactor;
    height = self.view.bounds.size.height * self.view.contentScaleFactor;
        
    width = self.view.bounds.size.width * self.view.contentScaleFactor;
    height = self.view.bounds.size.height * self.view.contentScaleFactor;
    [self extraInitWithWidth:width height:height]; //特别注意这里的大小
}
- (void)extraInitWithWidth:(GLint)width height:(GLint)height {

    self.frameManager = [[FrameBufferManger alloc]init];
    self.frameManager.width = width;
    self.frameManager.height = height;
    [self.frameManager build];
}

- (void)renderFBO {
    
    [self.frameManager offScreenRender:^{
        glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
        [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribColor numberOfCoordinates:3 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES];
        [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*6 shouldEnable:YES];
        [self.mEffect prepareToDraw];
        [self.elementsBuffer prepareToDrawWithAttrib];
        [self.elementsBuffer drawElementIndexWithMode:GL_TRIANGLES];
        
    }];
        glBindTexture(GL_TEXTURE_2D, 0);
    
    //如果视口和主缓存的不同，需要根据当前的大小调整，同时在下面的绘制时需要调整glviewport
    //    glViewport(0, 0, const_length, const_length)
  
 
    
    self.mMirrorEffect.texture2d0.name = self.frameManager.textureId;
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self renderFBO];
    [((GLKView *) self.view) bindDrawable];
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.mirrorBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.mirrorBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES];
    glDisableVertexAttribArray(GLKVertexAttribColor);

    [self.mMirrorEffect prepareToDraw];
    
    [self.mirrorBuffer drawArrayWithMode:GL_TRIANGLE_STRIP startVertexIndex:0 numberOfVertices:4];

    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribColor numberOfCoordinates:3 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*6 shouldEnable:YES];
    
    [self.mEffect prepareToDraw];
    [self.elementsBuffer prepareToDrawWithAttrib];
    [self.elementsBuffer drawElementIndexWithMode:GL_TRIANGLES];
    
}

-(void)update{
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -4.0f);
    
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.mDegreeX);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, self.mDegreeY);
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, self.mDegreeZ);
    
    self.mEffect.transform.modelviewMatrix = modelViewMatrix;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
