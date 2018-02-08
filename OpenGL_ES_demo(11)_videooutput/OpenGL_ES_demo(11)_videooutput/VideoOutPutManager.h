//
//  VideoOutPutManager.h
//  OpenGL_ES_demo(11)_videooutput
//
//  Created by 温杰 on 2018/2/5.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VideoOutPutManager : NSObject
-(void)selectImagePickerFromVC:(UIViewController *)pushVc completeBlock:(void(^)(NSDictionary *info))completeBlock missBlock:(void(^)(void)) missBlock;
@end
