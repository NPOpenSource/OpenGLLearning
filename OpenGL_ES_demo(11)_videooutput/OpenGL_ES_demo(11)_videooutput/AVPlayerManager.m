//
//  AVPlayerManager.m
//  OpenGL_ES_demo(11)_videooutput
//
//  Created by 温杰 on 2018/2/5.
//  Copyright © 2018年 温杰. All rights reserved.
//

#import "AVPlayerManager.h"
static void *AVPlayerItemStatusContext = &AVPlayerItemStatusContext;
@interface AVPlayerManager()<AVPlayerItemOutputPullDelegate>{
    dispatch_queue_t _myVideoOutputQueue;
    id _notificationToken;

}
@property (nonatomic ,strong)AVPlayer * player;
@property AVPlayerItemVideoOutput *currentOutput;
@property CADisplayLink *displayLink;

@end
@implementation AVPlayerManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.player = [[AVPlayer alloc] init];
        NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        [[self displayLink] addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[self displayLink] setPaused:YES];
        
        self.currentOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
        _myVideoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
        [[self currentOutput] setDelegate:self queue:_myVideoOutputQueue];
        [self addObserver];
    }
    return self;
}


-(void)addObserver{
    [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:AVPlayerItemStatusContext];

}
-(void)remveObserver{
    [self removeObserver:self forKeyPath:@"player.currentItem.status" context:AVPlayerItemStatusContext];

}

-(void)play;{
    [self.player play];
}
-(void)removeOutput;{
    if (self.currentOutput) {
        [[self.player currentItem] removeOutput:self.currentOutput];
    }
}

-(void)addOutPut:(AVPlayerItem*) outPut
{
    [outPut addOutput:self.currentOutput];
    [self.player replaceCurrentItemWithPlayerItem:outPut];
    [self.currentOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:0.03];
    
}

- (void)displayLinkCallback:(CADisplayLink *)sender
{
    CMTime outputItemTime = kCMTimeInvalid;
    CFTimeInterval nextVSync = ([sender timestamp] + [sender duration]);
    outputItemTime = [self.currentOutput itemTimeForHostTime:nextVSync];
    if ([self.currentOutput hasNewPixelBufferForItemTime:outputItemTime]) {
        CVPixelBufferRef pixelBuffer = NULL;
        pixelBuffer = [self.currentOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(displayPixelBuffer:)]) {
                [self.delegate displayPixelBuffer:pixelBuffer];
            }
        }
        
        if (pixelBuffer != NULL) {
            CFRelease(pixelBuffer);
        }
    }
}


-(void)addNotification{
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    if (_notificationToken) {
        _notificationToken = nil;
    }
   _notificationToken =  [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        // Simple item playback rewind.
        [[self.player currentItem] seekToTime:kCMTimeZero];
    }];

}
-(void)removetification{
    if (_notificationToken) {
    [[NSNotificationCenter defaultCenter] removeObserver:_notificationToken name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
        _notificationToken = nil;
    }
  
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
   
    if (context == AVPlayerItemStatusContext) {
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerItemStatusUnknown:
                break;
            case AVPlayerItemStatusReadyToPlay:
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(viewPresentationRect:)]) {
                        [self.delegate viewPresentationRect:self.player.currentItem.presentationSize];
                    }
                }
                break;
            case AVPlayerItemStatusFailed:{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[self.player.currentItem.error localizedDescription] message:[self.player.currentItem.error localizedFailureReason] delegate:nil cancelButtonTitle:@"cancelButtonTitle" otherButtonTitles:nil];
                [alertView show];
            }
                break;
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender
{
    // Restart display link.
    [[self displayLink] setPaused:NO];
}



@end
