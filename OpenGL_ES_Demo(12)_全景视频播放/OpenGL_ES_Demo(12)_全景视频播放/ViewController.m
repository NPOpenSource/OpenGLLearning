//
//  ViewController.m
//  OpenGL_ES_Demo(12)_全景视频播放
//
//  Created by 温杰 on 2018/2/7.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "VideoView.h"
#import "VideoPlayerManager.h"
@interface ViewController ()
@property (nonatomic ,strong)VideoPlayerManager * videoPlayerManager;
@property (nonatomic ,strong)VideoView * videoView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoView = [[VideoView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.videoView];
    
    self.videoPlayerManager = [[VideoPlayerManager alloc]init];
    self.videoPlayerManager.OneframePixelBufferBlock = ^(CVPixelBufferRef pixelBuffer) {
        [self.videoView displayPixelBuffer:pixelBuffer];
    };
    [self.videoPlayerManager loadLocalName:@"abc"];
    // Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
