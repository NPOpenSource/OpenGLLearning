//
//  AGLKElementIndexArrayBuffer.m
//  OpenGL_ES_Demo(3)
//
//  Created by 温杰 on 2018/1/29.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "AGLKElementIndexArrayBuffer.h"

@implementation AGLKElementIndexArrayBuffer


- (id)initWithAttribIndexCount:(GLsizei)count
                     bytes:(const GLvoid *)dataPtr
                {
    if(nil != (self = [super init]))
    {
       
    NSParameterAssert((0 < count) && (count < 4));
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, count,dataPtr, GL_STATIC_DRAW);
#ifdef DEBUG
    {  // Report any errors
        GLenum error = glGetError();
        if(GL_NO_ERROR != error)
        {
            NSLog(@"GL Error: 0x%x", error);
        }
    }
#endif
    }
    return self;
}





+ (void)drawElementIndexWithMode:(GLenum)mode indexCount:(GLsizei)count indexArr:(GLuint*)indexArr
{
    glDrawElements(mode, count, GL_UNSIGNED_INT, indexArr);
}
@end
