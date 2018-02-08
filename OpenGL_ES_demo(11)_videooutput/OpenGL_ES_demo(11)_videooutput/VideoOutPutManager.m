//
//  VideoOutPutManager.m
//  OpenGL_ES_demo(11)_videooutput
//
//  Created by 温杰 on 2018/2/5.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "VideoOutPutManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface APLImagePickerController : UIImagePickerController

@end

@implementation APLImagePickerController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

@end

@interface VideoOutPutManager()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic ,strong) UIViewController *pushVc;
@property (nonatomic ,copy) void(^completeBlock)(NSDictionary *info) ;
@property (nonatomic ,copy) void(^failBlockBlock)(void) ;

@end

@implementation VideoOutPutManager


-(void)selectImagePickerFromVC:(UIViewController *)pushVc completeBlock:(void(^)(NSDictionary *info))completeBlock missBlock:(void(^)(void)) missBlock{
    self.completeBlock = completeBlock;
    self.failBlockBlock = missBlock;
    self.pushVc = pushVc;
    APLImagePickerController *videoPicker = [[APLImagePickerController alloc] init];
    videoPicker.delegate = self;
    videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    videoPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie];
    [pushVc presentViewController:videoPicker animated:YES completion:nil];

}

- (void)imagePickerController:(APLImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.pushVc dismissViewControllerAnimated:YES completion:nil];
    if (self.completeBlock) {
        self.completeBlock(info);
    }
    picker.delegate = nil;

}


- (void)imagePickerControllerDidCancel:(APLImagePickerController *)picker{
    [self.pushVc dismissViewControllerAnimated:YES completion:nil];
    picker.delegate = nil;
    if (self.failBlockBlock) {
        self.failBlockBlock();
    }


}
@end
