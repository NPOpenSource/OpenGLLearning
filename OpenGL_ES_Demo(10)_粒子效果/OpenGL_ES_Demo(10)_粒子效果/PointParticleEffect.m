//
//  PointParticleEffect.m
//  OpenGL_ES_Demo(10)_粒子效果
//
//  Created by 温杰 on 2018/2/1.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "PointParticleEffect.h"
#import <GLKit/GLKit.h>
#import "ShaderManager.h"
#import "AGLKVertexAttribArrayBuffer.h"

// Attribute identifiers
typedef enum {
    BeginPosition = 0,
    BeginVelocity,
    Force,
    A_Size,
    BeginTime,
    EndTime,
} AGLKParticleAttrib;
typedef struct {
    GLKVector3 beginPosition;
    GLKVector3 beginVelocity;
    GLKVector3 force;
    GLKVector2 a_size;
    GLfloat beginTime;
    GLfloat endTime;
}AGLKParticleAttributes;

enum
{
  
    Samplers2D=0,
      MVPMatrix,
    CurrentTime,
    UGravity,
    AGLKNumUniforms
};

@interface PointParticleEffect()
{
    GLint uniforms[AGLKNumUniforms];

}
@property (nonatomic, assign) GLKVector3 gravity;

@property (strong, nonatomic) GLKEffectPropertyTexture
*texture2d0;
@property (strong, nonatomic) GLKEffectPropertyTransform
*transform;
@property (strong,nonatomic) ShaderManager * shader;
@property (nonatomic ,strong)NSMutableArray * data;
@property (nonatomic, strong) NSMutableData
*particleAttributesData;
@property (nonatomic, assign, readwrite) BOOL
particleDataWasUpdated;
@property (nonatomic ,assign)GLfloat   autoSpawnDelta;
@property (assign, nonatomic) NSTimeInterval lastSpawnTime;

@property (nonatomic ,strong)AGLKVertexAttribArrayBuffer *  particleAttributeBuffer;
@property (nonatomic, assign) GLint currentTag;
@end

@implementation PointParticleEffect

-(void)createTexture{
    
    NSString *path = [[NSBundle bundleForClass:[self class]]
                      pathForResource:@"ball" ofType:@"png"];
    NSAssert(nil != path, @"ball texture image not found");
    NSError *error = nil;
  GLKTextureInfo * texture= [GLKTextureLoader
                                textureWithContentsOfFile:path
                                options:nil
                                error:&error];
    self.texture2d0 = [[GLKEffectPropertyTexture alloc] init];
    self.texture2d0.enabled = YES;
    self.texture2d0.name = 0;
    self.texture2d0.target = GLKTextureTarget2D;
    self.texture2d0.envMode = GLKTextureEnvModeReplace;
    self.transform = [[GLKEffectPropertyTransform alloc] init];
    self.texture2d0.name = texture.name;
    self.texture2d0.target= texture.target;
    self.particleAttributesData = [[NSMutableData alloc]init];

}

-(void)mvp{
    GLfloat aspectRatio= CGRectGetWidth([UIScreen mainScreen].bounds) / CGRectGetHeight([UIScreen mainScreen].bounds);
    self.transform.projectionMatrix =
    GLKMatrix4MakePerspective(
                              GLKMathDegreesToRadians(85.0f),
                              aspectRatio,
                              0.1f,
                              20.0f);
    ///摄像机的位置。
    self.transform.modelviewMatrix =
    GLKMatrix4MakeLookAt(
                         0.0, 0.0, 1.0,   // Eye position
                         0.0, 0.0, 0.0,   // Look-at position
                         0.0, 1.0, 0.0);  // Up direction
    
}
- (BOOL)loadShaders{

    self.shader = [[ShaderManager alloc]init];
   return  [self.shader CompileLinkSuccessShaderName:@"Shader" glBindAttribLocationBlock:^(GLuint program) {
       glBindAttribLocation(program,BeginPosition,"beginPostion");
       glBindAttribLocation(program,BeginVelocity,"beginVelocity");
       glBindAttribLocation(program,Force,"force");
       glBindAttribLocation(program,A_Size,"a_size");
       glBindAttribLocation(program,BeginTime,"beginTime");
       glBindAttribLocation(program,EndTime,"endTime");

    } GetUniformLocationBlock:^(GLuint program) {

        uniforms[MVPMatrix] = glGetUniformLocation(program, "u_mvpMatrix");
        uniforms[Samplers2D] = glGetUniformLocation(program,
                                                    "u_samplers2D");
        uniforms[CurrentTime] = glGetUniformLocation(program,
                                                     "currentTime");
        uniforms[UGravity] = glGetUniformLocation(program,
                                                     "u_gravity");
        
    }];
}
#define __weakSelf  __weak typeof(self) weakSelf = self;

