//
//  LatencyOperation.h
//  SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ONE_HUNDRED     100
#define ONE_THOUSAND    1000
#define ONE_MILLION     1000000

#define SERVERTOCLIENTMAGIC 0x00006000
#define CLIENTTOSERVERMAGIC 0x00009000


typedef enum { 
    IDLE_STATUS, 
    INITIALIZING_STATUS, 
    RUNNING_STATUS, 
    COMPLETE_STATUS, 
    FINISHED_STATUS, 
    CANCELLED_STATUS, 
    TIMEOUT_STATUS,
    SEARCHING_STATUS,
    FAILED_STATUS
} LatencyStatus;

#pragma mark - Delegate

@protocol SKLatencyOperationDelegate

- (void)lodTestDidSendPacket:(NSUInteger)bytes;

- (void)lodTestDidFail:(NSUInteger)threadId;

- (void)lodTestDidSucceed:(double)latency_
               packetLoss:(int)packetLoss_
                   jitter:(double)jitter_
             stdDeviation:(double)stdDeviation_
                 threadId:(NSUInteger)threadId_;

- (void)lodTestWasCancelled:(NSUInteger)threadId;

- (void)lodUpdateProgress:(float)progress_ threadId:(NSUInteger)threadId;
- (void)lodUpdateProgress:(float)progress_ threadId:(NSUInteger)threadId latency:(float)latency_; //###HG
- (void)lodUpdateStatus:(LatencyStatus)status_ threadId:(NSUInteger)threadId;

@end

#pragma mark - Interface

@class SKLatencyTest;

@interface SKLatencyOperation : NSOperation <AsyncUdpSocketDelegate, GCDAsyncSocketDelegate>
{    
  NSString *target;
  int port;
  int numDatagrams;
  double delayTimeout;        // converted to seconds
  double interPacketTime;     // microseconds
  double maxExecutionTime;    // converted to seconds
  double percentile;
  BOOL testOK;
  BOOL isClosestTargetTest;
  
  int totalPacketsReceived;
  int totalPacketsLost;
  int packetLostPercentage;
  int packetReceivedPercentage;
  
  double minimumTripTime;
  double maximumTripTime;
  
  double jitter;
  double averagePacketTime;
  double standardDeviation;
  
  BOOL _Finished;
  BOOL _Executing;
  
  int threadId;
  
  NSTimer *cancelTimer;
  
  NSString *hostIPAddress;
    
    float lastLatency;
}

@property (nonatomic, strong) NSString *target;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) int numDatagrams;
@property (nonatomic, assign) double delayTimeout;
@property (nonatomic, assign) double interPacketTime;
@property (nonatomic, assign) double maxExecutionTime;
@property (nonatomic, assign) double percentile;
@property (nonatomic, assign) BOOL isClosestTargetTest;
@property (atomic, assign) BOOL testOK;

@property (nonatomic, assign) int totalPacketsReceived;
@property (nonatomic, assign) int totalPacketsLost;
@property (nonatomic, assign) int packetLostPercentage;
@property (nonatomic, assign) int packetReceivedPercentage;
@property (nonatomic, assign) double minimumTripTime;
@property (nonatomic, assign) double maximumTripTime;

@property (nonatomic, assign) double jitter;
@property (nonatomic, assign) double averagePacketTime;
@property (nonatomic, assign) double standardDeviation;

@property (nonatomic, assign) int threadId;

@property (atomic, strong) id<SKLatencyOperationDelegate> latencyOperationDelegate;

@property (nonatomic, strong) NSString *hostIPAddress;

#pragma mark - Init

- (id)initWithTarget:(NSString*)_target 
                port:(int)_port 
        numDatagrams:(int)_numDatagrams 
     interPacketTime:(double)_interPacketTime
        delayTimeout:(double)_delayTimeout
          percentile:(long)_percentile
    maxExecutionTime:(double)_maxExecutionTime
            threadId:(int)_threadId
             TheTest:(SKTest*)inTheTest
            LatencyOperationDelegate:(id<SKLatencyOperationDelegate>)_delegate;

#pragma mark - Methods

- (void)start;
// Must be implemented by a base class!
- (void)tearDown;
- (void)outputResults;

+(NSString*) getIdleStatus;
+(NSString*) getInitializingStatus;
+(NSString*) getRunningStatus;
+(NSString*) getCompleteStatus;
+(NSString*) getFinishedStatus;
+(NSString*) getCancelledStatus;
+(NSString*) getTimeoutStatus;
+(NSString*) getSearchingStatus;
+(NSString*) getFailedStatus;
+(NSString*) getStringSpace;

-(void) setSKAutotest:(SKAutotest*)inSkAutotest;

@end

