//
//  CBVideoCamera.h
//  Cambrian
//
//  Created by Joel Teply on 10/19/12.
//
//

#import <GLKit/GLKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@protocol CBVideoCameraDelegate
- (void) sendFrame:(CMSampleBufferRef)sampleBuffer isYUV:(BOOL)isYUV;
@end

@interface CBVideoCamera : NSObject

@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) BOOL isPaused;
@property (readonly) AVCaptureDevice *inputCamera;

- (id) init:(id <CBVideoCameraDelegate>)delegate;

- (BOOL)startRunning;
- (BOOL)stopRunning;

- (void)pause;
- (void)resume;

- (BOOL)setExposureMode:(AVCaptureExposureMode)exposureMode;
- (BOOL)exposeAtPoint:(CGPoint)point
      useAutoExposure:(BOOL)useAutoExposure;

@end
