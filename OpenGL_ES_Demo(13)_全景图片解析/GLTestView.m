//
//  GLTestView.m
//  OpenGL_ES_Demo(13)_全景图片解析
//
//  Created by 温杰 on 2018/2/7.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "GLTestView.h"
#import "OPenGLManger.h"
#import "sphere.h"

enum
{
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};

enum
{
    UNIFORM_TEXTURE,
    UNIFORM_PROJECTION_MARTRIX,
    UNIFORM_MODELVIEW_MARTRIX,
    UNIFORM_ROTATE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

@interface GLTestView()
{
    EAGLContext *_context;
    UILabel* horizontalLabel;
    float horizontalDegree;
    UILabel* verticalLabel;
    float verticalDegree;
}
@property (nonatomic ,strong) ShaderManager * shadermanager;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer * vertexBuffer;
@property (nonatomic ,strong) AGLKVertexAttribArrayBuffer * vertexTextureBuffer;
@property (nonatomic ,strong) FrameBufferManger * frameManager;
@property (nonatomic , strong) CADisplayLink *mDisplayLink;

@end

@implementation GLTestView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.mDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        self.mDisplayLink.frameInterval = 2; //FPS=30
        [[self mDisplayLink] addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[self mDisplayLink] setPaused:NO];
        
        [self setupView];
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],
                                          kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
        
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!_context || ![EAGLContext setCurrentContext:_context] || ![self loadShaders]) {
            return nil;
        }
        [EAGLContext setCurrentContext:_context];
        
        [self initVertex];
        [self frameBuffer];
        [self setShader];
        [self initImage];

        [self render];
        
    }
    return self;
}
///初始化顶点
-(void)initVertex{
    
    glDisable(GL_DEPTH_TEST);
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*3 numberOfVertices:sphereNumVerts bytes:sphereVerts usage:GL_STATIC_DRAW];
    self.vertexTextureBuffer=[[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*2 numberOfVertices:sphereNumVerts bytes:sphereTexCoords usage:GL_STATIC_DRAW];
}

-(void)initImage{
    //地球纹理
    [self setupTexture:@"Earth512x256.jpg"];
}

- (GLuint)setupTexture:(NSString *)fileName {
    // 1获取图片的CGImageRef
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2 读取图片的大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte)); //rgba共4个byte
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    // 4绑定纹理到默认的纹理ID（这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做）
    glBindTexture(GL_TEXTURE_2D, 0);
    
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    free(spriteData);
    return 0;
}

-(void)frameBuffer{
    self.frameManager = [[FrameBufferManger alloc]init];
    self.frameManager.renderBufferStore = ^{
        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        
    };
    [self.frameManager buildLayer];
}

- (BOOL)loadShaders{
    
    self.shadermanager =[[ShaderManager alloc]init];
    return  [self.shadermanager CompileLinkSuccessShaderName:@"Shader" glBindAttribLocationBlock:^(GLuint program) {
        glBindAttribLocation(program, ATTRIB_VERTEX, "position");
    } GetUniformLocationBlock:^(GLuint program) {
        uniforms[UNIFORM_TEXTURE] =glGetUniformLocation(program, "Sampler");
        uniforms[UNIFORM_ROTATE] = glGetUniformLocation(program, "preferredRotation");
        uniforms[UNIFORM_PROJECTION_MARTRIX] = glGetUniformLocation(program, "projectionMatrix");
        uniforms[UNIFORM_MODELVIEW_MARTRIX] = glGetUniformLocation(program, "modelViewMatrix");
    }];

}

-(void)setShader{
    glUseProgram(self.shadermanager.program);
    glUniform1f(uniforms[UNIFORM_ROTATE], GLKMathDegreesToRadians(180));
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(90, CGRectGetWidth(self.bounds) * 1.0 / CGRectGetHeight(self.bounds), 0.01, 10);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeLookAt(0, 0, 0,
                                                      1, 0, 0,
                                                      0, 1, 0);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    glUniformMatrix4fv(uniforms[UNIFORM_PROJECTION_MARTRIX], 1, GL_FALSE, projectionMatrix.m);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MARTRIX], 1, GL_FALSE, modelViewMatrix.m);
}

-(void)render{
   

    glClearColor(0.1f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(self.shadermanager.program);
    
    // 更新顶点数据
    [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_VERTEX numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    
    [self.vertexTextureBuffer prepareToDrawWithAttrib:ATTRIB_TEXCOORD numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
    
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];
    
    [self.frameManager layerRender:^{
        
        if ([EAGLContext currentContext] == _context) {
            [_context presentRenderbuffer:GL_RENDERBUFFER];
        }
    }];
}

#define LY_ROTATE YES
- (void)setupView{
    horizontalLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 200, 50)];
    [self addSubview:horizontalLabel];
    horizontalLabel.textColor = [UIColor redColor];
    verticalLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, 200, 50)];
    [self addSubview:verticalLabel];
    verticalLabel.textColor = [UIColor redColor];
    
    if (LY_ROTATE) {
        horizontalDegree = 0.0;
        verticalDegree = M_PI_2;
        horizontalLabel.text = [NSString stringWithFormat:@"绕X轴旋转角度为%.2f", GLKMathRadiansToDegrees(horizontalDegree)];
        verticalLabel.text = [NSString stringWithFormat:@"绕Y轴旋转角度为%.2f", GLKMathRadiansToDegrees(verticalDegree)];
    }
    else {
        horizontalDegree = M_PI_2;
        verticalDegree = 0.0;
        horizontalLabel.text = [NSString stringWithFormat:@"偏航角为%.2f", GLKMathRadiansToDegrees(horizontalDegree)];
        verticalLabel.text = [NSString stringWithFormat:@"高度角为%.2f", GLKMathRadiansToDegrees(verticalDegree)];
    }
}


- (void)roatateWithX:(float)x Y:(float)y {
    horizontalDegree -= x / 100;
    verticalDegree += y / 100;
    
    horizontalLabel.text = [NSString stringWithFormat:@"绕X轴旋转角度为%.2f", GLKMathRadiansToDegrees(horizontalDegree)];
    verticalLabel.text = [NSString stringWithFormat:@"绕Y轴旋转角度为%.2f", GLKMathRadiansToDegrees(verticalDegree)];
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, horizontalDegree);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, verticalDegree);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MARTRIX], 1, GL_FALSE, modelViewMatrix.m);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPoint prePoint = [touch previousLocationInView:self];
    if (LY_ROTATE) {
        [self roatateWithX:point.y - prePoint.y Y:point.x - prePoint.x];
    }
    else {
        [self changeModelViewWithHorizontal:point.x - prePoint.x Vertical:point.y - prePoint.y];
    }
}
- (void)changeModelViewWithHorizontal:(float)h Vertical:(float)v {
    horizontalDegree -= h / 100;
    verticalDegree -= v / 100;
    
    horizontalLabel.text = [NSString stringWithFormat:@"偏航角为%.2f", GLKMathRadiansToDegrees(horizontalDegree)];
    verticalLabel.text = [NSString stringWithFormat:@"高度角为%.2f", GLKMathRadiansToDegrees(verticalDegree)];
    
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeLookAt(0, 0, 0,
                                                      sin(horizontalDegree) * cos(verticalDegree),
                                                      sin(horizontalDegree) * sin(verticalDegree),
                                                      cos(horizontalDegree),
                                                      0, 1, 0);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MARTRIX], 1, GL_FALSE, modelViewMatrix.m);
}
- (void)displayLinkCallback:(CADisplayLink *)sender
{
    [self render];
}



@end
