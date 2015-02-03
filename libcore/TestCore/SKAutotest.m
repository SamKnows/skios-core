//
//  SKAutotest.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKAutotest.h"
#import "../UICore2/Reusable/IPHelper/IPHelper.h"

@interface SKAutotest ()

@end

static BOOL sbTestIsRunning = NO;

@implementation SKAutotest

@synthesize conditionBreaches;

@synthesize isRunning;
@synthesize isCancelled;
@synthesize testId;

@synthesize btid;
@synthesize autoTests;

@synthesize latencyTest;
@synthesize targetTest;
@synthesize httpTest;

@synthesize runAllTests;
@synthesize validTest;

@synthesize autotestManagerDelegate;
@synthesize autotestObserverDelegate;

@synthesize udpClosestTargetTestSucceeded;

@synthesize jsonDictionary;
@synthesize cpuCondition;

-(id) initWithAutotestManagerDelegate:(id<SKAutotestManagerDelegate>)inAutotestManagerDelegate AndAutotestObserverDelegate:(id<SKAutotestObserverDelegate>)inAutotestObserverDelegate AndTestType:(TestType)inTestType  IsContinuousTesting:(BOOL)isContinuousTesting {
  
  self = [super init];
  
  if (self)
  {
    autotestManagerDelegate = inAutotestManagerDelegate;
    autotestObserverDelegate = inAutotestObserverDelegate;
    isRunning = NO;
    sbTestIsRunning = NO;
    isCancelled = NO;
    
    switch (inTestType) {
      case  ALL_TESTS:
      case  DOWNLOAD_TEST:
      case  UPLOAD_TEST:
      case  LATENCY_TEST:
      case  JITTER_TEST:
        break;
        
      default:
        SK_ASSERT(false);
        break;
    }
    runAllTests = (inTestType == ALL_TESTS);
    
    validTest = [self getValidTestType:inTestType];
    udpClosestTargetTestSucceeded = NO;
  }
  
  return self;
}

// 0 is special case - meaning RUN EVERYTHING!
-(void)runTheTestsWithBitmask:(int)bitMaskForRequestedTests_
{
  // START monitoring location data!
  sbTestIsRunning = YES;
  [[SKAAppDelegate getAppDelegate] startLocationMonitoring];
  
  self.btid = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    if (self.btid != UIBackgroundTaskInvalid) {
      [[UIApplication sharedApplication] endBackgroundTask:self.btid];
      self.btid = UIBackgroundTaskInvalid;
    }
  }];
  
  NSArray *testsTimes = [[self.autotestManagerDelegate amdGetSchedule] getTestsAndTimes];
  
  if (nil != testsTimes)
  {
    // This is a big hack - the autotest code assumes we're ONLY interested in the very first item!
    NSArray *tests_ = [testsTimes objectAtIndex:0];
    
    NSMutableArray *testTypes = [[NSMutableArray alloc] init];
    NSMutableArray *testDisplayNames = [[NSMutableArray alloc] init];
    NSMutableArray *nextTests = [[NSMutableArray alloc] init];
    
    for (int j=0; j<[tests_ count]; j++)
    {
      NSDictionary *test_ = [tests_ objectAtIndex:j];
      
      if ([self shouldTestTypeIfIsIncluded])
      {
        NSString *testType = [test_ objectForKey:@"type"];
        if ([self testIsIncluded:testType])
        {
          if (![testTypes containsObject:testType])
          {
            [testTypes addObject:testType];
            [nextTests addObject:test_];
          }
        }
      }
      else
      {
        NSString *testDisplayName = [test_ objectForKey:@"displayName"];
        if (![testDisplayNames containsObject:testDisplayName])
        {
          [testDisplayNames addObject:testDisplayName];
          [nextTests addObject:test_];
        }
      }
    }
    
    if (nil != nextTests)
    {
      if ([nextTests count] > 0)
      {
        self.autoTests = [NSMutableArray new];
        
        if (bitMaskForRequestedTests_ > 0) {
          // Only use tests in the bitmask!
          for (NSDictionary *test in nextTests)
          {
            NSString *testNameFromType = [test objectForKey:@"type"];
            //NSString *type = (([self translateTestNameToBitMask:((NSString *)[testFromAvailableList objectForKey:@"type"])] & bitMaskForRequestedTests_) != 0)
            int bitMaskForTest = [self translateTestNameToBitMask:testNameFromType];
            if ((bitMaskForRequestedTests_ & bitMaskForTest) != 0)
            {
              [self.autoTests addObject:test];
            }
          }
          
        } else {
          // Use all tests!
          [self.autoTests addObjectsFromArray:nextTests];
        }
      }
      
      self.isRunning = YES;
      
      [self runNextTest:-1];
    }
  } else {
    [self markTestAsStopped];
  }
}

- (void)runTheTests {
  
  // 0 is special case - meaning RUN EVERYTHING!
  [self runTheTestsWithBitmask:0];
}

-(int)translateTestNameToBitMask:(NSString*)testName_
{
  if ([testName_ isEqualToString:@"closestTarget"]) {
    return CTTBM_CLOSESTTARGET;
  }
  
  if ([testName_ isEqualToString:@"downstreamthroughput"]) {
    return CTTBM_DOWNLOAD;
  }
  
  if ([testName_ isEqualToString:@"upstreamthroughput"]) {
    return CTTBM_UPLOAD;
  }
  
  if ([testName_ isEqualToString:@"latency"]) {
    return CTTBM_LATENCYLOSSJITTER;
  }
  
  //TODO: Loss, jitter ?
  SK_ASSERT(false);
  
  return 0;
}

-(void) dealloc {
  
  [self stopTheTests];
}



- (void)ctdDidStartTargetTesting
{
    if ([self.autotestObserverDelegate respondsToSelector:@selector(aodDidStartTargetTesting)])
        [self.autotestObserverDelegate aodDidStartTargetTesting];
}

- (void)ctdDidFinishAnotherTarget:(int)targetId withLatency:(double)latency withBest:(int)bestId
{
    if ([self.autotestObserverDelegate respondsToSelector:@selector(aodDidFinishAnotherTarget:withLatency:withBest:)])
    [self.autotestObserverDelegate aodDidFinishAnotherTarget:targetId withLatency:latency withBest:bestId];
}

- (void)ctdTestDidFail
{
  NSLog(@"Closest Target Test Did Fail");
  
  [self.autotestObserverDelegate aodClosestTargetTestDidFail];
}


- (void)ctdDidCompleteClosestTargetTest:(NSString*)target latency:(double)latency
{
  self.selectedTarget = target; //###HG
    
  NSLog(@"Closest Target Test Did Complete : %@, Latency : %f", target, latency);
    
  [self.autotestManagerDelegate amdSetClosestTarget:target];
  [self.autotestObserverDelegate aodClosestTargetTestDidSucceed:target];
  [self runNextTest:self.targetTest.testIndex];
}

- (void)ctdDidSendPacket:(NSUInteger)bytes
{
  [self.autotestManagerDelegate amdDoUpdateDataUsage:(int)bytes];
}

