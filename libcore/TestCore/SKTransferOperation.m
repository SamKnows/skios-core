//
//  SKTransferOperation.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKTransferOperation.h"

/*
NOTES: See also https://svn.samknows.com/svn/tests/http_server/trunk/docs/protocol.txt ... where the protocol
for the new service is defined.
 
create socket
connect
 
 ** Start by trying to do this in JUST ONE THREAD! **
 
boolean bQuit = false
 
 Thread 1:
 write header :
    Example header as follows:
*/

//  POST /?CONTROL=1&UNITID=1&SESSIONID=281541010&NUM_CONNECTIONS=2&CONNECTION=1&AGGREGATE_WARMUP=0&RESULTS_INTERVAL_PERIOD=10&RESULT_NUM_INTERVALS=1&TEST_DATA_CAP=4294967295&TRANSFER_MAX_SIZE=4294967295&WARMUP_SAMPLE_TIME=5000&NUM_WARMUP_SAMPLES=1&MAX_WARMUP_SIZE=4294967295&MAX_WARMUP_SAMPLES=1&WARMUP_FAIL_ON_MAX=0&WARMUP_TOLERANCE=5 HTTP/1.1
//  Host: n1-the1.samknows.com:6500
//  Accept: */*
//  Content-Length: 4294967295
//  Content-Type: application/x-www-form-urlencoded
//  Expect: 100-continue

/*
 }
 
 The server expects a query string with a "CONTROL" field. It's value should be set to "1.0", which specifies the version of the protocol.
 
 - UNITID
 Mandatory.
 
 - SESSIONID
 Mandatory.
 
 - NUM_CONNECTIONS
 Mandatory.
 
 - CONNECTION
 Mandatory.
 
 - WARMUP_SAMPLE_TIME
 Mandatory for POST requests.
 
 - NUM_WARMUP_SAMPLES
 Mandatory for POST requests.
 
 - MAX_WARMUP_SAMPLES
 Mandatory for POST requests.
 
 - WARMUP_TOLERANCE
 Mandatory for POST requests.
 
 - RESULTS_INTERVAL_PERIOD
 Mandatory for POST requests.
 
 - RESULT_NUM_INTERVALS
 Mandatory for POST requests.
 
 - AGGREGATE_WARMUP
 Optional. Default: false.
 
 - TEST_DATA_CAP
 Optional. Default: no limit.
 
 - TRANSFER_MAX_SIZE
 Optional. Default: no limit.
 
 - MAX_WARMUP_SIZE
 Optional. Default: no limit.
 
 - WARMUP_FAIL_ON_MAX
 Optional. Default: false.
 
 - TRACE_INTERVAL
 Optional. Default: no tracing.
 
 - TCP_CONG
 Optional. Default: server system default.
 
   The values must be sent to the server (e.g TEST_DATA_CAP).
   Once the server reaches the limits it will send the result up to that point.
   This makes the limit "maximum bytes to *RECEIVE*".
   To keep it as "maximum bytes to *SENT*" you could keep your own counter
   and close the connection when you have sent a fixed amount of bytes...
 }
 while (bQuit == false) {
   write(socket, buffer...)
 }
 
 Thread 2:
 while (bQuit == false) {
   if (read (socket, intobuffer, timeout)) succeeds:
   {
     Extract upload speed results from server response, which will be in this format:
SAMKNOWS_HTTP_REPLY\n
VERSION: <major>.<minor>\n
RESULT: <OK|FAIL>\n
END_TIME: <end time>
SECTION: WARMUP\n
NUM_WARMUP: <num>\n
WARMUP_SESSION <seconds> <nanoseconds> <bytes>\n
WARMUP_SESSION <seconds> <nanoseconds> <bytes>\n
SECTION: MEASUR\n
NUM_MEASUR: <num>\n
MEASUR_SESSION <seconds> <nanoseconds> <bytes>\n
MEASUR_SESSION <seconds> <nanoseconds> <bytes>\n
 
     In terms of sample data etc., the server will give you something like this:
...
NUM_MEASUR: 2\n
MEASUR_SESSION 5 0 5000000\n
MEASUR_SESSION 10 0 15000000\n
...
     ... It's the client job to calculate that during the first five seconds the speed has been 5,000,000 / 5 = 1,000,000 bytes/sec; and during the next 10 seconds 15,000,000 / 10 = 1,500,000 bytes/sec. Meaning that the speed between seconds 5 and 10 has been (15,000,000 - 5,000,000) / (10 - 5) = 2,000,000 bytes/sec.
     ... send this "final upload speed result value from the server" to the application.
     bQuit = true;
   }
 }
*/

typedef void (^TMyCallback)(NSString*responseString, int responseCode);

@interface MyHttpReadThread : NSThread

