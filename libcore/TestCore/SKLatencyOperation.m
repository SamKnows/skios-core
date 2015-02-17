//
//  LatencyOperation.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//



#pragma mark - Interface

@interface SKLatencyOperation ()
{
  NSTimeInterval runTime;
  NSTimeInterval startTime;
  
  NSPort* nsPort;
  AsyncUdpSocket *udpSocket;
  
  NSMutableDictionary *startTimes;
  NSMutableDictionary *endTimes;
  
  NSTimer *timeoutTimer;
  
  UIBackgroundTaskIdentifier btid;
}

@property BOOL shouldKeepRunning;
@property int sentPackets;
@property int sentPacketAttempts;
@property GCDAsyncUdpSocket *keepAwakeSocket;
@property NSOperationQueue *keepAwakeSocketOperationQueue;
@property NSBlockOperation *keepAwakeSocketOperation;

@property BOOL bDidTimeoutSoIgnoreLastPacket;
@property (weak) SKAutotest* skAutotest;

#pragma mark - Private Instance Methods

- (BOOL)setupSocket;
- (void)initVariables;
- (void)cancelled;
- (void)done;

- (void)timeoutTicked;

- (void)addEndTimes:(long)tag TheDate:(NSDate*)date;
- (void)addStartTimes:(long)tag TheDate:(NSDate*)date;
- (void)computeLatency:(long)tag;

- (NSTimeInterval)getTimeout;
- (void)sendPacket:(long)tag;

- (void)startBackgroundTask;
- (void)finishBackgroundTask;
- (void)setExecutingAndFinished:(BOOL)executing finished:(BOOL)finished;

- (SKTimeIntervalMicroseconds)microTime:(NSTimeInterval)time;

- (void)getStats;
- (void)failure;
- (void)outputResults;
- (void)tearDown;

- (void)getHostIP;

- (void)skDebug:(NSString*)msg;

//#pragma mark - Private Methods to invoke our delegate methods
//
//- (void)udpTestDidSendPacket:(NSUInteger)bytes_;
//
//- (void)udpTestDidFail:(NSUInteger)threadId_;
//
//- (void)udpTestDidSucceed:(double)latency_
//               packetLoss:(int)packetLoss_
//                   jitter:(double)jitter_
//             stdDeviation:(double)stdDeviation_
//                 threadId:(NSUInteger)threadId_;
//
//- (void)udpTestWasCancelled:(NSUInteger)threadId_;
//
//- (void)udpUpdateProgress:(float)progress_ threadId:(NSUInteger)threadId_;
//- (void)udpUpdateStatus:(LatencyStatus)status_ threadId:(NSUInteger)threadId_;

@property SKTest *theTest;
@property NSMutableDictionary *outputResultsDictionary;

@end

@implementation SKLatencyOperation

@synthesize shouldKeepRunning;
@synthesize sentPackets;
@synthesize sentPacketAttempts;
@synthesize target;
@synthesize port;
@synthesize numDatagrams;
@synthesize interPacketTime;
@synthesize delayTimeout;
@synthesize latencyOperationDelegate;
@synthesize testOK;
@synthesize percentile;
@synthesize maxExecutionTime;
@synthesize isClosestTargetTest;

@synthesize totalPacketsReceived;
@synthesize totalPacketsLost;
@synthesize packetReceivedPercentage;
@synthesize packetLostPercentage;
@synthesize minimumTripTime;
@synthesize maximumTripTime;
@synthesize standardDeviation;
@synthesize averagePacketTime;
@synthesize jitter;
@synthesize threadId;
@synthesize hostIPAddress;

@synthesize skAutotest;

@synthesize keepAwakeSocketOperationQueue;
@synthesize keepAwakeSocketOperation;

