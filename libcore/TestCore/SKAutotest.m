//
//  SKAutotest.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKAutotest.h"

@interface SKAutotest ()

@end

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

-(id) initWithAutotestManagerDelegate:(id<SKAutotestManagerDelegate>)inAutotestManagerDelegate AndAutotestObserverDelegate:(id<SKAutotestObserverDelegate>)inAutotestObserverDelegate AndTestType:(TestType)inTestType  IsContinuousTesting:(BOOL)isContinuousTesting {
  
    self = [super init];
    
    if (self)
    {
      autotestManagerDelegate = inAutotestManagerDelegate;
      autotestObserverDelegate = inAutotestObserverDelegate;
      isRunning = NO;
      isCancelled = NO;
      runAllTests = (inTestType == ALL_TESTS);
      validTest = [self getValidTestType:inTestType];
      udpClosestTargetTestSucceeded = NO;
    }
  
    return self;
}

-(void) dealloc {
  
  [self stopTheTests];
}

- (void)runTheTests
{
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
        if (nil == self.autoTests)
        {
          self.autoTests = [[NSMutableArray alloc] initWithArray:nextTests];
        }
        else
        {
          [self.autoTests removeAllObjects];
          [self.autoTests addObjectsFromArray:nextTests];
        }
        
        self.isRunning = YES;
        
        [self runNextTest:-1];
      }
    }
  }
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

- (void)runNextTest:(int)testIndex {
  // This MUST be overridden!
  SK_ASSERT(false);
}

- (void)createLatencyTest:(SKTestConfig *)config target:(NSString *)target
{
  // This MUST be overridden!
  SK_ASSERT(false);
}

- (void)createClosestTargetTest:(NSArray *)targets NumDatagrams:(int)numDatagrams
{
  // This MUST be overridden!
  SK_ASSERT(false);
}

- (void)createHttpTest:(SKTestConfig *)config isDownload:(BOOL)isDownload file:(NSString *)file target:(NSString *)target {
  // This MUST be overridden!
  SK_ASSERT(false);
}

- (BOOL)shouldCallCheckConditions
{
  // This MUST be overridden!
  SK_ASSERT(false);
  return NO;
}

-(BOOL) shouldTestTypeIfIsIncluded {
  // This MUST be overridden!
  SK_ASSERT(false);
  return NO;
}

- (void)tcdSetCPUConditionResult:(int)maxCPU avgCPU:(int)avgCPU  Success:(BOOL)bSuccess Type:(NSString*)type
{
  // This MUST be overridden!
  SK_ASSERT(false);
}

- (BOOL)testIsIncluded:(NSString*)testType {
  SK_ASSERT(false);
  return NO;
}

- (void)ctdDidSendPacket:(NSUInteger)bytes
{
  [self.autotestManagerDelegate amdDoUpdateDataUsage:(int)bytes];
}

- (void)checkTestId
{
  if (nil == self.testId)
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
  }
}

