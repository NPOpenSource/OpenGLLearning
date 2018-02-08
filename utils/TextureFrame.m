//
//  TextureFrame.m
//  OpenGL_ES_demo(14)_多重纹理
//
//  Created by 温杰 on 2018/2/8.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "TextureFrame.h"
#import <UIKit/UIKit.h>
@interface TextureFrame()

@end

@implementation TextureFrame

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.location = GL_TEXTURE0;
    }
    return self;
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
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextSaveGState(spriteContext);
    
    CGContextTranslateCTM(spriteContext, 0, height);
    CGContextScaleCTM(spriteContext, 1.0, -1.0);
    // 3在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRestoreGState(spriteContext);
    
    CGContextRelease(spriteContext);
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, self.texture);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    free(spriteData);
    return self.texture;
}
-(void)build{
    glActiveTexture(self.location);
    glBindTexture(GL_TEXTURE_2D, self.texture);
}

@end
