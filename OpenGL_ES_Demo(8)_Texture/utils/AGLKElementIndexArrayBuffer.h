//
//  AGLKElementIndexArrayBuffer.h
//  OpenGL_ES_Demo(3)
//
//  Created by 温杰 on 2018/1/29.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
@interface AGLKElementIndexArrayBuffer : NSObject

- (id)initWithAttribIndexCount:(GLsizei)count
                         bytes:(const GLvoid *)dataPtr;

+ (void)drawElementIndexWithMode:(GLenum)mode indexCount:(GLsizei)count indexArr:(GLuint*)indexArr;
@end
