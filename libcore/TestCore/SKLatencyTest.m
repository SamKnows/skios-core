//
//  LatencyTest.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#pragma mark - Interface

@interface SKLatencyTest ()
{
  NSOperationQueue *queue;
}

@property (weak) SKAutotest* skAutotest;

@end

#pragma mark - Implementation

@implementation SKLatencyTest

@synthesize outputResultsArray;
@synthesize outputResultsDictionary;

// Final test results
@synthesize latency;
@synthesize packetLoss;
@synthesize jitter;
@synthesize stdDeviation;

// Test Parameters
@synthesize target;
@synthesize port;
@synthesize numDatagrams;
@synthesize delayTimeout;
@synthesize interPacketTime;
@synthesize maxExecutionTime;
@synthesize percentile;

// Test status variables
@synthesize status;
@synthesize testOK;
@synthesize isRunning;
@synthesize progress;

// Delegate
@synthesize latencyTestDelegate;

// Network Type
@synthesize networkType;

// Display Name
@synthesize displayName;

@synthesize testIndex;

@synthesize skAutotest;

#pragma mark - Init

- (id)initWithTarget:(NSString*)_target 
                port:(int)_port 
        numDatagrams:(int)_numDatagrams 
     interPacketTime:(double)_interPacketTime
        delayTimeout:(double)_delayTimeout
          percentile:(long)_percentile
    maxExecutionTime:(double)_maxExecutionTime
 LatencyTestDelegate:(id <SKLatencyTestDelegate>)_delegate
{
  self = [super init];
  
  if (self)
  {
    SK_ASSERT ([((NSObject*)_delegate) conformsToProtocol:@protocol(SKLatencyTestDelegate)]);
    
    target = _target;
    port = _port;
    numDatagrams = _numDatagrams;
    interPacketTime = _interPacketTime;
    delayTimeout = _delayTimeout;
    percentile = _percentile;
    maxExecutionTime = _maxExecutionTime;
    latencyTestDelegate = _delegate;
    outputResultsDictionary = [[NSMutableDictionary alloc] init];
    status = IDLE_STATUS;
    testOK = NO;
    isRunning = NO;
    testIndex = 0;
    
    queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:1];
  }
  
  return self;
}

#pragma mark - Dealloc

- (void)dealloc
{
  target = nil;
  
  if (nil != outputResultsDictionary)
  {
    outputResultsDictionary = nil;
  }
  
  if (nil != queue)
  {
    [queue cancelAllOperations];
    queue = nil;
  }
  
  if (nil != networkType)
  {
    networkType = nil;
  }
  
  if (nil != displayName)
  {
    displayName = nil;
  }
  
}

#pragma mark - Public Methods

- (BOOL)isReady
{
  if([target length] == 0)
  {
    return false;
  }
  if(port == 0)
  {
    return false;
  }
  if(numDatagrams == 0)
  {
    return false;
  }
  if(delayTimeout == 0)
  {
    return false;
  }
  if(interPacketTime == 0)
  {
    return false;
  }
  if(percentile < 0 || percentile > 100)
  {
    return false;
  }
  
  return true;
}

- (void)reset
{
  testOK = NO;
  jitter = latency = packetLoss = stdDeviation = 0;
}

+(SKLatencyOperation*) createLatencyOperationWithTarget:(NSString*)_target
                                                   port:(int)_port
                                           numDatagrams:(int)_numDatagrams
                                        interPacketTime:(double)_interPacketTime
                                           delayTimeout:(double)_delayTimeout
                                             percentile:(long)_percentile
                                       maxExecutionTime:(double)_maxExecutionTime
                                               threadId:(int)_threadId
                                                TheTest:(SKTest*)inTheTest
                               LatencyOperationDelegate:(id <SKLatencyOperationDelegate>)_delegate
{
  return [[SKLatencyOperation alloc] initWithTarget:_target
                                                port:_port
                                        numDatagrams:_numDatagrams
                                     interPacketTime:_interPacketTime
                                        delayTimeout:_delayTimeout
                                          percentile:_percentile
                                    maxExecutionTime:_maxExecutionTime
                                            threadId:_threadId
                                             TheTest:inTheTest
                            LatencyOperationDelegate:_delegate];
}

- (void)startTest
{
  [self reset];
  [queue cancelAllOperations];
  [outputResultsDictionary removeAllObjects];
  
  SKLatencyOperation *operation = [self.class createLatencyOperationWithTarget:target
                                                                          port:port 
                                                                  numDatagrams:numDatagrams 
                                                               interPacketTime:interPacketTime 
                                                                  delayTimeout:delayTimeout 
                                                                    percentile:percentile 
                                                              maxExecutionTime:maxExecutionTime
                                                                      threadId:0
                                                                       TheTest:self
                                                      LatencyOperationDelegate:self];
  
  [operation setSKAutotest:self.skAutotest];
  
  [queue addOperation:operation];
  
  isRunning = YES;
}

- (void)stopTest
{
  if (nil != queue)
  {
#ifdef DEBUG
    NSLog(@"DEBUG: cancelling %d latency test operations!", (int)[queue operationCount]);
#endif // DEBUG
    [queue cancelAllOperations];
  }
  isRunning = NO;
}

// This value isn't very accurate; an external timer gives a smoother value.
- (float)getProgress0To100
{
  return self.progress;
}

- (BOOL)isSuccessful
{
  return testOK;
}

#pragma mark - SKLatencyOperationDelegate

- (void)lodTestDidSendPacket:(NSUInteger)bytes
{
  [self.latencyTestDelegate ltdTestDidSendPacket:bytes];
}

- (void)lodTestDidFail:(NSUInteger)threadId
{
  testOK = NO;
  isRunning = NO;
  [self.latencyTestDelegate ltdTestDidFail];
  
  NSLog(@"lodTestDidFail, threadId : %d", (int)threadId);
}

- (void)lodTestDidSucceed:(double)latency_
               packetLoss:(int)packetLoss_ 
                   jitter:(double)jitter_ 
             stdDeviation:(double)stdDeviation_
                 threadId:(NSUInteger)threadId_
{
  testOK = YES;
  isRunning = NO;
  
  jitter = jitter_;
  latency = latency_;
  packetLoss = packetLoss_;
  stdDeviation = stdDeviation_;
 
#ifdef DEBUG
  NSLog(@"DEBUG: Latency : %f", latency);
//  NSLog(@"DEBUG: Std Deviation : %f", stdDeviation);
//  NSLog(@"DEBUG: Packet Loss : %d", packetLoss);
//  NSLog(@"DEBUG: Jitter : %f", jitter);
#endif // DEBUG
  
  [self.latencyTestDelegate ltdTestDidSucceed];
}

- (void)lodTestWasCancelled:(NSUInteger)threadId
{
  isRunning = NO;
  [self.latencyTestDelegate ltdTestWasCancelled];
}

- (void)lodUpdateProgress:(float)progress_ threadId:(NSUInteger)threadId {
  SK_ASSERT(false);
}

//###HG
- (void)lodUpdateProgress:(float)progress_ threadId:(NSUInteger)threadId latency:(float)latency_
{
  self.progress = progress_;
  [self.latencyTestDelegate ltdUpdateProgress:progress_ latency:latency_];
}

- (void)lodUpdateStatus:(LatencyStatus)status_ threadId:(NSUInteger)threadId
{
  self.status = status_;
  
  SK_ASSERT(self.latencyTestDelegate != nil);
  [self.latencyTestDelegate ltdUpdateStatus:status_];
}

-(void) setSKAutotest:(SKAutotest*)inSkAutotest {
  self.skAutotest = inSkAutotest;
}

@end