@synthesize theTest;
@synthesize outputResultsDictionary;

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
LatencyOperationDelegate:(id<SKLatencyOperationDelegate>)_delegate
{
  self = [super init];
  
  if (self)
  {
    SK_ASSERT ([((NSObject*)_delegate) conformsToProtocol:@protocol(SKLatencyOperationDelegate)]);
    
    target = [_target copy];
    port = _port;
    numDatagrams = _numDatagrams;
    interPacketTime = _interPacketTime;
    delayTimeout = _delayTimeout;
    percentile = _percentile;
    maxExecutionTime = _maxExecutionTime;
    threadId = _threadId;
    latencyOperationDelegate = _delegate;
    
    // The latencyOperation delegate *can* be nil!
    //SK_ASSERT(latencyOperationDelegate != nil);
    isClosestTargetTest = NO;
    self.bDidTimeoutSoIgnoreLastPacket = NO;
    
    [self setCompletionBlock:nil];
    
    [self initVariables];
    
    outputResultsDictionary = [[NSMutableDictionary alloc] init];
    theTest = inTheTest;
    
    if (![inTheTest.class isSubclassOfClass:[SKTest class]]) {
      SK_ASSERT(false);
      return nil;
    }
#ifdef DEBUG
    NSLog(@"DEBUG: created NSOperationQueue (SKLatencyOperation): %@", [self description]);
#endif // DEBUG
  }
  
  return self;
}

+(NSString*) getIdleStatus
{
  return sSKCoreGetLocalisedString(@"lo_Idle");
}
+(NSString*) getInitializingStatus
{
  return sSKCoreGetLocalisedString(@"lo_Initializing");
}
+(NSString*) getRunningStatus
{
  return sSKCoreGetLocalisedString(@"lo_Running");
}
+(NSString*) getCompleteStatus
{
  return sSKCoreGetLocalisedString(@"lo_Complete");
}
+(NSString*) getFinishedStatus
{
  return sSKCoreGetLocalisedString(@"lo_Finished");
}
+(NSString*) getCancelledStatus
{
  return sSKCoreGetLocalisedString(@"lo_Cancelled");
}
+(NSString*) getTimeoutStatus
{
  return sSKCoreGetLocalisedString(@"lo_Timeout");
}
+(NSString*) getSearchingStatus
{
  return sSKCoreGetLocalisedString(@"lo_Searching");
}
+(NSString*) getFailedStatus
{
  return sSKCoreGetLocalisedString(@"lo_Failed");
}

+(NSString*) getStringSpace
{
  return @"SKTESTSPACE";
}

#pragma mark - Overrides

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return _Executing;
}

- (BOOL)isFinished
{
    return _Finished;
}

#pragma mark - Helper Debug Routine

- (void)skDebug:(NSString*)msg
{
    if (!isClosestTargetTest)
    {
#ifdef DEBUG
        //NSLog(@"DEBUG: %s %d %@", __FUNCTION__, __LINE__, msg);
#endif // DEBUG
    }
}

#pragma mark - Dealloc

- (void)tearDown
{
  if (nil != target)
  {
    target = nil;
  }
  
  if (nil != endTimes)
  {
    endTimes = nil;
  }
  
  if (nil != startTimes)
  {
    startTimes = nil;
  }
  
  if (nil != timeoutTimer)
  {
    [timeoutTimer invalidate];
    timeoutTimer = nil;
  }
  
  if (nil != udpSocket)
  {
    [udpSocket close];
    udpSocket = nil;
  }
  
  if (nil != cancelTimer)
  {
    [cancelTimer invalidate];
    cancelTimer = nil;
  }
  
  if (self.keepAwakeSocketOperation != nil)
  {
    [self.keepAwakeSocketOperation cancel];
  }
  
  if (self.keepAwakeSocketOperationQueue != nil)
  {
    [self.keepAwakeSocketOperationQueue cancelAllOperations];
  }
  
  if (nil != hostIPAddress)
  {
    hostIPAddress = nil;
  }
  
  if (nil != nsPort)
  {
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    [runLoop removePort:nsPort forMode:NSRunLoopCommonModes];
  }
  
  if (self.keepAwakeSocketOperation != nil)
  {
    [self.keepAwakeSocketOperation cancel];
  }

  if (self.keepAwakeSocketOperationQueue != nil)
  {
    [self.keepAwakeSocketOperationQueue cancelAllOperations];
  }
  
  if (self.keepAwakeSocket != nil) {
    //SK_ASSERT([self.keepAwakeSocket isConnected]);
    [self.keepAwakeSocket close];
    self.keepAwakeSocket = nil;
  }
  
  self.shouldKeepRunning = NO;
 
  // try to clear-up the caches!
  // http://stackoverflow.com/questions/17668617/sensitive-data-stored-in-cache-db-wal-file
  [[NSURLCache sharedURLCache] removeAllCachedResponses];
  
  if (nil != outputResultsDictionary)
  {
    outputResultsDictionary = nil;
  }
}

