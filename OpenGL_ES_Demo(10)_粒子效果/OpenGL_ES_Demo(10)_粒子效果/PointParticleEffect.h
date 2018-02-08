//
//  PointParticleEffect.h
//  OpenGL_ES_Demo(10)_粒子效果
//
//  Created by 温杰 on 2018/2/1.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
@interface PointParticleEffect : NSObject
@property (nonatomic, assign) GLfloat elapsedSeconds;

- (void)prepareToDraw;
- (void)draw;
-(void)updateData:(NSTimeInterval)currentTime;

-(void)prepareData:(NSInteger)tag;
@end
