//
//  SKTransferOperation.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKTransferOperation.h"


#pragma mark - Interface

@interface SKTransferOperation ()
{
  NSTimeInterval startWarmup;
  NSTimeInterval warmupTime;
  int warmupBytes;
  
  NSTimeInterval startTransfer;
  int transferBytes;
  
  NSUInteger totalBytes;
  
  BOOL warmupDone;
  
  NSPort* nsPort;
  
  struct timespec sleeptime;
  
  BOOL testOK;
}

@property BOOL shouldKeepRunning;

@property BOOL mbAsyncFlag;

@property (nonatomic, assign) TransferStatus status;

@property BOOL mbTestMode;

@property (weak) SKAutotest* skAutotest;

- (SKTimeIntervalMicroseconds)microTime:(NSTimeInterval)time;
- (BOOL)isWarmupDone:(int)bytes;
- (BOOL)isTransferDone:(int)bytes;

- (void)done;
- (void)cancelled;
- (void)prepareParams;
- (void)tearDown;

- (void)cancelTicked;

- (void)startBackgroundTask;
- (void)finishBackgroundTask;
- (void)setExecutingAndFinished:(BOOL)executing finished:(BOOL)finished;

//#pragma  mark - Private methods to invoke our delegate methods of the same name
//
//- (void)updateStatus:(TransferStatus)status_
//            threadId:(NSUInteger)threadId_;
//
//- (void)todDidTransferData:(NSUInteger)totalBytes_
//                  bytes:(NSUInteger)bytes_
//               progress:(float)progress_
//               threadId:(NSUInteger)threadId_;
//
//- (void)didCompleteTransfer:(SKTimeIntervalMicroseconds)transferTime_
//              transferBytes:(NSUInteger)transferBytes_
//                 totalBytes:(NSUInteger)totalBytes_
//                   threadId:(NSUInteger)threadId_;


@end

#pragma mark - Implementation

@implementation SKTransferOperation

@synthesize shouldKeepRunning;

@synthesize mbTestMode;

@synthesize mbAsyncFlag;

@synthesize target;
@synthesize port;
@synthesize warmupMaxTime;
@synthesize warmupMaxBytes;
@synthesize transferMaxBytes;
@synthesize transferMaxTimeMicroseconds;
@synthesize nThreads;
@synthesize file;
@synthesize transferOperationDelegate;
@synthesize isDownstream;
@synthesize startTime;
@synthesize transferTimeMicroseconds;
@synthesize threadId;

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
            threadId:(int)_threadId
TransferOperationDelegate:(id <SKTransferOperationDelegate>)_delegate
           asyncFlag:(BOOL)_asyncFlag
{
  self = [super init];
  
  if (self)
  {
    mbTestMode = NO;
    
    target = [_target copy];
    port = _port;
    file = [_file copy];
    isDownstream = _isDownstream;
    warmupMaxTime = _warmupMaxTime;
    warmupMaxBytes = _warmupMaxBytes;
    SK_ASSERT(warmupMaxBytes >= 0);
    SK_ASSERT(warmupMaxBytes != warmupMaxTime);
    transferMaxTime = _transferMaxTimeMicroseconds;
    transferMaxBytes = _transferMaxBytes;
    SK_ASSERT(transferMaxBytes >= 0);
    SK_ASSERT(transferMaxBytes != transferMaxTime);
    nThreads = _nThreads;
    threadId = _threadId;
    transferOperationDelegate = _delegate;
    mbAsyncFlag = _asyncFlag;
    
    self.status = INITIALIZING;
    
    [self setCompletionBlock:nil];
    
    sleeptime.tv_sec  = 0;
    sleeptime.tv_nsec = 1;
    
    testOK = YES;
    
#ifdef DEBUG
    NSLog(@"DEBUG: created NSOperationQueue (SKTransferOperation): %@", [self description]);
#endif // DEBUG
  }
  
  return self;
}

- (void)dealloc
{
  [self tearDown];
}


+(NSString*) getUpStream {
  return NSLocalizedString(@"to_UpStream",nil);
}

+(NSString*) getDownStream {
  return NSLocalizedString(@"to_DownStream",nil);
}