- (void)checkTestId
{
  if (self.testId == nil)
  {
    // Only set this once, after at least one test has completed successfully
    // A successful closest target test alone does not constitute a successful batch test..
    // .. we dont want to store a result on the map just for a closest target result.
    
    //SK_ASSERT([self.autotestManagerDelegate respondsToSelector@selector(getAutotestDelegate)]);
    
    double latitude = [autotestManagerDelegate amdGetLatitude];
    NSLog(@"latitude=%g", latitude);
    double longitude = [autotestManagerDelegate amdGetLongitude];
    NSLog(@"longitude=%g", latitude);
    SKScheduler *schedule = [autotestManagerDelegate amdGetSchedule];
    NSLog(@"schedule=%@", schedule);
    NSString *closestTargetName = [autotestManagerDelegate amdGetClosestTarget];
    NSLog(@"closestTargetName=%@", closestTargetName);
    NSString *targetName = [schedule getClosestTargetName:closestTargetName];
    NSLog(@"targetName=%@", targetName);
    
    self.testId = [SKDatabase
                   storeBatchTestMapData:latitude
                   longitude:longitude
                   target:targetName];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [[NSNotificationCenter defaultCenter] postNotificationName:kSKAAutoTest_GeneratedTestId object:self.testId];
    });
  }
}

//### HG - Modified to simplify
- (void)runClosestTargetTest:(SKTestConfig*)config testIndex:(int)testIndex;
{
    if (config == nil) return; //### Is it really necessary. Can it be NILL ?
    
    if (![self.autotestManagerDelegate amdGetIsConnected]) //These are always FALSE: ([self shouldCallCheckConditions] && ![config checkTestConditions])
    {
        // We must always try to call runNextTest; otherwise, the tests will never complete!
        [self runNextTest:testIndex];
        return;
    }
    
    if (nil != config)
    {
        NSArray *targets = [config getTargets];
        
        if (targets != nil)
        {
            if (self.targetTest == nil)
            {
                int numDatagramsFromSchedule = [[config paramObjectForKey:@"numberOfPackets"] intValue];
                [self createClosestTargetTest:targets NumDatagrams:numDatagramsFromSchedule];
            }
            else
            {
                [self.targetTest setTargets:targets];
                self.targetTest.closestTargetDelegate = self;
            }
            
            [self.targetTest setTestIndex:testIndex];
            [self.targetTest setNetworkType:[config getNetworkType]];
            [self.targetTest setDisplayName:[config displayName]];
            
            if ([self.targetTest isReady])
            {
                if (!self.isCancelled)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.autotestObserverDelegate aodClosestTargetTestDidStart];
                    });
                    [self.targetTest startTest];
                }
            }
        }
    }
}

- (void)runTransferTest:(SKTestConfig*)config testIndex:(int)testIndex isDownload:(BOOL)isDownload
{
  if (![self.autotestManagerDelegate amdGetIsConnected])
  {
    // We must always try to call runNextTest; otherwise, the tests will never complete!
    SK_ASSERT(false);
    [self runNextTest:testIndex];
    return;
  }
  
  if (config == nil)
  {
    SK_ASSERT(false);
    [self runNextTest:testIndex];
  }
  else
  {
    if ([self shouldCallCheckConditions])
    {
      if (![config checkTestConditions])
      {
        // Condition test failed.
#ifdef DEBUG
        NSLog(@"DEBUG warning - condition test failed=%@", config.type);
#endif // DEBUG
        [self runNextTest:testIndex];
        return;
      }
    }
    
    // Set the file, different for the upload and download case
    NSString *file = nil;
    if (isDownload)
    {
      file = [config paramObjectForKey:@"file"];
    }
    else
    {
      [self.autotestManagerDelegate amdDoCreateUploadFile];
      file = [self.autotestManagerDelegate amdGetFileUploadPath];
    }
    
    // Set the target, currently the tests are configured for the closest target, but this could change
    NSString *tmpTarget = [config paramObjectForKey:@"target"];
    NSString *target = [tmpTarget isEqualToString:@"$closest"] ? [self.autotestManagerDelegate amdGetClosestTarget] : tmpTarget;
    
    if (target == nil)
    {
      SK_ASSERT(false);
      [self runNextTest:self.httpTest.testIndex];
    }
    else
    {
      if (self.httpTest == nil)
      {
#ifdef DEBUG
        NSLog(@"DEBUG: ********* creating httpTransfer test, isDownload=%d", (int)isDownload);
#endif // DEBUG
        [self createHttpTest:config isDownload:isDownload file:file target:target];
        int sendDataChunkSize = [[config paramObjectForKey:@"sendDataChunk"] intValue];
        [self.httpTest setSendDataChunkSize:sendDataChunkSize];
        [self.httpTest setTestIndex:testIndex];
        [self.httpTest setNetworkType:[config getNetworkType]];
        [self.httpTest setDisplayName:[config displayName]];
        
        if ([self.httpTest isReady])
        {
#ifdef DEBUG
          NSLog(@"DEBUG: ********* test is ready");
#endif // DEBUG
          if (self.isCancelled)
          {
            SK_ASSERT(false);
          }
          else
          {
            SK_ASSERT(self.autotestObserverDelegate != nil);
            
            if (![NSThread isMainThread])
            {
              dispatch_async(dispatch_get_main_queue(), ^{
#ifdef DEBUG
                NSLog(@"DEBUG: ********* test is starting via delegate... routing async to main thread");
#endif // DEBUG
                [self.autotestObserverDelegate aodTransferTestDidStart:self.httpTest.isDownstream];
              });
            }
            else
            {
#ifdef DEBUG
              NSLog(@"DEBUG: ********* test is starting via delegate... on this main thread");
#endif // DEBUG
              [self.autotestObserverDelegate aodTransferTestDidStart:self.httpTest.isDownstream];
            }
            
#ifdef DEBUG
            NSLog(@"DEBUG: ********* test is starting!");
#endif // DEBUG
            [self.httpTest startTest];
          }
        }
        else
        {
          SK_ASSERT(false);
          //NSLog(@"httpTest :: runNextTest");
          [self runNextTest:self.httpTest.testIndex];
        }
      }
      else
      {
#ifdef DEBUG
        NSLog(@"DEBUG: ********* test already exists...");
#endif // DEBUG
        if ([self.httpTest isRunning])
        {
#ifdef DEBUG
          NSLog(@"DEBUG: ********* stopping the test that already exists...");
#endif // DEBUG
          [self.httpTest stopTest];
        }
        
#ifdef DEBUG
        NSLog(@"DEBUG: ********* preparing the test...");
#endif // DEBUG
        [self.httpTest prepareForTest];
        [self.httpTest setTarget:target];
        [self.httpTest setPort:[[config paramObjectForKey:@"port"] intValue]];
        [self.httpTest setFile:file];
        [self.httpTest setIsDownstream:isDownload];
        int sendDataChunkSize = [[config paramObjectForKey:@"sendDataChunk"] intValue];
        [self.httpTest setSendDataChunkSize:sendDataChunkSize];
        [self.httpTest setWarmupMaxTime:[[config paramObjectForKey:@"warmupmaxtime"] doubleValue]];
        [self.httpTest setWarmupMaxBytes:[[config paramObjectForKey:@"warmupmaxbytes"] doubleValue]];
        [self.httpTest setTransferMaxTimeMicroseconds:[[config paramObjectForKey:@"transfermaxtime"] doubleValue]];
        [self.httpTest setTransferMaxBytes:[[config paramObjectForKey:@"transfermaxbytes"] doubleValue]];
        [self.httpTest setNThreads:[[config paramObjectForKey:@"numberofthreads"] intValue]];
        self.httpTest.httpRequestDelegate = self;
        [self.httpTest setTestIndex:testIndex];
        [self.httpTest setNetworkType:[config getNetworkType]];
        [self.httpTest setDisplayName:[config displayName]];
        
        if ([self.httpTest isReady])
        {
#ifdef DEBUG
          NSLog(@"DEBUG: ********* test is ready...");
#endif // DEBUG
          if (!self.isCancelled)
          {
            if (![NSThread isMainThread])
            {
              dispatch_async(dispatch_get_main_queue(), ^{
#ifdef DEBUG
                NSLog(@"DEBUG: ********* test is ready on async main thread...");
#endif // DEBUG
                [self.autotestObserverDelegate aodTransferTestDidStart:self.httpTest.isDownstream];
              });
            }
            else
            {
#ifdef DEBUG
              NSLog(@"DEBUG: ********* test is ready on main thread...");
#endif // DEBUG
              [self.autotestObserverDelegate aodTransferTestDidStart:self.httpTest.isDownstream];
            }
            
#ifdef DEBUG
            NSLog(@"DEBUG: ********* test is starting!");
#endif // DEBUG
            [self.httpTest startTest];
          }
          else
          {
            SK_ASSERT(false);
          }
        }
        else
        {
          SK_ASSERT(false);
          [self runNextTest:self.httpTest.testIndex];
        }
      }
    }
  }
}

