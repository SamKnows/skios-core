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


@implementation  SKKitTestLatencyDetailedResults
@end


//
// Test: Latency
//
@interface SKKitTestLatency () <SKLatencyTestDelegate>
@property SKKitTestResultStatus mStatus;
@property SKLatencyTest *mpLatencyTest;
@property float mLatestLatencyMs;

@end

@implementation SKKitTestLatency

@synthesize mStatus;
@synthesize mProgressBlock;
@synthesize mpLatencyTest;
@synthesize mLatestLatencyMs;


- (instancetype)initWithLatencyTestDescriptor:(SKKitTestDescriptor_Latency*)latencyTest {
  self = [super init];
  
  if (self) {
#ifdef _DEBUG
    NSLog(@"DEBUG: SKKitTestLatency - init");
#endif // _DEBUG
    mStatus = SKKitTestResultStatus_Unknown;
    
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

-(void)setMockTestResultsDictionary:(NSDictionary*)mockResults {
  mpLatencyTest.outputResultsDictionary = [NSMutableDictionary dictionaryWithDictionary:mockResults];
}


-(NSString*) getTestResultValueString { // e.g. 17.2 Mbps
  
  if (mLatestLatencyMs < 0) {
    return @"Failed";
  }
  
  return [NSString stringWithFormat:@"%d ms", (int) mLatestLatencyMs];
}

-(SKKitTestResultStatus) getTestResultStatus { // e.g. SKKitTestResultStatus_Passed_Green
  return mStatus;
}

// MARK: Pragma SKLatencyTestDelegate
- (void)ltdTestDidFail {
  mStatus = SKKitTestResultStatus_Failed_Red;
  self.mProgressBlock(YES, 100.0, 0.0, 0.0, 0.0);
}

- (void)ltdTestDidSucceed {
  // TODO - mStatus = SKKitTestResultStatus_Warning_Yellow?
  mStatus = SKKitTestResultStatus_Passed_Green;
  
  double latency = mpLatencyTest.latency;
  double packetLoss = mpLatencyTest.packetLoss;
  double jitter = mpLatencyTest.jitter;
  
  mLatestLatencyMs = latency;
  self.mProgressBlock(YES, 100.0, latency, packetLoss, jitter);
}

- (void)ltdTestWasCancelled {
  mStatus = SKKitTestResultStatus_Warning_Yellow;
}

- (void)ltdUpdateProgress:(float)progress latency:(float)latency {
  
  if (progress > 100.0) {
    if (mStatus == SKKitTestResultStatus_Unknown) {
      mStatus = SKKitTestResultStatus_Passed_Green;
    }
    progress = 100.0;
  }
  //SK_ASSERT(progress < 100.0);
  //double latency = mpLatencyTest.latency;
  double packetLoss = mpLatencyTest.packetLoss;
  double jitter = mpLatencyTest.jitter;
  
  mLatestLatencyMs = latency;
  
  self.mProgressBlock(NO, progress, latency, packetLoss, jitter);
}

- (void)ltdUpdateStatus:(LatencyStatus)status {
  switch (status) {
    case FAILED_STATUS:
#ifdef DEBUG
      NSLog(@"DEBUG: SKKitTestLatency - failed!");
#endif // DEBUG
      mStatus = SKKitTestResultStatus_Failed_Red;
      mLatestLatencyMs = -1.0;
      self.mProgressBlock(YES, 100.0, -1.0, -1.0, -1.0);
      break;
    case CANCELLED_STATUS:
    case TIMEOUT_STATUS:
      mStatus = SKKitTestResultStatus_Failed_Red;
      break;
    case IDLE_STATUS:
    case INITIALIZING_STATUS:
    case RUNNING_STATUS:
    case COMPLETE_STATUS:
    case FINISHED_STATUS:
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

-(SKKitTestLatencyDetailedResults*) getDetailedLatencyResults {
  return [self.mpLatencyTest getDetailedLatencyResults];
}

-(NSTimeInterval) getDurationSeconds {
  return [mpLatencyTest getDurationSeconds];
}

-(NSNumber*) getPacketLossPercent {
  SKKitTestLatencyDetailedResults *detailedResults = [self getDetailedLatencyResults];
  
  if (detailedResults == nil) {
    SK_ASSERT(false);
    return [NSNumber numberWithInt:0];
  }
  
  int failures = detailedResults.mPacketsSent - detailedResults.mPacketsReceived;
  int successes = detailedResults.mPacketsReceived;
  
  int successesPlusFailures = successes + failures;
  if (successesPlusFailures  == 0) {
    SK_ASSERT(false);
    return [NSNumber numberWithInt:0];
  } else {
    float packetLossPercent = 0.0;
    packetLossPercent = 100.0F * ((float)failures) / ((float)(successes + failures));
    return [NSNumber numberWithFloat:packetLossPercent];
  }
}

-(NSNumber*) getJitterMilliseconds {
  SKKitTestLatencyDetailedResults *detailedResults = [self getDetailedLatencyResults];
  
  if (detailedResults == nil) {
    SK_ASSERT(false);
    return [NSNumber numberWithInt:0];
  }
  
  float jitterMicro = (float)detailedResults.mJitterMicro;
  float jitterMilli = jitterMicro / 1000.F;
  return [NSNumber numberWithFloat:jitterMilli];
}


@end
