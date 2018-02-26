//
//  TextureManager.m
//  OpenGL_ES_demo(11)_videooutput
//
//  Created by 温杰 on 2018/2/6.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "TextureManager.h"

@interface TextureManager()

@end

@implementation TextureManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.texture = GL_TEXTURE0;
        self.format =  GL_RED_EXT;
        self.planeIndex = 0;
    }
    return self;
}



-(BOOL)build{

  CVReturn err;
    glActiveTexture(self.texture);
    if (!self.cache) {
        NSLog(@"请设置缓存");
        return NO;
    }
    if (!self.pixelBuffer) {
        NSLog(@"请设置数据");
        return NO;
    }
    if (self.width<=0 ||self.height<=0) {
        NSLog(@"请设置宽高");
        return NO;
    }
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       self.cache,
                                                       self.pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       self.format,
                                                       self.width,
                                                       self.height,
                                                       self.format,
                                                       GL_UNSIGNED_BYTE,
                                                       self.planeIndex,
                                                       &_outTexture);
    
    if (err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        return NO;
    }
    
    glBindTexture(CVOpenGLESTextureGetTarget(_outTexture), CVOpenGLESTextureGetName(_outTexture));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    return YES;
}

@end