// This must only be called by the child classes's htdDidCompleteHttpTest:... method.
- (void)htdDidCompleteHttpTest
{
  SK_ASSERT(self.httpTest != nil);
  if (nil != self.httpTest)
  {
    [self runNextTest:self.httpTest.testIndex];
  }
}

#pragma mark SKHttpTestDelegate
- (void)htdDidTransferData:(NSUInteger)totalBytes bytes:(NSUInteger)bytes progress:(float)progress threadId:(NSUInteger)threadId
{
  [self.autotestManagerDelegate amdDoUpdateDataUsage:(int)bytes];
}

//###HG
- (void)htdDidUpdateTotalProgress:(float)progress currentBitrate:(double)currentBitrate
{
    if ([self.autotestObserverDelegate respondsToSelector:@selector(aodTransferTestDidUpdateProgress:isDownstream:bitrate1024Based:)])
        [self.autotestObserverDelegate aodTransferTestDidUpdateProgress:progress isDownstream:self.httpTest.isDownstream bitrate1024Based:currentBitrate];
    else
        [self.autotestObserverDelegate aodTransferTestDidUpdateProgress:progress isDownstream:self.httpTest.isDownstream];
}

#pragma mark - Latency Test Method

- (void)runLatencyTest:(SKTestConfig*)config testIndex:(int)testIndex
{
  if (![self.autotestManagerDelegate amdGetIsConnected])
  {
    [self runNextTest:testIndex];
    return;
  }
  
  if (nil != config)
  {
    if ([self shouldCallCheckConditions])
    {
      if (![config checkTestConditions])
      {
        [self runNextTest:testIndex];
        return;
      }
    }

    NSString *target = [self.autotestManagerDelegate amdGetClosestTarget];

    if (nil != target)
    {
      if (nil == self.latencyTest)
      {
        [self createLatencyTest:config target:target];
        
        [self.latencyTest setTestIndex:testIndex];
        [self.latencyTest setNetworkType:[config getNetworkType]];
        [self.latencyTest setDisplayName:[config displayName]];
        
        if ([self.latencyTest isReady])
        {
          if (!self.isCancelled)
          {
              //###HG
              if ([self.autotestObserverDelegate respondsToSelector:@selector(aodLatencyTestDidStart)]) [self.autotestObserverDelegate aodLatencyTestDidStart];
              [self.latencyTest startTest];
          }
        }
        else
        {
          [self runNextTest:self.latencyTest.testIndex];
        }
      }
      else
      {
        if ([self.latencyTest isRunning])
        {
          [self.latencyTest stopTest];
        }
        
        [self.latencyTest setTarget:target];
        [self.latencyTest setPort:[[config paramObjectForKey:@"port"] intValue]];
        [self.latencyTest setNumDatagrams:[[config paramObjectForKey:@"numberOfPackets"] intValue]];
        [self.latencyTest setInterPacketTime:[[config paramObjectForKey:@"interPacketTime"] doubleValue]];
        [self.latencyTest setDelayTimeout:[[config paramObjectForKey:@"delayTimeout"] doubleValue]];
        [self.latencyTest setPercentile:[[config paramObjectForKey:@"percentile"] intValue]];
        [self.latencyTest setMaxExecutionTime:[[config paramObjectForKey:@"maxTime"] doubleValue]];
        self.latencyTest.latencyTestDelegate = self;
        [self.latencyTest setTestIndex:testIndex];
        [self.latencyTest setNetworkType:[config getNetworkType]];
        [self.latencyTest setDisplayName:[config displayName]];
        
        if ([self.latencyTest isReady])
        {
          if (!self.isCancelled)
          {
              //###HG
              if ([self.autotestObserverDelegate respondsToSelector:@selector(aodLatencyTestDidStart)]) [self.autotestObserverDelegate aodLatencyTestDidStart];
              [self.latencyTest startTest];
          }
        }
        else
        {
          [self runNextTest:self.latencyTest.testIndex];
        }
      }
    }
    else
    {
      [self runNextTest:self.latencyTest.testIndex];
    }
  }
  else
  {
    [self runNextTest:testIndex];
  }
}

- (void)ltdTestDidFail
{
  NSLog(@"SKAutotest::ltdTestDidFail");
  
  [self.autotestObserverDelegate aodLatencyTestDidFail:@""];
  
  [self runNextTest:self.latencyTest.testIndex];
}

- (void)ltdTestWasCancelled
{
  NSLog(@"SKAutotest::ltdTestWasCancelled");
}

//###HG
- (void)ltdUpdateProgress:(float)progress latency:(float)latency_
{
    if ([self.autotestObserverDelegate respondsToSelector:@selector(aodLatencyTestUpdateProgress:latency:)])
        [self.autotestObserverDelegate aodLatencyTestUpdateProgress:progress latency:latency_];
    else
        [self.autotestObserverDelegate aodLatencyTestUpdateProgress:progress];
}

- (void)ltdUpdateStatus:(LatencyStatus)status
{
  [self.autotestObserverDelegate aodLatencyTestUpdateStatus:status];
}

- (void)ltdTestDidSendPacket:(NSUInteger)bytes
{
  [self.autotestManagerDelegate amdDoUpdateDataUsage:(int)bytes];
}

