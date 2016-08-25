//
//  SKKitTestLatency.m
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

// MARK: pragma SKKitTestProtocol

- (void) cancel {
  [mpLatencyTest cancel];
}

-(SKKitTestType) getTestType {
  return SKKitTestType_Latency;
}

-(NSDictionary*) getTestResultsDictionary {
  SK_ASSERT( mpLatencyTest.outputResultsDictionary != nil);
  return mpLatencyTest.outputResultsDictionary;
}


// MARK: Pragma SKLatencyTestDelegate
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
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] amdDoUpdateDataUsage:(int)bytes];
}

//// This value isn't very accurate; an external timer gives a smoother value.
//- (double) getProgress0To100 {
//  return [mpLatencyTest getProgress0To100];
//}

@end
