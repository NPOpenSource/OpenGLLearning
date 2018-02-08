//
//  CameraManager.m
//  OpenGL_ES_demo(12)_摄像头
//
//  Created by 温杰 on 2018/2/6.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "CameraManager.h"

@interface CameraManager()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    dispatch_queue_t mProcessQueue;

}
@property (nonatomic , strong) AVCaptureSession *mCaptureSession; //负责输入和输出设备之间的数据传递
@property (nonatomic , strong) AVCaptureDeviceInput *mCaptureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (nonatomic , strong) AVCaptureVideoDataOutput *mCaptureDeviceOutput; //
@end

@implementation CameraManager
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initbase];
    }
    return self;
}
-(void)initbase{
    self.mCaptureSession = [[AVCaptureSession alloc] init];
    self.mCaptureSession.sessionPreset 
    = AVCaptureSessionPreset640x480;
    mProcessQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    AVCaptureDevice *inputCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == AVCaptureDevicePositionBack)
        {
            inputCamera = device;
        }
    }
    self.mCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:nil];
 
    if ([self.mCaptureSession canAddInput:self.mCaptureDeviceInput]) {
        [self.mCaptureSession addInput:self.mCaptureDeviceInput];
    }
    
    self.mCaptureDeviceOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.mCaptureDeviceOutput setAlwaysDiscardsLateVideoFrames:NO];
    
    [self.mCaptureDeviceOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [self.mCaptureDeviceOutput setSampleBufferDelegate:self queue:mProcessQueue];
    if ([self.mCaptureSession canAddOutput:self.mCaptureDeviceOutput]) {
        [self.mCaptureSession addOutput:self.mCaptureDeviceOutput];
    }
    
    AVCaptureConnection *connection = [self.mCaptureDeviceOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
     [self.mCaptureSession startRunning];
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    static long frameID = 0;
    ++frameID;
    CFRetain(sampleBuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (self.dealDataBlock) {
            self.dealDataBlock(pixelBuffer);
        }
        CFRelease(sampleBuffer);
    });
}



@end
