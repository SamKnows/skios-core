//
//  SKKitTestAdaptor.h
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

typedef void (^TSKDownloadTestProgressUpdate)(float progress, double currentBitrate);

@interface SKKitTestDownload : NSObject
@property (copy) TSKDownloadTestProgressUpdate mProgressBlock;

- (instancetype)initWithDownloadTestDescriptor:(SKScheduleTest_Descriptor_Download*)downloadTest;
- (void) start:(TSKDownloadTestProgressUpdate)progressBlock;
- (void) stop;
@end

@interface SKKitTestUpload : NSObject
- (instancetype)initWithUploadTestDescriptor:(SKScheduleTest_Descriptor_Upload*)uploadTest;
@end

@interface SKKitTestLatency : NSObject
- (instancetype)initWithLatencyTestDescriptor:(SKScheduleTest_Descriptor_Latency*)latencyTest;
@end