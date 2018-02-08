//
//  AVPlayerManager.h
//  OpenGL_ES_demo(11)_videooutput
//
//  Created by 温杰 on 2018/2/5.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@protocol AVPlayerManagerDelegate<NSObject>
-(void)displayPixelBuffer:(CVPixelBufferRef)buffer;
-(void) viewPresentationRect:(CGSize)size;

@end


@interface AVPlayerManager : NSObject
@property (nonatomic ,weak) id<AVPlayerManagerDelegate> delegate;
-(void)play;
-(void)removeOutput;
-(void)addOutPut:(AVPlayerItem*) outPut;
-(void)addNotification;
-(void)removetification;

@end
