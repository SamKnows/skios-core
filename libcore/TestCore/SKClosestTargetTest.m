//
//  SKClosestTarget.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#define NPACKETS        5
#define INTERPACKETTIME 10000
#define DELAYTIMEOUT    2000000
#define PORT            6000
#define PERCENTILE      100

#define NUMBEROFPACKETSMAX  20
#define NUMBEROFPACKETSMIN  5
#define INTERPACKETIMEMAX   60000000
#define INTERPACKETIMEMIN   10000
#define DELAYTIMEOUTMIN     1000000
#define DELAYTIMEOUTMAX     5000000
#define NUMBEROFTARGETSMAX  50
#define NUMBEROFTARGETSMIN  1

@interface SKClosestTargetTest () <SKLatencyOperationDelegate>

@property int threadCounter;

@property (weak) SKAutotest* skAutotest;

- (void)checkIfDone:(int)threadCount;

@end

@implementation SKClosestTargetTest

@synthesize latency;
@synthesize packetLoss;
@synthesize jitter;
@synthesize stdDeviation;

@synthesize threadCounter;
@synthesize queue;

// Test Parameters
@synthesize port;
@synthesize numDatagrams;
@synthesize delayTimeout;
@synthesize interPacketTime;
@synthesize percentile;

// Test status variables
@synthesize isRunning;

@synthesize targets;
@synthesize closestTargetDelegate;
@synthesize testIndex;
@synthesize networkType;
@synthesize displayName;

@synthesize skAutotest;

#pragma mark - Init

