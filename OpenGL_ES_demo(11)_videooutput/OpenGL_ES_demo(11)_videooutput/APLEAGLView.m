/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This class contains an UIView backed by a CAEAGLLayer. It handles rendering input textures to the view. The object loads, compiles and links the fragment and vertex shader to be used during rendering.
 */

#import "APLEAGLView.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVUtilities.h>
#import <mach/mach_time.h>
#import "FrameBufferManger.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "ShaderManager.h"
#import "TextureManager.h"

// Uniform index.
enum
{
	UNIFORM_Y,
	UNIFORM_UV,
	UNIFORM_LUMA_THRESHOLD,
	UNIFORM_CHROMA_THRESHOLD,
	UNIFORM_ROTATION_ANGLE,
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

@interface APLEAGLView ()
{
	// The pixel dimensions of the CAEAGLLayer.
	GLint _backingWidth;
	GLint _backingHeight;

	EAGLContext *_context;
	CVOpenGLESTextureRef _lumaTexture;
	CVOpenGLESTextureRef _chromaTexture;
	CVOpenGLESTextureCacheRef _videoTextureCache;
	
	GLuint _frameBufferHandle;
	GLuint _colorBufferHandle;
	
	const GLfloat *_preferredConversion;
}
@property (nonatomic ,strong) ShaderManager * shaderManager;
@property (nonatomic ,strong) AGLKVertexAttribArrayBuffer * vertexBuffer;
@property (nonatomic ,strong) AGLKVertexAttribArrayBuffer * vertexTextureBuffer;
@property (nonatomic ,strong)TextureManager * textureLuma;
@property (nonatomic ,strong) TextureManager * textureChroma;
@property (nonatomic ,strong) FrameBufferManger * frameBuffer;
- (void)setupBuffers;
- (void)cleanUpTextures;

- (BOOL)loadShaders;


@end

@implementation APLEAGLView

+ (Class)layerClass
{
	return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frameBuffer = [[FrameBufferManger alloc]init];
        self.textureLuma = [[TextureManager alloc]init];
        self.textureChroma = [[TextureManager alloc]init];
        self.textureChroma.texture = GL_TEXTURE1;
        self.textureChroma.format =GL_RG_EXT;
        self.lumaThreshold = 1.0;
        self.chromaThreshold = 1.0;
        self.presentationRect = CGSizeMake(1242, 2208);
        // Use 2x scale factor on Retina displays.
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        
        // Get and configure the layer.
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],
                                          kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
        
        // Set the context into which the frames will be drawn.
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!_context || ![EAGLContext setCurrentContext:_context] || ![self loadShaders]) {
            return nil;
        }
        
        // Set the default conversion to BT.709, which is the standard for HDTV.
        _preferredConversion = kColorConversion709;
        
        [self setupGL];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		// Use 2x scale factor on Retina displays.
		self.contentScaleFactor = [[UIScreen mainScreen] scale];

		// Get and configure the layer.
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

		eaglLayer.opaque = TRUE;
		eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],
										  kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};

		// Set the context into which the frames will be drawn.
		_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

		if (!_context || ![EAGLContext setCurrentContext:_context] || ![self loadShaders]) {
			return nil;
		}
		
		// Set the default conversion to BT.709, which is the standard for HDTV.
		_preferredConversion = kColorConversion709;
	}
	return self;
}

# pragma mark - OpenGL setup

- (void)setupGL
{
	[EAGLContext setCurrentContext:_context];
	[self setupBuffers];
	[self loadShaders];
	
	glUseProgram(self.shaderManager.program);
	
	// 0 and 1 are the texture IDs of _lumaTexture and _chromaTexture respectively.
	glUniform1i(uniforms[UNIFORM_Y], 0);
	glUniform1i(uniforms[UNIFORM_UV], 1);
	glUniform1f(uniforms[UNIFORM_LUMA_THRESHOLD], self.lumaThreshold);
	glUniform1f(uniforms[UNIFORM_CHROMA_THRESHOLD], self.chromaThreshold);
	glUniform1f(uniforms[UNIFORM_ROTATION_ANGLE], self.preferredRotation);
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

#pragma mark - Utilities

- (void)setupBuffers
{
    ///深度关闭
	glDisable(GL_DEPTH_TEST);

    self.frameBuffer.renderBufferStore = ^{
        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    };
    [self.frameBuffer buildLayer];
	///FBO
//    glGenFramebuffers(1, &_frameBufferHandle);
//    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
//
//    glGenRenderbuffers(1, &_colorBufferHandle);
//    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
//
//
//    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
//    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
//
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBufferHandle);
//
//    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
//        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
//    }
}

