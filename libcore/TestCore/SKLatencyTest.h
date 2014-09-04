//
//  UDPLatencyTest.h
//  SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKTest.h"

#pragma mark - Interface

@protocol SKLatencyTestDelegate;

@class SKAutotest;

@interface SKLatencyTest : SKTest <SKLatencyOperationDelegate>
{
    // Test Parameters
    NSString *target;
    int port;
    int numDatagrams;
    double delayTimeout;        // converted to seconds
    double interPacketTime;     // microseconds
    double maxExecutionTime;    // converted to seconds
    double percentile;
    
    // Test status variables
    BOOL isRunning;
    BOOL testOK;
    LatencyStatus status;
    float progress;
    
    // Network type
    NSString *networkType;
    
    // Optional, Display name
    NSString *displayName;
    
    int testIndex;
}

// Test Parameters - Properties, so we can set them if required
@property (nonatomic, strong) NSString *target;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) int numDatagrams;
@property (nonatomic, assign) double delayTimeout;
@property (nonatomic, assign) double interPacketTime;
@property (nonatomic, assign) double maxExecutionTime;
@property (nonatomic, assign) double percentile;

// Test status variables
@property (atomic, assign) BOOL isRunning;
@property (atomic, assign) BOOL testOK;
@property (atomic, assign) LatencyStatus status;
@property (atomic, assign) float progress;

// Delegate
@property (atomic, strong) id <SKLatencyTestDelegate> latencyTestDelegate;

// Network Type
@property (nonatomic, strong) NSString *networkType;

// Display name
@property (nonatomic, strong) NSString *displayName;

@property (nonatomic, assign) int testIndex;

#pragma mark - Init

- (id)initWithTarget:(NSString*)_target 
                port:(int)_port 
        numDatagrams:(int)_numDatagrams 
     interPacketTime:(double)_interPacketTime
        delayTimeout:(double)_delayTimeout
          percentile:(long)_percentile
    maxExecutionTime:(double)_maxExecutionTime
            LatencyTestDelegate:(id <SKLatencyTestDelegate>)_delegate;

#pragma mark - Public Methods

- (void)reset;
- (BOOL)isReady;
- (void)startTest;
- (void)stopTest;
- (BOOL)isSuccessful;

// Must be overridden!
+(SKLatencyOperation*) createLatencyOperationWithTarget:(NSString*)_target
                                                   port:(int)_port
                                           numDatagrams:(int)_numDatagrams
                                        interPacketTime:(double)_interPacketTime
                                           delayTimeout:(double)_delayTimeout
                                             percentile:(long)_percentile
                                       maxExecutionTime:(double)_maxExecutionTime
                                               threadId:(int)_threadId
                                                TheTest:(SKTest*)inTheTest
                               LatencyOperationDelegate:(id <SKLatencyOperationDelegate>)_delegate;

-(void) setSKAutotest:(SKAutotest*)skAutotest;

@end

#pragma mark - SKLatencyTestDelegate

@protocol SKLatencyTestDelegate

- (void)ltdTestDidFail;
- (void)ltdTestDidSucceed;
- (void)ltdTestWasCancelled;
- (void)ltdUpdateProgress:(float)progress latency:(float)latency;
- (void)ltdUpdateStatus:(LatencyStatus)status;
- (void)ltdTestDidSendPacket:(NSUInteger)bytes;

@end