- (id)initWithTargets:(NSArray*)_targets ClosestTargetDelegate:(id<SKClosestTargetDelegate>)_delegate NumDatagrams:(int)inNumDatagrams
{
  self = [super init];
  
  SK_ASSERT ([((NSObject*)_delegate) conformsToProtocol:@protocol(SKClosestTargetDelegate)]);
 
  // The supplied inNumDatagrams is ALWAYS zero in our current XML schema!
  SK_ASSERT(inNumDatagrams == 0);
  
  if (self)
  {
    if ((inNumDatagrams >= NUMBEROFPACKETSMIN) || (inNumDatagrams >= NUMBEROFPACKETSMAX)) {
      numDatagrams = inNumDatagrams;
    } else {
      numDatagrams = NPACKETS;
    }
    
    port = PORT;
    interPacketTime = INTERPACKETTIME;
    delayTimeout = DELAYTIMEOUT;
    percentile = PERCENTILE;
    closestTargetDelegate = _delegate;
    targets = [_targets copy];
    nThreads = (int)[targets count];
    if(nThreads < 1 || nThreads > MAXNTHREADS)
    {
      SK_ASSERT(false);
    }
    isRunning = NO;
    threadCounter = 0;
    lowestLatency = DBL_MAX;
    lowestLatencyThreadId = 0;
    testIndex = 0;
  }
  
  return self;
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
                               LatencyOperationDelegate:(id<SKLatencyOperationDelegate>)_delegate
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

//
// The initial UDP-based closest target test for EAQ Mobility (29 servers)
// is very quick to fail (almost instantaneous) when the UDP is blocked by firewall using the Simulator;
// that would be because the sockets are prevented from being constructed *at all*.
//
// However, when blocked on SK-Test, the UDP blocking *can* take **at least** 10 seconds to respond!
// The reason for this is that there are 5 sequential attempts made to send UDP packets to every server,
// each with a 2 second timeout [and many such attempts are made in parallel].
// If **any one** of those attempts fail, then the UDP-based closest target test will take *at least* 10 seconds
// before the HTTP-based fallback tests are run.
//
// HTTP querying on iOS is also very quick (figures from Simulator). Note that the time is, basically,
// determined by the value for CHttpQueryTimeoutSeconds.
//
// 2014-05-09 09:06:50.780 EAQMobility[22222:60b] DEBUG: FIRED ALL HTTP QUERIES, after 0.00961405 seconds!
// 2014-05-09 09:06:52.802 EAQMobility[22222:60b] DEBUG: Found closest target via HTTP, at n1-tivit-saopaulo-br.samknows.com, with 0.438875, after 2.03195 seconds
//


// Timeout for each request...
// This determines how long the HTTP fallback querying will take.
const NSTimeInterval CHttpQueryTimeoutSeconds = 2.0;

// Number of queries to fire-off per server
// Has zero effect on how long it all takes to compute!
const int cQueryCountPerServer = 3;

// Fire the async query for the HTTP Latency test.
// Note that this method is overriddeden by the mock tests!
-(void) fireAsyncHttpQueryForHttpLatencyTest:(NSString*)urlString Callback:(SKQueryCompleted)callback {
  [SKNSURLAsyncQuery
   fireURLRequest:urlString
   InjectDictionaryIntoHeader:nil
   Callback:callback
   WithTimeout:CHttpQueryTimeoutSeconds
   ];
}

-(NSDateFormatter *)getDateFormatterWithMilliseconds {
  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  [df setDateFormat:@"yyyy-MM-dd-HH:mm:ss:SSS"];
  return df;
}


/*
 Some networks block UDP traffic; and some might even block raw TCP traffic!
 GIVEN: performing a closest target test
 WHEN:  UDP fails
 THEN:  we need use HTTP as the ultimate failsafe.
 Therefore, as a fall-back from the UDP best-target-selection process:
 1. Make three HTTP requests to "/" on each server. Set a 2 second timeout on each request.
 Ideally, you should parallelise them (maybe allow up to 6 concurrent requests).
 2. Choose the server with the lowest non-zero response time
 (not an average of the three requests - just take the one with the absolute lowest)
 */
-(void) tryHttpClosestTargetTestIfUdpTestFails {
  // Posting to NSNotificationCenter *must* be done in the main thread!
  [[NSNotificationCenter defaultCenter] postNotificationName:kSKAAutoTest_UDPFailedSkipTests object:self];
  
#ifdef DEBUG
  NSLog(@"DEBUG: CLOSEST HTTP: tryHttpClosestTargetTestIfUdpTestFails");
#endif // DEBUG
  // TODO!
 
  // 3 Threads per server!
  int serverCount = nThreads;
#ifdef DEBUG
  NSLog(@"DEBUG: tryHttpClosestTargetTestIfUdpTestFails - serverCount=%d", (int)serverCount);
#endif // DEBUG
  
#ifdef DEBUG
  NSLog(@"DEBUG: tryHttpClosestTargetTestIfUdpTestFails - targets=%@", [targets description]);
#endif // DEBUG
  
  int queriesToRun = serverCount * cQueryCountPerServer;
#ifdef DEBUG
  NSLog(@"DEBUG: tryHttpClosestTargetTestIfUdpTestFails - queriesToRun=%d", (int)queriesToRun);
#endif // DEBUG
 
#ifdef DEBUG
  __block NSDate *timeStartOfHttpQuery = [NSDate date];
#endif // DEBUG
 
  __block int queryCompleteCountdown = queriesToRun;
  
  __block NSMutableArray *startTimesPerQuery = [NSMutableArray new];
  __block NSMutableArray *bestLatencyPerServer = [NSMutableArray new];
  
  int i;
  for (i=0; i<queriesToRun; i++) {
    [startTimesPerQuery addObject:[NSDate date]];
  }
  
  int serverIndex;
  for (serverIndex=0; serverIndex < serverCount; serverIndex++)
  {
    // -100 means - no succesful response - yet!
    [bestLatencyPerServer addObject:@(-100.0)];
  }
  
#ifdef DEBUG
  NSDateFormatter *df = [self getDateFormatterWithMilliseconds];
#endif // DEBUG
  
  for (serverIndex=0; serverIndex < serverCount; serverIndex++)
  {
    NSString *target = targets[serverIndex];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/", target];
    
    int queryIndexForServer;
    for (queryIndexForServer=0; queryIndexForServer < cQueryCountPerServer; queryIndexForServer++)
    {
#ifdef DEBUG
      NSLog(@"DEBUG: CLOSEST HTTP start server:%d, sub-query:%d, start date/time=%@", serverIndex, queryIndexForServer, [df stringFromDate:[NSDate date]]);
#endif // DEBUG
      [self fireAsyncHttpQueryForHttpLatencyTest:urlString
       Callback:^(NSError *error, NSInteger responseCode, NSMutableData *responseData, NSString *responseDataAsString, NSDictionary *responseHeaders) {
         
         @synchronized (self) {
           queryCompleteCountdown--;
#ifdef DEBUG
           NSLog(@"DEBUG: CLOSEST HTTP completed server:%d, sub-query:%d, end date/time=%@, countdown=%d", serverIndex, queryIndexForServer, [df stringFromDate:[NSDate date]], queryCompleteCountdown);
#endif // DEBUG
           
           if (error != nil) {
#ifdef DEBUG
             NSLog(@"DEBUG: CLOSEST HTTP - error - %@", [error description]);
#endif // DEBUG
           } else {
             // This is useful - potentially!
             int arrayOffset = serverIndex * cQueryCountPerServer + queryIndexForServer;
             NSTimeInterval theLatency = [[NSDate date] timeIntervalSinceDate:startTimesPerQuery[arrayOffset]];
             if (theLatency > 0) {
               double bestLatencySoFarForServer = [bestLatencyPerServer[serverIndex] doubleValue];
               if (bestLatencySoFarForServer < 0.0 || theLatency < bestLatencySoFarForServer) {
                 bestLatencyPerServer[serverIndex] = @(theLatency);
                 
#ifdef DEBUG
                 //NSString *target = targets[serverIndex];
                 //NSLog(@"DEBUG: HTTP latency response, from %@, with %g", target, theLatency);
#endif // DEBUG
               }
             }
           }
           
           if (queryCompleteCountdown == 0) {
             // We have finished the tests, for all servers!
#ifdef DEBUG
             NSDateFormatter *df = [self getDateFormatterWithMilliseconds];
             NSLog(@"DEBUG: CLOSEST HTTP FINISHED ALL TESTS, date/time=%@", [df stringFromDate:[NSDate date]]);
#endif // DEBUG
             
             // 2. Choose the server with the lowest non-zero response time
             // (not an average of the three requests - just take the one with the absolute lowest)
             
             double bestLatencySoFar = -100.0;
             int theBestFinalServerIndex = -1;
             int theFinalServerIndex;
             for (theFinalServerIndex = 0; theFinalServerIndex < serverCount; theFinalServerIndex++) {
               double thisLatency = [bestLatencyPerServer[theFinalServerIndex] doubleValue];
               
               if (thisLatency <= 0.0) {
                 // Ignore this value!
                 continue;
               }
               
               if ( (bestLatencySoFar< 0.0) || (thisLatency <= bestLatencySoFar)) {
                 bestLatencySoFar = thisLatency;
                 theBestFinalServerIndex = theFinalServerIndex;
               }
             }
             
             // TODO - compute the best overall latency.
             // If there were NO best values, then call the FAIL method!
             
             if ((bestLatencySoFar >= 0) && (theBestFinalServerIndex != -1)) {
               SK_ASSERT(bestLatencySoFar >= 0.0);
               
               // Do the above code. If it succeeds - ultimately! - do this:
               // Our latency is in seconds. Convert this to MILLISECONDS!
               lowestLatency = bestLatencySoFar * 1000.0;
               
               NSString *target = targets[theBestFinalServerIndex];
               
#ifdef DEBUG
               NSDate *now = [NSDate date];
               NSLog(@"DEBUG: Found closest target via HTTP, at %@, with %g, after %g seconds", target, bestLatencySoFar, [now timeIntervalSinceDate:timeStartOfHttpQuery]);
#endif // DEBUG
               [self.closestTargetDelegate ctdDidCompleteClosestTargetTest:target latency:lowestLatency];
             } else {
               // If this fails - ultimately - call this!
               [self.closestTargetDelegate ctdTestDidFail];
               // Do not assert here, as that would upset the mock tests which monitor for this!
               // SK_ASSERT(false);
#ifdef DEBUG
               NSDate *now = [NSDate date];
               NSLog(@"DEBUG: warning - all http-based closest target tests failed, after %g seconds", [now timeIntervalSinceDate:timeStartOfHttpQuery]);
#endif // DEBUG
             }
           }
         }
       }
       ];
      
    }
  }

#ifdef DEBUG
  NSDate *now = [NSDate date];
  NSLog(@"DEBUG: FIRED ALL HTTP QUERIES, after %g seconds!", [now timeIntervalSinceDate:timeStartOfHttpQuery]);
#endif // DEBUG
}



#pragma mark - Methods

// This is extracted to a private method, so that mock tests could override in future...
// - If at least one UDP closest target succeeded, this will reutrn a value that is less than DBL_MAX...
// - Otherwise (all UDP closest target tests failed, e.g. due to a firewall) this will return DBL_MAX...
-(double) getTheBestUdpLatency {
  
  return lowestLatency;
}

//
// This method is called whenever a test "thread" completes or fails.
// When threadCount reaches the target values (where there is nominally one thread per target...),
// - if we have a "best" udp latency, we must return that value (and the target)
// - otherwise (the UDP closest target failed), we must determin the best Closest Target using our fall-back
//   case, which is to use a number of http-based latency queries.
//
- (void)checkIfDone:(int)threadCount
{
  if (threadCount == nThreads)
  {
//#ifdef DEBUG
//    if ((rand() % 100) < 25)
//    {
//      NSLog(@"DEBUG: WARNING: special mode, forcing the closest target test to fail 1 time in 4!");
//      lowestLatency = DBL_MAX;
//    }
//#endif // DEBUG
    
#ifdef DEBUG
    NSDateFormatter *df = [self getDateFormatterWithMilliseconds];
    NSLog(@"DEBUG: UDP server ALL DONE threadCount=%d, date/time=%@", (int)threadCount, [df stringFromDate:[NSDate date]]);
#endif // DEBUG
    
    double theLowestUdpLatency = [self getTheBestUdpLatency];

    if (theLowestUdpLatency < DBL_MAX)
    {
      self.skAutotest.udpClosestTargetTestSucceeded = YES;

      NSString *target = targets[lowestLatencyThreadId];
      
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.closestTargetDelegate ctdDidCompleteClosestTargetTest:target latency:theLowestUdpLatency];
      });
    }
    else 
    {
#ifdef DEBUG
      NSLog(@"DEBUG: Closest target test... UDP tests failed, so try http test instead!");
#endif // DEBUG
      dispatch_async(dispatch_get_main_queue(), ^{
        [self tryHttpClosestTargetTestIfUdpTestFails];
      });
    }
  }
}

