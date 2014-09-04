//
//  SKHttpTest.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKAAppDelegate.h"

NSString *const DOWNSTREAMSINGLE    = @"JHTTPGET";
NSString *const DOWNSTREAMMULTI     = @"JHTTPGETMT";
NSString *const UPSTREAMSINGLE      = @"JHTTPPOST";
NSString *const UPSTREAMMULTI       = @"JHTTPPOSTMT";


@implementation DebugTiming
- (instancetype)initWithDescription:(NSString*)inDescription ThreadIndex:(int)inThreadIndex Time:(NSTimeInterval)inTime CurrentSpeed:(int)inCurrentSpeed
{
  self = [super init];
  if (self) {
    self.description = inDescription;
    self.threadIndex = inThreadIndex;
    self.time = inTime;
    self.currentSpeed = inCurrentSpeed;
  }
  return self;
}
@end

static NSMutableArray* smDebugSocketSendTimeMicroseconds = nil;

//=======

@interface SKHttpTest ()
{
    NSOperationQueue *queue;
    
    NSUInteger multiThreadCount;
    NSUInteger testTotalBytes;
}

@property NSMutableArray* mServerUploadTestBitrates;
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
@synthesize arrTransferOperations;
@synthesize networkType;
@synthesize displayName;
@synthesize testOK;
@synthesize testIndex;
@synthesize runAsynchronously;

@synthesize testTransferBytes;
@synthesize testTransferBytes_New;
@synthesize testTransferTimeMicroseconds;
@synthesize testTransferTimeFirstBytesAt;
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
    self.mServerUploadTestBitrates = [NSMutableArray new];
    
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

