//
//  ViewController.m
//  OpenGL_ES_demo(5)
//
//  Created by 温杰 on 2018/1/30.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "ChartViewController.h"
@interface ViewController ()
@property(nonatomic,strong) ChartViewController *chartVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 第一步，添加3D 视图
    ChartViewController *chartVC = [[ChartViewController alloc]initWithChartData:@[@10,@100,@200,@300,@400]];
    self.chartVC = chartVC;
    chartVC.view.frame = self.view.bounds;
    [self.view insertSubview:chartVC.view atIndex:0];
    [self addChildViewController:chartVC];


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
