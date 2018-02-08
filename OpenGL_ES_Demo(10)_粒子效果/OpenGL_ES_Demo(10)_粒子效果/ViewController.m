//
//  ViewController.m
//  OpenGL_ES_Demo(10)_粒子效果
//
//  Created by 温杰 on 2018/2/1.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ViewController.h"
#import "PointParticleEffect.h"




@interface ViewController ()
@property (nonatomic , strong) EAGLContext* mContext;
@property (nonatomic ,strong)PointParticleEffect * effect;
@end



@implementation ViewController
-(void)config{
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.mContext];

    GLKView* view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;


    //开启混合
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

}

-(void)createButton{
    UIButton * button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    [button addTarget:self action:@selector(buttonHit:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
}
-(void)buttonHit:(UIButton *)button{
    [self.effect prepareData:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self config];
    self.effect =[[PointParticleEffect alloc]init];
    [self createButton];

}

- (void)update{
    [self.effect updateData:self.timeSinceFirstResume];
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glClearColor(0.3, 0.0, 0.0, 1);

    [self.effect prepareToDraw];
    [self.effect draw];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