-(void)markTestAsStopped {
  self.isRunning = NO;
  sbTestIsRunning = NO;
  // STOP monitoring location data!
  [[SKAAppDelegate getAppDelegate] stopLocationMonitoring];
}

- (void)stopTheTests
{
  NSLog(@"STOP AUTO TEST");

  [self markTestAsStopped];
  
  self.isCancelled = YES;
  
  if (self.httpTest)
  {
    [self.httpTest stopTest];
    self.httpTest = nil;
  }
  
  if (self.targetTest)
  {
    [self.targetTest stopTest];
    self.targetTest = nil;
  }
  
  if (self.latencyTest)
  {
    [self.latencyTest stopTest];
    self.latencyTest = nil;
  }
}


- (NSString*)getValidTestType:(TestType)testType
{
  if (testType == ALL_TESTS)
  {
    return @"all";
  }
  else if (testType == DOWNLOAD_TEST)
  {
    return @"downstreamthroughput";
  }
  else if(testType == UPLOAD_TEST)
  {
    return @"upstreamthroughput";
  }
  else if (testType == LATENCY_TEST)
  {
    return @"latency";
  }
  else
  {
    SK_ASSERT(false);
    return @"latency";
  }
}

+(BOOL) sGetIsTestRunning {
  return sbTestIsRunning;
}

//API API API **********************************************************
-(id) initAndRunWithAutotestManagerDelegateWithBitmask:(id<SKAutotestManagerDelegate>)inAutotestManagerDelegate autotestObserverDelegate:(id<SKAutotestObserverDelegate>)inAutotestObserverDelegate TestsToExecuteBitmask:(int)tests2execute isContinuousTesting:(BOOL)isContinuousTesting
{
  if (self = [self initWithAutotestManagerDelegate:inAutotestManagerDelegate AndAutotestObserverDelegate:inAutotestObserverDelegate AndTestType:ALL_TESTS IsContinuousTesting:isContinuousTesting])
  {
    [self doInit:isContinuousTesting];
    
    tests2execute |= CTTBM_CLOSESTTARGET;
    
    [self startOfTestRunThrottleQuery];
    [self runTheTestsWithBitmask:tests2execute];
  }
  
  return self;
}

-(id) initAndRunWithAutotestManagerDelegate:(id<SKAutotestManagerDelegate>)inAutotestManagerDelegate AndAutotestObserverDelegate:(id<SKAutotestObserverDelegate>)inAutotestObserverDelegate AndTestType:(TestType)testType  IsContinuousTesting:(BOOL)isContinuousTesting
{
  if (self = [self initWithAutotestManagerDelegate:inAutotestManagerDelegate AndAutotestObserverDelegate:inAutotestObserverDelegate AndTestType:testType IsContinuousTesting:isContinuousTesting])
  {
    [self doInit:isContinuousTesting];
    
    [self startOfTestRunThrottleQuery];
    [self runTheTests];
  }
  
  return self;
}

-(void) doInit:(BOOL)isContinuousTesting {
  
  self.mbIsContinuousTesting = isContinuousTesting;
  self.accumulatedNetworkTypeLocationMetrics = [NSMutableArray new];
  jsonDictionary = [[NSMutableDictionary alloc] init];
  self.requestedTests = [NSMutableArray new];
  [self writeJSON_TestHeader:[self.autotestManagerDelegate amdGetSchedule]];
  self.testId = nil;
  
}

-(void)startOfTestRunThrottleQuery {
  if ([[SKAAppDelegate getAppDelegate] isThrottleQuerySupported] == false)
  {
    // No throttle query supported...
    
    self.mpThrottledQueryResult = nil;
    self.mpThrottleResponse = @"no throttling";
  }
  else
  {
    // Throttle query supported!
    // When the test starts - we must fire-off a throttled web service query, where appropriate for
    // the current device / network.
    self.mpThrottleResponse = @"timeout";
    
    self.mpThrottledQueryResult = [[SKOperators getInstance] fireThrottledWebServiceQueryWithCallback:^(NSError *error, NSInteger responseCode, NSMutableData *responseData, NSString *responseDataAsString, NSDictionary *responseHeaders) {
      SK_ASSERT(self.mpThrottledQueryResult.returnCode == SKOperators_Return_FiredThrottleQueryAwaitCallback);
      
      if (error == nil) {
        NSLog(@"DEBUG - responseCode=%d, responseDataAsString=(%@)", (int)responseCode, responseDataAsString);
        
        if (responseCode == 200) {
          if ( [responseDataAsString isEqualToString:@"YES"]) {
            self.mpThrottleResponse = @"throttled";
          } else if ( [responseDataAsString isEqualToString:@"NO"]) {
            self.mpThrottleResponse = @"non-throttled";
          } else {
            SK_ASSERT(false);
            self.mpThrottleResponse = @"error";
          }
        } else {
          SK_ASSERT(false);
          
          // http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
          if (    (responseCode == 408) // Request Timeout
              || (responseCode == 504) // Gateway Timeout
              || (responseCode == 524) // Timeout
              || (responseCode == 598) // timeout
              || (responseCode == 599) // timeout
              )
          {
            self.mpThrottleResponse = @"timeout";
          } else {
            self.mpThrottleResponse = @"error";
          }
        }
      } else {
        NSLog(@"DEBUG - error running throttled query response...");
        //SK_ASSERT(false);
        self.mpThrottleResponse = @"error";
      }
    }
                                   ];
    
    if (self.mpThrottledQueryResult.returnCode == SKOperators_Return_NoThrottleQuery) {
      self.mpThrottleResponse = @"no throttling";
    }
  }
}

-(SKHttpTest *)getSKAHttpTest {
  return (SKHttpTest*)self.httpTest;
}

-(void)createClosestTargetTest:(NSArray *)targets NumDatagrams:(int)numDatagrams {
  self.targetTest = [[SKClosestTargetTest alloc] initWithTargets:targets ClosestTargetDelegate:self NumDatagrams:numDatagrams];
  [self.targetTest setSKAutotest:self];
}

- (BOOL)shouldCallCheckConditions
{
  return YES;
}

- (void)createLatencyTest:(SKTestConfig *)config target:(NSString *)target
{
  self.latencyTest = [[SKLatencyTest alloc]
                      initWithTarget:target
                      port:[[config paramObjectForKey:@"port"] intValue]
                      numDatagrams:[[config paramObjectForKey:@"numberOfPackets"] intValue]
                      interPacketTime:[[config paramObjectForKey:@"interPacketTime"] doubleValue]
                      delayTimeout:[[config paramObjectForKey:@"delayTimeout"] doubleValue]
                      percentile:[[config paramObjectForKey:@"percentile"] intValue]
                      maxExecutionTime:[[config paramObjectForKey:@"maxTime"] doubleValue]
                      LatencyTestDelegate:self];
  [self.latencyTest setSKAutotest:self];
}