@property (weak) SKTransferOperation *mpParentTransferOperation;
@property int mSocketFd;
@property (copy) TMyCallback mCallOnStopOrCancel;
@end

@implementation MyHttpReadThread

- (instancetype)initWithSKTransferOperation:(SKTransferOperation*)inSKTransferOperation SocketFd:(int)inSocketFd CallOnStopOrCancel:(TMyCallback)inCallOnStopOrCancel
{
    self = [super init];
    if (self) {
      self.mpParentTransferOperation = inSKTransferOperation;
      self.mSocketFd = inSocketFd;
      self.mCallOnStopOrCancel = inCallOnStopOrCancel;
    }
    return self;
}

-(void) cancel {
  @synchronized(self) {
    [super cancel];
  }
}

-(void) main {
 
  NSMutableString *response = [NSMutableString new];
  NSInteger responseCode = 0;
  
  for (;;) {
    if ([self isCancelled]) {
      break;
    }
    
    char buffer[4000];
  
    ssize_t bytes = 0;
    @synchronized(self) {
      int flags = MSG_DONTWAIT;
      //read(self.mSocketFd, buffer, sizeof(buffer));
      bytes = recv(self.mSocketFd, buffer, sizeof(buffer), flags);
    }
    
    if (bytes < 0) {
      // Is this an error?
      int theErrNo = errno;
      
      if ((theErrNo == EAGAIN) ||
          (theErrNo == EALREADY) ||
          (theErrNo == EINPROGRESS)
         )
      {
        // Not an error!
      } else {
#ifdef DEBUG
      NSLog(@"DEBUG: theErrNo2=%d", theErrNo);
#endif // DEBUG
        SK_ASSERT(false);
        break;
      }
    }
    
    if (bytes > 0) {
      buffer[bytes] = '\0';
      [response appendString:[NSString stringWithUTF8String:buffer]];
      
      NSArray *items = [response componentsSeparatedByString:@" "];
      
      if (items.count > 0) {
        if ([items[0] isEqualToString:@"HTTP/1.1"]) {
          if (items.count > 1) {
            responseCode = [items[1] integerValue];
            if ( (responseCode == 100) || // Continue
                 (responseCode == 200)    // OK
                )
            {
              // OK!
            } else {
              NSLog(@"Error in response, code %d", (int) responseCode);
              break;
            }
          }
        }
      }
      
      // Have we got everything we need yet?
      if ([response rangeOfString:@"SAMKNOWS_HTTP_REPLY"].length > 0) {
        // Got the header!
        if ([response rangeOfString:@"MEASUR_SESSION"].length > 0) {
          // Assume we have the lot!
          break;
        }
      }
    }
  }
  
  self.mCallOnStopOrCancel(response, (int)responseCode);
}

@end


#pragma mark - Interface

// Define the block size to force/use, in bytes.
//const int cDefaultBlockDataLength = 32768;
// Experimentation shows that using too small a value, leads to under-reporting.
// Experimentation shows that using too large a value (relative to the total amount of data to send)
// leads to over-reporting.
const int cDefaultBlockDataLength = 250000;
const unsigned char spBlockData[cDefaultBlockDataLength];

@interface SKTransferOperation ()
{
  BOOL warmupDone;
  NSPort* nsPort;
  BOOL testOK;
}


@property (weak) SKHttpTest *mpParentHttpTest;

@property u_int32_t mSESSIONID_ForServerUploadTest;

@property BOOL shouldKeepRunning;

@property BOOL mbAsyncFlag;

@property (nonatomic, assign) TransferStatus status;
@property NSDate *timeSetStatusToComplete;

@property BOOL mbTestMode;

@property (weak) SKAutotest* skAutotest;

- (BOOL)isWarmupDone:(int)bytes;

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


@synthesize mpParentHttpTest;
@synthesize shouldKeepRunning;
@synthesize mbTestMode;
@synthesize mbAsyncFlag;
@synthesize target;
@synthesize port;
@synthesize nThreads;
@synthesize file;
@synthesize isDownstream;
@synthesize threadId;

@synthesize skAutotest;

