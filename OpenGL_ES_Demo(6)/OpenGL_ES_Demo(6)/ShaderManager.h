//
//  ShaderManager.h
//  OpenGL_ES_Demo(1)
//
//  Created by 温杰 on 2018/1/26.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface ShaderManager : NSObject
@property (nonatomic,readonly ) GLuint program;
- (BOOL)loadShaderName:(NSString *)fileName;
@end