- (void)writeJSON_TestHeader:(SKScheduler*)scheduler
{
  NSString *enterpriseId = [[SKAAppDelegate getAppDelegate] getEnterpriseId];
  [jsonDictionary setObject:enterpriseId forKey:@"enterprise_id"];
  
  [jsonDictionary setObject:[SKGlobalMethods getSimOperatorCodeMCCAndMNC]
                     forKey:@"sim_operator_code"];
#ifdef DEBUG
  NSLog(@"DEBUG: sim_operator_code=%@", [SKGlobalMethods getSimOperatorCodeMCCAndMNC]);
#endif // DEBUG
  
  if (self.mbIsContinuousTesting) {
    [jsonDictionary setObject:@"continuous_testing" forKey:@"submission_type"];
  } else {
    [jsonDictionary setObject:@"manual_test" forKey:@"submission_type"];
  }
  
  NSString *appVersionName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  [jsonDictionary setObject:appVersionName forKey:@"app_version_name"];
#ifdef DEBUG
  NSLog(@"DEBUG: app_version_name=%@", appVersionName);
#endif // DEBUG
  
  NSString *appVersionCode = [appVersionName stringByReplacingOccurrencesOfString:@"." withString:@""];
  [jsonDictionary setObject:appVersionCode forKey:@"app_version_code"];
#ifdef DEBUG
  NSLog(@"DEBUG: app_version_code=%@", appVersionCode);
#endif // DEBUG
  
  SK_ASSERT(scheduler != nil);
  SK_ASSERT(scheduler.scheduleVersion != nil);
  
  if (scheduler.scheduleVersion != nil) {
    [jsonDictionary setObject:scheduler.scheduleVersion
                       forKey:@"schedule_config_version"];
  } else {
    SK_ASSERT(false);
  }
  
  [jsonDictionary setObject:[SKGlobalMethods getTimeStamp]
                     forKey:@"timestamp"];
  
  [jsonDictionary setObject:[NSDate sGetDateAsIso8601String:[SKCore getToday]] forKey:@"datetime"];
  
  NSTimeZone *tz = [NSTimeZone systemTimeZone];
  NSTimeInterval ti = [tz secondsFromGMT];
  
  ti = ti / 3600; // convert to hours
  
  NSString *result = nil;
  
  if ([self isWholeNumber:ti])
  {
    result = [NSString stringWithFormat:@"%d", (int)ti];
  }
  else
  {
    result = [NSString stringWithFormat:@"%@", [SKGlobalMethods format2DecimalPlaces:ti]];
  }
  
  NSString *prefix = (ti <= 0) ? @"" : @"+";
  NSString *timeZone = [NSString stringWithFormat:@"%@%@", prefix, result];
  
  [jsonDictionary setObject:timeZone forKey:@"timezone"];
  
#ifdef DEBUG
  NSLog(@"DEBUG: jsonDictionary=%@", [jsonDictionary description]);
#endif // DEBUG
}

- (BOOL)isWholeNumber:(double)number
{
  double integral;
  double fractional = modf(number, &integral);
  
  return fractional == 0.00 ? YES : NO;
}

-(void) rememberThatTestWasRequested:(NSString*)type {
  
  for (NSString *theTest in self.requestedTests)
  {
    if ([theTest isEqualToString:type]) {
      // Already exists - nothing to do!
      return;
    }
  }
  
  [self.requestedTests addObject:type];
}

- (void)writeJSON_TestResultsDictionary:(NSDictionary*)results
{
  // if results is nil, that historically would result in an assertion when adding to tests
  // at the end of the function. This was seen historically, and should be detected at runtime.
  // Note that the code now checks that results is not nil before trying to add it to the
  // tests array.
  SK_ASSERT(results != nil);
  
  NSMutableArray *tests;
  
  if ([jsonDictionary objectForKey:@"tests"] == nil)
  {
    // Create a new, empty array of tests.
    tests = [NSMutableArray array];
  }
  else {
    // Use the already part-populated array of tests.
    tests = [jsonDictionary objectForKey:@"tests"];
  }
  
  // Generate a pair of METRICS to capture "location" and "network_type"...
  
  // These are added to the passive METRICS
  NSMutableDictionary *locationDictionary = [self createLocationMetric];
  if (results[@"timestamp"] != nil) {
    locationDictionary[@"timestamp"] = results[@"timestamp"];
  }
  if (results[@"datetime"] != nil) {
    locationDictionary[@"datetime"] = results[@"datetime"];
  }
  
  [self.accumulatedNetworkTypeLocationMetrics  addObject:locationDictionary];
  
  NSMutableDictionary *networkTypeDictionary = [self createNetworkTypeMetric];
  if (results[@"timestamp"] != nil) {
    networkTypeDictionary[@"timestamp"] = results[@"timestamp"];
  }
  if (results[@"datetime"] != nil) {
    networkTypeDictionary[@"datetime"] = results[@"datetime"];
  }
  
  [self.accumulatedNetworkTypeLocationMetrics  addObject:networkTypeDictionary];
  
  if (results != nil) {
    [tests addObject:results];
  }
  
  [jsonDictionary setObject:tests forKey:@"tests"];
}


- (NSMutableDictionary *)createNetworkTypeMetric
{
  /*
   
   "type":"network_data",
   "active_network_type":api android.net.ConnectivityManager.getActiveNetworkInfo().getTypeName(),
   "active_network_type_code":api android.net.ConnectivityManager.getActiveNetworkInfo().getType(),
   "connected":api android.net.ConnectivityManager.getActiveNetworkInfo().isConnected(),
   "datetime":"Fri Jan 25 15:35:07 GMT 2013",
   "network_operator_code":api android.telephony.TelephonyManager.getNetworkOperator(),
   "network_operator_name":api android.telephony.TelephonyManager.getNetworkOperatorName(),
   "network_type_code":api android.telephony.TelephonyManager.getNetworkType(),
   "network_type":"HSDPA",
   "phone_type_code":api android.telephony.TelephonyManager.getPhoneType(),
   "phone_type":"GSM",
   "roaming":api android.telephony.TelephonyManager.isNetworkRoaming(),
   "sim_operator_code":api android.telephony.TelephonyManager.getSimOperator(),
   "sim_operator_name":api android.telephony.TelephonyManager.getSimOperatorName(),
   "timestamp":"1359128107"
   
   */
  
  // Updates the reachability status...
  [[SKAAppDelegate getAppDelegate] getIsConnected];
  
  NSMutableDictionary *network = [NSMutableDictionary dictionary];
  [network setObject:@"network_data"
              forKey:@"type"];
  [network setObject:@"true"
              forKey:@"connected"];   // must be true, seeing as we completed the test(s)
  [network setObject:[NSDate sGetDateAsIso8601String:[SKCore getToday]] forKey:@"datetime"];
  [network setObject:[SKGlobalMethods getConnectionResultString:(ConnectionStatus)[[SKAAppDelegate getAppDelegate] amdGetConnectionStatus]]
              forKey:@"active_network_type"];
  [network setObject:@"NA"
              forKey:@"active_network_type_code"];
  
  // Note: the sim_operator_code and network_operator_code values should both be the same,
  // i.e. they should both be the result of a call to getSimOperatorCodeMCCAndMNC...
  NSString *simOperatorCodeMCCAndMNC = [SKGlobalMethods getSimOperatorCodeMCCAndMNC];
  [network setObject:simOperatorCodeMCCAndMNC
              forKey:@"network_operator_code"];
  [network setObject:simOperatorCodeMCCAndMNC
              forKey:@"sim_operator_code"];
  
  [network setObject:[SKGlobalMethods getCarrierName]
              forKey:@"network_operator_name"];
  [network setObject:@"NA"
              forKey:@"network_type_code"];
  //[network setObject:[SKGlobalMethods getConnectionResultString:[[SKAAppDelegate getAppDelegate] amdGetConnectionStatus]]
  [network setObject:[SKGlobalMethods getNetworkType]
              forKey:@"network_type"];
  [network setObject:[SKGlobalMethods getDevicePlatform]
              forKey:@"phone_type_code"];
#ifdef DEBUG
  NSLog(@"DEBUG: sim_operator_code=%@", [SKGlobalMethods getSimOperatorCodeMCCAndMNC]);
#endif // DEBUG
  [network setObject:[SKGlobalMethods getCarrierName]
              forKey:@"sim_operator_name"];
  [network setObject:[SKGlobalMethods getTimeStamp]
              forKey:@"timestamp"];
  [network setObject:[SKGlobalMethods getDeviceModel]
              forKey:@"phone_type"];
  [network setObject:@"NA"
              forKey:@"roaming"];
  return network;
}

