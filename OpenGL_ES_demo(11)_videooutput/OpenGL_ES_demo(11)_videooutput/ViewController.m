//
//  ViewController.m
//  OpenGL_ES_demo(11)_videooutput
//
//  Created by 温杰 on 2018/2/5.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "VideoOutPutManager.h"
//#import "AVPlayerView.h"

#import "AVPlayerManager.h"
#import "APLEAGLView.h"


@interface ViewController ()
@property (nonatomic ,strong) VideoOutPutManager * outPutManger;
@property (nonatomic ,strong) AVPlayerManager * playerManager;
//@property (nonatomic ,strong) AVPlayerView * playerView;
@property (nonatomic ,strong)APLEAGLView * playerView;
@end





@implementation ViewController

-(void)createbutton{
    UIButton * button= [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor redColor]];
    button.frame = CGRectMake(0, 0, 100, 50);
    [button addTarget:self action:@selector(buttonEvent) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
}
-(void)buttonEvent{
    if (!self.outPutManger) {
        VideoOutPutManager * putManger=[[VideoOutPutManager alloc]init];
        self.outPutManger = putManger;
    }
    [self.outPutManger  selectImagePickerFromVC:self completeBlock:^(NSDictionary *info){
        [self setupPlaybackForURL:info[UIImagePickerControllerReferenceURL]];
        
    } missBlock:^{
        
    }];
    
   
    
}
- (void)setupPlaybackForURL:(NSURL *)URL
{
        [self.playerManager removeOutput];
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:URL];
        AVAsset *asset = [item asset];
        ///查找track
        [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
            ///结束了
            if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
                ///获取shi'pin
                NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
                if ([tracks count] > 0) {
                    // Choose the first video track.
                    AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
                    [videoTrack loadValuesAsynchronouslyForKeys:@[@"preferredTransform"] completionHandler:^{
                        
                        if ([videoTrack statusOfValueForKey:@"preferredTransform" error:nil] == AVKeyValueStatusLoaded) {
                            CGAffineTransform preferredTransform = [videoTrack preferredTransform];
                            self.playerView.preferredRotation = atan2(preferredTransform.b, preferredTransform.a);;
                            [self.playerManager addNotification];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.playerManager addOutPut:item];
                                [self.playerManager play];
                            });
                            
                        }
                        
                    }];
                }
            }
        }];
        
   
}

-(void)createPlayerView;{
    if (!self.playerView) {
        self.playerView = [[APLEAGLView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [self.view addSubview:self.playerView];
        
    }
}

-(void)createPlayer{
    if (!self.playerManager) {
        self.playerManager =[[AVPlayerManager alloc]init];
        self.playerManager.delegate = self.playerView;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createPlayerView];
    [self createPlayer];
    [self createbutton];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
