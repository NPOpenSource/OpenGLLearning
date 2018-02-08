//
//  ViewController.m
//  LearnOpenGLES
//
//  Created by loyinglin on 16/5/10.
//  Copyright © 2016年 loyinglin. All rights reserved.
//
precision mediump float;
varying highp vec2 texCoordVarying;

uniform sampler2D Sampler;


void main()
{
    lowp vec4 textureColor = texture2D(Sampler,texCoordVarying);
    gl_FragColor = textureColor;
}
