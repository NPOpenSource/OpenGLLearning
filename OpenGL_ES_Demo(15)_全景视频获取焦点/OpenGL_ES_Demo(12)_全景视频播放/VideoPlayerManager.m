//
//  VideoPlayerManager.m
//  OpenGL_ES_Demo(12)_全景视频播放
//
//  Created by 温杰 on 2018/2/7.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "VideoPlayerManager.h"

@interface VideoPlayerManager()
@property (nonatomic , strong) AVAsset *mAsset;
@property (nonatomic , strong) CADisplayLink *mDisplayLink;
@property (nonatomic , strong) AVAssetReader *mReader;
@property (nonatomic , strong) AVAssetReaderTrackOutput *mReaderVideoTrackOutput;
@end

@implementation VideoPlayerManager
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        self.mDisplayLink.frameInterval = 2; //FPS=30
        [[self mDisplayLink] addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[self mDisplayLink] setPaused:YES];
    }
    return self;
}
-(void)loadLocalName:(NSString *)urlName{
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *inputAsset = [[AVURLAsset alloc] initWithURL:[[NSBundle mainBundle] URLForResource:urlName withExtension:@"mp4"] options:inputOptions];
    __weak typeof(self) weakSelf = self;
    [inputAsset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler: ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = nil;
            AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
            if (tracksStatus != AVKeyValueStatusLoaded)
            {
                NSLog(@"error %@", error);
                return;
            }
            weakSelf.mAsset = inputAsset;
            [weakSelf processAsset];
        });
    }];
}
- (AVAssetReader*)createAssetReader
{
    NSError *error = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:self.mAsset error:&error];
    
    NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
    
    [outputSettings setObject:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    self.mReaderVideoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[[self.mAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] outputSettings:outputSettings];
    self.mReaderVideoTrackOutput.alwaysCopiesSampleData = NO;
    [assetReader addOutput:self.mReaderVideoTrackOutput];
    
    return assetReader;
}


- (void)processAsset
{
    self.mReader = [self createAssetReader];
    
    if ([self.mReader startReading] == NO)
    {
        NSLog(@"Error reading from file at URL: %@", self.mAsset);
        return;
    }
    else {
        [self.mDisplayLink setPaused:NO];
        NSLog(@"Start reading success.");
    }
}

- (void)displayLinkCallback:(CADisplayLink *)sender
{
    CMSampleBufferRef sampleBuffer = [self.mReaderVideoTrackOutput copyNextSampleBuffer];
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer) {
        if (self.OneframePixelBufferBlock) {
            self.OneframePixelBufferBlock(pixelBuffer);
        }
        if (pixelBuffer != NULL) {
            CFRelease(pixelBuffer);
        }
    }
    else {
        NSLog(@"播放完成");
        [self.mDisplayLink setPaused:YES];
    }
}




@end
