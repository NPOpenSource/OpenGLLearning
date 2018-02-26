//
//  FrameBufferManger.m
//  OPenGL_ES_Demo(10)帧缓存
//
//  Created by 温杰 on 2018/2/2.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "FrameBufferManger.h"

@interface FrameBufferManger()

@end

@implementation FrameBufferManger
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bindTextureId = GL_TEXTURE0;
    }
    return self;
}




-(void)textureInit{
    glActiveTexture( self.bindTextureId);
    glGenTextures(1, &_textureId);
    //    绑定texture纹理
    glBindTexture(GL_TEXTURE_2D, self.textureId);
    ///分配纹理内存
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RGBA,
                 self.width,
                 self.height,
                 0,
                 GL_RGBA,
                 GL_UNSIGNED_BYTE,
                 NULL);
    ///设置纹理内存样式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glBindTexture(GL_TEXTURE_2D, 0);
    
}

-(void)FrameFBO{
    ///生成一个FBO
    glGenFramebuffers(1, &_mExtraFBOID);
    ///绑定帧缓存
    glBindFramebuffer(GL_FRAMEBUFFER, self.mExtraFBOID);
    //把帧缓存当成纹理绘制到 mExtraTexture内存中
    
}

-(void)textureBindingFBO{
    ///把纹理关联到FBO .这里只是
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           GL_TEXTURE_2D, self.textureId, 0);
}


-(void)renderBuffer{
    ///生成buffer render
    glGenRenderbuffers(1, &_mExtraDepthBuffer);
    //    绑定渲染buffer
    glBindRenderbuffer(GL_RENDERBUFFER, self.mExtraDepthBuffer);
    //    存贮深度

}

-(void)renderBufferBindingFBO{
    //    /渲染镇缓存数据到这个buffer中
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16,
                          self.width, self.height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, self.mExtraDepthBuffer);
    
}

-(BOOL)checkFBO{
    GLenum status;
    status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    switch(status) {
        case GL_FRAMEBUFFER_COMPLETE:
            NSLog(@"fbo complete width %d height %d", self.width, self.height);
            return YES;
            break;
            
        case GL_FRAMEBUFFER_UNSUPPORTED:
            NSLog(@"fbo unsupported");
            
            break;
            
        default:
            NSLog(@"Framebuffer Error");
            break;
    }
    return NO;
}

-(BOOL)build{
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_mDefaultFBO);
    [self textureInit];
    [self FrameFBO];
    [self textureBindingFBO];
    [self renderBuffer];
    [self renderBufferBindingFBO];
    BOOL check=[self checkFBO];
    glBindFramebuffer(GL_FRAMEBUFFER, self.mDefaultFBO
                      );
    return check;
    
}
-(void)setLayerRenderBuffer{
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _mExtraDepthBuffer);
}

-(BOOL)buildLayer{
    /// 关联 到leyer 颜色
    [self FrameFBO];
    glBindFramebuffer(GL_FRAMEBUFFER, self.mExtraFBOID);
    [self renderBuffer];
    if (!self.renderBufferStore) {
//        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        NSLog(@"请设置渲染buffer");
        return NO;
    }
    self.renderBufferStore();
    [self setLayerRenderBuffer];
    glBindRenderbuffer(GL_RENDERBUFFER, self.mExtraDepthBuffer);
    glViewport(0, 0, self.width, self.height);

    BOOL check=[self checkFBO];

    return check;
}

-(GLfloat (^)(void))layerWidth
{
    return ^GLfloat(void){
        return self.width;
    };
}

-(GLfloat (^)(void))layerHeight{
    return ^GLfloat(void){
        return self.height;
    };
}

-(void)offScreenRender:(void(^)(void)) performBlock{
    glBindFramebuffer(GL_FRAMEBUFFER, self.mExtraFBOID);
    glBindRenderbuffer(GL_RENDERBUFFER, self.mExtraDepthBuffer);
    glBindTexture(GL_TEXTURE_2D, self.textureId);
    if (performBlock) {
        performBlock();
    }
    glBindFramebuffer(GL_FRAMEBUFFER, self.mDefaultFBO
                      );
}
-(void)layerRender:(void(^)(void)) performBlock{
    glBindFramebuffer(GL_FRAMEBUFFER, self.mExtraFBOID);
    glBindRenderbuffer(GL_RENDERBUFFER, self.mExtraDepthBuffer);
    glViewport(0, 0, self.width,self.height);

    if (performBlock) {
        performBlock();
    }
}

- (void)dealloc
{
    if (self.mExtraFBOID) {
        glDeleteFramebuffers(1, &_mExtraFBOID);
        self.mExtraFBOID = 0;
    }
    if (self.mExtraDepthBuffer) {
        glDeleteRenderbuffers(1, &_mExtraDepthBuffer);
        self.mExtraDepthBuffer=0;
    }

}

@end