- (id)initWithTarget:(NSString*)_target
                port:(int)_port
                file:(NSString*)_file
        isDownstream:(BOOL)_isDownstream
            nThreads:(int)_nThreads
            threadId:(int)_threadId
            SESSIONID:(uint32_t)sessionId
       ParentHttpTest:(SKHttpTest*)inParentHttpTest // (id <SKTransferOperationDelegate>)_delegate
           asyncFlag:(BOOL)_asyncFlag
{
  self = [super init];
  
  if (self)
  {
    // Weak reference...
    mpParentHttpTest = inParentHttpTest;

    mbTestMode = NO;
    
    self.mSESSIONID_ForServerUploadTest = sessionId;
    
    target = [_target copy];
    port = _port;
    file = [_file copy];
    isDownstream = _isDownstream;
    nThreads = _nThreads;
    threadId = _threadId;
    mbAsyncFlag = _asyncFlag;
    
    self.status = INITIALIZING;
    
    [self setCompletionBlock:nil];
    
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
  return sSKCoreGetLocalisedString(@"to_UpStream");
}

+(NSString*) getDownStream {
  return sSKCoreGetLocalisedString(@"to_DownStream");
}

+(NSString*) getStatusInitializing {
  return sSKCoreGetLocalisedString(@"to_StatusInitializing");
}

+(NSString*) getStatusWarming {
  return sSKCoreGetLocalisedString(@"to_StatusWarming");
}

+(NSString*) getStatusTransferring {
  return sSKCoreGetLocalisedString(@"to_StatusTransferring");
}

+(NSString*) getStatusComplete {
  return sSKCoreGetLocalisedString(@"to_StatusComplete");
}

+(NSString*) getStatusCancelled {
  return sSKCoreGetLocalisedString(@"to_StatusCancelled");
}

+(NSString*) getStatusFailed {
  return sSKCoreGetLocalisedString(@"to_StatusFailed");
}

+(NSString*) getStatusFinished {
  return sSKCoreGetLocalisedString(@"to_StatusFinished");
}

+(NSString*) getStatusIdle {
  return sSKCoreGetLocalisedString(@"to_StatusIdle");
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

-(void) runUrlRequest {
  if (urlRequest == nil) {
    SK_ASSERT(false);
    return;
  }
  
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

-(void) startDownloadTest {
#ifdef DEBUG
  NSLog(@"DEBUG startDownloadTest: %@ - isDownstream", [self description]);
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
  
  if (urlRequest != nil) {
    [self runUrlRequest];
  }
}

// We SHARE the body data, to save memory footprint - otherwise, we can run out of memory on e.g. iPhone 4S
//static NSData *sbBodyData = nil;

-(void) startUploadTest {
#ifdef DEBUG
  NSLog(@"DEBUG startUploadTest: %@ - isUpstream", [self description]);
#endif // DEBUG
  
  struct hostent *server = gethostbyname([target UTF8String]);
  if (server == NULL) {
#ifdef _DEBUG
    NSLog(@"DEBUG ERROR, no such host\n");
#endif // _DEBUG
    [self connection:nil didFailWithError:nil];
    return;
  }
  
  //  [SKIPHelper hostIPAddress:target];
  //  struct hostent *host = gethostbyname([[self target] UTF8String]);
  //  struct in_addr **list = (struct in_addr **)host->h_addr_list;
  //  NSLog(@"ADDRESS: %@", [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding]);
  
  /* Create a socket point */
  __block int sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (sockfd < 0)
  {
#ifdef _DEBUG
    NSLog(@"DEBUG ERROR, failed to create socket\n");
#endif // _DEBUG
    [self connection:nil didFailWithError:nil];
    return;
  }
  
  struct sockaddr_in serv_addr;
  bzero((char *) &serv_addr, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  bcopy((char *)server->h_addr,
        (char *)&serv_addr.sin_addr.s_addr,
        server->h_length);
  serv_addr.sin_port = htons(port);
  
  //  int buff_size = 0;
  int sockerr = 0;
  //socklen_t socklen = 0;
  
  //  socklen = sizeof(buff_size);
  //  sockerr = getsockopt(sockfd,SOL_SOCKET,SO_SNDBUF,(char*)&buff_size,&socklen);
  //#ifdef _DEBUG
  //  NSLog(@"DEBUG: sock buf size was %d\n",buff_size);
  //#endif // _DEBUG
  
  //  buff_size = cBlockDataLength / 2;
  const int useBlockSize = cDefaultBlockDataLength;
  if (self.mpParentHttpTest.sendDataChunkSize > 0) {
    //useBlockSize = self.mpParentHttpTest.sendDataChunkSize;
  }
  
  //  buff_size = useBlockSize/2;
  //  socklen = sizeof(buff_size);
  //  sockerr = setsockopt(sockfd,SOL_SOCKET,SO_SNDBUF,(const void*)&buff_size,socklen);
  
  int timeoutSeconds = HTTP_UPLOAD_TIMEOUT;
  //socklen = sizeof(timeout);
  struct timeval tv;
  memset(&tv, 0, sizeof(tv));
  tv.tv_sec  = timeoutSeconds;
  tv.tv_usec = 0;
  sockerr = setsockopt(sockfd,SOL_SOCKET,SO_SNDTIMEO,(const void*)&tv,sizeof(tv));
  SK_ASSERT(sockerr == 0);
  
  // http://stackoverflow.com/questions/15486979/ios-multithreaded-sockets-under-libupnp-hanging-on-send
  int set = 1;
  sockerr = setsockopt(sockfd,SOL_SOCKET,SO_NOSIGPIPE,(const void*)&set,sizeof(set));
  SK_ASSERT(sockerr == 0);
  
  /* Now connect to the server */
  if (connect(sockfd,(const struct sockaddr *)&serv_addr,sizeof(serv_addr)) < 0)
  {
#ifdef _DEBUG
    NSLog(@"DEBUG ERROR, connecting to host\n");
#endif // _DEBUG
    SK_ASSERT(false); // This is quite rare: maybe the server is down, or the network is down (e.g. Airplane mode)
    
    // Must ALWAYS close the sockfd!
    close(sockfd);
    
    [self connection:nil didFailWithError:nil];
    
    return;
  }
  
  // Experimentation shows a *much* better settling-down on upload speed,
  // if we force a 32K send buffer size in bytes, rather than relying
  // on the default send buffer size.
  
  // When forcing value in bytes, you must actually divide by two!
  // https://code.google.com/p/android/issues/detail?id=13898
  //desideredSendBufferSize = 65536 / 2; // (2 ^ 16) / 2
 
//  @synchronized (self.class) {
//    NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:file];
//    NSFileManager *man = [NSFileManager defaultManager];
//    NSDictionary *attrs = [man attributesOfItemAtPath:file error: nil];
//    UInt32 fileSizeBytes = [attrs fileSize];
//    UInt32 dataSizeBytes = 0;
//    
//    //The file data is read only when the size is different than requested
//    if (sbBodyData != nil)
//    {
//      dataSizeBytes  = sbBodyData.length;
//    }
//    
//    if ( (sbBodyData == nil) ||
//        (dataSizeBytes != fileSizeBytes)
//        )
//    {
//      sbBodyData = [[NSData alloc] initWithContentsOfURL:fileUrl options:NSUTF8StringEncoding error:NULL];
//    }
//  }
  
//  int lengthBytes = (int)sbBodyData.length;
//  NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:file];
  NSFileManager *man = [NSFileManager defaultManager];
  NSDictionary *attrs = [man attributesOfItemAtPath:file error: nil];
  int lengthBytes = (int) [attrs fileSize];
  SK_ASSERT(lengthBytes > 0);
  
  // Use the correct parameters in the header... INCLUDING THE UNIT ID!
  // c.f. instructions at the top of this file.
  // The system will reject a header with "WARMUP_SAMPLE_TIME=0".
  // If that happens, set WARMUP_SAMPLE_TIME to UINT32_MAX instead of zero.
  long millisecondsWarmupSampleTime = (long)(warmupMaxTime/1000.0);
  if (millisecondsWarmupSampleTime == 0) {
    millisecondsWarmupSampleTime = UINT32_MAX;
  }
  
  NSMutableString *requestStr =
  //[NSMutableString stringWithFormat:@"POST /?CONTROL=1&UNITID=1&SESSIONID=281541010&NUM_CONNECTIONS=%d&CONNECTION=%d&AGGREGATE_WARMUP=0&RESULTS_INTERVAL_PERIOD=10&RESULT_NUM_INTERVALS=1&TEST_DATA_CAP=4294967295&TRANSFER_MAX_SIZE=%d&WARMUP_SAMPLE_TIME=5000&NUM_WARMUP_SAMPLES=1&MAX_WARMUP_SIZE=4294967295&MAX_WARMUP_SAMPLES=1&WARMUP_FAIL_ON_MAX=0&WARMUP_TOLERANCE=5 HTTP/1.1\r\n",
  [NSMutableString stringWithFormat:@"POST /?CONTROL=1&UNITID=1&SESSIONID=%u&NUM_CONNECTIONS=%d&CONNECTION=%d&AGGREGATE_WARMUP=0&RESULTS_INTERVAL_PERIOD=10&RESULT_NUM_INTERVALS=1&TEST_DATA_CAP=4294967295&TRANSFER_MAX_SIZE=%d&WARMUP_SAMPLE_TIME=%ld&NUM_WARMUP_SAMPLES=1&MAX_WARMUP_SIZE=%d&MAX_WARMUP_SAMPLES=1&WARMUP_FAIL_ON_MAX=0&WARMUP_TOLERANCE=5 HTTP/1.1\r\n",
   self.mSESSIONID_ForServerUploadTest,
   nThreads,         // NUM_CONNECTIONS=%d
   self.threadId,    // CONNECTION=%d
   transferMaxBytes, // TRANSFER_MAX_SIZE=%d
   (long)millisecondsWarmupSampleTime,
   warmupMaxBytes    // MAX_WARMUP_SIZE=%d
   ];
  [requestStr appendString:[NSString stringWithFormat:@"Host: %@\r\n", target]];
  [requestStr appendString:@"Accept: */*\r\n"];
  [requestStr appendString:@"Content-Length: 4294967295\r\n"];
  [requestStr appendString:@"Content-Type: application/x-www-form-urlencoded\r\n"];
  [requestStr appendString:@"Expect: 100-continue\r\n"];
  [requestStr appendString:@"\r\n"];
  
#ifdef DEBUG
  NSLog(@"DEBUG: requestStr=>>>\n%@\n<<<", requestStr);
#endif // DEBUG
  
  NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
  ssize_t bytesWritten = write(sockfd, [requestData bytes], requestData.length);
  if (bytesWritten < 0) {
#ifdef DEBUG
    int theErrNo = errno;
    NSLog(@"DEBUG: theErrNo3=%d", theErrNo);
#endif // DEBUG
    SK_ASSERT(false);
    [self connection:nil didFailWithError:nil];
    close(sockfd);
    return;
  }
  
  __block bool bGotValidResponseFromServer = false;
  __block bool bReadThreadIsRunning = true;
  __block double bitrateMbps1024Based = -1.0;
  
  // Create a read thread, that starts monitor for a response from the server.
  MyHttpReadThread *readThread = nil;
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getDoesAppSupportServerBasedUploadSpeedTesting] == NO) {
    // No, we are on an older app, that does not use server-based upload speed testing...
#ifdef DEBUG
    NSLog(@"DEBUG: app does not use server-based upload speed testing...");
#endif // DEBUG
    bGotValidResponseFromServer = false;
    bReadThreadIsRunning = false;
  } else {
    // Yes, we can use server-based upload speed testing!
#ifdef DEBUG
    NSLog(@"DEBUG: app uses server-based upload speed testing...!");
#endif // DEBUG
    
    // Create a read thread, that starts monitor for a response from the server.
    
    readThread = [[MyHttpReadThread alloc] initWithSKTransferOperation:self SocketFd:sockfd CallOnStopOrCancel:^(NSString*responseString, int responseCode){
      // HTTP response fully returned from upload() test - do something with it!
      // And finally, close the socket!
      
      @synchronized(self) {
        close(sockfd);
        sockfd = -1;
      }
      
      if ((responseCode != 100) && (responseCode != 200)) {
#ifdef DEBUG
        NSLog(@"DEBUG: reponseCode=%d", responseCode);
#endif // DEBUG
        SK_ASSERT(false);
        [self connection:nil didFailWithError:nil];
      } else {
#ifdef DEBUG
        NSLog(@"DEBUG: reponseCode=%d, responseString=>>>\n%@\n<<<", responseCode, responseString);
#endif // DEBUG
        
        // Example
        /*
         HTTP/1.1 100 Continue
         X-SamKnows: 1
         
         SAMKNOWS_HTTP_REPLY
         VERSION: 1.0
         RESULT: OK
         END_TIME: 1402570650
         SECTION: WARMUP
         NUM_WARMUP: 1
         WARMUP_SESSION: 5 1030000 3994048
         SECTION: MEASUR
         NUM_MEASUR: 1
         MEASUR_SESSION: 15 1666000 8293952
         
         That is 829352/15 = 552930.13333 bytes per second.
         */
        
        double finalBytesPerSecond = 0.0;
        //double finalBytesMilliseconds = 0.0;
        //double finalBytes = 0.0;
        
        NSArray *items = [responseString componentsSeparatedByString:@"\n"];
        if (items.count == 0) {
          SK_ASSERT(false);
        } else {
          for (NSString *item in items) {
            // Locate the MEASURE_SESSION items.
            if ([item rangeOfString:@"MEASUR_SESSION"].location == 0) {
              // Use the final calculated value!
              NSArray *items2 = [item componentsSeparatedByString:@" "];
              if (items2.count != 4) {
                SK_ASSERT(false);
              } else {
                double seconds = [items2[1] doubleValue];
                
                if (seconds <= 0) {
                  SK_ASSERT(false);
                } else {
                  bGotValidResponseFromServer = true;
                  
                  double bytesThusFar = [items2[3] doubleValue];
                  SK_ASSERT(bytesThusFar > 0);
                  
                  double bytesThisTime = bytesThusFar; // - bytesAtLastMeasurement;
                  SK_ASSERT(bytesThisTime > 0);
                  
                  double bytesPerSecond = bytesThisTime / seconds;
                  SK_ASSERT(bytesPerSecond > 0);
                  
                  finalBytesPerSecond = bytesPerSecond;
//                  finalBytesMilliseconds = seconds * 1000.0;
//                  finalBytes = bytesThusFar;
                }
              }
            }
          }
          
        }
        
        // We can introduce this assertion only when all servers support upload test measurement.
        //SK_ASSERT(bGotValidResponseFromServer == true);
        
        // bGotValidResponseFromServer = false; // debug hack for testing!
        
        if (bGotValidResponseFromServer == true)
        {
#ifdef DEBUG
          NSLog(@"DEBUG: BYTES CALCULATED FROM SERVER, PER SECOND = %g", finalBytesPerSecond);
#endif // DEBUG
          bitrateMbps1024Based = [SKGlobalMethods convertBytesPerSecondToMbps1024Based:finalBytesPerSecond];
#ifdef DEBUG
          NSLog(@"DEBUG: bitsPerSecond CALCULATED FROM SERVER = %@", [SKGlobalMethods bitrateMbps1024BasedToString:bitrateMbps1024Based]);
#endif // DEBUG
        }
        
        [self done];
        
        [self setStatusToComplete];
        
        [self doSendUpdateStatus:self.status threadId:threadId];
        
        // bGotValidResponseFromServer = false; // DEBUG ONLY TESTING!
      }
      bReadThreadIsRunning = false;
    }];
    [readThread start];
  }
  
  int totalBytesWritten = 0;
  int totalBytesExpectedToWrite = lengthBytes;
  
  // Keep running this loop, until the read thread tells us to stop!
  int numberOfCalls = 0;
  for (;;) {
    NSDate *start = [NSDate date];
    ssize_t bytesWritten = 0;
    @synchronized(self) {
      if (sockfd == -1) {
        NSLog(@"MPC, loop - break 1");
        break;
      }
      
      bytesWritten = write(sockfd, spBlockData, useBlockSize);
    }
    
    NSDate *end = [NSDate date];
    
    if (bytesWritten > 0) {
      
      if (self.status == WARMING) {
        [SKHttpTest sAddDebugTimingWithDescription:@"warmup" ThreadIndex:threadId Time:(NSTimeInterval)[end timeIntervalSinceDate:start] CurrentSpeed:0];
      } else if ((self.status == TRANSFERRING) || (self.status == COMPLETE)) {
        
        double bytesPerSecondRealTimeUpload = [mpParentHttpTest getBytesPerSecondRealTimeUpload];
        [SKHttpTest sAddDebugTimingWithDescription:@"testit" ThreadIndex:threadId Time:(NSTimeInterval)[end timeIntervalSinceDate:start] CurrentSpeed:bytesPerSecondRealTimeUpload];
      }
    }
    
    if (bytesWritten < 0) {
      bytesWritten = 0;
      
      int theErrNo = errno;
#ifdef DEBUG
      NSLog(@"DEBUG: theErrNo1=%d", theErrNo);
#endif // DEBUG
      if ( (theErrNo == EAGAIN) || (theErrNo == ENOSPC) )
      {
        // OK to continue!
      } else {
        // e.g. 32 - broken pipe!
#ifdef DEBUG
        if (theErrNo == EPIPE) {
          NSLog(@"DEBUG: ERROR: broken pipe!");
        }
#endif // DEBUG
        SK_ASSERT(false);
        // Kill the read thread - this will close the socket in the block callback.
        if (readThread != nil) {
          [readThread cancel];
          readThread = nil;
        }
        break;
      }
    }
    SK_ASSERT(bytesWritten <= useBlockSize);
    
    //[asyncSocket writeData:blockData withTimeout:1.0 tag:0];
    totalBytesWritten += bytesWritten; // blockDataLength;
    
    // This is a DUMMY call... 
    [self connection:nil didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    if (bytesWritten == 0) {
      // Allow other threads a chance!
      [NSThread sleepForTimeInterval:0.001];
    }
    
    // Stop EITHER if:
    // 1) the read thread tells us!
    if ([self isCancelled]) {
      NSLog(@"MPC, loop - break 4");
      break;
    }
    
    // 2) we at least 10 seconds AFTER the detection of "isTransferDone" i.e. COMPLETE - giving server long enough to respond...
    if (self.status == COMPLETE) {
      if (readThread == nil) {
        // Old style test - quit immedidately, as otherwise that skews the test results
        // to be much slower than the required value...
        break;
      }
      
      if (self.timeSetStatusToComplete != nil) {
        // TODO: This code (for upload-based servers in fall-back mode) can skew the upload speed results
        // in the fall-back case.... needs to be investigated in that case.
        if ([[NSDate date] timeIntervalSinceDate:self.timeSetStatusToComplete] >= 10.0) {
          NSLog(@"MPC - loop - break 5a");
          break;
        }
      }
    }
    
    // Give other threads a chance, otherwise we're locked a hard loop...
    [NSThread sleepForTimeInterval:0.001];
    
    numberOfCalls++;
  }
  
  // Kill the read thread - this will close the socket in the block callback.
  if (readThread != nil) {
    [readThread cancel];
    readThread = nil;
  }
  
  // Once the read thread completes, send our best known result.
  while (bReadThreadIsRunning == YES) {
    [NSThread sleepForTimeInterval:0.05];
  }
  
  if (bGotValidResponseFromServer == true) {
    // BEST RESULT is from the SERVER!
#ifdef DEBUG
    NSLog(@"DEBUG: Best result is from the SERVER, bitrateMbps1024Based=%d", (int)bitrateMbps1024Based);
#endif // DEBUG
    SK_ASSERT(bitrateMbps1024Based > 0);
    [self doSendtodDidCompleteTransferOperation:0 transferBytes:0 totalBytes:0 ForceThisBitsPerSecondFromServer:bitrateMbps1024Based threadId:threadId];
  } else {
    // Best result is from the built-in measurement.
    if (bitrateMbps1024Based == -1) {
      double bytesPerSecondRealTimeUpload = [mpParentHttpTest getBytesPerSecondRealTimeUpload];
      bitrateMbps1024Based = [SKGlobalMethods convertBytesPerSecondToMbps1024Based:bytesPerSecondRealTimeUpload];
    }
    SK_ASSERT(bitrateMbps1024Based >= 0);
#ifdef DEBUG
    NSLog(@"DEBUG: Best result is from the BUILT-IN MEASUREMENT, bitrateMbps1024Based=%d", (int)bitrateMbps1024Based);
#endif // DEBUG
    
    int theTransferBytes;
    NSUInteger theTotalBytes;
    SKTimeIntervalMicroseconds theTransferTimeMicroseconds;
    @synchronized(mpParentHttpTest) {
      theTransferBytes = mpParentHttpTest.mTransferBytes;
      theTotalBytes = mpParentHttpTest.mTotalBytes;
      theTransferTimeMicroseconds = mpParentHttpTest.transferMaxTimeMicroseconds;
    }
    
    [self doSendtodDidCompleteTransferOperation:theTransferTimeMicroseconds transferBytes:theTransferBytes totalBytes:theTotalBytes ForceThisBitsPerSecondFromServer:-1.0  threadId:threadId];
  }
}
        
///**
//* Called when a socket has completed writing the requested data. Not called if there is an error.
//**/
//- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
//  
//  totalBytesWritten += blockDataLength;
//  
//  // This is a DUMMY call...
//  [self connection:nil didSendBodyData:blockDataLength totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
//}

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
      [self startDownloadTest];
    }
    else
    {
      [self startUploadTest];
    }
  }
}

