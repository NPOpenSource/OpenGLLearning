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
    
     GLuint _textureBufferR;

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
    scale=0.5;
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale); //设置视口大小
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
}


static GLfloat vertex[8*2] = {
    1,1, 0,1, //1
    -1,1,1,1,//0
    -1,-1,1,0, //2
    1,-1,0,0//3
};




-(void) createVertexBufferAndColorBuffer{
    self.vertexsbuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*4 numberOfVertices:4 bytes:vertex usage:GL_STATIC_DRAW];
    [self.vertexsbuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
    [self.vertexsbuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:sizeof(GLfloat)*2 shouldEnable:YES];
    
    glUniform1i(_textureBufferR, 0); // 0 代表GL_TEXTURE0
    GLuint tex1;
    glActiveTexture(GL_TEXTURE0);
    glGenTextures(1, &tex1);
    glBindTexture(GL_TEXTURE_2D,  tex1);
    UIImage *image = [UIImage imageNamed:@"2.png"];
    GLubyte *imageData = [self getImageData:image];
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA , image.size.width, image.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    free(imageData);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    [self.vertexsbuffer drawArrayWithMode:GL_TRIANGLE_FAN startVertexIndex:0 numberOfVertices:4];

}
- (void*)getImageData:(UIImage*)image{
    CGImageRef imageRef = [image CGImage];
    size_t imageWidth = CGImageGetWidth(imageRef);
    size_t imageHeight = CGImageGetHeight(imageRef);
    GLubyte *imageData = (GLubyte *)malloc(imageWidth*imageHeight*4);
    memset(imageData, 0,imageWidth *imageHeight*4);
    CGContextRef imageContextRef = CGBitmapContextCreate(imageData, imageWidth, imageHeight, 8, imageWidth*4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(imageContextRef, 0, imageHeight);
    CGContextScaleCTM(imageContextRef, 1.0, -1.0);
    CGContextDrawImage(imageContextRef, CGRectMake(0.0, 0.0, (CGFloat)imageWidth, (CGFloat)imageHeight), imageRef);
    CGContextRelease(imageContextRef);
    return  imageData;
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
        glBindAttribLocation(program, GLKVertexAttribPosition, "position");
        glBindAttribLocation(program, GLKVertexAttribTexCoord0, "texCoord0");
    } GetUniformLocationBlock:^(GLuint program) {
        glGetUniformLocation(program, "sam2DR");
    }];
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    [self setupGL];
}


@end
