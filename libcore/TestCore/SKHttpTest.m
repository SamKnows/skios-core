//
//  SKHttpTest.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKAAppDelegate.h"
#import "NSDate+Helper.h"

NSString *const DOWNSTREAMSINGLE    = @"JHTTPGET";
NSString *const DOWNSTREAMMULTI     = @"JHTTPGETMT";
NSString *const UPSTREAMSINGLE      = @"JHTTPPOST";
NSString *const UPSTREAMMULTI       = @"JHTTPPOSTMT";
NSString *const UDPLATENCY          = @"JUDPLATENCY";

#import "SKJPassiveServerUploadTest.h"

@implementation DebugTiming
- (instancetype)initWithDescription:(NSString*)inDescription ThreadIndex:(int)inThreadIndex Time:(NSTimeInterval)inTime CurrentSpeed:(int)inCurrentSpeed
{
  self = [super init];
  if (self) {
    self.mDescription = inDescription;
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

@property BOOL warmupDone;

@property NSMutableArray* mDescription;
@property NSMutableArray* mServerUploadTestBitrates;
@property (weak) SKAutotest* skAutotest;

@property SKJPassiveServerUploadTest *mpNewStyleSKJUploadTest;

- (void)prepareStatus;
- (BOOL)isMultiThreaded;
- (void)computeMultiThreadProgress;

@end

#pragma mark - Implementation

@implementation SKHttpTest

@synthesize warmupDone;
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

// The following are shared ACROSS ALL THREADS...
// ... and therefore are accessed (in a synchronized way) by the SKTransferOperation instances...
@synthesize mbMoveToTransferring;
@synthesize mStartWarmup;
@synthesize mWarmupTime;
@synthesize mStartTransfer;
@synthesize mWarmupBytes;
@synthesize mTransferBytes;
@synthesize mTotalBytes;
@synthesize mTransferTimeMicroseconds;

@synthesize outputResultsDictionary;

@synthesize skAutotest;

@synthesize mpNewStyleSKJUploadTest;

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
{
  self = [super init];
  
  if (self)
  {
    SK_ASSERT ([((NSObject*)_delegate) conformsToProtocol:@protocol(SKHttpTestDelegate)]);
    mpNewStyleSKJUploadTest = nil;
    
    self.mServerUploadTestBitrates = [NSMutableArray new];
    
    port = _port;
    target = [_target copy];
    file = [_file copy];
    isDownstream = _isDownstream;
    warmupMaxTime = _warmupMaxTime;
    warmupMaxBytes = _warmupMaxBytes;
    SK_ASSERT(warmupMaxBytes >= 0);
    //SK_ASSERT(warmupMaxBytes != warmupMaxTime);
    transferMaxTimeMicroseconds = _transferMaxTimeMicroseconds;
    transferMaxBytes = _transferMaxBytes;
    SK_ASSERT(transferMaxBytes >= 0);
    //SK_ASSERT(transferMaxBytes != transferMaxTimeMicroseconds);
    nThreads = _nThreads;
    isRunning = NO;
    httpRequestDelegate = _delegate;
    testOK = NO;
    runAsynchronously = NO;
    
    [self setRunningStatus:IDLE];
    
    [self prepareForTest];
    
    self.outputResultsDictionary = [[NSMutableDictionary alloc] init];
  }
  
  return self;
}

-(void) prepareForTest {
  
  warmupDone = NO;
  mbMoveToTransferring = NO;
  mStartWarmup = 0;
  mWarmupTime = 0;
  mStartTransfer = 0;
  mWarmupBytes = 0;
  mTransferBytes = 0;
  mTotalBytes      = 0;
  mTransferTimeMicroseconds = 0;
  
  testTotalBytes = 0;
  testTransferBytes = 0;
  testWarmupBytes = 0;
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
  SK_ASSERT (mpNewStyleSKJUploadTest == nil);
  
  float total = 0;
  SKTimeIntervalMicroseconds transferTime = 0;
  // Actually, the total transfer bytes are stored at the HttpTest level, now!
//  int totalTransferBytes = self.mTransferBytes;
  
  //int totalTransferBytes = 0;
  @synchronized(arrTransferOperations)
  {
    for (SKTransferOperationStatus* opStatus in arrTransferOperations) {
      total += opStatus.progress;
      //totalTransferBytes += opStatus.totalTransferBytes;
      
      if (opStatus.transferTimeMicroseconds > transferTime) transferTime = opStatus.transferTimeMicroseconds;
    }
  }
//  
//  double bitrateMbps1024Based = 0;
//  
//  if (transferTime > 0)
//  {
//    bitrateMbps1024Based = [SKGlobalMethods getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:transferTime transferBytes:totalTransferBytes];
//  }
//  
//  if (self.isDownstream == NO)
//  {
//    //Upload test - correct the first huge readings
//    if (transferTime < C_MAX_UPLOAD_FALSE_TIME && bitrateMbps1024Based > C_MAX_UPLOAD_SPEED)
//      bitrateMbps1024Based = transferTime;
//  }
  
  double bitrateMbps1024Based = [self getSpeedbitrateMbps1024Based_ForDownloadOrLocalUpload];
  
  if (bitrateMbps1024Based >= 0.0) {
    
#ifdef DEBUG
    if (isDownstream == NO) {
      // Upload test!
      // Check for unexpectedly large results...
      //SK_ASSERT (bitrateMbps1024Based <= 100);
    }
#endif // DEBUG
    
    [[self httpRequestDelegate] htdDidUpdateTotalProgressPercent:(total / arrTransferOperations.count) BitrateMbps1024Based:bitrateMbps1024Based];
  }
}

//##HG
- (void)reset
{
    for (SKTransferOperationStatus* opStatus in arrTransferOperations) {
        [opStatus resetProperties];
    }
}

//AsyncUdpSocket *spSocket = nil;
//
//-(void) sendTestPing:(NSString *)token {
//  //
//  @try {
//    if (spSocket == nil) {
//      spSocket = [[AsyncUdpSocket alloc] init];
//    }
//    const int cPort = 10001;
//    
//    @try {
//      SKUDPDataGram *datagram = [[SKUDPDataGram alloc] initWithTagAndMagicCookie:(int)99 :CLIENTTOSERVERMAGIC];
//      NSData *data = [[NSData alloc] initWithData:datagram.packetData];
//      SK_ASSERT(data.length > 0);
//      if ([spSocket sendData:data toHost:@"192.168.2.105" port:cPort withTimeout:-1 tag:99] == NO) {
//        SK_ASSERT(false);
//      }
//    } @catch (NSException *e) {
//      SK_ASSERT(false);
//    }
//  } @catch (NSException *e2) {
//    SK_ASSERT(false);
//  } @finally {
//    // Keep the socket open!
//  }
//}

- (void)startTest
{
  // CODE TO ENABLE THE NEW-STYLE UPLOAD SPEED TEST.
  // IF YOU DON'T WANT TO USE IT, JUST COMMENT IT OUT!
  if (isDownstream == NO) {
#ifdef DEBUG
    NSLog(@"*** DEBUG: using SKJ UPLOAD SPEED TEST!!!!");
#endif // DEBUG
    NSDictionary *paramDictionary = @{
                                      TARGET:target,
                                      PORT:[NSString stringWithFormat:@"%ld",(long)port],
                                      WARMUPMAXTIME:[NSString stringWithFormat:@"%ld",(long)warmupMaxTime],
                                      TRANSFERMAXTIME:[NSString stringWithFormat:@"%ld",(long)transferMaxTimeMicroseconds],
                                      NTHREADS:[NSString stringWithFormat:@"%ld",(long)nThreads],
                                      BUFFERSIZE: @"512",
                                      //SENDBUFFERSIZE: @"200000", // This can give HIGHER score if > 32768!
                                      SENDBUFFERSIZE: @"100000", // This can give HIGHER score if > 32768!
                                      RECEIVEBUFFERSIZE: @"32768",
                                      SENDDATACHUNK: @"32768",   // This appears to make no difference
                                      POSTDATALENGTH: @"10485760"};
    
    mpNewStyleSKJUploadTest = [[SKJPassiveServerUploadTest alloc] initWithParams:paramDictionary];
    
    //Start an activity indicator here
    __block BOOL bStopNowFlag = false;
    
    //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_queue_t theTestQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(theTestQueue, ^{
      
      //Call your function or whatever work that needs to be done
      //Code in this part is run on a background thread
      [mpNewStyleSKJUploadTest execute];
      
      bStopNowFlag = true;
#ifdef DEBUG
      double uploadSpeedMbpsMovingAverage = [SKJHttpTest sGetLatestSpeedForExternalMonitorAsMbps];
#endif // DEBUG
      
      double bytesPerSecond = [mpNewStyleSKJUploadTest getTransferBytesPerSecond];
      double uploadSpeedMbps = [SKGlobalMethods convertBytesPerSecondToMbps1000Based:bytesPerSecond];
#ifdef DEBUG
      if (uploadSpeedMbps > 0.0) {
        // Would expect these values to be pretty close to each other - probably around 20%
        double diffAsFraction = fabs(uploadSpeedMbps-uploadSpeedMbpsMovingAverage) / uploadSpeedMbps;
        SK_ASSERT(diffAsFraction <= 0.20);
      }
#endif // DEBUG
      //NSLog(@"****** TEST progress=%d, uploadSpeed bytes persec=%g, mbps=%g AT END", progress, uploadSpeed, uploadSpeedMbps);
  
      __block double bitrateMbps1024Based = [SKGlobalMethods convertMbps1000BasedToMbps1024Based:uploadSpeedMbps];
#ifdef DEBUG
      //__block double bitrateMbps1024BasedMovingAverage = [SKGlobalMethods convertMbps1000BasedToMbps1024Based:uploadSpeedMbpsMovingAverage];
      NSLog(@"****** DEBUG: END TEST uploadSpeed mbps=%g, movingAverage=%g (1024based=%g)", uploadSpeedMbps, uploadSpeedMbpsMovingAverage, bitrateMbps1024Based);
#endif // DEBUG
      
      dispatch_async(dispatch_get_main_queue(), ^(void) {
        const BOOL cbResultIsFromServerFalse = NO;
       
        [self cancel];
        testOK = ![self.mpNewStyleSKJUploadTest getError];
        long totalBytes = [mpNewStyleSKJUploadTest getTotalWarmUpBytes] +  [mpNewStyleSKJUploadTest getTotalTransferBytes];
        SK_ASSERT(totalBytes > 0);
        mTotalBytes = totalBytes;
        [[self httpRequestDelegate] htdUpdateDataUsage:self.mTotalBytes bytes:totalBytes progress:100.0];
        [self setRunningStatus:COMPLETE];
        
        SK_ASSERT(self.testTransferBytes == 0);
        self.testTransferBytes = totalBytes;
        self.testTransferTimeMicroseconds = [mpNewStyleSKJUploadTest getWarmUpTimeMicro];
        
        self.testWarmupBytes = [mpNewStyleSKJUploadTest getTotalWarmUpBytes];
        self.testWarmupEndTime = [[NSDate date] timeIntervalSince1970];
        self.testWarmupStartTime = self.testWarmupEndTime - [mpNewStyleSKJUploadTest getWarmUpTimeMicro] / 1000000.0;
        
        [self storeOutputResults:bitrateMbps1024Based];
        [[self httpRequestDelegate] htdDidCompleteHttpTest:bitrateMbps1024Based
                                        ResultIsFromServer:cbResultIsFromServerFalse
                                           TestDisplayName:self.displayName
         ];
      });
    });
    return;
  }
  
  mpNewStyleSKJUploadTest = nil;
  
  if (nil != queue)
  {
    [queue cancelAllOperations];
    queue = nil;
  }
  
  queue = [[NSOperationQueue alloc] init];
  [queue setMaxConcurrentOperationCount:nThreads];
  
  [self prepareStatus];
  [self reset];
  
  [self prepareForTest];
  testOK = NO;
  multiThreadCount = 0;
  testTotalBytes = 0;
  testTransferTimeMicroseconds = 0;
//              double dTime = testTransferTimeMicroseconds / 1000000.0;
//              NSLog(@"testTransferTimeMiroseconds(0)=%g", dTime);
  testTransferTimeFirstBytesAt = nil;
  testTransferBytes = 0;
  testTransferBytes_New = 0;
  testWarmupBytes = 0;
  testWarmupStartTime = DBL_MAX;
  testWarmupEndTime = DBL_MIN;
  self.warmupDoneCounter = 0;
  
//  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    [self sendTestPing:@"TIMING_Start"];
//  });
  
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
                                       nThreads:nThreads
                                       threadId:i
                                      SESSIONID:lSESSIONID_ForServerUploadTest
                                 ParentHttpTest:self
                                      asyncFlag:[self getTestIsAsyncFlag]];
    
    [operation setSKAutotest:self.skAutotest];
    
    [queue addOperation:operation];
  }
  
  isRunning = YES;
}