+ (SKTimeIntervalMicroseconds)sMicroTimeForSeconds:(NSTimeInterval)time
{
  return time * 1000000.0; // convert to microseconds
}

- (BOOL)isWarmupDone:(int)bytes
{
  if (warmupDone)
  {
    return YES;
  }
 
  @synchronized(mpParentHttpTest) {
    warmupDone = [mpParentHttpTest getIsWarmupDone:bytes];
    
    if (mpParentHttpTest.mbMoveToTransferring == YES) {
      SK_ASSERT (isDownstream == NO);
      // Upstream -  immediately move to transferring!
      self.status = TRANSFERRING;
    }
  }
  
  return warmupDone;
}

#pragma mark - Private methods

- (void)doSendUpdateStatus:(TransferStatus)status_ threadId:(NSUInteger)threadId_
{
  [self.mpParentHttpTest todUpdateStatus:status_ threadId:threadId_];
}

- (void)doSendtodDidTransferData:(NSUInteger)totalBytes_
                           bytes:(NSUInteger)bytes_
                        progress:(float)progress_
                        threadId:(NSUInteger)threadId_
{
    [self.mpParentHttpTest todDidTransferData:totalBytes_ bytes:bytes_ transferBytes:mpParentHttpTest.mTransferBytes progress:progress_ threadId:threadId_ operationTime:mpParentHttpTest.mTransferTimeMicroseconds];
}

