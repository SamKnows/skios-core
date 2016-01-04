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

@class SKScheduleTest_Descriptor_ClosestTarget;
@class SKScheduleTest_Descriptor_Download;
@class SKScheduleTest_Descriptor_Upload;
@class SKScheduleTest_Descriptor_Latency;

@interface SKKitTestClosestTarget : NSObject
- (instancetype)initWithClosestTargetTestDescriptor:(SKScheduleTest_Descriptor_ClosestTarget*)closestTarget;
@end

typedef void (^TSKDownloadTestProgressUpdate)(float progress, double bitrateMbps1024Based);

@interface SKKitTestDownload : NSObject
@property (copy) TSKDownloadTestProgressUpdate mProgressBlock;

- (instancetype)initWithDownloadTestDescriptor:(SKScheduleTest_Descriptor_Download*)downloadTest;
- (void) start:(TSKDownloadTestProgressUpdate)progressBlock;
- (void) stop;
@end

typedef void (^TSKUploadTestProgressUpdate)(float progress, double bitrateMbps1024Based);

@interface SKKitTestUpload : NSObject
@property (copy) TSKUploadTestProgressUpdate mProgressBlock;

- (instancetype)initWithUploadTestDescriptor:(SKScheduleTest_Descriptor_Upload*)uploadTest;
- (void) start:(TSKUploadTestProgressUpdate)progressBlock;
- (void) stop;
-(CGFloat) getLatestSpeedAs1000BasedMbps;
@end

typedef void (^TSKLatencyTestProgressUpdate)(BOOL finalResult, float progress, double latency, double packetLoss, double jitter);

@interface SKKitTestLatency : NSObject
@property (copy) TSKLatencyTestProgressUpdate mProgressBlock;

- (instancetype)initWithLatencyTestDescriptor:(SKScheduleTest_Descriptor_Latency*)latencyTest;
- (void) start:(TSKLatencyTestProgressUpdate)progressBlock;
- (void) stop;
@end