+(NSString*) getStatusInitializing {
  return NSLocalizedString(@"to_StatusInitializing",nil);
}

+(NSString*) getStatusWarming {
  return NSLocalizedString(@"to_StatusWarming",nil);
}

+(NSString*) getStatusTransferring {
  return NSLocalizedString(@"to_StatusTransferring",nil);
}

+(NSString*) getStatusComplete {
  return NSLocalizedString(@"to_StatusComplete",nil);
}

+(NSString*) getStatusCancelled {
  return NSLocalizedString(@"to_StatusCancelled",nil);
}

+(NSString*) getStatusFailed {
  return NSLocalizedString(@"to_StatusFailed",nil);
}

+(NSString*) getStatusFinished {
  return NSLocalizedString(@"to_StatusFinished",nil);
}

+(NSString*) getStatusIdle {
  return NSLocalizedString(@"to_StatusIdle",nil);
}

-(BOOL)getAsyncFlag {
  return mbAsyncFlag;
}

#pragma mark - Instance Methods

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

- (void)prepareParams
{
  totalBytes      = 0;
  transferBytes   = 0;
  warmupDone      = NO;
}

- (void)cancelTicked
{
  if([self isCancelled])
  {
    [self cancelled];
  }
}

- (void)done
{
  [self tearDown];
  [self finishBackgroundTask];
  [self setExecutingAndFinished:NO finished:YES];
}

- (void)tearDown
{
  if (nil != urlConnection)
  {
    [urlConnection cancel];
    urlConnection = nil;
  }
  
  if (nil != urlRequest)
  {
    urlRequest = nil;
  }
  
  if (nil != target)
  {
    target = nil;
  }
  
  if (nil != file)
  {
    file = nil;
  }
  
  if (nil != cancelTimer)
  {
    [cancelTimer invalidate];
    cancelTimer = nil;
  }
  
  if (nil != nsPort)
  {
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    [runLoop removePort:nsPort forMode:NSRunLoopCommonModes];
    nsPort = nil;
  }
  
  self.shouldKeepRunning = NO;
}

- (void)cancelled
{
  [self done];
	[self doSendUpdateStatus:CANCELLED threadId:threadId];
}

// Put in a method, so we can mock it out when required under testing!
- (NSURLConnection *)newAsynchronousRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate>)theDelegate startImmediately:(NSNumber*)inStartImmediately {
  NSURLConnection *theUrlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:theDelegate startImmediately:[inStartImmediately boolValue]];
  return theUrlConnection;
}

