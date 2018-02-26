//
//  ViewController.m
//  OpenGL_ES_Demo(16)_多滤镜
//
//  Created by 温杰 on 2018/2/8.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "LearningView.h"
#import "LearningColorView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    LearningView * view = [[LearningView alloc]initWithFrame:self.view.bounds];
    LearningColorView * view =[[LearningColorView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:view];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
