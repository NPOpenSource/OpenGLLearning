//
//  VideoView.m
//  OpenGL_ES_Demo(12)_全景视频播放
//
//  Created by 温杰 on 2018/2/7.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "VideoView.h"
#import "OPenGLManger.h"
#import "sphere.h"
// Uniform index.
enum
{
    UNIFORM_Y,
    UNIFORM_UV,
    UNIFORM_COLOR_CONVERSION_MATRIX,
    UNIFORM_PROJECTION_MARTRIX,
    UNIFORM_MODELVIEW_MARTRIX,
    UNIFORM_ROTATE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};

// Color Conversion Constants (YUV to RGB) including adjustment from 16-235/16-240 (video range)

// BT.601, which is the standard for SDTV.
static const GLfloat kColorConversion601[] = {
    1.164,  1.164, 1.164,
    0.0, -0.392, 2.017,
    1.596, -0.813,   0.0,
};

// BT.709, which is the standard for HDTV.
static const GLfloat kColorConversion709[] = {
    1.164,  1.164, 1.164,
    0.0, -0.213, 2.112,
    1.793, -0.533,   0.0,
};

// BT.601 full range (ref: http://www.equasys.de/colorconversion.html)
const GLfloat kColorConversion601FullRange[] = {
    1.0,    1.0,    1.0,
    0.0,    -0.343, 1.765,
    1.4,    -0.711, 0.0,
};


@interface VideoView()
{
    EAGLContext *_context;
    CVOpenGLESTextureCacheRef _videoTextureCache;
    const GLfloat *_preferredConversion;
    
    UILabel* horizontalLabel;
    float horizontalDegree;
    UILabel* verticalLabel;
    float verticalDegree;
}
@property (nonatomic ,assign) BOOL isFullYUVRange;
@property (nonatomic ,strong) ShaderManager * shadermanager;
@property (nonatomic ,strong) FrameBufferManger * frameManager;
@property (nonatomic ,strong)TextureManager *lumaManager;
@property (nonatomic ,strong) TextureManager * chomaManager;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer * vertexBuffer;
@property (nonatomic ,strong) AGLKVertexAttribArrayBuffer * vertexTextureBuffer;
@end

@implementation VideoView



+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lumaManager = [[TextureManager alloc]init];
        self.lumaManager.format = GL_LUMINANCE;
        
        self.chomaManager = [[TextureManager alloc]init];
        self.chomaManager.texture = GL_TEXTURE1;
        self.chomaManager.format = GL_LUMINANCE_ALPHA;
        self.chomaManager.planeIndex = 1;
        
        self.isFullYUVRange = YES;
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],
                                          kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
        
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!_context || ![EAGLContext setCurrentContext:_context] || ![self loadShaders]) {
            return nil;
        }
        
        _preferredConversion = kColorConversion709;
          [self setupView];
        [self setupGL];
    }
    return self;
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

- (BOOL)loadShaders{
    self.shadermanager =[[ShaderManager alloc]init];
   return  [self.shadermanager CompileLinkSuccessShaderName:@"Shader" glBindAttribLocationBlock:^(GLuint program) {
        glBindAttribLocation(program, ATTRIB_VERTEX, "position");
        glBindAttribLocation(program, ATTRIB_TEXCOORD, "texCoord");
    } GetUniformLocationBlock:^(GLuint program) {
        uniforms[UNIFORM_Y] = glGetUniformLocation(program, "SamplerY");
        uniforms[UNIFORM_UV] = glGetUniformLocation(program, "SamplerUV");
        uniforms[UNIFORM_ROTATE] = glGetUniformLocation(program, "preferredRotation");
        uniforms[UNIFORM_COLOR_CONVERSION_MATRIX] = glGetUniformLocation(program, "colorConversionMatrix");
        uniforms[UNIFORM_PROJECTION_MARTRIX] = glGetUniformLocation(program, "projectionMatrix");
        uniforms[UNIFORM_MODELVIEW_MARTRIX] = glGetUniformLocation(program, "modelViewMatrix");
        
    }];
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:_context];
    [self setupBuffers];
    [self loadShaders];
    
    glUseProgram(self.shadermanager.program);
    
    glUniform1i(uniforms[UNIFORM_Y], 0);
    glUniform1i(uniforms[UNIFORM_UV], 1);
    glUniform1f(uniforms[UNIFORM_ROTATE], GLKMathDegreesToRadians(180));
    
    glUniformMatrix3fv(uniforms[UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_FALSE, _preferredConversion);
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(90, CGRectGetWidth(self.bounds) * 1.0 / CGRectGetHeight(self.bounds), 0.01, 10);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeLookAt(0, 0, 0,
                                                      1, 0, 0,
                                                      0, 1, 0);
    
    glUniformMatrix4fv(uniforms[UNIFORM_PROJECTION_MARTRIX], 1, GL_FALSE, projectionMatrix.m);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MARTRIX], 1, GL_FALSE, modelViewMatrix.m);
    
    
    if (!_videoTextureCache) {
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_videoTextureCache);
        if (err != noErr) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
            return;
        }
    }
}

-(void)setupBuffers{
    glDisable(GL_DEPTH_TEST);
    
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*3 numberOfVertices:sphereNumVerts bytes:sphereVerts usage:GL_STATIC_DRAW];
    
    self.vertexTextureBuffer=[[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*2 numberOfVertices:sphereNumVerts bytes:sphereTexCoords  usage:GL_STATIC_DRAW];
    

    
    
    self.frameManager = [[FrameBufferManger alloc]init];
    self.frameManager.renderBufferStore = ^{
        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];

    };
    [self.frameManager buildLayer];
}
- (void)cleanUpTextures
{
    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    CVReturn err;
    if (pixelBuffer != NULL) {
        int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
        int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
        
        if (!_videoTextureCache) {
            NSLog(@"No video texture cache");
            return;
        }
        if ([EAGLContext currentContext] != _context) {
            [EAGLContext setCurrentContext:_context]; // 非常重要的一行代码
        }
        [self cleanUpTextures];
        CFTypeRef colorAttachments = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
        
        if (colorAttachments == kCVImageBufferYCbCrMatrix_ITU_R_601_4) {
            if (self.isFullYUVRange) {
                _preferredConversion = kColorConversion601FullRange;
            }
            else {
                _preferredConversion = kColorConversion601;
            }
        }
        else {
            _preferredConversion = kColorConversion709;
        }
        
        self.lumaManager.cache = _videoTextureCache;
        self.lumaManager.pixelBuffer = pixelBuffer;
        self.lumaManager.width = frameWidth;
        self.lumaManager.height = frameHeight;
        [self.lumaManager build];
        self.chomaManager.cache = _videoTextureCache;
        self.chomaManager.pixelBuffer = pixelBuffer;
        self.chomaManager.width = frameWidth/2;
        self.chomaManager.height = frameHeight/2;
        [self.chomaManager build];
        
    }
    glClearColor(0.1f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(self.shadermanager.program);
    glUniformMatrix3fv(uniforms[UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_FALSE, _preferredConversion);
    
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

///怎么将贴图贴到球上
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
