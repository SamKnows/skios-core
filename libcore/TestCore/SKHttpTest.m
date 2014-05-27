//
//  SKHttpTest.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

NSString *const DOWNSTREAMSINGLE    = @"JHTTPGET";
NSString *const DOWNSTREAMMULTI     = @"JHTTPGETMT";
NSString *const UPSTREAMSINGLE      = @"JHTTPPOST";
NSString *const UPSTREAMMULTI       = @"JHTTPPOSTMT";

@interface SKHttpTest ()
{
    NSOperationQueue *queue;
    
    NSUInteger multiThreadCount;
    NSUInteger testTotalBytes;
}

@property (weak) SKAutotest* skAutotest;

- (void)prepareStatus;
- (BOOL)isMultiThreaded;
- (void)computeMultiThreadProgress;

@end

#pragma mark - Implementation

@implementation SKHttpTest

@synthesize isRunning;
@synthesize target;
@synthesize port;
@synthesize warmupMaxTime;
@synthesize warmupMaxBytes;
@synthesize transferMaxBytes;
@synthesize transferMaxTimeMicroseconds;
@synthesize nThreads;
@synthesize file;
@synthesize httpRequestDelegate;
@synthesize isDownstream;
@synthesize postDataLength;
@synthesize sendDataChunkSize;
@synthesize warmupDoneCounter;
@synthesize statusArray;
@synthesize networkType;
@synthesize displayName;
@synthesize testOK;
@synthesize testIndex;
@synthesize runAsynchronously;

@synthesize testTransferBytes;
@synthesize testTransferTimeMicroseconds;
@synthesize testWarmupBytes;
@synthesize testWarmupStartTime;
@synthesize testWarmupEndTime;

@synthesize skAutotest;

- (id)initWithTarget:(NSString*)_target
                port:(int)_port
                file:(NSString*)_file
        isDownstream:(BOOL)_isDownstream
       warmupMaxTime:(double)_warmupMaxTime
      warmupMaxBytes:(double)_warmupMaxBytes
     TransferMaxTimeMicroseconds:(SKTimeIntervalMicroseconds)_transferMaxTimeMicroseconds
    transferMaxBytes:(double)_transferMaxBytes
            nThreads:(int)_nThreads
            HttpTestDelegate:(id <SKHttpTestDelegate>)_delegate
   runAsynchronously:(BOOL)_runAsynchronously
{
    self = [super init];
    
    if (self)
    {
        port = _port;
        target = [_target copy];
        file = [_file copy];
        isDownstream = _isDownstream;
        warmupMaxTime = _warmupMaxTime;
        warmupMaxBytes = _warmupMaxBytes;
        SK_ASSERT(warmupMaxBytes >= 0);
        SK_ASSERT(warmupMaxBytes != warmupMaxTime);
        transferMaxTimeMicroseconds = _transferMaxTimeMicroseconds;
        transferMaxBytes = _transferMaxBytes;
        SK_ASSERT(transferMaxBytes >= 0);
        SK_ASSERT(transferMaxBytes != transferMaxTimeMicroseconds);
        nThreads = _nThreads;
        isRunning = NO;
        httpRequestDelegate = _delegate;
        testOK = NO;
        runAsynchronously = _runAsynchronously;
      
        [self setRunningStatus:IDLE];
    }
    
    return self;
}

- (void)dealloc
{
    if (nil != queue)
    {
        [queue cancelAllOperations];
        queue = nil;
    }
    
}

#pragma mark - Instance Methods

- (void)setRunningStatus:(TransferStatus)status
{
    // INITIALIZING, WARMING, TRANSFERRING, COMPLETE, CANCELLED, FAILED, FINISHED, IDLE
    
    if (status == COMPLETE || status == CANCELLED || status == FAILED || status == FINISHED || status == IDLE)
    {
        isRunning = NO;
    }
    else
    {
        isRunning = YES;
    }
}

- (BOOL)isMultiThreaded
{
    return (nThreads > 1);
}

- (void)todIncrementWarmupDoneCounter
{
    self.warmupDoneCounter += 1;
}

- (int)todGetWarmupDoneCounter
{
    return self.warmupDoneCounter;
}

- (void)todAddWarmupBytes:(NSUInteger)bytes
{
    testWarmupBytes += bytes;
}

- (void)todAddWarmupTimes:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime
{
    //NSLog(@"startTime: %f, endTime: %f", startTime, endTime);
    
    // We use the earliest start time, and latest end time, to calculate the full warmup time of all threads
    
    if (endTime > testWarmupEndTime)
    {
        testWarmupEndTime = endTime;
    }
    
    if (startTime < testWarmupStartTime)
    {
        testWarmupStartTime = startTime;
    }
}