- (void)dealloc
{
    [self tearDown];
}

#pragma mark - Get the host IP address

- (void)getHostIP
{
    @try
    {
        self.hostIPAddress = [SKIPHelper hostIPAddress:target];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error getting host IP address");
    }
}

#pragma mark - Methods to message delegate methods

- (void)doSendLodTestDidSendPacket:(NSUInteger)bytes_
{
  [self.latencyOperationDelegate lodTestDidSendPacket:bytes_];
}

- (void)doSendLodTestDidFail:(NSUInteger)threadId_
{
#ifdef DEBUG
  NSLog(@"DEBUG: doSendLodTestDidFail");
#endif // DEBUG
  
  [self.latencyOperationDelegate lodTestDidFail:threadId_];
}

- (void)doSendLodTestDidSucceed:(double)latency_
               packetLoss:(int)packetLoss_
                   jitter:(double)jitter_
             stdDeviation:(double)stdDeviation_
                 threadId:(NSUInteger)threadId_
{
  [self.latencyOperationDelegate lodTestDidSucceed:latency_
                                        packetLoss:packetLoss_
                                            jitter:jitter_
                                      stdDeviation:stdDeviation_
                                          threadId:threadId_];
}

- (void)doSendLodTestWasCancelled:(NSUInteger)threadId_
{
  [self.latencyOperationDelegate lodTestWasCancelled:threadId_];
}

- (void)doSendLodUpdateProgress:(float)progress_ threadId:(NSUInteger)threadId_
{
//  SK_ASSERT(self.latencyOperationDelegate != nil);
  
    if (isClosestTargetTest)
        [self.latencyOperationDelegate lodUpdateProgress:progress_ threadId:threadId_];
    else
        [self.latencyOperationDelegate lodUpdateProgress:progress_ threadId:threadId_ latency:lastLatency];
}

- (void)doSendLodUpdateStatus:(LatencyStatus)status_ threadId:(NSUInteger)threadId_
{
  //SK_ASSERT(self.latencyOperationDelegate != nil);
  [self.latencyOperationDelegate lodUpdateStatus:status_ threadId:threadId_];
}

#pragma mark - Instance Methods

- (SKTimeIntervalMicroseconds)microTime:(NSTimeInterval)time
{
    return time * 1000000.0;  // Convert the seconds to microseconds
}

#ifdef DEBUG
// https://stackoverflow.com/questions/4083608/on-ios-iphone-too-many-open-files-need-to-list-open-files-like-lsof
+(void) lsof
{
  @synchronized(self) {
    int flags;
    int fd;
    char buf[1000+1] ;
    int n = 1 ;
    
    for (fd = 0; fd < (int) FD_SETSIZE; fd++) {
      errno = 0;
      flags = fcntl(fd, F_GETFD, 0);
      if (flags == -1 && errno) {
        if (errno != EBADF) {
          return ;
        }
        else
          continue;
      }
      fcntl(fd , F_GETPATH, buf ) ;
      
//      if (fd >= 11) { // strstr(buf, "com.samknows.eaqmobility") != NULL) {
//        close(fd);
//      }
      NSLog( @"File Descriptor %d number %d in use for: %s",fd,n , buf ) ;
      ++n ;
    }
    
    NSLog(@"DONE");
  }
}
#endif // DEBUG

