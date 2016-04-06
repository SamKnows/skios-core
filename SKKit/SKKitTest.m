//
//  SKKitTest.m
//  SKKit
//
//  Created by Pete Cole on 26/01/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//

#import "SKKitTest.h"

#import "../../skios-core/libcore/SKCore.h"
#import "../../skios-core/libcore/TestCore/SKClosestTargetTest.h"
#import "../../skios-core/libcore/TestCore/SKJHttpTest.h"

// Without this call, we can't use Swift classes from our objective C.
// The file is AUTO-GENERATED and is under the build folder, you won't find it in the project area!
// Note that *only* swift code marked with @objc is put in this file...
//#import <SKKit/SKKit-Swift.h>

#import "SKKitTestDescriptor.h"
//
// Test: Closest Target - TODO - this has yet to be implemented fully.
//
@interface SKKitTestClosestTarget () <SKClosestTargetDelegate>
@property SKClosestTargetTest *mpClosestTargetTest;
//@property SKKitTestDescriptor_ClosestTarget *abc;
@end

@implementation SKKitTestClosestTarget

@synthesize mpClosestTargetTest;

- (instancetype)initWithClosestTargetTestDescriptor:(SKKitTestDescriptor_ClosestTarget*)closestTarget {
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
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] amdDoUpdateDataUsage:bytes];
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

- (instancetype)initWithDownloadTestDescriptor:(SKKitTestDescriptor_Download*)downloadTest {
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

- (void) cancel {
  [mpDownloadTest cancel];
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
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] amdDoUpdateDataUsage:bytes];
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
@synthesize mProgressBlock;

- (instancetype)initWithUploadTestDescriptor:(SKKitTestDescriptor_Upload*)uploadTest {
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

- (void) start:(TSKUploadTestProgressUpdate)progressBlock {
  self.mProgressBlock = progressBlock;
  [mpUploadTest startTest];
}

- (void) cancel {
  [mpUploadTest cancel];
}

-(CGFloat) getLatestSpeedAs1000BasedMbps {
  return [SKJHttpTest sGetLatestSpeedForExternalMonitorAsMbps];
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
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] amdDoUpdateDataUsage:bytes];
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
// Test: Latency
//
@interface SKKitTestLatency () <SKLatencyTestDelegate>
@property SKLatencyTest *mpLatencyTest;
@end

@implementation SKKitTestLatency

@synthesize mProgressBlock;
@synthesize mpLatencyTest;

- (instancetype)initWithLatencyTestDescriptor:(SKKitTestDescriptor_Latency*)latencyTest {
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

- (void) start:(TSKLatencyTestProgressUpdate)progressBlock {
  self.mProgressBlock = progressBlock;
  [mpLatencyTest startTest];
}

- (void) cancel {
  [mpLatencyTest cancel];
}

// Pragma SKLatencyTestDelegate
- (void)ltdTestDidFail {
  
}

- (void)ltdTestDidSucceed {
  
  double latency = mpLatencyTest.latency;
  double packetLoss = mpLatencyTest.packetLoss;
  double jitter = mpLatencyTest.jitter;
  self.mProgressBlock(YES, 100.0, latency, packetLoss, jitter);
  
}
- (void)ltdTestWasCancelled {
  
}

- (void)ltdUpdateProgress:(float)progress latency:(float)latency {
  
  if (progress > 100.0) {
    progress = 100.0;
  }
  //SK_ASSERT(progress < 100.0);
  //double latency = mpLatencyTest.latency;
  double packetLoss = mpLatencyTest.packetLoss;
  double jitter = mpLatencyTest.jitter;
  self.mProgressBlock(NO, progress, latency, packetLoss, jitter);
}

- (void)ltdUpdateStatus:(LatencyStatus)status {
  switch (status) {
  case FAILED_STATUS:
#ifdef DEBUG
      NSLog(@"DEBUG: SKKitTestLatency - failed!");
#endif // DEBUG
      self.mProgressBlock(YES, 100.0, -1.0, -1.0, -1.0);
      break;
  case IDLE_STATUS:
  case INITIALIZING_STATUS:
  case RUNNING_STATUS:
  case COMPLETE_STATUS:
  case FINISHED_STATUS:
  case CANCELLED_STATUS:
  case TIMEOUT_STATUS:
  case SEARCHING_STATUS:
  default:
    break;
  }
  
}
- (void)ltdTestDidSendPacket:(NSUInteger)bytes {
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] amdDoUpdateDataUsage:bytes];
}

//// This value isn't very accurate; an external timer gives a smoother value.
//- (double) getProgress0To100 {
//  return [mpLatencyTest getProgress0To100];
//}

@end