- (void)start
{
  // If we're running from the MAIN THREAD, then we're in test mode, where start is being
  // called directly from the main thread!
  if ([NSThread isMainThread] == YES) {
    // In TEST MODE, we do NOT start the URL connection... we rely on hard-coded callbacks into the delegate
    // methods to provoke the system under test!
    self.mbTestMode = YES;
    
#ifdef DEBUG
    NSLog(@"DEBUG: running %s in TEST mode (this is the main thread!) - delete methods must be called MANUALLY by the test!", __FUNCTION__);
#endif // DEBUG
  }

  // Main method behaviour...
  
  if(_Finished)
  {
    [self done];
    [self doSendUpdateStatus:FINISHED threadId:threadId];
  }
  else if ([self isCancelled])
  {
    [self cancelled];
  }
  else
  {
    self.status = INITIALIZING;
    [self doSendUpdateStatus:self.status threadId:threadId];
    [self prepareParams];
    
#ifdef DEBUG
    NSLog(@"DEBUG %@ - INITIALIZING", [self description]);
#endif // DEBUG
    
    if (isDownstream)
    {
#ifdef DEBUG
      NSLog(@"DEBUG %@ - isDownstream", [self description]);
#endif // DEBUG
      
      NSMutableString *urlString = [[NSMutableString alloc] init];
      
      if (![target hasPrefix:@"http"])
      {
        [urlString appendString:@"http://"];
      }
      [urlString appendString:target];
      [urlString appendString:@"/"];
      [urlString appendString:file];
      
#ifdef DEBUG
      NSLog(@"DEBUG %@ - urlString=%@", [self description], urlString);
#endif // DEBUG
      
      NSURL *nsUrl = [[NSURL alloc] initWithString:urlString];
      
      urlRequest = [[NSMutableURLRequest alloc] initWithURL:nsUrl
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                            timeoutInterval:HTTP_DOWNLOAD_TIMEOUT];
    }
    else
    {
#ifdef DEBUG
      NSLog(@"DEBUG %@ - isUpstream", [self description]);
#endif // DEBUG
      
      if (nil == file)
      {
#ifdef DEBUG
        NSLog(@"DEBUG file is nil");
#endif //DEBUG
        SK_ASSERT(false);
        return;
      }
      
      
      NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:file];
      NSData *bodyData = [[NSData alloc] initWithContentsOfURL:fileUrl options:NSUTF8StringEncoding error:NULL];
      
      NSMutableString *urlString = [[NSMutableString alloc] init];
      
      if (![target hasPrefix:@"http"])
      {
        [urlString appendString:@"http://"];
      }
      [urlString appendString:target];
      
#ifdef DEBUG
      NSLog(@"DEBUG %@ - urlString=%@, bodyData=%d", [self description], urlString, (int)[bodyData length]);
#endif // DEBUG
      
      NSURL *nsUrl = [[NSURL alloc] initWithString:urlString];
      
      urlRequest = [[NSMutableURLRequest alloc] initWithURL:nsUrl
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                            timeoutInterval:HTTP_DOWNLOAD_TIMEOUT];
      urlRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;
      
      [urlRequest setHTTPMethod:@"POST"];
      //[urlRequest setHTTPBodyStream:[[NSInputStream alloc] initWithData:bodyData]];
      [urlRequest setHTTPBody:bodyData];
      //[urlRequest setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
      [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
      
#ifdef DEBUG
      NSLog(@"DEBUG %@ - upload request header fields=\n%@", [self description], [[urlRequest allHTTPHeaderFields] description]);
#endif // DEBUG
      
      
    }
    
    if (urlRequest != nil)
    {
      [self setExecutingAndFinished:YES finished:NO];
      [self startBackgroundTask];
      
      cancelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                     target:self
                                                   selector:@selector(cancelTicked)
                                                   userInfo:nil
                                                    repeats:YES];
      
      urlConnection = [self newAsynchronousRequest:urlRequest delegate:self startImmediately:NO];
      
      // If we're in "Test Mode", the call is in the main thread; in which case, we leave it up to the test
      // harness to call our delegate methods.
      // Otherwise, this is *not* the main thread; we'll be using an NSOperation queue.
      // as we're in a separate thread, we need to keep the thread running in its own run loop
      // until the network access has completed...
      // http://cocoaintheshell.com/2011/04/nsurlconnection-synchronous-asynchronous/
     
      if (self.mbTestMode) {
        
        // Do nothing!
        
      } else {
        
        SK_ASSERT([NSThread isMainThread] == NO);
        
        nsPort = [NSPort port];
        
        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        //runLoop = [NSRunLoop mainRunLoop];
        [runLoop addPort:nsPort forMode:NSRunLoopCommonModes];
        [urlConnection scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];
        [urlConnection start];
        
        //[runLoop run];
        self.shouldKeepRunning = YES;
        NSRunLoop *theRL = [NSRunLoop currentRunLoop];
        //while (shouldKeepRunning && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
        for (;;) {
          if ([self isCancelled]) {
            break;
          }
          
          if (self.shouldKeepRunning == NO) {
            break;
          }
          
          if (testOK == NO) {
#ifdef DEBUG
            NSLog(@"DEBUG: SKTransferOperation test stopped as testOK = NO");
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
}

- (int)getProgress
{
  double result = 0;
  
  if(startWarmup == 0)
  {
    result = 0;
  }
  else if(transferMaxTime != 0)
  {
    SKTimeIntervalMicroseconds currTime = [self microTime:[[SKCore getToday] timeIntervalSince1970] - startWarmup];
    result = currTime/(warmupMaxTime + transferMaxTime);
  }
  else
  {
    int currBytes = warmupBytes + transferBytes;
    result = (double)currBytes/(warmupMaxBytes+transferMaxBytes);
  }
  
  result = result < 0 ? 0 : result;
  result = result > 1 ? 1 : result;
  
  return (int) (result*100);
}

- (SKTimeIntervalMicroseconds)microTime:(NSTimeInterval)time
{
  return time * 1000000.0; // convert to microseconds
}

- (BOOL)isWarmupDone:(int)bytes
{
  if (warmupDone)
  {
    return YES;
  }
  else
  {
    @synchronized(self)
    {
      warmupBytes += bytes;
      
      if (startWarmup == 0)
      {
        startWarmup = [[SKCore getToday] timeIntervalSince1970];
      }
      
      NSTimeInterval currentTime = [[SKCore getToday] timeIntervalSince1970];
      
      warmupTime = [self microTime:currentTime - startWarmup];
      
      if (((warmupMaxTime > 0) && (warmupTime >= warmupMaxTime)) ||
          ((warmupMaxBytes > 0) && (warmupBytes >= warmupMaxBytes)))
      {
        [self.transferOperationDelegate todIncrementWarmupDoneCounter];
        
        while ([self.transferOperationDelegate todGetWarmupDoneCounter] < nThreads)
        {
          nanosleep (&sleeptime, NULL);
        }
        
        [self.transferOperationDelegate todAddWarmupBytes:warmupBytes];
        [self.transferOperationDelegate todAddWarmupTimes:startWarmup endTime:currentTime];
        
        warmupDone = YES;
      }
      
      return warmupDone;
    }
  }
}

- (BOOL)isTransferDone:(int)bytes
{
  BOOL result = false;
  
  @synchronized(self)
  {
    transferBytes += bytes;
    
    if (startTransfer == 0)
    {
      startTransfer = [[SKCore getToday] timeIntervalSince1970];
    }
    transferTimeMicroseconds = [self microTime:[[SKCore getToday] timeIntervalSince1970] - startTransfer];
    
    if (((transferMaxTime > 0) && (transferTimeMicroseconds >= transferMaxTime)) ||
        ((transferMaxBytes > 0) && (transferBytes >= transferMaxBytes)))
    {
      result = true;
    }
  }
  
  return result;
}

- (BOOL)isUploadTransferDone:(int)inTotalBytes TotalBytesToTransfer:(int)inTotalBytesToTransfer
{
  BOOL result = false;
  
  @synchronized(self)
  {
    transferBytes = inTotalBytes;
    
    if (startTransfer == 0)
    {
      startTransfer = [[SKCore getToday] timeIntervalSince1970];
    }
    transferTimeMicroseconds = [self microTime:[[SKCore getToday] timeIntervalSince1970] - startTransfer];
    
    if (inTotalBytes >= inTotalBytesToTransfer) {
      return true;
    }
    
    if (((transferMaxTime > 0) && (transferTimeMicroseconds >= transferMaxTime)) ||
        ((transferMaxBytes > 0) && (transferBytes >= transferMaxBytes)))
    {
      result = true;
    }
  }
  
  return result;
}


#pragma mark - Private methods

- (void)doSendUpdateStatus:(TransferStatus)status_ threadId:(NSUInteger)threadId_
{
  if (self.mbTestMode) {
    SK_ASSERT ([NSThread isMainThread]);
    SK_ASSERT (dispatch_get_current_queue() == dispatch_get_main_queue());
    // We're in the main thread!
    // This means that we're in TEST MODE (where the start method is called directly from the main thread...)
    // This IGNORES the setting of mbAsyncFlag.
    [self.transferOperationDelegate todUpdateStatus:status_ threadId:threadId_];
  } else if (mbAsyncFlag) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.transferOperationDelegate todUpdateStatus:status_ threadId:threadId_];
    });
  } else {
    SK_ASSERT (dispatch_get_current_queue() != dispatch_get_main_queue());
    // If we use dispatch_sync, it can stop working / hang on fast networks!
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.transferOperationDelegate todUpdateStatus:status_ threadId:threadId_];
    });
  }
}