-(void)loadData{
    __weakSelf
    self.data = [[NSMutableArray alloc]initWithCapacity:0];
    [self.data addObject:[^{
        weakSelf.autoSpawnDelta = 1.0f;
        
        weakSelf.gravity = GLKVector3Make( 0.0f, 0.0f, 0.0f);
        
        for(int i = 0; i < 100; i++)
        {
            float randomXVelocity = -0.1f + 0.2f *
            (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.1f + 0.2f *
            (float)random() / (float)RAND_MAX;
            
            [weakSelf
             addParticleAtPosition:GLKVector3Make(0.0f, 0.0, 0.9)
             velocity:GLKVector3Make(
                                     0.0,
                                     0.0,
                                     0.0)
             force:GLKVector3Make(randomXVelocity, randomYVelocity, 0.0f)
             size:8.0f
             lifeSpanSeconds:2.2f
             fadeDurationSeconds:3.0f];
        }
        
    } copy]];
    [self.data addObject:[^{
        weakSelf.autoSpawnDelta = 0.05f;
        
        weakSelf.gravity = GLKVector3Make( 0.0f, 0.5f, 0.0f);
        
        for(int i = 0; i < 20; i++)
        {
            float randomXVelocity = -0.1f + 0.2f *
            (float)random() / (float)RAND_MAX;
            float randomZVelocity = 0.1f + 0.2f *
            (float)random() / (float)RAND_MAX;
            
            [weakSelf
             addParticleAtPosition:GLKVector3Make(0.0f, -0.5f, randomZVelocity)
             velocity:GLKVector3Make(
                                     randomXVelocity,
                                     0.0,
                                     0.0)
             force:GLKVector3Make(0.0f, 0.0f, 0.0f)
             size:16.0f
             lifeSpanSeconds:2.2f
             fadeDurationSeconds:3.0f];
        }
        
                          } copy]];
    [self.data addObject:[^{  // 1
        weakSelf.autoSpawnDelta = 0.5f;
        weakSelf.gravity = GLKVector3Make( 0.0f, -9.80665f, 0.0f);

        float randomXVelocity = -0.5f + 1.0f *
        (float)random() / (float)RAND_MAX;
        [weakSelf
         addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.9f)
         velocity:GLKVector3Make(randomXVelocity, 1.0f, -1.0f)
         force:GLKVector3Make(0.0f, 9.0f, 0.0f)
         size:4.0f
         lifeSpanSeconds:3.2f
         fadeDurationSeconds:0.5f];
    } copy]];
    [self.data addObject:[^{  // 2
        weakSelf.autoSpawnDelta = 0.05f;
        
        weakSelf.gravity = GLKVector3Make( 0.0f, 0.5f, 0.0f);
        
        for(int i = 0; i < 20; i++)
        {
            float randomXVelocity = -0.1f + 0.2f *
            (float)random() / (float)RAND_MAX;
            float randomZVelocity = 0.1f + 0.2f *
            (float)random() / (float)RAND_MAX;
            
            [weakSelf
             addParticleAtPosition:GLKVector3Make(0.0f, -0.5f, 0.0f)
             velocity:GLKVector3Make(
                                     randomXVelocity,
                                     0.0,
                                     randomZVelocity)
             force:GLKVector3Make(0.0f, 0.0f, 0.0f)
             size:16.0f
             lifeSpanSeconds:2.2f
             fadeDurationSeconds:3.0f];
        }
    } copy]];
    
    [self.data addObject:[^{  // 3
        weakSelf.autoSpawnDelta = 0.5f;
        weakSelf.gravity = GLKVector3Make( 0.0f, 0.0f, 0.0f);

        for(int i = 0; i < 100; i++)
        {
            float randomXVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            float randomZVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            
            [weakSelf
             addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.0f)
             velocity:GLKVector3Make(
                                     randomXVelocity,
                                     randomYVelocity,
                                     randomZVelocity)
             force:GLKVector3Make(0.0f, 0.0f, 0.0f)
             size:4.0f
             lifeSpanSeconds:3.2f
             fadeDurationSeconds:0.5f];
        }
    } copy]];
    [self.data addObject: [^{  // 4
        weakSelf.autoSpawnDelta = 3.2f;
        weakSelf.gravity = GLKVector3Make( 0.0f, 0.0f, 0.0f);

        for(int i = 0; i < 100; i++)
        {
            float randomXVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            GLKVector3 velocity = GLKVector3Normalize(
                                                      GLKVector3Make(
                                                                     randomXVelocity,
                                                                     randomYVelocity,
                                                                     0.0f));
            
            [weakSelf
             addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.0f)
             velocity:velocity
             force:GLKVector3MultiplyScalar(velocity, -1.5f)
             size:4.0f
             lifeSpanSeconds:3.2f
             fadeDurationSeconds:0.2f];
        }
    } copy]];
    
}

