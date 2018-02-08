//
//  Camera.h
//  OpenGL_ES_demo(12)_摄像头
//
//  Created by 温杰 on 2018/2/6.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Camera : UIView
- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end