- (void)todAddTransferBytes:(NSUInteger)bytes {
  @synchronized(self) {
    if (testTransferTimeFirstBytesAt == nil) {
      testTransferTimeFirstBytesAt = [NSDate date];
    }
  }
  testTransferBytes_New += bytes;
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

//###HG
- (void)prepareStatus
{
    SKTransferOperationStatus* op;
    
    if (arrTransferOperations == nil) arrTransferOperations = [[NSMutableArray alloc] init];
    else [arrTransferOperations removeAllObjects];
    
    for (int j=0; j<nThreads; j++)
    {
        op = [[SKTransferOperationStatus alloc] init];
        
        [op resetProperties];
        
        op.threadId = j;
        
        [arrTransferOperations addObject:op];
    }
}

//###HG
#define C_MAX_UPLOAD_FALSE_TIME   12
#define C_MAX_UPLOAD_SPEED    100

- (void)computeMultiThreadProgress
{
    float total = 0;
    SKTimeIntervalMicroseconds transferTime = 0;
    int totalTransferBytes = 0;
    
    @synchronized(arrTransferOperations)
    {
        for (SKTransferOperationStatus* opStatus in arrTransferOperations) {
            total += opStatus.progress;
            totalTransferBytes += opStatus.totalTransferBytes;
            
            if (opStatus.transferTimeMicroseconds > transferTime) transferTime = opStatus.transferTimeMicroseconds;
        }
    }
    
    double bitrateMbps1024Based = 0;
    
    if (transferTime > 0)
    {
        bitrateMbps1024Based = [SKGlobalMethods getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:transferTime transferBytes:totalTransferBytes];
    }
    
    if (self.isDownstream == NO)
    {
      //Upload test - correct the first huge readings
      if (transferTime < C_MAX_UPLOAD_FALSE_TIME && bitrateMbps1024Based > C_MAX_UPLOAD_SPEED)
        bitrateMbps1024Based = transferTime;
    }
  
    [[self httpRequestDelegate] htdDidUpdateTotalProgress:(total / arrTransferOperations.count) currentBitrate:bitrateMbps1024Based];
}

//##HG
- (void)reset
{
    for (SKTransferOperationStatus* opStatus in arrTransferOperations) {
        [opStatus resetProperties];
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
    testTransferTimeFirstBytesAt = nil;
    testTransferBytes = 0;
    testTransferBytes_New = 0;
    testWarmupBytes = 0;
    testWarmupStartTime = DBL_MAX;
    testWarmupEndTime = DBL_MIN;
    self.warmupDoneCounter = 0;
    
    [self setRunningStatus:INITIALIZING];
  
    // nThreads = 1; // TODO - this is a HACK!
  
    // Generate this value in case we need it.
    // It is a random value from [0...2^32-1]
    uint32_t lSESSIONID_ForServerUploadTest = arc4random();
  
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
                                        SESSIONID:lSESSIONID_ForServerUploadTest
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
  double dTime = testTransferTimeMicroseconds / 1000000.0;   // convert microseconds -> seconds
  if (dTime == 0) {
    return 0;
  }
  double bytesPerSecond = ((double)testTransferBytes) / dTime;
  return (int)bytesPerSecond;
}


- (double)getBytesPerSecondRealTimeUpload
{
  if (testTransferBytes_New != 0) {
    
    NSDate *now = [NSDate date];
    
    NSTimeInterval dTime;
    
    @synchronized (self) {
      SK_ASSERT(self.testTransferTimeFirstBytesAt != nil);
      dTime = [now timeIntervalSinceDate:self.testTransferTimeFirstBytesAt];
      if (dTime <= 0.001) {
        return 0.0;
      }
    }
    
    double bytesPerSecond = ((double)testTransferBytes_New) / dTime;
    //NSLog(@"UPLOAD SPEED: bytes=%d, bytesPersecond=%d, bitsPersecond=%d", (int)testTransferBytes_New, (int)bytesPerSecond, (int) bytesPerSecond*8);
    return bytesPerSecond;
  }
  
  double dTime = testTransferTimeMicroseconds / 1000000.0;   // convert microseconds -> seconds
  if (dTime == 0) {
    return 0;
  }
  double bytesPerSecond = ((double)testTransferBytes) / dTime;
  return bytesPerSecond;
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

//###HG
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
  
    ((SKTransferOperationStatus*)arrTransferOperations[threadId]).status = status; //###HG
}

//###HG
- (void)todDidTransferData:(NSUInteger)totalBytes
                  bytes:(NSUInteger)bytes
               transferBytes:(NSUInteger)transferBytes
               progress:(float)progress
               threadId:(NSUInteger)threadId
               operationTime:(SKTimeIntervalMicroseconds)transferTime
{
 
    NSLog(@"DIDTRANSFER THREAD %lu / %lu %lu %lu %lf", (unsigned long)threadId, (unsigned long)totalBytes, (unsigned long)bytes, (unsigned long)transferBytes, transferTime);
    
    
    [[self httpRequestDelegate] htdDidTransferData:totalBytes bytes:bytes progress:progress threadId:threadId];
    
    @synchronized(arrTransferOperations)
    {
        ((SKTransferOperationStatus*)arrTransferOperations[threadId]).progress = progress; //###HG
        ((SKTransferOperationStatus*)arrTransferOperations[threadId]).totalTransferBytes = (int)transferBytes; //###HG
        ((SKTransferOperationStatus*)arrTransferOperations[threadId]).transferTimeMicroseconds = transferTime; //###HG
    }
    
    NSLog(@"Transfer time in Miliseconds: %f", transferTime);

    
    [self computeMultiThreadProgress];
}

- (void)todUploadTestCompletedNotAServeResponseYet:(SKTimeIntervalMicroseconds)transferTimeMicroseconds
              transferBytes:(NSUInteger)transferBytes
                                        totalBytes:(NSUInteger)totalBytes {
  // This block MUST be synchronized, otherwise the multiple callbacks can all interfere with each other!
  @synchronized(self) {
      // We will sum them up, and take he final value from this.
      testTransferTimeMicroseconds += transferTimeMicroseconds;
      testTotalBytes = testTotalBytes + totalBytes;
      testTransferBytes = testTransferBytes + transferBytes;
  }
  
}

- (void)todDidCompleteTransferOperation:(SKTimeIntervalMicroseconds)transferTimeMicroseconds
              transferBytes:(NSUInteger)transferBytes
                 totalBytes:(NSUInteger)totalBytes
       ForceThisBitsPerSecondFromServer:(double)bitrateMpbs1024Based // If > 0, use this instead!
                   threadId:(NSUInteger)threadId
{
  // This block MUST be synchronized, otherwise the multiple callbacks can all interfere with each other!
  @synchronized(self) {
    if ([self isMultiThreaded])
    {
      if (bitrateMpbs1024Based > 0.0) {
        [self.mServerUploadTestBitrates addObject:[NSNumber numberWithDouble:bitrateMpbs1024Based]];
      }
      
      multiThreadCount += 1;
      SK_ASSERT (multiThreadCount <= nThreads);
      
      // We will sum them up, and take he final value from this.
      testTransferTimeMicroseconds += transferTimeMicroseconds;
      testTotalBytes = testTotalBytes + totalBytes;
      testTransferBytes = testTransferBytes + transferBytes;
      
      // TODO - we're now using the best value FROM THE DYNAMIC MEASURING!
      //NSLog(@"**** DEBUG - SKHttpTesttodDidCompleteTransferOperation - multiThreadCount = %d (%d)", (int)(int)multiThreadCount, (int)(int)nThreads);
      // Override with the values from the new algorithm!
      
      if (multiThreadCount == nThreads)
      {
        @synchronized(self) {
          if (self.isDownstream == NO && testTransferBytes_New > 0 && self.testTransferTimeFirstBytesAt != nil) {
            if (bitrateMpbs1024Based < 0.0) {
#ifdef DEBUG
              NSLog(@"DEBUG: We have NO TIMES FROM THE SERVER. So, use our best guess of locally calculated upload time.");
#endif // DEBUG
              testTransferTimeMicroseconds = [[NSDate date] timeIntervalSinceDate:self.testTransferTimeFirstBytesAt] * 1000000.0;
              testTransferBytes = testTransferBytes_New;
            }
          }
        }
        
#ifdef DEBUG
        // Debug - dump timings
        for (DebugTiming *value in smDebugSocketSendTimeMicroseconds) {
          NSLog(@"HttpTest DUMP - threadIndex:%d description:%@ time:%d microsec speed:%g bitsPerSec:%g", value.threadIndex, value.description, (int) (value.time*1000000), value.currentSpeed, value.currentSpeed*8.0);
        }
#endif // DEBUG
        [self.class sClearDebugSocketSendTimeMicroseconds];
        
        testOK = YES;
        
#ifdef DEBUG
        NSLog(@"**** DEBUG - SKHttpTest:todDidCompleteTransferOperation - hit the thread threshold - calling htdDidCompleteHttpTest!");
#endif // DEBUG
        
        
        NSLog(@"::::: BYTES: %lu TIME %f", (unsigned long)testTotalBytes, testTransferTimeMicroseconds);
        
        
        [self setRunningStatus:COMPLETE];
        [self storeOutputResults];
        
        SK_ASSERT(self.httpRequestDelegate != nil);
        
        BOOL bResultIsFromServer;
        if (self.mServerUploadTestBitrates.count > 0) {
          // Calculate average result from server!
          bResultIsFromServer = YES;
          
          double totalBitrateMpbs1024Based = 0.0;
          
          for (NSNumber *number in self.mServerUploadTestBitrates) {
            totalBitrateMpbs1024Based += number.doubleValue;
          }
          
          bitrateMpbs1024Based = totalBitrateMpbs1024Based / (double)self.mServerUploadTestBitrates.count;
          
        } else {
          // Use our best guess from the client, instead!
          bResultIsFromServer = NO;
          bitrateMpbs1024Based = [SKGlobalMethods getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:transferTimeMicroseconds transferBytes:transferBytes];
        }
        
        if ((self.isDownstream == NO) && [[SKAAppDelegate getAppDelegate] getDoesAppSupportServerBasedUploadSpeedTesting]) {
          // New-style upload stream measurement!
          
        } else {
          // Downstream, or old-style upload
          bitrateMpbs1024Based = [self getSpeedBitrateMpbs1024Based_ForDownloadOrLocalUpload];
        }
        
        [[self httpRequestDelegate] htdDidCompleteHttpTest:bitrateMpbs1024Based
                                        ResultIsFromServer:bResultIsFromServer];
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
      
      BOOL bResultIsFromServer;
      if (bitrateMpbs1024Based > 0.0) {
        // From server!
        bResultIsFromServer = YES;
      } else {
        // Use our best guess from the client, instead!
        bResultIsFromServer = NO;
        bitrateMpbs1024Based = [SKGlobalMethods getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:transferTimeMicroseconds transferBytes:transferBytes];
      }
      
      if ((self.isDownstream == NO) && [[SKAAppDelegate getAppDelegate] getDoesAppSupportServerBasedUploadSpeedTesting]) {
        // New-style upload stream measurement!
      } else {
        // Downstream, or old-style upload
        bitrateMpbs1024Based = [self getSpeedBitrateMpbs1024Based_ForDownloadOrLocalUpload];
      }
      
      [[self httpRequestDelegate] htdDidCompleteHttpTest:bitrateMpbs1024Based
                                      ResultIsFromServer:bResultIsFromServer];
    }
  }
}

-(double)getSpeedBitrateMpbs1024Based_ForDownloadOrLocalUpload {
  double total = 0;
  SKTimeIntervalMicroseconds transferTime = 0;
  int totalTransferBytes = 0;
  
  @synchronized(arrTransferOperations)
  {
    for (SKTransferOperationStatus* opStatus in arrTransferOperations) {
      total += opStatus.progress;
      totalTransferBytes += opStatus.totalTransferBytes;
      
      if (opStatus.transferTimeMicroseconds > transferTime) transferTime = opStatus.transferTimeMicroseconds;
    }
  }
  
  double bitrateMpbs1024Based = 0;
  
  if (transferTime > 0)
  {
    bitrateMpbs1024Based = [SKGlobalMethods getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:transferTime transferBytes:totalTransferBytes];
  }
  
  return bitrateMpbs1024Based;
}
// ---------------------------------------------------------------------------------------------------------



- (BOOL)isSuccessful
{
  return testOK;
}

-(void) setSKAutotest:(SKAutotest*)inSkAutotest {
  self.skAutotest = inSkAutotest;
}

+(NSMutableArray*) sGetDebugSocketSendTimeMicroseconds {
  @synchronized(self) {
    if (smDebugSocketSendTimeMicroseconds == nil) {
      smDebugSocketSendTimeMicroseconds = [NSMutableArray new];
    }
    
    return smDebugSocketSendTimeMicroseconds;
  }
}

+(void) sClearDebugSocketSendTimeMicroseconds {
  @synchronized(self) {
    smDebugSocketSendTimeMicroseconds = nil;
    [self sGetDebugSocketSendTimeMicroseconds];
  }
}

+(void) sAddDebugTimingWithDescription:(NSString*)inDescription ThreadIndex:(int)inThreadIndex Time:(NSTimeInterval)inTime CurrentSpeed:(double)inCurrentSpeed {
  @synchronized(self) {
    NSMutableArray*theArray = [self sGetDebugSocketSendTimeMicroseconds];
    SK_ASSERT(theArray != nil);
    DebugTiming *debugTiming = [[DebugTiming alloc] initWithDescription:inDescription ThreadIndex:inThreadIndex Time:inTime  CurrentSpeed:inCurrentSpeed];
    [theArray addObject:debugTiming];
  }
}

@end

//##HG
@implementation SKTransferOperationStatus

-(void)resetProperties
{
    self.progress = 0;
    self.status = IDLE;
    self.totalTransferBytes = 0;
    self.transferTimeMicroseconds = 0;
}

@end
