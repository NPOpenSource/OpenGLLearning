//
//  FrameBufferManger.h
//  OPenGL_ES_Demo(10)帧缓存
//
//  Created by 温杰 on 2018/2/2.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
@interface FrameBufferManger : NSObject
@property (nonatomic ,assign)GLint width;
@property (nonatomic ,assign)GLint height;

@property (nonatomic ,assign)GLuint mExtraFBOID;
@property (nonatomic , assign) GLint mDefaultFBO;
@property (nonatomic,assign) GLuint mExtraDepthBuffer;

@property (nonatomic ,assign)GLuint textureId;
///layer  get
@property (nonatomic,copy) GLfloat(^layerHeight)(void);
@property (nonatomic,copy) GLfloat(^layerWidth)(void);

///layer set
@property (nonatomic ,copy) void(^renderBufferStore)(void);

-(BOOL)build;
-(void)offScreenRender:(void(^)(void)) performBlock;

-(BOOL)buildLayer;
-(void)layerRender:(void(^)(void)) performBlock;
@end