- (void)doSendtodDidTransferData:(NSUInteger)totalBytes_
                           bytes:(NSUInteger)bytes_
                        progress:(float)progress_
                        threadId:(NSUInteger)threadId_
{
  if (self.mbTestMode) {
    SK_ASSERT ([NSThread isMainThread]);
    SK_ASSERT (dispatch_get_current_queue() == dispatch_get_main_queue());
    // We're in the main thread!
    // This means that we're in TEST MODE (where the start method is called directly from the main thread...)
    // This IGNORES the setting of mbAsyncFlag.
    [self.transferOperationDelegate todDidTransferData:totalBytes_ bytes:bytes_ progress:progress_ threadId:threadId_];
  } else if (mbAsyncFlag) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.transferOperationDelegate todDidTransferData:totalBytes_ bytes:bytes_ progress:progress_ threadId:threadId_];
    });
  } else {
    SK_ASSERT (dispatch_get_current_queue() != dispatch_get_main_queue());
    // If we use dispatch_sync, it can stop working / hang on fast networks!
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.transferOperationDelegate todDidTransferData:totalBytes_ bytes:bytes_ progress:progress_ threadId:threadId_];
    });
  }
}

- (void)doSendtodDidCompleteTransferOperation:(SKTimeIntervalMicroseconds)transferTime_
                                transferBytes:(NSUInteger)transferBytes_
                                   totalBytes:(NSUInteger)totalBytes_
                                     threadId:(NSUInteger)threadId_
{
  if (self.mbTestMode) {
    SK_ASSERT ([NSThread isMainThread]);
    SK_ASSERT (dispatch_get_current_queue() == dispatch_get_main_queue());
    // We're in the main thread!
    // This means that we're in TEST MODE (where the start method is called directly from the main thread...)
    // This IGNORES the setting of mbAsyncFlag.
    [self.transferOperationDelegate todDidCompleteTransferOperation:transferTime_
                                                      transferBytes:transferBytes_
                                                         totalBytes:totalBytes_
                                                           threadId:threadId_];
  } else if (mbAsyncFlag) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.transferOperationDelegate todDidCompleteTransferOperation:transferTime_
                                                        transferBytes:transferBytes_
                                                           totalBytes:totalBytes_
                                                             threadId:threadId_];
    });
  } else {
    SK_ASSERT (dispatch_get_current_queue() != dispatch_get_main_queue());
    // If we use dispatch_sync, it can stop working / hang on fast networks!
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.transferOperationDelegate todDidCompleteTransferOperation:transferTime_
                                                        transferBytes:transferBytes_
                                                           totalBytes:totalBytes_
                                                             threadId:threadId_];
    });
  }
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

