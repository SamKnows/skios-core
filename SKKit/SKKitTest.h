//
//  SKKitTest.h
//  SKKit
//
//  Created by Pete Cole on 26/01/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//

// Swift-accessible that act as adaptors around the core tests
// (which are implemented (using Objective-C) in libcore)

#import <Foundation/Foundation.h>

//#import <SKKit/SKKit-Swift.h>

@class SKKitTestDescriptor_ClosestTarget;
@class SKKitTestDescriptor_Download;
@class SKKitTestDescriptor_Upload;
@class SKKitTestDescriptor_Latency;

@interface SKKitTestClosestTarget : NSObject
- (instancetype)initWithClosestTargetTestDescriptor:(SKKitTestDescriptor_ClosestTarget*)closestTarget;
@end

typedef void (^TSKDownloadTestProgressUpdate)(float progress, double bitrateMbps1024Based);

@interface SKKitTestDownload : NSObject
@property (copy) TSKDownloadTestProgressUpdate mProgressBlock;

- (instancetype)initWithDownloadTestDescriptor:(SKKitTestDescriptor_Download*)downloadTest;
- (void) start:(TSKDownloadTestProgressUpdate)progressBlock;
- (void) cancel;
@end

typedef void (^TSKUploadTestProgressUpdate)(float progress, double bitrateMbps1024Based);

@interface SKKitTestUpload : NSObject
@property (copy) TSKUploadTestProgressUpdate mProgressBlock;

- (instancetype)initWithUploadTestDescriptor:(SKKitTestDescriptor_Upload*)uploadTest;
- (void) start:(TSKUploadTestProgressUpdate)progressBlock;
- (void) cancel;
-(CGFloat) getLatestSpeedAs1000BasedMbps;
@end

typedef void (^TSKLatencyTestProgressUpdate)(BOOL finalResult, float progress, double latency, double packetLoss, double jitter);

@interface SKKitTestLatency : NSObject
@property (copy) TSKLatencyTestProgressUpdate mProgressBlock;

- (instancetype)initWithLatencyTestDescriptor:(SKKitTestDescriptor_Latency*)latencyTest;
- (void) start:(TSKLatencyTestProgressUpdate)progressBlock;
- (void) cancel;
//- (double) getProgress0To100;
@end