- (void)start
{
  if(_Finished)
  {
    [self doSendLodUpdateStatus:FINISHED_STATUS threadId:threadId];
    [self done];
  }
  else if ([self isCancelled])
  {
    [self cancelled];
  }
  else
  {
    [self doSendLodUpdateStatus:INITIALIZING_STATUS threadId:threadId];
    [self initVariables];
    
    if ([self setupSocket])
    {
      [self setExecutingAndFinished:YES finished:NO];
      
      startTime = [[SKCore getToday] timeIntervalSince1970];
      
      cancelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                     target:self
                                                   selector:@selector(cancelTicked)
                                                   userInfo:nil
                                                    repeats:YES];
      
      [self startBackgroundTask];
      [self doSendLodUpdateStatus:RUNNING_STATUS threadId:threadId];
      
      nsPort = [NSPort port];
      NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
      [runLoop addPort:nsPort forMode:NSRunLoopCommonModes];
      [self sendPacket:0];
     
      // Set this BEFORE the keep awake socket, which we ALSO shut-down using this flag!
      self.shouldKeepRunning = YES;
      
      self.keepAwakeSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
      NSError *err = nil;
      if (![self.keepAwakeSocket connectToHost:self.target onPort:6000 error:&err]) // Asynchronous!
      {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
#ifdef DEBUG
        NSLog(@"Failed to open keepAwakeSocket on port 5000 for target %@, error=%@", target, err);
        if ([[err description] rangeOfString:@"Too many open files"].length > 0) {
          [self.class lsof];
        }
#endif // DEBUG
        //SK_ASSERT(false);
        [self.keepAwakeSocket close];
        self.keepAwakeSocket = nil;
      }
      else
      {
        SK_ASSERT(self.keepAwakeSocket != nil);
        // At this point, it is still connecting!
        [self doRunKeepAwakeUntilCancelled];
      }
     
      //[runLoop run];
      NSRunLoop *theRL = [NSRunLoop currentRunLoop];
      //while (shouldKeepRunning && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
      for (;;) {
        if ([self isCancelled]) {
          break;
        }
        
        if (self.shouldKeepRunning == NO) {
          break;
        }
        
        if (self.testOK == NO) {
#ifdef DEBUG
          NSLog(@"DEBUG: SKLatencyOperation test stopped as testOK = NO");
#endif // DEBUG
          break;
        }
        
        if ([theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]] == NO) {
          break;
        }
      }
    }
  }
}

- (void)cancelTicked
{
    if([self isCancelled])
    {
        [self cancelled];
    }
}

- (void)cancelled
{
    [self doSendLodUpdateStatus:CANCELLED_STATUS threadId:threadId];
    
    if (nil != udpSocket)
    {
        [udpSocket close];
    }
    
    [self tearDown];
    [self finishBackgroundTask];
    [self setExecutingAndFinished:NO finished:YES];

}

- (void)done
{
    if (nil != udpSocket)
    {
        [udpSocket close];
    }
    
    [self getStats];
    [self tearDown];
    [self finishBackgroundTask];
    [self setExecutingAndFinished:NO finished:YES];
}

- (void)complete
{
#ifdef DEBUG
    NSLog(@"DEBUG: SKLatencyOperation::complete");
#endif // DEBUG
    [self doSendLodUpdateProgress:100 threadId:threadId];
    [self doSendLodUpdateStatus:COMPLETE_STATUS threadId:threadId];
    [self done];
}

- (void)failure
{
  testOK = NO;
  [self outputResults];
  [self doSendLodTestDidFail:threadId];
}