- (void)reset
{
  jitter = latency = packetLoss = stdDeviation = 0;
  
  isRunning = NO;
  nThreads = (int)[targets count];
  if(nThreads < 1 || nThreads > MAXNTHREADS)
  {
    SK_ASSERT(false);
  }
  threadCounter = 0;
  lowestLatency = DBL_MAX;
  lowestLatencyThreadId = 0;
}

- (void)startTest
{
  [self reset];
  
  if (queue != nil) {
    [queue cancelAllOperations];
    queue = nil;
  }
  queue = [[NSOperationQueue alloc] init];
  [queue setMaxConcurrentOperationCount:nThreads];
  
  if (targets == nil) {
    SK_ASSERT(false);
    return;
  }
  
  if (nThreads == 0) {
    SK_ASSERT(false);
    return;
  }
  
//#ifdef DEBUG
//  if ((rand() % 100) < 25)
//  {
//    NSLog(@"DEBUG: WARNING: special mode, forcing the closest target test to fail 1 time in 4!");
//   
//    double secondsToError = 5.0 + (rand() % 5);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondsToError * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//      [self.closestTargetDelegate ctdTestDidFail];
//    });
//    
//  }
//#endif // DEBUG
  
#ifdef DEBUG
  NSDateFormatter *df = [self getDateFormatterWithMilliseconds];
#endif // DEBUG
  
  for (int m=0; m<nThreads; m++)
  {
    NSString *target = targets[m];
    
#ifdef DEBUG
    NSLog(@"DEBUG: UDP server START thread:%d, target=%@, start date/time=%@", m, target, [df stringFromDate:[NSDate date]]);
#endif // DEBUG
    
    SKLatencyOperation *operation = [SKClosestTargetTest createLatencyOperationWithTarget:target
                                                                                port:port 
                                                                        numDatagrams:numDatagrams 
                                                                     interPacketTime:interPacketTime 
                                                                        delayTimeout:delayTimeout 
                                                                          percentile:percentile 
                                                                    maxExecutionTime:0
                                                                            threadId:m
                                                                             TheTest:self
                                                                 LatencyOperationDelegate:self];
    [operation setIsClosestTargetTest:YES];
    [operation setSKAutotest:self.skAutotest];
    
    [queue addOperation:operation];
    // Alternative to start the operation in an auto-spawned thread.
    // Testing proved that there is no measureable performance difference between the two approaches;
    // both have their operations perform asynchronously (due to their isAsynchronous overrides)
    //   [NSThread detachNewThreadSelector:@selector(start) toTarget:operation withObject:nil];
  }
  
  //##HG
  if ([self.closestTargetDelegate respondsToSelector:@selector(ctdDidStartTargetTesting)]) {
    [self.closestTargetDelegate ctdDidStartTargetTesting];
  }
  
  isRunning = YES;
}

