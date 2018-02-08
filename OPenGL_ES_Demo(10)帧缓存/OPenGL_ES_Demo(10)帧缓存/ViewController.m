//
//  ViewController.m
//  OPenGL_ES_Demo(10)帧缓存
//
//  Created by 温杰 on 2018/2/2.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "FrameBufferManger.h"
#import "FrameBufferManger.h"
@interface ViewController ()
@property (nonatomic , strong) EAGLContext* mContext;
@property (nonatomic , assign) GLint mDefaultFBO;
@property (nonatomic , assign) GLuint mExtraFBO;
@property (nonatomic , strong) GLKBaseEffect* mBaseEffect;
@property (nonatomic , strong) GLKBaseEffect* mExtraEffect;
@property (nonatomic ,strong) AGLKVertexAttribArrayBuffer * angleVertex;
@property (nonatomic ,strong) AGLKVertexAttribArrayBuffer * cubeVertex;
@property (nonatomic ,strong)FrameBufferManger * frameBuffer;
@end




@implementation ViewController

-(void)config{
    //新建OpenGLES 上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView* view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.mContext];
    
}

//MVP矩阵
- (void)preparePointOfViewWithAspectRatio:(GLfloat)aspectRatio
{
    self.mBaseEffect.transform.projectionMatrix =
    GLKMatrix4MakePerspective(
                              GLKMathDegreesToRadians(85.0f),
                              aspectRatio,
                              0.1f,
                              20.0f);
    self.mExtraEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-1, 1, -1, 1, 0.1, 20.0);

    self.mExtraEffect.transform.modelviewMatrix =
    GLKMatrix4MakeLookAt(
                         0.0, 0.0, 3.0,   // Eye position
                         0.0, 0.0, 0.0,   // Look-at position
                         0.0, 1.0, 0.0);  // Up direction
    self.mBaseEffect.transform.modelviewMatrix =
    GLKMatrix4MakeLookAt(
                         0.0, 0.0, 3.0,   // Eye position
                         0.0, 0.0, 0.0,   // Look-at position
                         0.0, 1.0, 0.0);  // Up direction
}
static GLfloat  angleVertexs[]={
    -1,-1,1,0,0,1,1,
    -1,1,0,1,0,1,0,
    1,1,0,0,1,0,0
};

static GLfloat cubeVertexs[]={
    -1,-1,1,0,0,0,0,
    -1,1,1,0,0,1,0,
    1,1,1,0,0,1,1,
    1,-1,1,0,0,0,1
};
- (void)viewDidLoad {
    [super viewDidLoad];
    [self config];


    

    
    self.mBaseEffect = [[GLKBaseEffect alloc] init];
    self.mExtraEffect = [[GLKBaseEffect alloc] init];
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"png"];
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];

    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    self.mBaseEffect.texture2d0.enabled= self.mExtraEffect.texture2d0.enabled = GL_TRUE;
    self.mBaseEffect.texture2d0.name =  self.mExtraEffect.texture2d0.name =  textureInfo.name;
    

    ///开启深度
    glEnable(GL_DEPTH_TEST);
    [self preparePointOfViewWithAspectRatio:
     CGRectGetWidth(self.view.bounds) / CGRectGetHeight(self.view.bounds)];
    int width, height;
    width = self.view.bounds.size.width * self.view.contentScaleFactor;
    height = self.view.bounds.size.height * self.view.contentScaleFactor;
    [self extraInitWithWidth:width height:height];
    
}

- (void)extraInitWithWidth:(GLint)width height:(GLint)height {
    /// 系统的缓存
    FrameBufferManger * buffer = [[FrameBufferManger alloc]init];
    self.frameBuffer = buffer;
    buffer.width = width;
    buffer.height = height;
    [buffer build];
    
}
-(void)update{
    return;
    static int m = 0;
    GLKMatrix4 modelViewMatrix;

        m+= 2;
        modelViewMatrix = GLKMatrix4Identity;
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, -3);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(m), 1, 1, 1);
        self.mBaseEffect.transform.modelviewMatrix = modelViewMatrix;
    modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, -3);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(m/2), 1, 1, 1);
    self.mExtraEffect.transform.modelviewMatrix = modelViewMatrix;

}


- (void)renderFBO {

    [self.frameBuffer offScreenRender:^{
        glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        self.angleVertex = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*7 numberOfVertices:3 bytes:angleVertexs usage:GL_STATIC_DRAW];
        [self.angleVertex prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
        
        [self.angleVertex prepareToDrawWithAttrib:GLKVertexAttribColor numberOfCoordinates:3 attribOffset:sizeof(GLfloat)*2 shouldEnable:YES];
        [self.angleVertex prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*5 shouldEnable:YES];
        [self.mExtraEffect prepareToDraw];
        
        [self.angleVertex drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:3];
    }];
    

    
    self.mBaseEffect.texture2d0.name = self.frameBuffer.textureId;
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self renderFBO];


    [((GLKView *) self.view) bindDrawable];
    
    glClearColor(1.0, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    self.cubeVertex = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*7 numberOfVertices:4 bytes:cubeVertexs usage:GL_STATIC_DRAW];
    [self.cubeVertex prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
    
    [self.cubeVertex prepareToDrawWithAttrib:GLKVertexAttribColor numberOfCoordinates:3 attribOffset:sizeof(GLfloat)*2 shouldEnable:YES];
    [self.cubeVertex prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*5 shouldEnable:YES];
    [self.mBaseEffect prepareToDraw];

    [self.cubeVertex drawArrayWithMode:GL_TRIANGLE_FAN startVertexIndex:0 numberOfVertices:4];

}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