- (void)getStats {
  int recvPackets = 0;
  
  NSMutableArray *results = [[NSMutableArray alloc] init];
  
  int useSentPackets = sentPackets;
  if (self.bDidTimeoutSoIgnoreLastPacket == YES)
  {
    // We timed-out, so IGNORE the last sent packet, for which we will not have received a response yet.
    // As we send only one packet at at time, this should always be valid.
    if (sentPackets > 0) {
      useSentPackets--;
    }
  }
  
  // Loop the total 'sent packet' count
  for (long tag=0; tag<useSentPackets; tag++)
  {
    NSString *key = [NSString stringWithFormat:@"%ld", tag];
    
    // These both need to be valid for a successful packet round trip
    if ([startTimes objectForKey:key] && [endTimes objectForKey:key])
    {
      NSDate *start = [startTimes objectForKey:key];
      NSDate *end = [endTimes objectForKey:key];
      
      double timeDiff = [end timeIntervalSinceDate:start];
      
      [results addObject:[NSNumber numberWithDouble:timeDiff]];
      
      recvPackets += 1;
    }
  }
  
  if (recvPackets == 0)
  {
    [self failure];
    
    if (nil != results)
    {
      results = nil;
    }
    return;
  }
  
  testOK = YES;
  
  // Calculate packet Received and Lost numbers and percentages
  totalPacketsReceived = recvPackets;
  totalPacketsLost = useSentPackets - totalPacketsReceived;
  
  float fPacketLostPercent = ((100.0 * (float)totalPacketsLost) / (float)useSentPackets);
  int iPacketLostPercent = floor(fPacketLostPercent);
  
#ifdef DEBUG
  NSLog(@"DEBUG: recvPackets=%d, useSentPackets=%d, fPacketLossPercent=%g", recvPackets, useSentPackets, fPacketLostPercent);
#endif // DEBUG
  
  packetLostPercentage = iPacketLostPercent;
  packetReceivedPercentage = ONE_HUNDRED - packetLostPercentage;
  
  // Calculate statistics
  int nResults = totalPacketsReceived;
  
  // Sort the results array, minimum first
  NSSortDescriptor *lowToHigh = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
  [results sortUsingDescriptors:[NSArray arrayWithObject:lowToHigh]];
  
  // Calculate the minimum and maximum RTT
  minimumTripTime = [[results objectAtIndex:0] doubleValue];
  maximumTripTime = [[results objectAtIndex:nResults - 1] doubleValue];
  
  // Calculate the average RTT
  for (int m=0; m<nResults; m++)
  {
    averagePacketTime += [[results objectAtIndex:m] doubleValue];
  }
  averagePacketTime = averagePacketTime / nResults;
  
  // Calculate the standard deviation
  for (int j=0; j<nResults; j++)
  {
    double result = [[results objectAtIndex:j] doubleValue];
    standardDeviation += pow(result - averagePacketTime, 2);
  }
  standardDeviation = (nResults - 1 > 0) ? sqrt(standardDeviation / (nResults - 1)) : 0;
  
  // Calculate the jitter
  jitter = (averagePacketTime - minimumTripTime);
  
  
  // Jitter Calculation - Alternative
  double sumVariance = 0;
  
  for (int i=0; i<nResults-1; i++)
  {
    double result1 = [[results objectAtIndex:i] doubleValue];
    double result2 = [[results objectAtIndex:i+1] doubleValue];
    
    double difference = fabs(result2 - result1);
    
    sumVariance = sumVariance + difference;
  }
  
  double iosJitter = sumVariance / (double)(nResults-1);
  
  [self skDebug:[NSString stringWithFormat:@"%s Jitter (ms) [Java algo] : %f", __FUNCTION__, jitter*ONE_THOUSAND]];
  [self skDebug:[NSString stringWithFormat:@"%s Jitter (ms) [iOS algo] : %f", __FUNCTION__, iosJitter*ONE_THOUSAND]];
  
  [self outputResults];
  
  if (nil != results)
  {
    results = nil;
  }
  
  [self doSendLodTestDidSucceed:(averagePacketTime*ONE_THOUSAND)
                     packetLoss:packetLostPercentage
                         jitter:(jitter*ONE_THOUSAND)
                   stdDeviation:(standardDeviation*ONE_THOUSAND)
                       threadId:threadId];
}

- (void)initVariables {
  testOK = YES;
  
  runTime = 0;
  startTime = 0;
  sentPackets = 0;
  sentPacketAttempts = 0;
  
  totalPacketsReceived = 0;
  totalPacketsLost = 0;
  packetLostPercentage = 0;
  packetReceivedPercentage = 0;
  averagePacketTime = 0;
  standardDeviation = 0;
  minimumTripTime = 0;
  maximumTripTime = 0;
  jitter = 0;
  
  if (nil != startTimes)
  {
    startTimes = nil;
  }
  startTimes = [[NSMutableDictionary alloc] init];
  
  if (nil != endTimes)
  {
    endTimes = nil;
  }
  endTimes = [[NSMutableDictionary alloc] init];
}

- (float)getProgress
{
  if( maxExecutionTime > 0 )
  {
    double currTime = [self microTime:[[SKCore getToday] timeIntervalSince1970] - startTime];
    double retProgressPercent = 100.0 * (currTime / maxExecutionTime);
    
    if (retProgressPercent >= 100.0)
    {
      // NSLog(@"STOPPED due to TIME-OUT");
      // When this happens, we MUST have an outstanding packet, for which we'll never
      // see the result.
      // We need to ignore that in our "packet loss" calculation.
      self.bDidTimeoutSoIgnoreLastPacket = YES;
    }
    
    return retProgressPercent;
  }
  else
  {
    double retProgressPercent = 100.0 * ((double)sentPacketAttempts/numDatagrams);
//    if (retProgressPercent >= 100.0)
//    {
//      NSLog(@"STOPPED");
//    }
    
    return retProgressPercent;
  }
}