- (void)doSendtodDidCompleteTransferOperation:(SKTimeIntervalMicroseconds)transferTime_
                                transferBytes:(NSUInteger)transferBytes_
                                   totalBytes:(NSUInteger)totalBytes_
       ForceThisBitsPerSecondFromServer:(double)bitrateMbps1024Based // If > 0, use this instead!
                                     threadId:(NSUInteger)threadId_
{
  [self.mpParentHttpTest todDidCompleteTransferOperation:transferTime_
                                                    transferBytes:transferBytes_
                                                       totalBytes:totalBytes_
                                 ForceThisBitsPerSecondFromServer:(double)bitrateMbps1024Based // If > 0, use this instead!
                                                         threadId:threadId_];
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
  if (error != nil) {
    SK_ASSERT(false);
    NSLog(@"DEBUG: %s, Error Description : %@", __FUNCTION__, [error localizedDescription]);
    
    // Note that the following tests is locale specific - once we trap the error code in the debugger, we can use the code rather than the string in future.
    if([[error localizedDescription] isEqualToString:@"The request timed out."]) {
      NSLog(@"DEBUG: SKTransferOperation timed-out, error code = %d", (int)error.code);
      SK_ASSERT(false);
    }
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
   
    @synchronized(mpParentHttpTest) {
      mpParentHttpTest.mTotalBytes = mpParentHttpTest.mTotalBytes + bytesLength;
      
      float progress = (float)[mpParentHttpTest getProgress];
      
      [self doSendtodDidTransferData:mpParentHttpTest.mTotalBytes bytes:bytesLength progress:progress threadId:threadId];
      
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
        if (![mpParentHttpTest isTransferDone:(int)bytesLength])
        {
          if (!(self.status == TRANSFERRING))
          {
            self.status = TRANSFERRING;
            [self doSendUpdateStatus:self.status threadId:threadId];
          }
        }
        else
        {
          [self done];
          
          [self setStatusToComplete];
          
          [self doSendUpdateStatus:self.status threadId:threadId];
          [self doSendtodDidCompleteTransferOperation:mpParentHttpTest.mTransferTimeMicroseconds transferBytes:mpParentHttpTest.mTransferBytes totalBytes:mpParentHttpTest.mTotalBytes ForceThisBitsPerSecondFromServer:-1.0 threadId:threadId];
        }
      }
    }
  }
}

