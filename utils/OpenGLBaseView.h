//
//  OpenGLBaseView.h
//  OpenGL_ES_demo(14)_多重纹理
//
//  Created by 温杰 on 2018/2/8.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPenGLManger.h"

@interface OpenGLBaseView : UIView
@property (nonatomic ,strong)  EAGLContext *context;
@property (nonatomic ,strong) FrameBufferManger * frameManager;
@property (nonatomic ,strong) ShaderManager * shadermanager;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer * vertexBuffer;
-(void)initFrameRender;
@end