- (void)timeoutTicked
{
    [self complete];
}

- (NSTimeInterval)sleep:(long)tag;
{
  if (tag == 0) return 0.0;
  
  // get the key for the previous packet
  tag = tag - 1;
  NSString *key = [NSString stringWithFormat:@"%ld", tag];
  
  // both start and end time need to exist for a valid rtt
  if ([startTimes objectForKey:key] && [endTimes objectForKey:key])
  {
    NSDate *start = [startTimes objectForKey:key];
    NSDate *end = [endTimes objectForKey:key];
    
    double rtt = [end timeIntervalSinceDate:start];     // in seconds
    //rtt = rtt * ONE_MILLION;                            // convert to microseconds for sleep calculation
    //double sleepPeriod = interPacketTime  - rtt;
    double sleepPeriod = (interPacketTime / 1000000.0)  - rtt;
		
		if(sleepPeriod < 0)
    {
      sleepPeriod = 0.0;
		}
    else
    {
      //usleep((unsigned int)sleepPeriod);
    }
    
    return sleepPeriod;
  }
  else
  {
    // either a packet failed to send or wasnt received
    // sleep for the default interpacket time
    //usleep((unsigned int)interPacketTime);
    //return interPacketTime;
    double sleepPeriod = (interPacketTime / 1000000.0);
    return sleepPeriod;
  }
}

- (NSTimeInterval)getTimeout
{
    NSTimeInterval timeOut = self.delayTimeout/ONE_MILLION;
    
    return timeOut;
}

- (BOOL)setupSocket
{
  if (nil != udpSocket)
  {
    [udpSocket close];
    udpSocket = nil;
  }
  
  udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
	
	NSError *error = nil;
	if (![udpSocket bindToPort:0 error:&error])
	{
    NSLog(@"Socket : Error Binding : %@", error);
		return NO;
	}
	
  return YES;
}

- (void)sendPacket:(long)tag
{
  if ([self isCancelled])
  {
    [self cancelled];
    return;
  }
  
  float progress = [self getProgress];
  
  if (progress < 100)
  {
    [self doSendLodUpdateProgress:progress threadId:threadId];
    //[self sleep:tag];
    
    SKUDPDataGram *datagram = [[SKUDPDataGram alloc] initWithTagAndMagicCookie:(int)tag :CLIENTTOSERVERMAGIC];
    
    NSData *data = [[NSData alloc] initWithData:datagram.packetData];
    
    if ([udpSocket sendData:data toHost:self.target port:self.port withTimeout:[self getTimeout] tag:tag] == NO) {
      // Ooops - failure occured!
#ifdef DEBUG
      NSLog(@"DEBUG: failure occurred calling [udpSocket sendData...]");
#endif // DEBUG
      [self failure];
    }
    
    sentPacketAttempts = sentPacketAttempts + 1;
  }
  else
  {
    [self doSendLodUpdateProgress:progress threadId:threadId];
    [self complete];
  }
}

- (void)addStartTimes:(long)tag TheDate:(NSDate *)date
{
    [startTimes setObject:date forKey:[NSString stringWithFormat:@"%ld", tag]];
}

- (void)addEndTimes:(long)tag TheDate:(NSDate *)date
{
    [endTimes setObject:date forKey:[NSString stringWithFormat:@"%ld", tag]];
}

- (void)computeLatency:(long)tag
{
  NSString *key = [NSString stringWithFormat:@"%ld", tag];
  
  if ([startTimes objectForKey:key] && [endTimes objectForKey:key])
  {
    NSDate *start = [startTimes objectForKey:key];
    NSDate *end = [endTimes objectForKey:key];
    
    if (!isClosestTargetTest) {
      double rtt = [end timeIntervalSinceDate:start];
#ifdef DEBUG
      //NSLog(@"DEBUG: computeLatency LATENCY: %ld : %.2f", tag, rtt*1000.0f);
#endif // DEBUG
        
        lastLatency = rtt*1000.0f;
        
    }
  }
}

- (void)startBackgroundTask
{
    btid = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        if (btid != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:btid];
            btid = UIBackgroundTaskInvalid;
        }
    }];
}

- (void)finishBackgroundTask
{
    if (btid != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:btid];
        btid = UIBackgroundTaskInvalid;
    }
}