-(void) setStatusToComplete  {
  if (self.status != COMPLETE) {
    self.status = COMPLETE;
    self.timeSetStatusToComplete = [NSDate date];
  }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
  
#ifdef DEBUG
  if (bytesWritten > 0) {
    NSLog(@"DEBUG %@ - didSendBodyData : %d, %d, %d; bps=%d", [self description], (int)bytesWritten, (int)totalBytesWritten, (int)totalBytesExpectedToWrite, [mpParentHttpTest getBytesPerSecond:totalBytesWritten]);
  }
#endif // DEBUG
  
  if ([self isCancelled])
  {
    [self cancelled];
    return;
  }
 
  @synchronized(mpParentHttpTest)
  {
    mpParentHttpTest.mTotalBytes = mpParentHttpTest.mTotalBytes + bytesWritten;
    
    // Must use the getProgress method - as that accounts for the WARMUP PERIOD that always comes first.
    //float progress = 100.0F * ((float) totalBytesWritten) / ((float)totalBytesExpectedToWrite);
    float progress = [mpParentHttpTest getProgress];
    
#ifdef DEBUG
    if (bytesWritten > 0) {
      NSLog(@"DEBUG %@ - didSendBodyData, progress=%f, thread=%@", [self description], progress, [[NSThread currentThread] description]);
    }
#endif // DEBUG
    
    if (bytesWritten > 0) {
      [self doSendtodDidTransferData:mpParentHttpTest.mTotalBytes bytes:bytesWritten progress:progress threadId:threadId];
    }
    
    if (![self isWarmupDone:(int)bytesWritten]){
      if (!self.status == WARMING) {
        self.status = WARMING;
        [self doSendUpdateStatus:self.status threadId:threadId];
      }
    }
    else if (![self.mpParentHttpTest isUploadTransferDoneBytesThisTime:(int)bytesWritten TotalBytes:(int)totalBytesWritten TotalBytesToTransfer:(int)totalBytesExpectedToWrite]) {
      if (!(self.status == TRANSFERRING))
      {
        self.status = TRANSFERRING;
        [self doSendUpdateStatus:self.status threadId:threadId];
      }
    } else {
      [self done];
      
      [self setStatusToComplete];
      
      [self doSendUpdateStatus:self.status threadId:threadId];
      mpParentHttpTest.mTransferTimeMicroseconds = [self.class sMicroTimeForSeconds:[[SKCore getToday] timeIntervalSince1970] - mpParentHttpTest.mStartTransfer];
      
      // The transfer bytes is the sum of ALL values, across ALL threads!
      mpParentHttpTest.mTransferBytes = mpParentHttpTest.mTransferBytes + (int)bytesWritten;
      
      if (isDownstream == NO ) {
        // Upload: do NOT send this, until we've seen if we have a better reponse from the server query!
        
        // But DO increase the number of bytes...
        [self.mpParentHttpTest
         todUploadTestCompletedNotAServeResponseYet:mpParentHttpTest.mTransferTimeMicroseconds
         transferBytes:mpParentHttpTest.mTransferBytes
         totalBytes:mpParentHttpTest.mTotalBytes];
      } else {
        [self doSendtodDidCompleteTransferOperation:mpParentHttpTest.mTransferTimeMicroseconds transferBytes:mpParentHttpTest.mTransferBytes totalBytes:mpParentHttpTest.mTotalBytes ForceThisBitsPerSecondFromServer:-1.0 threadId:threadId];
      }
    }
  }
}

-(void) setSKAutotest:(SKAutotest*)inSkAutotest {
  self.skAutotest = inSkAutotest;
}


@end