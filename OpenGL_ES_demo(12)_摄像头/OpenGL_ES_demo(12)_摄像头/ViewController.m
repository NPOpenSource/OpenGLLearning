//
//  ViewController.m
//  OpenGL_ES_demo(12)_摄像头
//
//  Created by 温杰 on 2018/2/6.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "Camera.h"
#import "CameraManager.h"
#import "TextureManager.h"
@interface ViewController ()
@property (nonatomic ,strong) Camera * showCameraView;
@property (nonatomic ,strong)CameraManager * cameraManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showCameraView = [[Camera alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.showCameraView];
    
    self.cameraManager =[[CameraManager alloc]init];
    self.cameraManager.dealDataBlock = ^(CVPixelBufferRef buffer) {
        [self.showCameraView displayPixelBuffer:buffer];
    };
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