- (void)cancel
{
  if (nil != queue)
  {
#ifdef DEBUG
    NSLog(@"DEBUG: SKClosestTargetTest cancelling %d closest target operations!", (int)[queue operationCount]);
#endif // DEBUG
    [queue cancelAllOperations];
  }
  isRunning = NO;
}

- (BOOL)isReady
{
  if(nil == targets)
  {
    return false;
  }
  if(port == 0)
  {
    return false;
  }
  if(percentile < 0 || percentile > 100)
  {
    return false;
  }
  if (nThreads == 0 || !(nThreads >= NUMBEROFTARGETSMIN && nThreads <= NUMBEROFTARGETSMAX))
  {
    SK_ASSERT(false);
    return  false;
  }
  if(numDatagrams == 0 || !(numDatagrams >= NUMBEROFPACKETSMIN && numDatagrams <= NUMBEROFPACKETSMAX))
  {
    return false;
  }
  if(delayTimeout == 0 || !(delayTimeout >= DELAYTIMEOUTMIN && delayTimeout <= DELAYTIMEOUTMAX))
  {
    return false;
  }
  if(interPacketTime == 0 || !(interPacketTime >= INTERPACKETIMEMIN && interPacketTime <= INTERPACKETIMEMAX))
  {
    return false;
  }
  
  return true;
}

