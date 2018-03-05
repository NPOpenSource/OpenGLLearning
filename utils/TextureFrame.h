//
//  TextureFrame.h
//  OpenGL_ES_demo(14)_多重纹理
//
//  Created by 温杰 on 2018/2/8.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

@interface TextureFrame : NSObject
//默认是GL_TEXTURE0
@property (nonatomic ,assign)GLuint location;


@property (nonatomic , assign) GLuint texture;
- (void)setupTexture:(NSString *)fileName ;

-(GLuint)build;
@end
