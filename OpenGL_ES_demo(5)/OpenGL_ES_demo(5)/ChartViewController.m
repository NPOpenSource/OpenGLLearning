
//
//  ChartViewController.m
//  OpenGL_ES_demo(5)
//
//  Created by 温杰 on 2018/1/30.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "ChartViewController.h"
#import "os_cube.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKElementIndexArrayBuffer.h"
@interface CubeModel:NSObject
@property (nonatomic ,strong)AGLKVertexAttribArrayBuffer * buffer;
@property (nonatomic ) GLuint begin;
@property (nonatomic )GLuint end;
@property (nonatomic )GLKVector4 color;

@end
@implementation CubeModel

@end

@interface ChartViewController ()
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) NSMutableArray *values;
@property (strong,nonatomic) NSArray *targetValues;
@property (nonatomic)BOOL isRotation;
@property (nonatomic ,strong) NSMutableArray * cubeArr;
@property (nonatomic) GLKMatrixStackRef modelviewMatrixStack;

@end

@implementation ChartViewController
-(instancetype)initWithChartData:(NSArray*)chartData{
    if (self = [super init]){
        [self loadData:chartData];
    }
    return  self;
}

// MARK: - 下面是主要的方法
- (void)loadData:(NSArray*)data{
    self.targetValues = data;
    self.values = [NSMutableArray arrayWithArray:self.targetValues];
    for (int i=0;i<self.values.count;i++){
        self.values[i] = @(0);
    }
}

-(void)config{
    self.cubeArr = [[NSMutableArray alloc]init];
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
}
- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    self.modelviewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.0f, 1.0f, 1.0f);
        float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
        GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), aspect, 0.1f, 20.0);
        self.effect.transform.projectionMatrix = projectionMatrix;
        GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
        self.effect.transform.modelviewMatrix = baseModelViewMatrix;
    GLKMatrixStackLoadMatrix4(self.modelviewMatrixStack,self.effect.transform.modelviewMatrix);
    
    
    glEnable(GL_DEPTH_TEST);
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self config];
    [self setupGL];
    [self setCubeModeArr];
}
-(void)setCubeModeArr{
    
    for (int i=0; i<self.targetValues.count; i++) {
        CubeModel * model  = [[CubeModel alloc]init];
        model.buffer =[self getCubeBuffer];
        model.color = GLKVector4Make( arc4random_uniform(255)/225.0, arc4random_uniform(255)/225.0, arc4random_uniform(255)/225.0, 1);
        model.begin = 0;
        model.end = ((NSNumber *)self.targetValues[i]).intValue;
        [self.cubeArr addObject:model];
    }
}



-(AGLKVertexAttribArrayBuffer * )getCubeBuffer{
    AGLKVertexAttribArrayBuffer *buffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLfloat)*6 numberOfVertices:36 bytes:gCubeVertexData usage:GL_STATIC_DRAW];
    [buffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    // 开启绘制命令 GLKVertexAttribPosition(位置)
    // 开启绘制命令 GLKVertexAttribPosition(法线)
    [buffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:sizeof(GLfloat)*3 shouldEnable:YES]; 
    return buffer;
}

-(void)clear{
    glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

-(GLKMatrix4)cubeMatrixIndex:(GLuint)index count:(GLuint)count model:(CubeModel *)model{
///具体算法不做了。
    static GLfloat m = 0;
    m+=0.5;
    static GLfloat x = -.50;
    GLKMatrix4 matrix ;
     GLKMatrixStackPush(self.modelviewMatrixStack);
    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                    GLKMathDegreesToRadians(m),
                         0.0, 1.0, 0.0);
    
    GLKMatrixStackTranslate(self.modelviewMatrixStack, x, 0.0, 0.0);
    x+=0.25;
    if (x>0.5) {
        x=-0.5;
    }
    GLuint height=400;
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);

    GLfloat y = model.begin*1.0 /height;
    if (model.begin<model.end) {
        model.begin+=4;;
    }
 
    GLKMatrixStackScale(self.modelviewMatrixStack, 0.2, 1, 0.2);

    GLKMatrixStackTranslate(self.modelviewMatrixStack, 0.0, y/2.0, 0.0);
    GLKMatrixStackScale(self.modelviewMatrixStack, 1, y, 1);

    matrix =    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);

    GLKMatrixStackPop(self.modelviewMatrixStack);
    
  
    
    return matrix;
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self clear];
    for (int i =0; i<self.cubeArr.count; i++) {
        CubeModel * model = self.cubeArr[i];
     
        self.effect.light0.diffuseColor = model.color;
        self.effect.light0.transform.modelviewMatrix = [self cubeMatrixIndex:i count:self.cubeArr.count model:model];
        [self.effect prepareToDraw];
        
        [model.buffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:36];
        
    }
}


- (void)update
{

}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