- (void)runClosestTargetTest:(SKTestConfig*)config testIndex:(int)testIndex;
{
  if (![self.autotestManagerDelegate amdGetIsConnected])
  {
    // We must always try to call runNextTest; otherwise, the tests will never complete!
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
    
    NSArray *targets = [config getTargets];
    
    if (nil != targets)
    {
      if (self.targetTest == nil)
      {
        int numDatagramsFromSchedule = [[config paramObjectForKey:@"numberOfPackets"] intValue];
        [self createClosestTargetTest:targets NumDatagrams:numDatagramsFromSchedule];
        [self.targetTest setTestIndex:testIndex];
        [self.targetTest setNetworkType:[config getNetworkType]];
        [self.targetTest setDisplayName:[config displayName]];
        
        if ([self.targetTest isReady])
        {
          if (!self.isCancelled)
          {
            if (![NSThread isMainThread])
            {
              dispatch_async(dispatch_get_main_queue(), ^{
                [self.autotestObserverDelegate aodClosestTargetTestDidStart];
              });
            }
            else
            {
              [self.autotestObserverDelegate aodClosestTargetTestDidStart];
            }
            
            [self.targetTest startTest];
          }
        }
      }
      else
      {
        [self.targetTest setTargets:targets];
        self.targetTest.closestTargetDelegate = self;
        [self.targetTest setTestIndex:testIndex];
        [self.targetTest setNetworkType:[config getNetworkType]];
        [self.targetTest setDisplayName:[config displayName]];
        
        if ([self.targetTest isReady])
        {
          if (!self.isCancelled)
          {
            if (![NSThread isMainThread])
            {
              dispatch_async(dispatch_get_main_queue(), ^{
                [self.autotestObserverDelegate aodClosestTargetTestDidStart];
              });
            }
            else
            {
              [self.autotestObserverDelegate aodClosestTargetTestDidStart];
            }
            
            [self.targetTest startTest];
          }
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
        NSLog(@"********* creating httpTransfer test, isDownload=%d", (int)isDownload);
        [self createHttpTest:config isDownload:isDownload file:file target:target];
        
        [self.httpTest setTestIndex:testIndex];
        [self.httpTest setNetworkType:[config getNetworkType]];
        [self.httpTest setDisplayName:[config displayName]];
        
        if ([self.httpTest isReady])
        {
          NSLog(@"********* test is ready");
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
                NSLog(@"********* test is starting via delegate... routing async to main thread");
                [self.autotestObserverDelegate aodTransferTestDidStart:self.httpTest.isDownstream];
              });
            }
            else
            {
              NSLog(@"********* test is starting via delegate... on this main thread");
              [self.autotestObserverDelegate aodTransferTestDidStart:self.httpTest.isDownstream];
            }
            
            NSLog(@"********* test is starting!");
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
        NSLog(@"********* test already exists...");
        if ([self.httpTest isRunning])
        {
          NSLog(@"********* stopping the test that already exists...");
          [self.httpTest stopTest];
        }
        
        NSLog(@"********* preparing the test...");
        [self.httpTest setTarget:target];
        [self.httpTest setPort:[[config paramObjectForKey:@"port"] intValue]];
        [self.httpTest setFile:file];
        [self.httpTest setIsDownstream:isDownload];
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
          NSLog(@"********* test is ready...");
          if (!self.isCancelled)
          {
            if (![NSThread isMainThread])
            {
              dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"********* test is ready on async main thread...");
                [self.autotestObserverDelegate aodTransferTestDidStart:self.httpTest.isDownstream];
              });
            }
            else
            {
              NSLog(@"********* test is ready on main thread...");
              [self.autotestObserverDelegate aodTransferTestDidStart:self.httpTest.isDownstream];
            }
            
            NSLog(@"********* test is starting!");
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

- (void)htdDidUpdateTotalProgress:(float)progress
{
  [self.autotestObserverDelegate aodTransferTestDidUpdateProgress:progress isDownstream:self.httpTest.isDownstream];
}

- (void)htdUpdateStatus:(TransferStatus)status
            threadId:(NSUInteger)threadId {
  
}

- (void)htdDidCompleteHttpTest:(SKTimeIntervalMicroseconds)transferTimeMicroseconds
              transferBytes:(NSUInteger)transferBytes
                 totalBytes:(NSUInteger)totalBytes
                   threadId:(NSUInteger)threadId {
  
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

- (void)ltdTestDidSucceed {
  NSLog(@"SKAutotest::ltdTestDidSucceed");
  // This must be overridden... the overriding implement must, amongst other things,
  // call:
  //   [self runNextTest:self.latencyTest.testIndex];
  SK_ASSERT(false);
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

- (void)ltdUpdateProgress:(float)progress
{
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

- (void)stopTheTests
{
  NSLog(@"STOP AUTO TEST");
  
  self.isRunning = NO;
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
  else
  {
    return @"latency";
  }
}

@end