- (NSMutableDictionary *)createLocationMetric
{
  /*
   
   "type":"location",
   "accuracy":api android.location.Location.getAccuracy(),
   "datetime":"Thu Jan 24 22:40:05 EST 2013",
   "latitude":api android.location.Location.getLatitude(),
   "location_type":gps
   "longitude":api android.location.Location.getLongitude(),
   "timestamp":api android.location.Location.getTime()
   
   */
  
  NSMutableDictionary *location = [NSMutableDictionary dictionary];
  
  [location setObject:@"location"
               forKey:@"type"];
  
  [location setObject:@"NA"
               forKey:@"accuracy"];
  
  [location setObject:[NSDate sGetDateAsIso8601String:[SKCore getToday]] forKey:@"datetime"];
  
  [location setObject:[NSString stringWithFormat:@"%f", [self.autotestManagerDelegate amdGetLatitude]]
               forKey:@"latitude"];
  
  [location setObject:[NSString stringWithFormat:@"%f", [self.autotestManagerDelegate amdGetLongitude]]
               forKey:@"longitude"];
  
  [location setObject:[SKGlobalMethods getNetworkOrGps]
               forKey:@"location_type"];
  
  [location setObject:[SKGlobalMethods getTimeStampForTimeInteralSince1970:[self.autotestManagerDelegate amdGetDateAsTimeIntervalSince1970]]
               forKey:@"timestamp"];
  return location;
}

- (void)writeJSON_Metrics
{
  
  // Phone info ////////////////////////////////////////////////////////////////////////////////////////////////
  
  /*
   
   "type":"phone_identity",
   "datetime":"Fri Jan 25 15:35:07 GMT 2013",
   "manufacturer":api android.os.Build.MANUFACTURER,
   "model":api android.os.Build.MODEL,
   "os_type":"android",
   "os_version":api android.os.Build.VERSION.SDK_INT,
   "timestamp":1359128107
   "test_id":"190329108"
   */
  
  NSMutableDictionary *phone = [NSMutableDictionary dictionary];
  
  [phone setObject:@"phone_identity"
            forKey:@"type"];
  
  // Return the device 'unique id' via the app_id value in the upload data *only* for some app variants.
  if ([[SKAAppDelegate getAppDelegate] getShouldUploadDeviceId]) {
    [phone setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"app_id"];
  }
  
  [phone setObject:[NSDate sGetDateAsIso8601String:[SKCore getToday]] forKey:@"datetime"];
  
  [phone setObject:@"Apple"
            forKey:@"manufacturer"];
  
  [phone setObject:[SKGlobalMethods getDeviceModel]
            forKey:@"model"];
  
  [phone setObject:[[UIDevice currentDevice] systemName]
            forKey:@"os_type"];
  
  [phone setObject:[[UIDevice currentDevice] systemVersion]
            forKey:@"os_version"];
  
  [phone setObject:[SKGlobalMethods getTimeStamp]
            forKey:@"timestamp"];
  
  [phone setObject:[self.testId stringValue]
            forKey:@"test_id"];
  
  
  // Location ////////////////////////////////////////////////////////////////////////////////////////////////
  
  NSMutableDictionary *location;
  location = [self createLocationMetric];
  
  
  // Last Known Location /////////////////////////////////////////////////////////////////////////////////////
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  double latitude = 0.0;
  double longitude = 0.0;
  //NSTimeInterval locationdate = 0;
  NSDictionary *loc = [prefs objectForKey:Prefs_LastLocation];
  if (loc != nil) {
    latitude = [[loc objectForKey:@"LATITUDE"] doubleValue];
    longitude = [[loc objectForKey:@"LONGITUDE"] doubleValue];
    //locationdate = [[loc objectForKey:@"LOCATIONDATE"] doubleValue];
  }
  
  //  if (locationdate == 0) {
  //    locationdate = [[SKCore getToday] timeIntervalSince1970];
  //  }
  
  NSMutableDictionary *lastLocation = [NSMutableDictionary dictionary];
  
  [lastLocation setObject:@"last_known_location"
                   forKey:@"type"];
  
  [lastLocation setObject:@"NA"
                   forKey:@"accuracy"];
  
  [lastLocation setObject:[NSDate sGetDateAsIso8601String:[SKCore getToday]] forKey:@"datetime"];
  
  [lastLocation setObject:[NSString stringWithFormat:@"%f", latitude]
                   forKey:@"latitude"];
  
  [lastLocation setObject:[NSString stringWithFormat:@"%f", longitude]
                   forKey:@"longitude"];
  
  [lastLocation setObject:[SKGlobalMethods getNetworkOrGps]
                   forKey:@"location_type"];
  
  [lastLocation setObject:[SKGlobalMethods getTimeStamp]
                   forKey:@"timestamp"];
  
  
  // Network ////////////////////////////////////////////////////////////////////////////////////////////////
  
  NSMutableDictionary *network;
  network = [self createNetworkTypeMetric];
  
  NSMutableArray *metrics = [NSMutableArray array];
  [metrics addObject:phone];
  [metrics addObject:location];
  [metrics addObject:lastLocation];
  [metrics addObject:network];
  
  for (NSDictionary *accumulatedMetric in self.accumulatedNetworkTypeLocationMetrics) {
    [metrics  addObject:accumulatedMetric];
  }
  
  // If we fired a throttle query, upload the response...
  if ( (self.mpThrottledQueryResult != nil) &&
      (self.mpThrottledQueryResult.returnCode != SKOperators_Return_NoThrottleQuery)
      )
  {
    NSMutableDictionary *carrierStatus = [NSMutableDictionary dictionary];
    [carrierStatus setObject:@"carrier_status"
                      forKey:@"type"];
    // timestamp of the operator status check...
    [carrierStatus setObject:self.mpThrottledQueryResult.timestamp
                      forKey:@"timestamp"];
    // date/time of the operator status check...
    [carrierStatus setObject:self.mpThrottledQueryResult.datetimeUTCSimple forKey:@"datetime"];
    // operator name that matched by our status check
    [carrierStatus setObject:self.mpThrottledQueryResult.carrier
                      forKey:@"carrier"];
    // status response from our status check
    [carrierStatus setObject:self.mpThrottleResponse
                      forKey:@"status"];
    
    [metrics addObject:carrierStatus];
  }
  
  if (nil != cpuCondition)
  {
    [metrics addObject:cpuCondition];
  }
  
  [jsonDictionary setObject:metrics forKey:@"metrics"];
}

