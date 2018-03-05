//
//  LearningBlendView.h
//  OPenGL_ES_Demo(17)混合或者blend渲染
//
//  Created by 温杰 on 2018/2/26.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "OpenGLBaseView.h"

enum
{
    UNIFORM_TEXTURE0,
    UNIFORM_TEXTURE1,
    UNIFORM_TEXTURE_Mat_Scale_0,
    UNIFORM_TEXTURE_Mat_Scale_1,
    UNIFORM_TEXTURE_Mat,
    NUM_UNIFORMS
};

static GLint uniforms[NUM_UNIFORMS];

enum{
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};
typedef struct
{
    float position[3];
    float textureCoordinate[2];
} CustomVertex;
static const CustomVertex vertices[] =
{
    { .position = { -1.0, -1.0, 0 }, .textureCoordinate = { 0.0, 0.0 } },
    { .position = {  1.0, -1.0, 0}, .textureCoordinate = { 1.0, 0.0 } },
    { .position = {  1.0,  1.0, 0 }, .textureCoordinate = { 1.0, 1.0 }},
    { .position = { -1.0,  1.0, 0}, .textureCoordinate = { 0.0, 1.0 }
    }
};

@interface LearningBlendView : OpenGLBaseView

@end