- (void)addParticleAtPosition:(GLKVector3)beginPosition
                     velocity:(GLKVector3)beginVelocity
                        force:(GLKVector3)aForce
                         size:(float)aSize
              lifeSpanSeconds:(NSTimeInterval)aSpan
          fadeDurationSeconds:(NSTimeInterval)aDuration;
{
    AGLKParticleAttributes newParticle;
    newParticle.beginPosition = beginPosition;
    newParticle.beginVelocity = beginVelocity;
    ///速度
    newParticle.force = aForce;
    ///受力
    newParticle.a_size = GLKVector2Make(aSize, aDuration);
    ///大小和持续时间
    newParticle.beginTime =self.elapsedSeconds;
    newParticle.endTime =self.elapsedSeconds+aSpan;

    ///下面这段没
    BOOL foundSlot = NO;
    const long count = self.numberOfParticles;
    ///检测是否淘汰掉了。重复利用
    for(int i = 0; i < count && !foundSlot; i++)
    {
        
        AGLKParticleAttributes oldParticle =
        [self particleAtIndex:i];
        ///结束时间 大于当前时间
        if(oldParticle.endTime < self.elapsedSeconds)
        {
            [self setParticle:newParticle atIndex:i];
            foundSlot = YES;
        }
    }
    
    /// particleDataWasUpdated 顶点数据更新了
    if(!foundSlot)
    {
        ///保存的是属性
        [self.particleAttributesData appendBytes:&newParticle
                                          length:sizeof(newParticle)];
        self.particleDataWasUpdated = YES;
    }
    
   
}

- (void)setParticle:(AGLKParticleAttributes)aParticle
            atIndex:(NSUInteger)anIndex
{
    ///这是什么行为
    NSParameterAssert(anIndex < self.numberOfParticles);
    
    AGLKParticleAttributes *particlesPtr =
    (AGLKParticleAttributes *)[self.particleAttributesData
                               mutableBytes];
    particlesPtr[anIndex] = aParticle;
    
    self.particleDataWasUpdated = YES;
}

- (AGLKParticleAttributes)particleAtIndex:(NSUInteger)anIndex
{
    NSParameterAssert(anIndex < self.numberOfParticles);
    
    const AGLKParticleAttributes *particlesPtr =
    (const AGLKParticleAttributes *)[self.particleAttributesData
                                     bytes];
    
    return particlesPtr[anIndex];
}


- (NSUInteger)numberOfParticles;
{
    static long last;
    long ret = [self.particleAttributesData length] /
    sizeof(AGLKParticleAttributes);
    if (last != ret) {
        last = ret;
        //        NSLog(@"count %ld", ret);
    }
    return ret;
}