#pragma mark - Connection lifecycle

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
 
  // Return nil to PREVENT the response from being cached!
  return nil;
}

// This is in NSURLConnectionDataDelegate ... which is the base delegate.
- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
  //SK_ASSERT(false);
#ifdef DEBUG
  NSLog(@"DEBUG %@ -  SKTransferOperation.m, %s, thread=%@", [self description], __FUNCTION__, [[NSThread currentThread] description]);
#endif // DEBUG
  
  if([self isCancelled])
  {
    [self cancelled];
  }
	else
  {
    [self done];
    [self doSendUpdateStatus:FINISHED threadId:threadId];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
  
#ifdef DEBUG
  NSLog(@"DEBUG %@ - didReceiveResponse :: status code: %d, length: %d", [self description], (int)httpResponse.statusCode, (int)httpResponse.expectedContentLength);
  NSLog(@"DEBUG %@ - HTTP/1.X %d\n%@", [self description], (int)[httpResponse statusCode], [[httpResponse allHeaderFields] description]);
#endif // DEBUG
  
  SK_ASSERT ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]);
  
  if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]])
  {
    if (httpResponse.statusCode == 200)
    {
      // Success!
      return;
    }
  }
  
  // Failed!
  SK_ASSERT(false);
  
  [self done];
  [self doSendUpdateStatus:FAILED threadId:threadId];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError*)error
{
#ifdef DEBUG
  NSLog(@"DEBUG: %s, Error Description : %@", __FUNCTION__, [error localizedDescription]);
  
  // Note that the following tests is locale specific - once we trap the error code in the debugger, we can use the code rather than the string in future.
  if([[error localizedDescription] isEqualToString:@"The request timed out."]) {
    NSLog(@"DEBUG: SKTransferOperation timed-out, error code = %d", (int)error.code);
    SK_ASSERT(false);
  }
#endif // DEBUG
  
  if([self isCancelled])
  {
    [self cancelled];
  }
  else
  {
    [self done];
  }
  
  testOK = NO;
  
  // Whether or not we've already cancelled - send a FAILED status update through.
  [self doSendUpdateStatus:FAILED threadId:threadId];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
#ifdef DEBUG
  //NSLog(@"DEBUG %@ - didReceiveData :: length: %d", [self description], (int)[data length]);
#endif // DEBUG
  
  if ([self isCancelled])
  {
    [self cancelled];
    return;
  }
  
  if (nil != data)
  {
    NSUInteger bytesLength = [data length];
    
    totalBytes = totalBytes + bytesLength;
    
    float progress = (float)[self getProgress];
    
    [self doSendtodDidTransferData:totalBytes bytes:bytesLength progress:progress threadId:threadId];
    
    if (![self isWarmupDone:(int)bytesLength])
    {
      if (!self.status == WARMING)
      {
        self.status = WARMING;
        [self doSendUpdateStatus:self.status threadId:threadId];
      }
    }
    else
    {
      if (![self isTransferDone:(int)bytesLength])
      {
        if (!self.status == TRANSFERRING)
        {
          self.status = TRANSFERRING;
          [self doSendUpdateStatus:self.status threadId:threadId];
        }
      }
      else
      {
        [self done];
        self.status = COMPLETE;
        [self doSendUpdateStatus:self.status threadId:threadId];
        [self doSendtodDidCompleteTransferOperation:transferTimeMicroseconds transferBytes:transferBytes totalBytes:totalBytes threadId:threadId];
      }
    }
  }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
  
#ifdef DEBUG
  NSLog(@"DEBUG %@ - didSendBodyData : %d, %d, %d", [self description], (int)bytesWritten, (int)totalBytesWritten, (int)totalBytesExpectedToWrite);
#endif // DEBUG
  
  if ([self isCancelled])
  {
    [self cancelled];
    return;
  }
  
  totalBytes = totalBytes + bytesWritten;

  // Must use the getProgress method - as that accounts for the WARMUP PERIOD that always comes first.
  //float progress = 100.0F * ((float) totalBytesWritten) / ((float)totalBytesExpectedToWrite);
  float progress = [self getProgress];
  
#ifdef DEBUG
  NSLog(@"DEBUG %@ - didSendBodyData, progress=%f, thread=%@", [self description], progress, [[NSThread currentThread] description]);
#endif // DEBUG
  
  [self doSendtodDidTransferData:totalBytes bytes:bytesWritten progress:progress threadId:threadId];
  
  if (![self isWarmupDone:(int)bytesWritten]){
    if (!self.status == WARMING) {
      self.status = WARMING;
      [self doSendUpdateStatus:self.status threadId:threadId];
    }
  }
  //if (totalBytesWritten >= totalBytesExpectedToWrite) {
  else if (![self isUploadTransferDone:(int)totalBytesWritten TotalBytesToTransfer:(int)totalBytesExpectedToWrite]) {
    if (!self.status == TRANSFERRING)
    {
      self.status = TRANSFERRING;
      [self doSendUpdateStatus:self.status threadId:threadId];
    }
  } else {
    [self done];
    self.status = COMPLETE;
    [self doSendUpdateStatus:self.status threadId:threadId];
    transferTimeMicroseconds = [self microTime:[[SKCore getToday] timeIntervalSince1970] - startTransfer];
    transferBytes = (int)totalBytesWritten;
    [self doSendtodDidCompleteTransferOperation:transferTimeMicroseconds transferBytes:transferBytes totalBytes:totalBytes threadId:threadId];
  }
}

-(void) setSKAutotest:(SKAutotest*)inSkAutotest {
  self.skAutotest = inSkAutotest;
}

@end