- (void)prepareStatus
{
    if (nil == statusArray)
    {
        statusArray = [[NSMutableArray alloc] init];
    }
    [statusArray removeAllObjects];
    
    for (int j=0; j<nThreads; j++)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:[NSNumber numberWithInt:j] forKey:@"THREAD_ID"];
        [dict setObject:[NSNumber numberWithFloat:0] forKey:@"PROGRESS"];
        [dict setObject:[NSNumber numberWithInt:IDLE] forKey:@"STATUS"];
        
        [statusArray addObject:dict];
    }
}

- (void)computeMultiThreadProgress
{
    float progressPercent = 0;
    
    @synchronized(statusArray)
    {
        int count = (int)[statusArray count];
        
        float total = 0;
        for (int j=0; j<count; j++)
        {
            NSDictionary *data = [statusArray objectAtIndex:j];
            
            total += [[data objectForKey:@"PROGRESS"] floatValue];
        }
        
        progressPercent = total / count;
    }
    
    [[self httpRequestDelegate] htdDidUpdateTotalProgress:progressPercent];
}

- (void)reset
{
    if (nil != statusArray)
    {
        for (int j=0; j<nThreads; j++)
        {
            NSMutableDictionary *dict = [statusArray objectAtIndex:j];
            
            if (nil != dict)
            {
                [dict setObject:[NSNumber numberWithFloat:0] forKey:@"PROGRESS"];
                [dict setObject:[NSNumber numberWithInt:IDLE] forKey:@"STATUS"];
            }
        }
    }
}

- (void)startTest
{
    if (nil != queue)
    {
        [queue cancelAllOperations];
        queue = nil;
    }
    
    queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:nThreads];
    
    [self prepareStatus];
    [self reset];
    
    testOK = NO;
    multiThreadCount = 0;
    testTotalBytes = 0;
    testTransferTimeMicroseconds = 0;
    testTransferBytes = 0;
    testWarmupBytes = 0;
    testWarmupStartTime = DBL_MAX;
    testWarmupEndTime = DBL_MIN;
    self.warmupDoneCounter = 0;
    
    [self setRunningStatus:INITIALIZING];
    
    for (int i=0; i<nThreads; i++)
    {
      SKTransferOperation *operation =
      [[SKTransferOperation alloc] initWithTarget:target
                                             port:port
                                             file:file
                                     isDownstream:isDownstream
                                    warmupMaxTime:warmupMaxTime
                                    warmupMaxBytes:warmupMaxBytes
                                  TransferMaxTimeMicroseconds:transferMaxTimeMicroseconds
                                  transferMaxBytes:transferMaxBytes
                                         nThreads:nThreads
                                         threadId:i
                                         TransferOperationDelegate:self
                                        asyncFlag:[self getTestIsAsyncFlag]];
      
      [operation setSKAutotest:self.skAutotest];
        
        [queue addOperation:operation];
    }
    
    isRunning = YES;
}

-(BOOL) getTestIsAsyncFlag {
  return runAsynchronously;
}

- (void)stopTest
{
    if (nil != queue)
    {
#ifdef DEBUG
      NSLog(@"DEBUG: cancelling %d http test operations!", (int)[queue operationCount]);
#endif // DEBUG
      [queue cancelAllOperations];
    }
    isRunning = NO;
}

- (void)setDirection:(NSString*)direction
{
    isDownstream = [direction isEqualToString:[SKTransferOperation getDownStream]];
}


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
    if(isDownstream && ([file length] == 0))
    {
        return false;
    }
    if(warmupMaxTime == 0 && warmupMaxBytes == 0)
    {
        return false;
    }
    if(transferMaxTimeMicroseconds == 0 && transferMaxBytes == 0)
    {
        return false;
    }
    if(nThreads < 1 || nThreads > MAXNTHREADS)
    {
        return false;
    }
    
    return true;
}

- (int)getBytesPerSecond
{
    if ([self isSuccessful])
    {
        double time = testTransferTimeMicroseconds / 1000000.0;   // convert microseconds -> seconds
        double bytesPerSecond = testTransferBytes / time;
        return (int)bytesPerSecond;
    }
    
    return 0;
}

- (void)storeOutputResults
{
  SK_ASSERT(false);
}

