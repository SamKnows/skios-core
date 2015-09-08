//
//  SKKitTestAdaptor.m
//  SKKit
//
//  Created by Pete Cole on 26/01/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//

#import "SKKitTestAdaptor.h"

#import "../../skios-core/libcore/SKCore.h"
#import "../../skios-core/libcore/TestCore/SKClosestTargetTest.h"

// Without this call, we can't use Swift classes from our objective C.
// The file is AUTO-GENERATED and is under the build folder, you won't find it in the project area!
// Note that *only* swift code marked with @objc is put in this file...
//#import <SKKit/SKKit-Swift.h>

#import "SKScheduleParser.h"
//
// Test: Closest Target
//
@interface SKKitTestClosestTarget () <SKClosestTargetDelegate>
@property SKClosestTargetTest *mpClosestTargetTest;
@property SKScheduleTest_Descriptor_ClosestTarget *abc;
@end

@implementation SKKitTestClosestTarget

@synthesize mpClosestTargetTest;

- (instancetype)initWithClosestTargetTestDescriptor:(SKScheduleTest_Descriptor_ClosestTarget*)closestTarget {
  self = [super init];
  
  if (self) {
    NSLog(@"DEBUG: SKKitTestClosestTarget - init");
    mpClosestTargetTest = [[SKClosestTargetTest alloc] initWithTargets:closestTarget.mTargetArray ClosestTargetDelegate:self NumDatagrams:0];
  }
  return self;
}

-(void)dealloc {
  NSLog(@"DEBUG: SKKitTestClosestTarget - dealloc");
  mpClosestTargetTest = nil;
}

- (void)ctdDidCompleteClosestTargetTest:(NSString*)target latency:(double)latency {
  // TODO
}

- (void)ctdTestDidFail {
  // TODO
}
- (void)ctdDidSendPacket:(NSUInteger)bytes {
  // TODO
}

- (void)ctdDidStartTargetTesting {
  // TODO
}

- (void)ctdDidFinishAnotherTarget:(int)targetId withLatency:(double)latency withBest:(int)bestId {
  // TODO
}

@end

//
// Test: Download
//
@interface SKKitTestDownload () <SKHttpTestDelegate>
@property SKHttpTest *mpDownloadTest;
@end

@implementation SKKitTestDownload

@synthesize mpDownloadTest;
@synthesize mProgressBlock;

- (instancetype)initWithDownloadTestDescriptor:(SKScheduleTest_Descriptor_Download*)downloadTest {
  self = [super init];
  
  if (self) {
    NSLog(@"DEBUG: SKKitTestDownload - init");
    mpDownloadTest = [[SKHttpTest alloc]
                      initWithTarget:downloadTest.mTarget
                      port:(int)downloadTest.mPort
                      file:downloadTest.mFile
                      isDownstream:YES
                      warmupMaxTime:downloadTest.mWarmupMaxTimeSeconds*1000000.0
                      warmupMaxBytes:0
                      TransferMaxTimeMicroseconds:downloadTest.mTransferMaxTimeSeconds*1000000.0
                      transferMaxBytes:0
                      nThreads:(int)downloadTest.mNumberOfThreads
                      HttpTestDelegate:self];
  }
  return self;
}

-(void)dealloc {
#ifdef DEBUG
  NSLog(@"DEBUG: SKKitTestDownload - dealloc");
#endif // DEBUG
  
  mpDownloadTest = nil;
}

- (void) start:(TSKDownloadTestProgressUpdate)progressBlock {
  self.mProgressBlock = progressBlock;
  [mpDownloadTest startTest];
}

- (void) stop {
  [mpDownloadTest stopTest];
}

// Pragma SKHttpTestDelegate

- (void)htdUpdateStatus:(TransferStatus)status
               threadId:(NSUInteger)threadId {
  
  switch (status) {
    case FAILED:
#ifdef DEBUG
  NSLog(@"DEBUG: SKKitTestDownload - failed!");
#endif // DEBUG
      mProgressBlock(100.0, -1.0);
      break;
    case CANCELLED:
    case INITIALIZING:
    case WARMING:
    case TRANSFERRING:
    case COMPLETE:
    case FINISHED:
    case IDLE:
    default:
      break;
  }
}