-(BOOL) getTestIsAsyncFlag {
  return runAsynchronously;
}

- (void)cancel
{
  if (mpNewStyleSKJUploadTest != nil) {
    
    [mpNewStyleSKJUploadTest cancel];
   
    isRunning = NO;
    return;
  }
  
  if (nil != queue)
  {
#ifdef DEBUG
    NSLog(@"DEBUG: %@ SKHttpTest cancelling %d http test operations!", isDownstream ? @"Download" : @"Upload", (int)[queue operationCount]);
#endif // DEBUG
    [queue cancelAllOperations];
  }
  isRunning = NO;
}

- (BOOL)isReady
{
  if (mpNewStyleSKJUploadTest != nil) {
    return YES;
  }
  
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

- (int)getBytesPerSecondForFinalDisplayAndUploadOld
{
  double dTime = testTransferTimeMicroseconds / 1000000.0;   // convert microseconds -> seconds
  if (dTime == 0) {
    return 0;
  }
  double bytesPerSecond = ((double)testTransferBytes) / dTime;
  
  int intBytesPerSecond = (int)bytesPerSecond;
  
  return intBytesPerSecond;
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
  SK_ASSERT(dTime < 120.0); // No more than 2 minutes, or something is VERY wrong...
  double bytesPerSecond = ((double)testTransferBytes) / dTime;
  return bytesPerSecond;
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
      [self cancel];
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
  
  //NSLog(@"DIDTRANSFER THREAD %lu / %lu %lu %lu %lf", (unsigned long)threadId, (unsigned long)totalBytes, (unsigned long)bytes, (unsigned long)transferBytes, transferTime);
  
  [[self httpRequestDelegate] htdUpdateDataUsage:totalBytes bytes:bytes progress:progress];
  
  @synchronized(arrTransferOperations)
  {
    ((SKTransferOperationStatus*)arrTransferOperations[threadId]).progress = progress; //###HG
    //((SKTransferOperationStatus*)arrTransferOperations[threadId]).totalTransferBytes = (int)transferBytes; //###HG
    ((SKTransferOperationStatus*)arrTransferOperations[threadId]).transferTimeMicroseconds = transferTime; //###HG
  }
  
  // TODO - ENABLE THIS TO DEBUG TRACK PROGRESS! NSLog(@"Transfer time in Milliseconds: %f, PROGRESS=%g", transferTime/1000.0F, progress);

//#ifdef DEBUG
//  if (isDownstream == NO) {
//    NSLog(@"todDidTransfer - upload test, progress = %d", (int)progress);
// }
//#endif // DEBUG
  
  [self computeMultiThreadProgress];
}

- (void)todUploadTestCompletedNotAServeResponseYet:(SKTimeIntervalMicroseconds)transferTimeMicroseconds
              transferBytes:(NSUInteger)transferBytes
                                        totalBytes:(NSUInteger)totalBytes {
  // This block MUST be synchronized, otherwise the multiple callbacks can all interfere with each other!
  @synchronized(self) {
      // We will sum them up, and take he final value from this.
      testTransferTimeMicroseconds += transferTimeMicroseconds;
//              double dTime = testTransferTimeMicroseconds / 1000000.0;
//              NSLog(@"testTransferTimeMiroseconds(4)=%g", dTime);
      testTotalBytes = testTotalBytes + totalBytes;
      testTransferBytes = testTransferBytes + transferBytes;
  }
  
}

- (void)todDidCompleteTransferOperation:(SKTimeIntervalMicroseconds)transferTimeMicroseconds
              transferBytes:(NSUInteger)transferBytes
                 totalBytes:(NSUInteger)totalBytes
       ForceThisBitsPerSecondFromServer:(double)bitrateMbps1024Based // If > 0, use this instead!
                   threadId:(NSUInteger)threadId
{
  SK_ASSERT(mpNewStyleSKJUploadTest == nil);
  
  // This block MUST be synchronized, otherwise the multiple callbacks can all interfere with each other!
  @synchronized(self) {
    if ([self isMultiThreaded])
    {
      if (bitrateMbps1024Based > 0.0) {
        if (self.isDownstream == NO) {
          [self.mServerUploadTestBitrates addObject:[NSNumber numberWithDouble:bitrateMbps1024Based]];
        }
      }
      
      multiThreadCount += 1;
      SK_ASSERT (multiThreadCount <= nThreads);
      
      // We will sum them up, and take he final value from this.
      testTransferTimeMicroseconds += transferTimeMicroseconds;
//              double dTime = testTransferTimeMicroseconds / 1000000.0;
//              NSLog(@"testTransferTimeMiroseconds(5)=%g", dTime);
      testTotalBytes = testTotalBytes + totalBytes;
      testTransferBytes = testTransferBytes + transferBytes;
      
      // TODO - we're now using the best value FROM THE DYNAMIC MEASURING!
      //NSLog(@"DEBUG **** - SKHttpTesttodDidCompleteTransferOperation - multiThreadCount = %d (%d)", (int)(int)multiThreadCount, (int)(int)nThreads);
      // Override with the values from the new algorithm!
      
      if (multiThreadCount == nThreads)
      {
        @synchronized(self) {
          if (self.isDownstream == NO && testTransferBytes_New > 0 && self.testTransferTimeFirstBytesAt != nil) {
            if (bitrateMbps1024Based < 0.0) {
#ifdef DEBUG
              NSLog(@"DEBUG: We have NO TIMES FROM THE SERVER. So, use our best guess of locally calculated upload time.");
#endif // DEBUG
              testTransferTimeMicroseconds = [[NSDate date] timeIntervalSinceDate:self.testTransferTimeFirstBytesAt] * 1000000.0;
              
#ifdef DEBUG
              double dTime = testTransferTimeMicroseconds / 1000000.0;
//              NSLog(@"testTransferTimeMiroseconds(1)=%g", dTime);
              
              SK_ASSERT(dTime < 120.0); // No more than 2 minutes, or something is VERY wrong...
#endif // DEBUG
              testTransferBytes = testTransferBytes_New;
              
              //double bitrateMbps1024Based = [SKGlobalMethods getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:testTransferTimeMicroseconds transferBytes:testTransferBytes];
              //NSLog(@"DEBUG: bitrateMbps1024Based (RESULT)=%f (bytes=%f, micro=%f)", bitrateMbps1024Based, (double)testTransferBytes, (double)testTransferTimeMicroseconds);
            }
          }
        }
        
#ifdef DEBUG
        // Debug - dump timings
        for (DebugTiming *value in smDebugSocketSendTimeMicroseconds) {
          NSLog(@"DEBUG: HttpTest DUMP - threadIndex:%d description:%@ time:%d microsec speed:%f bitsPerSec:%f", value.threadIndex, value.mDescription, (int) (value.time*1000000), value.currentSpeed, value.currentSpeed*8.0);
        }
#endif // DEBUG
        [self.class sClearDebugSocketSendTimeMicroseconds];
        
        testOK = YES;
        
#ifdef DEBUG
        NSLog(@"DEBUG **** - SKHttpTest:todDidCompleteTransferOperation - hit the thread threshold - calling htdDidCompleteHttpTest!");
        
        NSLog(@"DEBUG: ::::: BYTES: %lu TIME %f", (unsigned long)testTotalBytes, testTransferTimeMicroseconds);
#endif // DEBUG
        
        
        [self setRunningStatus:COMPLETE];
        
        SK_ASSERT(self.httpRequestDelegate != nil);
        
        BOOL bResultIsFromServer;
        if (self.mServerUploadTestBitrates.count > 0) {
          // Calculate average result from server!
          bResultIsFromServer = YES;
          
          double totalbitrateMbps1024Based = 0.0;
          
          for (NSNumber *number in self.mServerUploadTestBitrates) {
            totalbitrateMbps1024Based += number.doubleValue;
          }
          
          bitrateMbps1024Based = totalbitrateMbps1024Based / (double)self.mServerUploadTestBitrates.count;
          
        } else {
          // Use our best guess from the client, instead!
          bResultIsFromServer = NO;
          bitrateMbps1024Based = [SKGlobalMethods getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:transferTimeMicroseconds transferBytes:transferBytes];
        }
        
        if ((self.isDownstream == NO) && [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getDoesAppSupportServerBasedUploadSpeedTesting]) {
          // New-style upload stream measurement!
          
        } else {
          // Downstream, or old-style upload
          // Returns -1.0 if invalid!
          double tryThis = [self getSpeedbitrateMbps1024Based_ForDownloadOrLocalUpload];
          if (tryThis >= 0.0) {
            
            bitrateMbps1024Based = tryThis;
            //NSLog(@"DEBUG: bitrateMbps1024Based (TRYTHIS)=%f)", bitrateMbps1024Based);
            
          }
        }
      
        [self storeOutputResults:bitrateMbps1024Based];
        
        [[self httpRequestDelegate] htdDidCompleteHttpTest:bitrateMbps1024Based
                                        ResultIsFromServer:bResultIsFromServer
                                           TestDisplayName:self.displayName
         ];
      }
    }
    else
    {
      testOK = YES;
      
      [self setRunningStatus:COMPLETE];
      
      testTotalBytes = totalBytes;
      testTransferBytes = transferBytes;
      testTransferTimeMicroseconds = transferTimeMicroseconds;
//              double dTime = testTransferTimeMicroseconds / 1000000.0;
//              NSLog(@"testTransferTimeMiroseconds(3)=%g", dTime);
      
      
      BOOL bResultIsFromServer;
      if (bitrateMbps1024Based > 0.0) {
        // From server!
        bResultIsFromServer = YES;
      } else {
        // Use our best guess from the client, instead!
        bResultIsFromServer = NO;
        bitrateMbps1024Based = [SKGlobalMethods getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:transferTimeMicroseconds transferBytes:transferBytes];
      }
      
      if ((self.isDownstream == NO) && [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getDoesAppSupportServerBasedUploadSpeedTesting]) {
        // New-style upload stream measurement!
      } else {
        // Downstream, or old-style upload
        // returns -1.0 if invalid.
        double tryThis = [self getSpeedbitrateMbps1024Based_ForDownloadOrLocalUpload];
        if (tryThis >= 0.0) {
          
          bitrateMbps1024Based = tryThis;
        }
      }
     
      [self storeOutputResults:bitrateMbps1024Based];
      
      [[self httpRequestDelegate] htdDidCompleteHttpTest:bitrateMbps1024Based
                                      ResultIsFromServer:bResultIsFromServer
                                         TestDisplayName:self.displayName
       ];
    }
  }
}

// RETURNS -1 if value returned is NOT YET VALID!
-(double)getSpeedbitrateMbps1024Based_ForDownloadOrLocalUpload {
  double total = 0.0;
  SKTimeIntervalMicroseconds transferTimeMicroseconds = 0.0;
  
  // Actually, the total transfer bytes are stored at the HttpTest level, now!
  int totalTransferBytes = self.mTransferBytes;
  //int totalTransferBytes = 0;
  @synchronized(arrTransferOperations)
  {
    for (SKTransferOperationStatus* opStatus in arrTransferOperations) {
      total += opStatus.progress;
      //totalTransferBytes += opStatus.totalTransferBytes;
      
      if (opStatus.transferTimeMicroseconds > transferTimeMicroseconds) {
        transferTimeMicroseconds = opStatus.transferTimeMicroseconds;
      }
    }
  }
 
  
  
  if (transferTimeMicroseconds < 1000000.0) // At least a second!
  {
    // Not yet possible to return a valid result!
    return -1.0;
  }
  
  double bitrateMbps1024Based = [SKGlobalMethods getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:transferTimeMicroseconds transferBytes:totalTransferBytes];
  
  return bitrateMbps1024Based;
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


// Moved from SKTransferOperation.m ...

+ (SKTimeIntervalMicroseconds)sMicroTimeForSeconds:(NSTimeInterval)time
{
  return time * 1000000.0; // convert to microseconds
}

- (int)getProgress
{
  double result = 0;
  
  @synchronized(self) {
    if(self.mStartWarmup == 0)
    {
      result = 0;
    }
    else if(transferMaxTimeMicroseconds != 0)
    {
      SKTimeIntervalMicroseconds currTime = [self.class sMicroTimeForSeconds:[[SKCore getToday] timeIntervalSince1970] - mStartWarmup];
      result = currTime/(warmupMaxTime + transferMaxTimeMicroseconds);
    }
    else
    {
      int currBytes = mWarmupBytes + mTransferBytes;
      result = (double)currBytes/(warmupMaxBytes+transferMaxBytes);
    }
  }
  
  result = result < 0 ? 0 : result;
  result = result > 1 ? 1 : result;
  
  return (int) (result*100);
}

-(BOOL) getIsWarmupDone:(int)bytes
{
  @synchronized(self)
  {
    if (warmupDone == YES) {
      return YES;
    }
    
    mWarmupBytes += bytes;
    
    if (mStartWarmup == 0)
    {
      mStartWarmup = [[SKCore getToday] timeIntervalSince1970];
    }
    
    NSTimeInterval currentTime = [[SKCore getToday] timeIntervalSince1970];
    
    mWarmupTime = [self.class sMicroTimeForSeconds:currentTime - mStartWarmup];
    
    if (((warmupMaxTime > 0) && (mWarmupTime >= warmupMaxTime)) ||
        ((warmupMaxBytes > 0) && (mWarmupBytes >= warmupMaxBytes)))
    {
      [self todIncrementWarmupDoneCounter];
      
      [self todAddWarmupBytes:mWarmupBytes];
      [self todAddWarmupTimes:mStartWarmup endTime:currentTime];
      
      warmupDone = YES;
      
      if (isDownstream == NO) {
        // Upstream -  immediately move to transferring!
        self.mbMoveToTransferring = YES;
      }
    }
    
    return warmupDone;
  }
}


- (BOOL)isTransferDone:(int)bytes
{
  BOOL result = false;
  
  @synchronized(self)
  {
    mTransferBytes += bytes;
    
    if (mStartTransfer == 0)
    {
      mStartTransfer = [[SKCore getToday] timeIntervalSince1970];
    }
    mTransferTimeMicroseconds = [self.class sMicroTimeForSeconds:[[SKCore getToday] timeIntervalSince1970] - mStartTransfer];
    
    if (((transferMaxTimeMicroseconds > 0) && (mTransferTimeMicroseconds >= transferMaxTimeMicroseconds)) ||
        ((transferMaxBytes > 0) && (mTransferBytes >= transferMaxBytes)))
    {
      result = true;
    }
  }
  
  return result;
}

- (int)getBytesPerSecond:(NSInteger)TotalBytesWritten
{
  @synchronized(self) {
    // if ([self isSuccessful])
    SKTimeIntervalMicroseconds elapsedTime = [self.class sMicroTimeForSeconds:[[SKCore getToday] timeIntervalSince1970] - mStartTransfer];
    
    double dTime = elapsedTime / 1000000.0;   // convert microseconds -> seconds
    if (dTime == 0) {
      return 0;
    }
    
    double bytesPerSecond = ((double)TotalBytesWritten) / dTime;
    return (int)bytesPerSecond;
  }
}

- (BOOL)isUploadTransferDoneBytesThisTime:(int)bytesThisTime TotalBytes:(int)inTotalBytes TotalBytesToTransfer:(int)inTotalBytesToTransfer
{
  BOOL result = false;
  
  @synchronized(self)
  {
    // The transfer bytes is the sum of ALL values, across ALL threads!
    //mTransferBytes = inTotalBytes;
    mTransferBytes += bytesThisTime;
  
    if (mStartTransfer == 0)
    {
      mStartTransfer = [[SKCore getToday] timeIntervalSince1970];
    }
    mTransferTimeMicroseconds = [self.class sMicroTimeForSeconds:[[SKCore getToday] timeIntervalSince1970] - mStartTransfer];
    
    if (inTotalBytes >= inTotalBytesToTransfer) {
      return true;
    }
    
    if ((transferMaxTimeMicroseconds > 0) && (mTransferTimeMicroseconds >= transferMaxTimeMicroseconds))
    {
      result = true;
    }
    if ((transferMaxBytes > 0) && (mTransferBytes >= transferMaxBytes))
    {
      result = true;
    }
    
    [self todAddTransferBytes:bytesThisTime];
  }
  
  return result;
}



- (void)storeOutputResults:(double)bitrateMbps1024Based
{
//  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    [self sendTestPing:@"TIMING_Stop"];
//  });

  //    "type": "JHTTPPOSTMT",
  //    "bytes_sec": "167995",
  //    "datetime": "Fri Jan 25 15:35:36 GMT 2013",
  //    "number_of_threads": "3",
  //    "success": "true",
  //    "target": "n1-the1.samknows.com",
  //    "target_ipaddress": "46.17.56.234",
  //    "timestamp": "1359128136",
  //    "transfer_bytes": "1944064",
  //    "transfer_time": "11572113",
  //    "warmup_bytes": "114176",
  //    "warmup_time": "1496460"
  
  // Always re-create the dictionary...
  outputResultsDictionary = [[NSMutableDictionary alloc] init];
  
  if (self.isDownstream)
  {
    NSString *type = (self.nThreads == 1) ? DOWNSTREAMSINGLE : DOWNSTREAMMULTI;
    
    [outputResultsDictionary setObject:type
                                forKey:@"type"];
  }
  else
  {
    NSString *type = (self.nThreads == 1) ? UPSTREAMSINGLE : UPSTREAMMULTI;
    
    [outputResultsDictionary setObject:type
                                forKey:@"type"];
  }
 
#ifdef DEBUG
  int bytesPerSecondOld = [self getBytesPerSecondForFinalDisplayAndUploadOld];
  double bitrateMbps1024BasedOld = [SKGlobalMethods getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:testTransferTimeMicroseconds transferBytes:testTransferBytes];
  NSLog(@"DEBUG: bitrateMpbs1024Based=%f, bitrateMbps1024BasedOld (JSON)=%f (bytes=%f, micro=%f)", bitrateMbps1024Based, bitrateMbps1024BasedOld, (double)testTransferBytes, (double)testTransferTimeMicroseconds);
  
  double bitrateMbps1000Based = [SKGlobalMethods convertMbps1024BasedToMBps1000Based:bitrateMbps1024Based];
  NSString *mbpsString = [SKGlobalMethods sGet3DigitsNumber:bitrateMbps1000Based];
  NSLog(@"DEBUG: The app should display Mbps value of ... %@ Mbps", mbpsString);
#endif // DEBUG
  
  int bytesPerSecond = [SKGlobalMethods convertMpbs1024BasedToBytesPerSecond:bitrateMbps1024Based];
  if (bytesPerSecond <= 0) {
    // 30/03/2015 - note that if bytesPerSecond is (less than or equal to) ZERO, we must also tag this with "success": false
    // c.f. HttpTest.java on
#ifdef DEBUG
  NSLog(@"DEBUG: WARNING: bytesPerSecond = 0");
#endif // DEBUG
    self.testOK = NO;
  }
  
#ifdef DEBUG
  NSLog(@"DEBUG: bytesPerSecond (JSON)=%d (bytesPerSecondOld=%d)", bytesPerSecond, bytesPerSecondOld);
#endif // DEBUG
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", bytesPerSecond]
                              forKey:@"bytes_sec"];
  
  [outputResultsDictionary setObject:[NSDate sGetDateAsIso8601String:[SKCore getToday]] forKey:@"datetime"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", self.nThreads]
                              forKey:@"number_of_threads"];
  
  [outputResultsDictionary setObject:self.testOK ? @"true" : @"false"
                              forKey:@"success"];
  
  [outputResultsDictionary setObject:self.target
                              forKey:@"target"];
  
  [outputResultsDictionary setObject:[SKIPHelper hostIPAddress:self.target]
                              forKey:@"target_ipaddress"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)([[SKCore getToday] timeIntervalSince1970])]
                              forKey:@"timestamp"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)testTransferBytes]
                              forKey:@"transfer_bytes"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)(testTransferTimeMicroseconds)]
                              forKey:@"transfer_time"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)self.testWarmupBytes]
                              forKey:@"warmup_bytes"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)((self.testWarmupEndTime - self.testWarmupStartTime) * 1000000)]
                              forKey:@"warmup_time"];
}

@end

//##HG
@implementation SKTransferOperationStatus

-(void)resetProperties
{
    self.progress = 0;
    self.status = IDLE;
    //self.totalTransferBytes = 0;
    self.transferTimeMicroseconds = 0;
}
@end
