//
//  Camera.m
//  OpenGL_ES_demo(12)_摄像头
//
//  Created by 温杰 on 2018/2/6.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "Camera.h"
#import "ShaderManager.h"
#import "FrameBufferManger.h"
#import "TextureManager.h"
#import "AGLKVertexAttribArrayBuffer.h"
// Uniform index.
enum
{
    UNIFORM_Y,
    UNIFORM_UV,
    UNIFORM_COLOR_CONVERSION_MATRIX,
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

@interface Camera()
{
    EAGLContext *_context;

    const GLfloat *_preferredConversion;

    CVOpenGLESTextureCacheRef _videoTextureCache;

}
@property (nonatomic ,strong) ShaderManager * shaderManager;
@property  (nonatomic ,strong) FrameBufferManger * bufferManger;
@property (nonatomic , assign) BOOL isFullYUVRange;
@property (nonatomic,strong)TextureManager * lumaTexture;
@property (nonatomic,strong)TextureManager * chromaTexture;
@property (nonatomic ,strong) AGLKVertexAttribArrayBuffer * vertexBuffer;
@property (nonatomic ,strong) AGLKVertexAttribArrayBuffer * vertexTextureBuffer;
@end


@implementation Camera
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         self.bufferManger = [[ FrameBufferManger alloc]init];
        self.lumaTexture = [[TextureManager alloc]init];
        self.lumaTexture.format = GL_LUMINANCE;
        
        self.chromaTexture = [[TextureManager alloc]init];
        self.chromaTexture.format = GL_LUMINANCE_ALPHA;
        self.chromaTexture.texture =GL_TEXTURE1;
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
        [self setupGL];
    }
    return self;
}


- (void)setupGL
{
    [EAGLContext setCurrentContext:_context];
    [self setupBuffers];
    [self loadShaders];
    
    glUseProgram(self.shaderManager.program);

    glUniform1i(uniforms[UNIFORM_Y], 0);
    glUniform1i(uniforms[UNIFORM_UV], 1);
    
    glUniformMatrix3fv(uniforms[UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_FALSE, _preferredConversion);
    
    // Create CVOpenGLESTextureCacheRef for optimal CVPixelBufferRef to GLES texture conversion.
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
   
    self.bufferManger.renderBufferStore = ^{
        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];

    };
    [self.bufferManger buildLayer];
}

- (BOOL)loadShaders{
    self.shaderManager = [[ShaderManager alloc]init];
    return [self.shaderManager CompileLinkSuccessShaderName:@"Shader" glBindAttribLocationBlock:^(GLuint program) {
        glBindAttribLocation(program, ATTRIB_VERTEX, "position");
        glBindAttribLocation(program, ATTRIB_TEXCOORD, "texCoord");
    } GetUniformLocationBlock:^(GLuint program) {
        // Get uniform locations.
        uniforms[UNIFORM_Y] = glGetUniformLocation(program, "SamplerY");
        uniforms[UNIFORM_UV] = glGetUniformLocation(program, "SamplerUV");
        uniforms[UNIFORM_COLOR_CONVERSION_MATRIX] = glGetUniformLocation(program, "colorConversionMatrix");
    }];
    
}


- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer{
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
        [self cleanUpTextures];
        
        self.lumaTexture.width = frameWidth;
        self.lumaTexture.height = frameHeight;
        self.lumaTexture.cache = _videoTextureCache;
        self.lumaTexture.pixelBuffer = pixelBuffer;
        [self.lumaTexture build];
        
        self.chromaTexture.width=frameWidth/2;
        self.chromaTexture.height=frameHeight/2;
        self.chromaTexture.planeIndex = 1;
        self.chromaTexture.pixelBuffer = pixelBuffer;
        self.chromaTexture.cache = _videoTextureCache;
        [self.chromaTexture build];
    }
    
    
    glClearColor(0.1f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGRect vertexSamplingRect = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(self.bufferManger.layerWidth(), self.bufferManger.layerHeight()), self.layer.bounds);
    
    CGSize normalizedSamplingSize = CGSizeMake(0.0, 0.0);
    CGSize cropScaleAmount = CGSizeMake(vertexSamplingRect.size.width/self.layer.bounds.size.width, vertexSamplingRect.size.height/self.layer.bounds.size.height);
    
    if (cropScaleAmount.width > cropScaleAmount.height) {
        normalizedSamplingSize.width = 1.0;
        normalizedSamplingSize.height = cropScaleAmount.height/cropScaleAmount.width;
    }
    else {
        normalizedSamplingSize.width = 1.0;
        normalizedSamplingSize.height = cropScaleAmount.width/cropScaleAmount.height;
    }
    
    GLfloat quadVertexData [] = {
        -1 * normalizedSamplingSize.width, -1 * normalizedSamplingSize.height,
        normalizedSamplingSize.width, -1 * normalizedSamplingSize.height,
        -1 * normalizedSamplingSize.width, normalizedSamplingSize.height,
        normalizedSamplingSize.width, normalizedSamplingSize.height,
    };
    
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*2 numberOfVertices:4 bytes:quadVertexData usage:GL_STATIC_DRAW];
    [self.vertexBuffer prepareToDrawWithAttrib:ATTRIB_VERTEX numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
    GLfloat quadTextureData[] =  { // 正常坐标
        0, 0,
        1, 0,
        0, 1,
        1, 1
    };
    self.vertexTextureBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*2 numberOfVertices:4 bytes:quadTextureData usage:GL_STATIC_DRAW];
    [self.vertexTextureBuffer prepareToDrawWithAttrib:ATTRIB_TEXCOORD numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
    
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLE_STRIP startVertexIndex:0 numberOfVertices:4];
    
    [self.bufferManger layerRender:^{
        if ([EAGLContext currentContext] == _context) {
            [_context presentRenderbuffer:GL_RENDERBUFFER];
        }
    }];
    
    
}
- (void)cleanUpTextures
{
    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}
    
    

@end