- (void)htdUpdateDataUsage:(NSUInteger)totalBytes
                     bytes:(NSUInteger)bytes
                  progress:(float)progress {
  // TODO
}

- (void)htdDidUpdateTotalProgress:(float)progress BitrateMbps1024Based:(double)bitrateMbps1024Based {
  mProgressBlock(progress, bitrateMbps1024Based);
}

- (void)htdDidCompleteHttpTest:(double)bitrateMbps1024Based
            ResultIsFromServer:(BOOL)resultIsFromServer
               TestDisplayName:(NSString *)testDisplayName
{
  mProgressBlock(100.0, bitrateMbps1024Based);
}

@end

//
// Test: Upload
//

@interface SKKitTestUpload () <SKHttpTestDelegate>
@property SKHttpTest *mpUploadTest;
@end

@implementation SKKitTestUpload

@synthesize mpUploadTest;

- (instancetype)initWithUploadTestDescriptor:(SKScheduleTest_Descriptor_Upload*)uploadTest {
  self = [super init];
  
  if (self) {
    NSLog(@"DEBUG: SKKitTestUpload - init");
    mpUploadTest = [[SKHttpTest alloc]
                    initWithTarget:uploadTest.mTarget
                    port:(int)uploadTest.mPort
                    file:@"" // uploadTest.mFile
                    isDownstream:NO
                    warmupMaxTime:uploadTest.mWarmupMaxTimeSeconds*1000000.0
                    warmupMaxBytes:0
                    TransferMaxTimeMicroseconds:uploadTest.mTransferMaxTimeSeconds*1000000.0
                    transferMaxBytes:0
                    nThreads:(int)uploadTest.mNumberOfThreads
                    HttpTestDelegate:self];
  }
  return self;
}

-(void)dealloc {
  NSLog(@"DEBUG: SKKitTestUpload - dealloc");
  mpUploadTest = nil;
}

// Pragma SKHttpTestDelegate

- (void)htdUpdateStatus:(TransferStatus)status
               threadId:(NSUInteger)threadId {
  // TODO
}

- (void)htdUpdateDataUsage:(NSUInteger)totalBytes
                     bytes:(NSUInteger)bytes
                  progress:(float)progress {
  // TODO
}

- (void)htdDidUpdateTotalProgress:(float)progress BitrateMbps1024Based:(double)bitrateMbps1024Based {
  
}

- (void)htdDidCompleteHttpTest:(double)bitrateMbps1024Based
            ResultIsFromServer:(BOOL)resultIsFromServer
               TestDisplayName:(NSString *)testDisplayName
{
  // TODO
}
@end

//
// Test: Latency
//
@interface SKKitTestLatency () <SKLatencyTestDelegate>
@property SKLatencyTest *mpLatencyTest;
@end

@implementation SKKitTestLatency

@synthesize mpLatencyTest;

- (instancetype)initWithLatencyTestDescriptor:(SKScheduleTest_Descriptor_Latency*)latencyTest {
  self = [super init];
  
  if (self) {
    NSLog(@"DEBUG: SKKitTestLatency - init");
    mpLatencyTest = [[SKLatencyTest alloc]
                     initWithTarget:latencyTest.mTarget
                     port:(int)latencyTest.mPort
                     numDatagrams:(int)latencyTest.mNumberOfPackets
                     interPacketTime:latencyTest.mInterPacketTimeSeconds*1000000.0
                     delayTimeout:latencyTest.mDelayTimeoutSeconds*1000000.0
                     percentile:latencyTest.mPercentile
                     maxExecutionTime:latencyTest.mMaxTimeSeconds*1000000.0
                     LatencyTestDelegate:self];
  }
  
  return self;
}

-(void)dealloc {
  NSLog(@"DEBUG: SKKitTestLatency - dealloc");
  mpLatencyTest = nil;
}

// Pragma SKLatencyTestDelegate
- (void)ltdTestDidFail {
  
}
- (void)ltdTestDidSucceed {
  
}
- (void)ltdTestWasCancelled {
  
}
- (void)ltdUpdateProgress:(float)progress latency:(float)latency {
  
}
- (void)ltdUpdateStatus:(LatencyStatus)status {
  
}
- (void)ltdTestDidSendPacket:(NSUInteger)bytes {
  
}

@end