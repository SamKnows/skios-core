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
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] startLocationMonitoring];
  
  self.btid = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    if (self.btid != UIBackgroundTaskInvalid) {
      [[UIApplication sharedApplication] endBackgroundTask:self.btid];
      self.btid = UIBackgroundTaskInvalid;
    }
  }];
  
  NSArray *tests_ = [[self.autotestManagerDelegate amdGetSchedule] getArrayOfTests];
  
  if (tests_ != nil)
  {
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
    
    double latitude = [autotestManagerDelegate amdLocationGetLatitude];
    //NSLog(@"latitude=%g", latitude);
    double longitude = [autotestManagerDelegate amdLocationGetLongitude];
    //NSLog(@"longitude=%g", latitude);
    SKScheduler *schedule = [autotestManagerDelegate amdGetSchedule];
    //NSLog(@"schedule=%@", schedule);
    NSString *closestTargetName = [autotestManagerDelegate amdGetClosestTarget];
    SK_ASSERT(closestTargetName != nil);
    //NSLog(@"closestTargetName=%@", closestTargetName);
    NSString *targetName = [schedule getClosestTargetName:closestTargetName];
    SK_ASSERT(targetName != nil);
    //NSLog(@"targetName=%@", targetName);
   
    self.testId = [SKDatabase
                   storeBatchTestMapData:latitude
                   longitude:longitude
                   target:targetName];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      // Posting to NSNotificationCenter *must* be done in the main thread!
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
      int postDataLength = [[config paramObjectForKey:@"postdatalength"] intValue];
      SK_ASSERT(postDataLength > 0);
      [self.autotestManagerDelegate amdDoCreateUploadFile:postDataLength];
      file = [self.autotestManagerDelegate amdGetFileUploadPath:postDataLength];
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
          [self.httpTest cancel];
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
- (void)htdUpdateDataUsage:(NSUInteger)totalBytes bytes:(NSUInteger)bytes progress:(float)progress
{
  [self.autotestManagerDelegate amdDoUpdateDataUsage:(int)bytes];
}

//###HG
- (void)htdDidUpdateTotalProgress:(float)progress BitrateMbps1024Based:(double)bitrateMbps1024Based
{
  [self.autotestObserverDelegate aodTransferTestDidUpdateProgress:progress isDownstream:self.httpTest.isDownstream bitrate1024Based:bitrateMbps1024Based];
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
          [self.latencyTest cancel];
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

- (void)ltdUpdateProgress:(float)progress latency:(float)latency_
{
  [self.autotestObserverDelegate aodLatencyTestUpdateProgress:progress latency:latency_];
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
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] stopLocationMonitoring];
}

- (void)stopTheTests
{
  NSLog(@"STOP AUTO TEST");

  [self markTestAsStopped];
  
  self.isCancelled = YES;
  
  if (self.httpTest)
  {
    [self.httpTest cancel];
    self.httpTest = nil;
  }
  
  if (self.targetTest)
  {
    [self.targetTest cancel];
    self.targetTest = nil;
  }
  
  if (self.latencyTest)
  {
    [self.latencyTest cancel];
    self.latencyTest = nil;
  }
}


- (NSString*)getValidTestType:(TestType)testType
{
  if (testType == ALL_TESTS)
  {
    return C_NETWORKTYPEASSTRING_ALL;
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
  
  self.testId = nil;
  self.requestedTests = [NSMutableArray new];
  self.jsonDictionary = [SKKitJSONDataCaptureAndUpload sCreateJSONDictionary_IsContinuousTest:isContinuousTesting];
 
  SKScheduler*scheduler = [self.autotestManagerDelegate amdGetSchedule];
  SK_ASSERT(scheduler != nil);
  if (scheduler.scheduleVersion != nil) {
    [jsonDictionary setObject:scheduler.scheduleVersion forKey:@"schedule_config_version"];
  } else {
    SK_ASSERT(false);
  }
}

-(void)startOfTestRunThrottleQuery {
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isThrottleQuerySupported] == false)
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


-(void) rememberThatTestWasRequested:(NSString*)type {
  
  for (NSObject *theTest in self.requestedTests)
  {
    NSString *compare = [NSString stringWithFormat:@"%@",theTest];
    if ([compare isEqualToString:type]) {
    //if ([theTest isEqualToString:type]) {
      // Already exists - nothing to do!
      return;
    }
  }
  
  [self.requestedTests addObject:type];
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
  NSLog(@"DEBUG - SKAutotest: doSaveAndUploadJson");
#endif // DEBUG
 
  //
  // Save metrics!
  //
  
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

  //
  // Prepare the JSON dictionary for upload... and then save/upload it!
  //
  
  // Write metric data to the json dictionary!
  NSString *testIdAsString = [self.testId stringValue];
  NSMutableArray *metrics = [SKKitJSONDataCaptureAndUpload sWriteMetricsToJSONDictionary:self.jsonDictionary TestId:testIdAsString SKKitLocationMonitor:[self.autotestManagerDelegate amdGetSKKitLocationMonitor] AccumulatedNetworkTypeLocationMetrics:self.accumulatedNetworkTypeLocationMetrics];
  
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
  
  if (self.conditionBreaches != nil) {
    [self.jsonDictionary setObject:self.conditionBreaches forKey:@"condition_breach"];
  }
  
  if (nil != cpuCondition)
  {
    [metrics addObject:cpuCondition];
  }
 
  //
  // Write the Dictionary as JSON file, and upload to the server!
  //
  [SKKitJSONDataCaptureAndUpload sWriteTestDataAsJSONAndUploadToServer:self.jsonDictionary RequestedTests:self.requestedTests];
}