- (BOOL)testIsIncluded:(NSString*)testType
{
  if (self.runAllTests)
    return YES;
  
  if ([testType isEqualToString:@"closestTarget"])
    return YES;
  
  return [testType isEqualToString:self.validTest];
}

-(BOOL) shouldTestTypeIfIsIncluded {
  return YES;
}

- (void)privateDoSaveAndUploadJson
{
  // See the comment for "checkTestId", which is used to create the testId.
  // "Only set this once, after at least one test has completed successfully
  // A successful closest target test alone does not constitute a successful batch test..
  // .. we dont want to store a result on the map just for a closest target result."
  
  if (self.testId == nil) {
    // We've not got a completed test - nothing to upload.
    SK_ASSERT(false);
    return;
  }
  
#ifdef DEBUG
  NSLog(@"DEBUG - SKAAutoTest: doSaveAndUploadJson");
#endif // DEBUG
  
  [self writeJSON_Metrics];
  
  // Append data on the requested tests!
  [jsonDictionary setObject:self.requestedTests forKey:@"requested_tests"];
  
  if (self.conditionBreaches != nil) {
    [jsonDictionary setObject:self.conditionBreaches forKey:@"condition_breach"];
  }
  
  [SKDatabase storeMetrics:self.testId
                    device:[SKGlobalMethods getDeviceModel]
                        os:[[UIDevice currentDevice] systemVersion]
               carrierName:[SKGlobalMethods getCarrierName]
               countryCode:[SKGlobalMethods getCarrierMobileCountryCode]
                   isoCode:[SKGlobalMethods getCarrierIsoCountryCode]
               networkCode:[SKGlobalMethods getCarrierNetworkCode]
               networkType:[SKGlobalMethods getNetworkTypeString]
                 radioType:[SKGlobalMethods getNetworkType]
                    target:self.selectedTarget];
  
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];
  
  NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
#ifdef DEBUG
  //NSLog(@"DEBUG: doSaveAndUploadJson - jsonStr=...\n%@", jsonStr);
  NSLog(@"DEBUG: doSaveAndUploadJson...");
#endif // DEBUG
  
  [self privateDoSaveJSON:jsonStr];
  [self.autotestManagerDelegate amdDoUploadJSON];
}

- (void) privateDoSaveJSON:(NSString*)jsonString {
  
  // 1. Write to JSON file for upload
  {
    NSString *path = [SKAAppDelegate getNewJSONFilePath];
    NSError *error = nil;
    if ([jsonString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
      //NSLog(@"Wrote JSON Successfully");
    }
    else
    {
#ifdef DEBUG
      NSLog(@"Error writing JSON : %@", error.localizedDescription);
      SK_ASSERT(false);
#endif // DEBUG
    }
  }
  
  // 2. Write to JSON file for archive (for subsequent export!)
  {
    NSString *path = [SKAAppDelegate getNewJSONArchiveFilePath];
    NSError *error = nil;
    if ([jsonString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
      NSLog(@"Wrote Archive JSON Successfully");
    }
    else
    {
#ifdef DEBUG
      NSLog(@"Error writing archive JSON : %@", error.localizedDescription);
      SK_ASSERT(false);
#endif // DEBUG
    }
  }
}

- (void)runNextTest:(int)testIndex
{
  int nextTestIndex = testIndex + 1;
  
#ifdef DEBUG
  NSLog(@"DEBUG **** - SKAAutoTest:runNextTest< testIndex=%d, nextTestIndex=%d", testIndex, nextTestIndex);
#endif // DEBUG
  
  if ([self.autoTests count] > 0)
  {
#ifdef DEBUG
    NSLog(@"DEBUG **** - SKAAutoTest: self.autoTests.count=%d", (int)[self.autoTests count]);
#endif // DEBUG
    
    int testsCount = (int)[self.autoTests count];
    
    if (nextTestIndex < testsCount)
    {
#ifdef DEBUG
      NSLog(@"DEBUG **** - SKAAutoTest: nextTestIndex < testsCount (%d)", testsCount);
#endif // DEBUG
      
      NSDictionary *dict = [self.autoTests objectAtIndex:nextTestIndex];
      SK_ASSERT(dict != nil);
      
      if (nil != dict)
      {
        SKTestConfig *config = [[SKTestConfig alloc] initWithDictionary:dict];
        SK_ASSERT(config != nil);
        
        if (nil != config)
        {
          config.testConfigDelegate = self;
          
          NSString *tstType = config.type;
#ifdef DEBUG
          NSLog(@"DEBUG **** - SKAAutoTest: about to run next test - tstType=%@", tstType);
#endif // DEBUG
          
          if ([tstType isEqualToString:@"closestTarget"])
          {
            // NOT RECORDED! [self rememberThatTestWasRequested:@"JUDPLATENCY"];
            
            [self runClosestTargetTest:config testIndex:nextTestIndex];
          }
          else if ([tstType isEqualToString:@"latency"])
          {
            if (self.udpClosestTargetTestSucceeded == NO) {
              // UDP failed - SKIP the latency test entirely.
              // Do NOT record that it was run, and do NOT run it!
              [self runNextTest: nextTestIndex];
              return;
            }
            
            // To get here, UDP succeeded: record that the test has been requested... and run the test.
            [self rememberThatTestWasRequested:@"JUDPLATENCY"];
            [self runLatencyTest:config testIndex:nextTestIndex];
          }
          else if ([tstType isEqualToString:@"downstreamthroughput"])
          {
            NSArray *targets = [config getTargets];
            int nThreads = (int)[targets count];
            NSString *type = (nThreads == 1) ? DOWNSTREAMSINGLE : DOWNSTREAMMULTI;
            [self rememberThatTestWasRequested:type];
            
            [self runTransferTest:config testIndex:nextTestIndex isDownload:YES];
          }
          else if ([tstType isEqualToString:@"upstreamthroughput"])
          {
            NSArray *targets = [config getTargets];
            int nThreads = (int)[targets count];
            NSString *type = (nThreads == 1) ? UPSTREAMSINGLE : UPSTREAMMULTI;
            [self rememberThatTestWasRequested:type];
            
            [self runTransferTest:config testIndex:nextTestIndex isDownload:NO];
          }
          else
          {
            SK_ASSERT(false);
          }
        }
      }
    }
    else
    {
      // Complete
#ifdef DEBUG
      NSLog(@"DEBUG **** - SKAAutoTest: COMPLETE!");
#endif // DEBUG
      
      self.isRunning = NO;
      [self markTestAsStopped]; // Only called by child class!
      
      SK_ASSERT(self.autotestManagerDelegate != nil);
      
      if (![NSThread isMainThread])
      {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self.autotestObserverDelegate aodAllTestsComplete];
        });
      }
      else
      {
        [self.autotestObserverDelegate aodAllTestsComplete];
      }
      
      // This method saves & uploads the JSON, if at least one Test completed!
      [self privateDoSaveAndUploadJson];
    }
  }
  else
  {
    self.isRunning = NO;
    [self markTestAsStopped]; // Only called by child class!
    
    if (![NSThread isMainThread])
    {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.autotestObserverDelegate aodAllTestsComplete];
      });
    }
    else
    {
      [self.autotestObserverDelegate aodAllTestsComplete];
    }
  }
}