-(void)prepareData:(NSInteger)tag{
    
    static int mm=0;
     mm++;
    self.currentTag = mm;
    if (self.currentTag>=self.data.count) {
        mm=0;
        self.currentTag =mm;
    }
}



- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createTexture];
        [self loadShaders];
        [self mvp];
        [self loadData];
    }
    return self;
}

-(void)updateData:(NSTimeInterval)currentTime
{
    self.elapsedSeconds = currentTime;
    
    if(self.autoSpawnDelta < (currentTime - self.lastSpawnTime))
    {
        self.lastSpawnTime = currentTime;
        
        void(^emitterBlock)() = [self.data objectAtIndex: self.currentTag];
        emitterBlock();
    }
}

- (void)prepareToDraw{
//    glUseProgram(self.shader.program);
    // Precalculate the mvpMatrix
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(
                                                              self.transform.projectionMatrix,
                                                              self.transform.modelviewMatrix);
    /// 将数据更新到 unform 0 位置
    glUniformMatrix4fv(uniforms[MVPMatrix], 1, 0,
                       modelViewProjectionMatrix.m);
    glUniform1i(uniforms[Samplers2D], 0);
    glUniform1fv(uniforms[CurrentTime], 1, &_elapsedSeconds);
    glUniform3fv(uniforms[UGravity], 1, &_gravity);
    if(self.particleDataWasUpdated)
    {
        if(nil == self.particleAttributeBuffer &&
           0 < [self.particleAttributesData length])
        {  // vertex attiributes haven't been sent to GPU yet
            self.particleAttributeBuffer =
            [[AGLKVertexAttribArrayBuffer alloc]
             initWithAttribStride:sizeof(AGLKParticleAttributes)
             numberOfVertices:
             (int)[self numberOfParticles]
             bytes:[self.particleAttributesData bytes]
             usage:GL_DYNAMIC_DRAW];
        }
        else
        {
            [self.particleAttributeBuffer
             reinitWithAttribStride:
             sizeof(AGLKParticleAttributes)
             numberOfVertices:
             (int)[self numberOfParticles]
             bytes:[self.particleAttributesData bytes]];
        }
        
        self.particleDataWasUpdated = NO;
    }
    [self.particleAttributeBuffer
     prepareToDrawWithAttrib:BeginPosition
     numberOfCoordinates:3
     attribOffset:
     offsetof(AGLKParticleAttributes, beginPosition)
     shouldEnable:YES];
    [self.particleAttributeBuffer
     prepareToDrawWithAttrib:BeginVelocity
     numberOfCoordinates:3
     attribOffset:
     offsetof(AGLKParticleAttributes, beginVelocity)
     shouldEnable:YES];

    [self.particleAttributeBuffer
     prepareToDrawWithAttrib:Force
     numberOfCoordinates:3
     attribOffset:
     offsetof(AGLKParticleAttributes, force)
     shouldEnable:YES];

    [self.particleAttributeBuffer
     prepareToDrawWithAttrib:A_Size
     numberOfCoordinates:2
     attribOffset:
     offsetof(AGLKParticleAttributes, a_size)
     shouldEnable:YES];

    [self.particleAttributeBuffer
     prepareToDrawWithAttrib:BeginTime
     numberOfCoordinates:1
     attribOffset:
     offsetof(AGLKParticleAttributes, beginTime)
     shouldEnable:YES];

    [self.particleAttributeBuffer
     prepareToDrawWithAttrib:EndTime
     numberOfCoordinates:1
     attribOffset:
     offsetof(AGLKParticleAttributes, endTime)
     shouldEnable:YES];
    
    glActiveTexture(GL_TEXTURE0);
    if(0 != self.texture2d0.name && self.texture2d0.enabled)
    {
        glBindTexture(GL_TEXTURE_2D, self.texture2d0.name);
    }
    else
    {
        glBindTexture(GL_TEXTURE_2D, 0);
    }

}


- (void)draw{
    glDepthMask(GL_FALSE);  // Disable depth buffer writes
    [self.particleAttributeBuffer
     drawArrayWithMode:GL_POINTS
     startVertexIndex:0
     numberOfVertices:(int)self.numberOfParticles];
    glDepthMask(GL_TRUE);  // Reenable depth buffer writes
}
@end
