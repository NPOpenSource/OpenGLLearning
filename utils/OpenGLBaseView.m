//
//  OpenGLBaseView.m
//  OpenGL_ES_demo(14)_多重纹理
//
//  Created by 温杰 on 2018/2/8.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "OpenGLBaseView.h"

@implementation OpenGLBaseView
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

-(void)baseInit{
    self.contentScaleFactor = [[UIScreen mainScreen] scale];
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],
                                      kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
        
    }
    return self;
}
-(void)initFrameRender{
        self.frameManager = [[FrameBufferManger alloc]init];
        self.frameManager.renderBufferStore = ^{
            [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        };
        [self.frameManager buildLayer];
}


@end
