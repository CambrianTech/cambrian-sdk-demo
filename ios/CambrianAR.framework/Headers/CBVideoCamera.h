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

#ifdef __IPHONE_11_0
#   define ARKIT_ENABLED 1
#else
#   define ARKIT_ENABLED 0
#endif

#if ARKIT_ENABLED
#import <ARKit/ARKit.h>
#endif

#if ARKIT_ENABLED
@protocol CBVideoCameraDelegate <ARSessionDelegate>
#else
@protocol CBVideoCameraDelegate
#endif

- (void) sendFrame:(CVPixelBufferRef)pixelBuffer;

@end

@interface CBVideoCamera : NSObject

@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) BOOL isPaused;
@property (readonly) AVCaptureDevice *inputCamera;

#if ARKIT_ENABLED
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
@property (readonly) ARSession *arSession;
#pragma clang diagnostic pop
#endif

- (id) init:(id <CBVideoCameraDelegate>)delegate;

- (BOOL)startRunning;
- (BOOL)stopRunning;

- (void)pause;
- (void)resume;

- (BOOL)setExposureMode:(AVCaptureExposureMode)exposureMode;
- (BOOL)exposeAtPoint:(CGPoint)point
      useAutoExposure:(BOOL)useAutoExposure;

@end