#pragma mark - Dealloc

- (void)dealloc
{    
  if (nil != queue)
  {
    [queue cancelAllOperations];
    queue = nil;
  }
  
  if (nil != targets)
  {
    targets = nil;
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

#pragma mark - Latency Operation Delegate Methods

- (void)lodTestDidSendPacket:(NSUInteger)bytes
{
  [self.closestTargetDelegate ctdDidSendPacket:bytes];
}

- (void)lodTestDidFail:(NSUInteger)threadId
{
#ifdef DEBUG
  NSDateFormatter *df = [self getDateFormatterWithMilliseconds];
  NSLog(@"DEBUG: UDP lodTestDidFail, threadId=%d, date/time=%@", (int)threadId, [df stringFromDate:[NSDate date]]);
#endif // DEBUG
  
  @synchronized(self) {
    threadCounter = threadCounter + 1;
    
    [self checkIfDone:threadCounter];
  }
}

- (void)lodTestDidSucceed:(double)latency_
               packetLoss:(int)packetLoss_ 
                   jitter:(double)jitter_ 
             stdDeviation:(double)stdDeviation_
                 threadId:(NSUInteger)threadId_
{
#ifdef DEBUG
  NSDateFormatter *df = [self getDateFormatterWithMilliseconds];
  NSLog(@"DEBUG: UDP lodTestDidSucceed, threadId=%d, date/time=%@", (int)threadId_, [df stringFromDate:[NSDate date]]);
#endif // DEBUG

  @synchronized(self) {

#ifdef DEBUG
    NSString *target = targets[threadId_];
    NSString *targetName = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate].schedule getClosestTargetName:target];
    if (targetName == nil) {
      targetName = target;
    }
    NSLog(@"DEBUG: targetName=%@, latency_=%g", targetName, latency_);
#endif // DEBUG
    
    if (latency_ < lowestLatency)
    {
      lowestLatency = latency_;
      lowestLatencyThreadId = threadId_;
    }
    
    threadCounter = threadCounter + 1;
    
    //###HG
    if ([self.closestTargetDelegate respondsToSelector:@selector(ctdDidFinishAnotherTarget:withLatency:withBest:)]) {
      [self.closestTargetDelegate ctdDidFinishAnotherTarget:(int)threadId_ withLatency:lowestLatency withBest:(int)lowestLatencyThreadId];
    }
    
    [self checkIfDone:threadCounter];
  }
}

- (void)lodTestWasCancelled:(NSUInteger)threadId
{
#ifdef DEBUG
  NSLog(@"DEBUG: UDP lodTestWasCancelled, threadId=%d", (int)threadId);
#endif // DEBUG

  @synchronized(self) {
    threadCounter = threadCounter + 1;
    
    [self checkIfDone:threadCounter];
  }
}

- (void)lodUpdateProgress:(float)progress_ threadId:(NSUInteger)threadId latency:(float)latency_ { //###HG
}

- (void)lodUpdateProgress:(float)progress_ threadId:(NSUInteger)threadId
{
  //NSLog(@"lodUpdateProgress : %f", progress_);
}

- (void)lodUpdateStatus:(LatencyStatus)status_ threadId:(NSUInteger)threadId
{
  if (status_ == CANCELLED_STATUS)
  {
    NSLog(@"lodUpdateStatus : CANCELLED_STATUS");
  }
}

-(void) setSKAutotest:(SKAutotest*)inSkAutotest {
  self.skAutotest = inSkAutotest;
}

@end
