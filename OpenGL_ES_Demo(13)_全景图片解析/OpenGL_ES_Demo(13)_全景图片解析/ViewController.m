//
//  ViewController.m
//  OpenGL_ES_Demo(13)_全景图片解析
//
//  Created by 温杰 on 2018/2/7.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "GLTestView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GLTestView * view = [[GLTestView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:view];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