#pragma mark -Test Config Delegate

- (void)tcdSetCPUConditionResult:(int)maxCPU avgCPU:(int)avgCPU Success:(BOOL)bSuccess Type:(NSString*)type
{
  SK_ASSERT([type isEqualToString:@"CpuActivity"]);
  
  // Force this as the CpuActivity string!
  NSString *cpuActivityType = @"CPUACTIVITY";
  
  if (cpuCondition == nil)
  {
    cpuCondition = [[NSMutableDictionary alloc] init];
    
    /*
     "type": "CPUACTIVITY",
     "datetime": "Fri Jan 25 10:23:16 EST 2013",
     "max_average": "25",
     "read_average": "5",
     "success": "true",
     "timestamp": "1359127396"
     */
    
    [cpuCondition setObject:cpuActivityType forKey:@"type"];
    [cpuCondition setObject:[NSDate sGetDateAsIso8601String:[SKCore getToday]] forKey:@"datetime"];
    [cpuCondition setObject:[NSString stringWithFormat:@"%d", maxCPU] forKey:@"max_average"];
    [cpuCondition setObject:[NSString stringWithFormat:@"%d", avgCPU] forKey:@"read_average"];
    [cpuCondition setObject:(bSuccess) ? @"true" : @"false" forKey:@"success"];
    [cpuCondition setObject:[SKGlobalMethods getTimeStamp] forKey:@"timestamp"];
  }
  
  if (bSuccess == NO) {
    //
    // Failed!
    //
    
    // Record this condition failure - we'll upload it in the JSON later!
    if (self.conditionBreaches == nil)
    {
      self.conditionBreaches = [NSMutableArray new];
    }
    
    // Add this item, if we don't already have a duplicate.
    BOOL matchFound = NO;
    for (NSString *theType in self.conditionBreaches) {
      if ([theType isEqualToString:cpuActivityType]) {
        matchFound = YES;
        break;
      }
    }
    
    if (matchFound == NO) {
      [self.conditionBreaches addObject:cpuActivityType];
    }
  }
}

#pragma mark - HTTP Test Method

- (void)createHttpTest:(SKTestConfig *)config isDownload:(BOOL)isDownload file:(NSString *)file target:(NSString *)target
{
  self.httpTest = [[SKHttpTest alloc]
                   initWithTarget:target
                   port:[[config paramObjectForKey:@"port"] intValue]
                   file:file
                   isDownstream:isDownload
                   warmupMaxTime:[[config paramObjectForKey:@"warmupmaxtime"] doubleValue]
                   warmupMaxBytes:[[config paramObjectForKey:@"warmupmaxbytes"] doubleValue]
                   TransferMaxTimeMicroseconds:[[config paramObjectForKey:@"transfermaxtime"] doubleValue]
                   transferMaxBytes:[[config paramObjectForKey:@"transfermaxbytes"] doubleValue]
                   nThreads:[[config paramObjectForKey:@"numberofthreads"] intValue]
                   HttpTestDelegate:self];
  
  [self.httpTest setSKAutotest:self];
}


- (void)updateStatus:(TransferStatus)status threadId:(NSUInteger)threadId
{
  if (status == FAILED)
  {
    [self writeJSON_TestResultsDictionary:[self getSKAHttpTest].outputResultsDictionary];
    
    [self.autotestObserverDelegate aodTransferTestDidFail:self.httpTest.isDownstream];
    
    [self runNextTest:self.httpTest.testIndex];
  }
}

- (void)ltdTestDidSucceed
{
  NSDate *dt = [SKCore getToday];
  
  [self checkTestId];
  
  if (nil != self.testId)
  {
    [SKDatabase storeLatency:dt latency:self.latencyTest.latency testId:self.testId testName:self.latencyTest.displayName];
    [SKDatabase storePacketLoss:dt packetLoss:self.latencyTest.packetLoss testId:self.testId testName:self.latencyTest.displayName];
    [SKDatabase storeJitter:dt jitter:self.latencyTest.jitter testId:self.testId testName:self.latencyTest.displayName];
  }
  
  [self writeJSON_TestResultsDictionary:self.latencyTest.outputResultsDictionary];
  
  [self.autotestObserverDelegate aodLatencyTestDidSucceed:self.latencyTest];
  
  [self runNextTest:self.latencyTest.testIndex];
}

- (void)htdUpdateStatus:(TransferStatus)status threadId:(NSUInteger)threadId {
  if (status == FAILED)
  {
#ifdef DEBUG
    NSLog(@"DEBUG: %s htdUpdateStatus:FAILED", __FUNCTION__);
#endif // DEBUG
    [self.autotestObserverDelegate aodTransferTestDidFail:self.httpTest.isDownstream];
    [self runNextTest:self.httpTest.testIndex];
  }
}

- (void)htdDidCompleteHttpTest:(double)bitrateMpbs1024Based
            ResultIsFromServer:(BOOL)resultIsFromServer
//              transferBytes:(NSUInteger)transferBytes
//                 totalBytes:(NSUInteger)totalBytes
//                   threadId:(NSUInteger)threadId
{
#ifdef DEBUG
  NSLog(@"DEBUG: htdDidCompleteHttpTest (%@) : %@ ... result is from=%@", self.httpTest.displayName, [SKGlobalMethods bitrateMbps1024BasedToString:bitrateMpbs1024Based], resultIsFromServer ? @"Server" : @"Client");
#endif // DEBUG
  
  [self checkTestId];
  
  if (nil != self.testId)
  {
    if (self.httpTest.isDownstream)
    {
      [SKDatabase storeDownload:[SKCore getToday] BitrateMbps1024Based:bitrateMpbs1024Based testId:self.testId testName:self.httpTest.displayName];
    }
    else
    {
      [SKDatabase storeUpload:[SKCore getToday] BitrateMbps1024Based:bitrateMpbs1024Based testId:self.testId testName:self.httpTest.displayName];
    }
  }
  
  [self.autotestObserverDelegate aodTransferTestDidCompleteTransfer:self.httpTest Bitrate1024Based:bitrateMpbs1024Based];
  
  [self writeJSON_TestResultsDictionary:[self getSKAHttpTest].outputResultsDictionary];
  
  [self htdDidCompleteHttpTest];
}

@end
