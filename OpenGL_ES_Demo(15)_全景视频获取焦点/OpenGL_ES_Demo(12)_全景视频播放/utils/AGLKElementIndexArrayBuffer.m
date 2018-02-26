//
//  AGLKElementIndexArrayBuffer.m
//  OpenGL_ES_Demo(3)
//
//  Created by 温杰 on 2018/1/29.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "AGLKElementIndexArrayBuffer.h"
@interface AGLKElementIndexArrayBuffer()
@property (nonatomic)GLsizei count;
@property (nonatomic) GLvoid * dataPtr;
@property (nonatomic) GLuint index;
@end


@implementation AGLKElementIndexArrayBuffer


- (id)initWithAttribIndexCount:(GLsizei)count
                     bytes:(const GLvoid *)dataPtr
                {
    if(nil != (self = [super init]))
    {
       
        self.count = count;
        self.dataPtr= dataPtr   ;

    glGenBuffers(1, &_index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, self.count *4,dataPtr, GL_STATIC_DRAW);
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

-(void)prepareToDrawWithAttrib{
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.index);

}

-(void)drawElementIndexWithMode:(GLenum)mode {
    glDrawElements(mode, self.count, GL_UNSIGNED_INT, 0);

}




@end