- (void)runNextTest:(int)testIndex
{
  int nextTestIndex = testIndex + 1;
  
#ifdef DEBUG
  NSLog(@"DEBUG **** - SKAutotest:runNextTest< testIndex=%d, nextTestIndex=%d", testIndex, nextTestIndex);
#endif // DEBUG
  
  if ([self.autoTests count] > 0)
  {
#ifdef DEBUG
    NSLog(@"DEBUG **** - SKAutotest: self.autoTests.count=%d", (int)[self.autoTests count]);
#endif // DEBUG
    
    int testsCount = (int)[self.autoTests count];
    
    if (nextTestIndex < testsCount)
    {
#ifdef DEBUG
      NSLog(@"DEBUG **** - SKAutotest: nextTestIndex < testsCount (%d)", testsCount);
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
          NSLog(@"DEBUG **** - SKAutotest: about to run next test - tstType=%@", tstType);
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
      NSLog(@"DEBUG **** - SKAutotest: COMPLETE!");
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
    [SKKitJSONDataCaptureAndUpload sWriteJSON_TestResultsDictionary:[self getSKAHttpTest].outputResultsDictionary ToDictionary:self.jsonDictionary SKKitLocationMonitor:[self.autotestManagerDelegate amdGetSKKitLocationMonitor] AccumulateNetworkTypeLocationMetricsToHere:self.accumulatedNetworkTypeLocationMetrics];
    
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
  
  [SKKitJSONDataCaptureAndUpload sWriteJSON_TestResultsDictionary:self.latencyTest.outputResultsDictionary ToDictionary:self.jsonDictionary SKKitLocationMonitor:[self.autotestManagerDelegate amdGetSKKitLocationMonitor]  AccumulateNetworkTypeLocationMetricsToHere:self.accumulatedNetworkTypeLocationMetrics];
 
  dispatch_async(dispatch_get_main_queue(), ^{
    // Posting to NSNotificationCenter *must* be done in the main thread!
    [self.autotestObserverDelegate aodLatencyTestDidSucceed:self.latencyTest];
    [self runNextTest:self.latencyTest.testIndex];
  });
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

- (void)htdDidCompleteHttpTest:(double)bitrateMbps1024Based
            ResultIsFromServer:(BOOL)resultIsFromServer
               TestDisplayName:(NSString*)testDisplayName
//              transferBytes:(NSUInteger)transferBytes
//                 totalBytes:(NSUInteger)totalBytes
//                   threadId:(NSUInteger)threadId
{
#ifdef DEBUG
  NSLog(@"DEBUG: htdDidCompleteHttpTest (%@) : %@ ... result is from=%@", self.httpTest.displayName, [SKGlobalMethods bitrateMbps1024BasedToString:bitrateMbps1024Based], resultIsFromServer ? @"Server" : @"Client");
#endif // DEBUG
  
  [self checkTestId];
  
  SK_ASSERT(testDisplayName != nil);
  
  if (nil != self.testId)
  {
    if (self.httpTest.isDownstream)
    {
      [SKDatabase storeDownload:[SKCore getToday] BitrateMbps1024Based:bitrateMbps1024Based testId:self.testId testName:testDisplayName];
    }
    else
    {
      [SKDatabase storeUpload:[SKCore getToday] BitrateMbps1024Based:bitrateMbps1024Based testId:self.testId testName:testDisplayName];
    }
  }
  
  [self.autotestObserverDelegate aodTransferTestDidCompleteTransfer:self.httpTest Bitrate1024Based:bitrateMbps1024Based];
  
  [SKKitJSONDataCaptureAndUpload sWriteJSON_TestResultsDictionary:[self getSKAHttpTest].outputResultsDictionary ToDictionary:self.jsonDictionary SKKitLocationMonitor:[self.autotestManagerDelegate amdGetSKKitLocationMonitor] AccumulateNetworkTypeLocationMetricsToHere:self.accumulatedNetworkTypeLocationMetrics];
  
  [self htdDidCompleteHttpTest];
}

@end
