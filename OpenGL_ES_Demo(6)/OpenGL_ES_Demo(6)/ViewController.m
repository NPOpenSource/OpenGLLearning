//
//  ViewController.m
//  OpenGL_ES_Demo(6)
//
//  Created by 温杰 on 2018/1/31.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "TestShaderView.h"
@interface ViewController ()

@end

@implementation ViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    TestShaderView * view = [[TestShaderView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:view];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