+(NSString*) getStatusAsString:(TransferStatus)inStatus {
  switch(inStatus) {
    case INITIALIZING:
      return @"INITIALIZING";
    case WARMING:
      return @"WARMING";
    case TRANSFERRING:
      return @"TRANSFERRING";
    case COMPLETE:
      return @"COMPLETE";
    case CANCELLED:
      return @"CANCELLED";
    case FAILED:
      return @"FAILED";
    case FINISHED:
      return @"FINISHED";
    case IDLE:
      return @"IDLE";
    default:
      SK_ASSERT(false);
      return @"Unknown";
  }
}

#pragma mark - SKTransferOperationDelegate Methods

- (void)todUpdateStatus:(TransferStatus)status threadId:(NSUInteger)threadId
{
  if (status == FAILED || status == FINISHED)
  {
    if (isRunning)
    {
#ifdef DEBUG
      NSLog(@"DEBUG: todUpdateStatus %d (%@) - isRunning", (int)status, [self.class getStatusAsString:status]);
#endif // DEBUG
      [self setRunningStatus:status];
      [self setWarmupDoneCounter:nThreads];
      [self stopTest];
      [[self httpRequestDelegate] htdUpdateStatus:status threadId:threadId];
    }
    else if (status == FAILED)
    {
#ifdef DEBUG
      NSLog(@"DEBUG: todUpdateStatus - FAILED - not isRunning!");
#endif // DEBUG
      [[self httpRequestDelegate] htdUpdateStatus:status threadId:threadId];
    }
  }
  else
  {
    [[self httpRequestDelegate] htdUpdateStatus:status threadId:threadId];
  }
  
  NSMutableDictionary *dict = [statusArray objectAtIndex:threadId];
  if (nil != dict)
  {
    [dict setObject:[NSNumber numberWithInt:status] forKey:@"STATUS"];
  }
}

- (void)todDidTransferData:(NSUInteger)totalBytes
                  bytes:(NSUInteger)bytes
               progress:(float)progress
               threadId:(NSUInteger)threadId
{
    [[self httpRequestDelegate] htdDidTransferData:totalBytes bytes:bytes progress:progress threadId:threadId];
    
    @synchronized(statusArray)
    {
        NSMutableDictionary *dict = [statusArray objectAtIndex:threadId];
        if (nil != dict)
        {
            [dict setObject:[NSNumber numberWithFloat:progress] forKey:@"PROGRESS"];
        }
    }
    
    [self computeMultiThreadProgress];
}

- (void)todDidCompleteTransferOperation:(SKTimeIntervalMicroseconds)transferTimeMicroseconds
              transferBytes:(NSUInteger)transferBytes
                 totalBytes:(NSUInteger)totalBytes
                   threadId:(NSUInteger)threadId
{
  // This block MUST be synchronized, otherwise the multiple callbacks can all interfere with each other!
  @synchronized(self) {
    if ([self isMultiThreaded])
    {
      multiThreadCount += 1;
      
      NSLog(@"**** DEBUG - SKHttpTesttodDidCompleteTransferOperation - multiThreadCount = %d (%d)", (int)(int)multiThreadCount, (int)(int)nThreads);
      
      // For the multi threaded case, use the longest duration
      if (testTransferTimeMicroseconds < transferTimeMicroseconds)
      {
        testTransferTimeMicroseconds = transferTimeMicroseconds;
      }
      
      testTotalBytes = testTotalBytes + totalBytes;
      testTransferBytes = testTransferBytes + transferBytes;
      
      if (multiThreadCount == nThreads)
      {
        testOK = YES;
        
        NSLog(@"**** DEBUG - SKHttpTest:todDidCompleteTransferOperation - hit the thread threshold - calling htdDidCompleteHttpTest!");
        
        [self setRunningStatus:COMPLETE];
        [self storeOutputResults];
        
        SK_ASSERT(self.httpRequestDelegate != nil);
        [[self httpRequestDelegate] htdDidCompleteHttpTest:testTransferTimeMicroseconds
                               transferBytes:testTransferBytes
                                  totalBytes:testTotalBytes
                                    threadId:threadId];
      }
    }
    else
    {
      testOK = YES;
      
      [self setRunningStatus:COMPLETE];
      
      testTotalBytes = totalBytes;
      testTransferBytes = transferBytes;
      testTransferTimeMicroseconds = transferTimeMicroseconds;
      
      [self storeOutputResults];
      [[self httpRequestDelegate] htdDidCompleteHttpTest:testTransferTimeMicroseconds
                             transferBytes:testTransferBytes
                                totalBytes:testTotalBytes
                                  threadId:threadId];
    }
  }
}

- (BOOL)isSuccessful
{
  return testOK;
}

-(void) setSKAutotest:(SKAutotest*)inSkAutotest {
  self.skAutotest = inSkAutotest;
}

@end
