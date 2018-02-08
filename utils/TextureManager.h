//
//  TextureManager.h
//  OpenGL_ES_demo(11)_videooutput
//
//  Created by 温杰 on 2018/2/6.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <AVFoundation/AVUtilities.h>

@interface TextureManager : NSObject

@property (nonatomic)CVOpenGLESTextureCacheRef cache;
@property (nonatomic) CVImageBufferRef pixelBuffer;
@property  GLsizei width;
@property GLsizei height;

@property (nonatomic) GLenum texture;
@property GLenum format;
@property size_t planeIndex;

@property (nonatomic)CVOpenGLESTextureRef  outTexture;
-(BOOL)build;
@end
