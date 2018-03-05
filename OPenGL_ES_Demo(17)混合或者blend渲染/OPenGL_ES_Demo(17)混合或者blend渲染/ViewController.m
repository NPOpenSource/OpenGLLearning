//
//  ViewController.m
//  OPenGL_ES_Demo(17)混合或者blend渲染
//
//  Created by 温杰 on 2018/2/26.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "LearningBlendView.h"
#import "LearningCustomView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LearningCustomView * view = [[LearningCustomView alloc]initWithFrame:self.view.bounds];
//    LearningBlendView *view =[[LearningBlendView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:view];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
