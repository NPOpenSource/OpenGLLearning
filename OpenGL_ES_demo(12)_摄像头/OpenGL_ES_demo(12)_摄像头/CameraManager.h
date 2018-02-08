//
//  CameraManager.h
//  OpenGL_ES_demo(12)_摄像头
//
//  Created by 温杰 on 2018/2/6.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

@interface CameraManager : NSObject
@property (nonatomic ,copy)void(^ dealDataBlock)(CVPixelBufferRef buffer);
@end