- (void)cleanUpTextures
{
	if (_lumaTexture) {
		CFRelease(_lumaTexture);
		_lumaTexture = NULL;
	}
	
	if (_chromaTexture) {
		CFRelease(_chromaTexture);
		_chromaTexture = NULL;
	}
	
	// Periodic texture cache flush every frame
	CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

- (void)dealloc
{
	[self cleanUpTextures];
	
	if(_videoTextureCache) {
		CFRelease(_videoTextureCache);
	}
}

#pragma mark - OpenGLES drawing

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    ///真正的绘制image
	if (pixelBuffer != NULL) {
		int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
		int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
		if (!_videoTextureCache) {
			NSLog(@"No video texture cache");
			return;
		}
		[self cleanUpTextures];
		CFTypeRef colorAttachments = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
		
		if (colorAttachments == kCVImageBufferYCbCrMatrix_ITU_R_601_4) {
			_preferredConversion = kColorConversion601;
		}
		else {
			_preferredConversion = kColorConversion709;
		}
        
        self.textureLuma.width =frameWidth;
        self.textureLuma.height =frameHeight;
        self.textureLuma.cache = _videoTextureCache;
        self.textureLuma.pixelBuffer = pixelBuffer;
        [self.textureLuma  build];

        self.textureChroma.width =frameWidth/2;
        self.textureChroma.height =frameHeight/2;
        self.textureChroma.cache = _videoTextureCache;
        self.textureChroma.pixelBuffer = pixelBuffer;
        self.textureChroma.planeIndex = 1;
        [self.textureChroma  build];
	
	}

        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        // Use shader program.
        glUseProgram(self.shaderManager.program);
        glUniform1f(uniforms[UNIFORM_LUMA_THRESHOLD], self.lumaThreshold);
        glUniform1f(uniforms[UNIFORM_CHROMA_THRESHOLD], self.chromaThreshold);
        glUniform1f(uniforms[UNIFORM_ROTATION_ANGLE], self.preferredRotation);
        glUniformMatrix3fv(uniforms[UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_FALSE, _preferredConversion);
        
        // Set up the quad vertices with respect to the orientation and aspect ratio of the video.
        CGRect vertexSamplingRect = AVMakeRectWithAspectRatioInsideRect(self.presentationRect, self.layer.bounds);
        
        // Compute normalized quad coordinates to draw the frame into.
        CGSize normalizedSamplingSize = CGSizeMake(0.0, 0.0);
        CGSize cropScaleAmount = CGSizeMake(vertexSamplingRect.size.width/self.layer.bounds.size.width, vertexSamplingRect.size.height/self.layer.bounds.size.height);
        
        // Normalize the quad vertices.
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
        
        CGRect textureSamplingRect = CGRectMake(0, 0, 1, 1);
        GLfloat quadTextureData[] =  {
            CGRectGetMinX(textureSamplingRect), CGRectGetMaxY(textureSamplingRect),
            CGRectGetMaxX(textureSamplingRect), CGRectGetMaxY(textureSamplingRect),
            CGRectGetMinX(textureSamplingRect), CGRectGetMinY(textureSamplingRect),
            CGRectGetMaxX(textureSamplingRect), CGRectGetMinY(textureSamplingRect)
        };
        
        self.vertexTextureBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*2 numberOfVertices:4 bytes:quadTextureData usage:GL_STATIC_DRAW];
        [self.vertexTextureBuffer prepareToDrawWithAttrib:ATTRIB_TEXCOORD numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
        
        [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLE_STRIP startVertexIndex:0 numberOfVertices:4];
    [self.frameBuffer layerRender:^{

        [_context presentRenderbuffer:GL_RENDERBUFFER];

    }];

	
    
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    self.shaderManager = [[ShaderManager alloc]init];
   BOOL isSuccess =  [self.shaderManager CompileLinkSuccessShaderName:@"Shader" glBindAttribLocationBlock:^(GLuint program) {
        glBindAttribLocation(program, ATTRIB_VERTEX, "position");
        glBindAttribLocation(program, ATTRIB_TEXCOORD, "texCoord");
        
    } GetUniformLocationBlock:^(GLuint program) {
        // Get uniform locations.
        uniforms[UNIFORM_Y] = glGetUniformLocation(program, "SamplerY");
        uniforms[UNIFORM_UV] = glGetUniformLocation(program, "SamplerUV");
        uniforms[UNIFORM_LUMA_THRESHOLD] = glGetUniformLocation(program, "lumaThreshold");
        uniforms[UNIFORM_CHROMA_THRESHOLD] = glGetUniformLocation(program, "chromaThreshold");
        uniforms[UNIFORM_ROTATION_ANGLE] = glGetUniformLocation(program, "preferredRotation");
        uniforms[UNIFORM_COLOR_CONVERSION_MATRIX] = glGetUniformLocation(program, "colorConversionMatrix");
    }];
    return isSuccess;
}


@end