- (void)setExecutingAndFinished:(BOOL)executing finished:(BOOL)finished
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _Executing = executing;
    _Finished = finished;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Socket Delegate Methods

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
  NSDate *now = [NSDate date];
  
  if (self.bDidTimeoutSoIgnoreLastPacket == YES)
  {
    return;
  }
  
  [self skDebug:[NSString stringWithFormat:@"%s %ld : DID SEND PACKET", __FUNCTION__, tag]];
  
  sentPackets = sentPackets + 1;
  
  if ([self isCancelled])
  {
    [self cancelled];
    return;
  }
  
  [self addStartTimes:tag TheDate:now];
  [self doSendLodTestDidSendPacket:PACKET_SIZE];
  
  [sock receiveWithTimeout:[self getTimeout] tag:tag];
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    [self skDebug:[NSString stringWithFormat:@"%s %ld : DID NOT SEND PACKET : %@", __FUNCTION__, tag, [error localizedDescription]]];
    
    if ([self isCancelled])
    {
        [self cancelled];
        return;
    }
    
    [self sendPacket:tag+1];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
  NSDate *now = [NSDate date];
#ifdef DEBUG
  if (isClosestTargetTest) {
    NSLog(@"DEBUG: onUdpSocket - CLOSEST TARGET TEST: DID RECEIVE PACKET for host (%@)", host);
  }
#endif // DEBUG
  
  [self addEndTimes:tag TheDate:now];
  [self computeLatency:tag];
  
  if (self.bDidTimeoutSoIgnoreLastPacket == YES)
  {
    return YES;
  }

  // Send a new even IMMEDIATELY, to keep the device's network hardware awake!
  // https://devforums.apple.com/message/911430#911430
  // [self sendPacketImmediatelyWithTag:tag];
  
  
  NSTimeInterval delayInterval = [self sleep:tag];
  
  // Send a new event, using a timer!
  [NSTimer
   scheduledTimerWithTimeInterval:delayInterval
   target:self
   selector:@selector(handleTimer:)
   userInfo:[NSNumber numberWithLong:tag]
   repeats:NO];
  
  return YES;
}

-(void) sendPacketImmediatelyWithTag:(long)tag {
  [self sendPacket:tag+1];
  
  if ([self isCancelled])
  {
    [self cancelled];
  }
}

-(void) handleTimer: (NSTimer*)theTimer {
  long tag = [((NSNumber*)theTimer.userInfo) longValue];
  
  [self sendPacketImmediatelyWithTag:tag];
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
#ifdef DEBUG
  NSLog(@"DEBUG: - (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error, DID NOT RECEIVE PACKET, error:(%@)", [error localizedDescription]);
#endif // DEBUG
  
  if ([self isCancelled])
  {
    [self cancelled];
    return;
  }
  
  [sock close];
  
  if ([self setupSocket])
  {
    [self sendPacket:tag+1];
  }
  else
  {
    [self complete];
  }
}

- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
    //NSLog(@"onUdpSocketDidClose");
}

-(void) setSKAutotest:(SKAutotest*)inSkAutotest {
  self.skAutotest = inSkAutotest;
}

-(void) doRunKeepAwakeUntilCancelled {
  //  self.tcpTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
  //                                                 target:self
  //                                               selector:@selector(tcpTimerTicked)
  //                                               userInfo:nil
  //                                                repeats:YES];
  
  
  //Start an activity indicator here
  
  self.keepAwakeSocketOperationQueue = [[NSOperationQueue alloc] init];
  
  self.keepAwakeSocketOperation = [NSBlockOperation blockOperationWithBlock: ^{
#ifdef DEBUG
    NSLog(@"DEBUG: Beginning operation.\n");
#endif // DEBUG
    // Do some work.
    while (true) {
      
      //NSLog(@"Tick!");
      
      if ([self.keepAwakeSocketOperation isCancelled]) {
#ifdef DEBUG
        NSLog(@"DEBUG: CANCELLED KEEP AWAKE OPERATION!");
#endif // DEBUG
        break;
      }
      
      if (self.shouldKeepRunning == NO) {
#ifdef DEBUG
        NSLog(@"DEBUG: CANCELLED KEEP AWAKE OPERATION as shouldKeenRunning is NO...");
#endif // DEBUG
        break;
      }
      
      if (self.testOK == NO) {
#ifdef DEBUG
        NSLog(@"DEBUG: STOPPED as testOK == NO!");
#endif // DEBUG
        break;
      }
      
      //const char *hello = "mgknmbr";
      //NSData* data=[NSData dataWithBytes:hello length:strlen(hello)];
      
      // Always send the same data as we do in the "actual" test, but with tag fixed at 0
      const long cTag = 0;
      SKUDPDataGram *datagram = [[SKUDPDataGram alloc] initWithTagAndMagicCookie:cTag :CLIENTTOSERVERMAGIC];
      NSData *data = [[NSData alloc] initWithData:datagram.packetData];

      [self.keepAwakeSocket sendData:data withTimeout:0.1 tag:cTag];
      
      //      NSData* resultData=[NSData new];
      //      [self.keepAwakeSocket readDataToData:resultData withTimeout:0.1 tag:-1];
      //NSString *str = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
      //NSLog(@"TCP read data: %@",str);
      
      [NSThread sleepForTimeInterval:0.05];
    }
  }];
  
  [self.keepAwakeSocketOperationQueue addOperation:self.keepAwakeSocketOperation];
}

