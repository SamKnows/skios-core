//
//  ClosestTarget.h
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Delegate

@protocol SKClosestTargetDelegate <NSObject>

- (void)ctdDidCompleteClosestTargetTest:(NSString*)target latency:(double)latency;
- (void)ctdTestDidFail;
- (void)ctdDidSendPacket:(NSUInteger)bytes;

//### HG
- (void)ctdDidStartTargetTesting;
- (void)ctdDidFinishAnotherTarget:(int)targetId withLatency:(double)latency withBest:(int)bestId;

@end

@class SKAutotest;

@interface SKClosestTargetTest : SKTest
{
  // Test Parameters
  int port;
  int numDatagrams;
  double delayTimeout;        // converted to seconds
  double interPacketTime;     // microseconds
  double percentile;
  
  // Test status variables
  BOOL isRunning;
  
  NSArray *targets;
  int nThreads;
  
  double lowestLatency;
  NSUInteger lowestLatencyThreadId;
  
  // Network Type
  NSString *networkType;
  
  // Display Name
  NSString *displayName;
  
  int testIndex;
}

@property (readonly) NSOperationQueue *queue;

// Test Parameters - Properties, so we can set them if required
@property (nonatomic, assign) int port;
@property (nonatomic, assign) int numDatagrams;
@property (nonatomic, assign) double delayTimeout;
@property (nonatomic, assign) double interPacketTime;
@property (nonatomic, assign) double percentile;

// Test status variables
@property (atomic, assign) BOOL isRunning;

@property (nonatomic, strong) NSArray *targets;

// Delegate
@property (atomic, strong) id<SKClosestTargetDelegate> closestTargetDelegate;

@property (nonatomic, assign) int testIndex;

// Network Type
@property (nonatomic, strong) NSString *networkType;

// Display Name
@property (nonatomic, strong) NSString *displayName;

#pragma mark - Init

- (id)initWithTargets:(NSArray*)_targets ClosestTargetDelegate:(id<SKClosestTargetDelegate>)_delegate NumDatagrams:(int)numDatagrams;

#pragma mark - Methods

- (void)reset;
- (void)startTest;
- (void)stopTest;

- (BOOL)isReady;

-(void) setSKAutotest:(SKAutotest*)skAutotest;

@end

