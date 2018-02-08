//
//  ViewController.m
//  OpenGL_ES_demo(14)_多重纹理
//
//  Created by 温杰 on 2018/2/8.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "LearningView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  LearningView *learning=  [[LearningView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:learning];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