#pragma mark delegate GCDAsyncSocketDelegate
//- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
//{
//  SK_ASSERT([self.keepAwakeSocket isConnected]);
//#ifdef DEBUG
//  NSLog(@"keepAwakeSocket connected!");
//#endif // DEBUG
//  
//  [self doRunKeepAwakeUntilCancelled];
//  
//}
//
//- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
//#ifdef DEBUG
//  NSLog(@"keepAwakeSocket disconnected!");
//#endif // DEBUG
//  
//  SK_ASSERT_NONSERROR(err);
//  
//  if (self.keepAwakeSocketOperation != nil)
//  {
//    [self.keepAwakeSocketOperation cancel];
//  }
//  
//  if (self.keepAwakeSocketOperationQueue != nil)
//  {
//    [self.keepAwakeSocketOperationQueue cancelAllOperations];
//  }
//
//}

// Called if a read operation has reached its timeout without completing.
// If you return a positive time interval (> 0) the write's timeout will be extended by the given amount.
// Upon a timeout, the "socket:didDisconnectWithError:" method is called
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
  return 0;
}

//  Called if a write operation has reached its timeout without completing.
// If you return a positive time interval (> 0) the write's timeout will be extended by the given amount.
// Upon a timeout, the "socket:didDisconnectWithError:" method is called
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
  return 0;
}


#pragma mark - Dealloc

- (void)outputResults
{
  [outputResultsDictionary removeAllObjects];
  
  //    "type": "JUDPLATENCY"
  //    "datetime": "Fri Jan 25 15:36:07 GMT 2013",
  //    "lost_packets": "1",
  //    "received_packets": "53",
  //    "rtt_avg": "255144",
  //    "rtt_max": "1488525",
  //    "rtt_min": "68023",
  //    "rtt_stddev": "243171",
  //    "success": "true",
  //    "target": "n1-the1.samknows.com",
  //    "target_ipaddress": "46.17.56.234",
  //    "timestamp": "1359128167"
  
  [outputResultsDictionary setObject:@"JUDPLATENCY"
                              forKey:@"type"];
  
  [outputResultsDictionary setObject:[NSDate sGetDateAsIso8601String:[SKCore getToday]] forKey:@"datetime"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", totalPacketsLost]
                              forKey:@"lost_packets"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", totalPacketsReceived]
                              forKey:@"received_packets"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)(averagePacketTime * ONE_MILLION)]
                              forKey:@"rtt_avg"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)(maximumTripTime * ONE_MILLION)]
                              forKey:@"rtt_max"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)(minimumTripTime * ONE_MILLION)]
                              forKey:@"rtt_min"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)(standardDeviation * ONE_MILLION)]
                              forKey:@"rtt_stddev"];
  
  [outputResultsDictionary setObject:testOK ? @"true" : @"false"
                              forKey:@"success"];
  
  [outputResultsDictionary setObject:target
                              forKey:@"target"];
  
  [outputResultsDictionary setObject:[SKIPHelper hostIPAddress:target]
                              forKey:@"target_ipaddress"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)([[SKCore getToday] timeIntervalSince1970])]
                              forKey:@"timestamp"];
  
  theTest.outputResultsDictionary = outputResultsDictionary;
}

@end
