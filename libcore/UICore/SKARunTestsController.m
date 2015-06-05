//
//  SKARunTestsController.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKARunTestsController.h"
#import "SKAMainResultsController.h"
#import "SKAArchivedResultsController.h"

@protocol SKARunTestsDelegate;

@interface SKARunTestsController ()
{
  SKAutotest *autoTest;
  NSMutableArray *resultsArray;
  
  UIBackgroundTaskIdentifier btid;
  
  int64_t dataStart;
  int64_t dataEnd;
  
  BOOL testsComplete;
}

@property SKAppBehaviourDelegate *appDelegate;
@property NSString *networkType;
@property (nonatomic, strong) NSMutableArray *resultsArray;

- (void)cancelCurrentTests;
- (void)setConnectionStatus;
- (void)statusChanged:(NSNotification*)notification;
- (NSIndexPath*)getIndexPathForTest:(NSString*)testType;
- (void)updateResultsArray:(id)object key:(NSString*)key testType:(NSString*)testType;
- (void)createDefaultResults;
- (BOOL)testIsIncluded:(NSString*)type;
- (void)setStartDataUsage;
- (void)setEndDataUsage;
- (void)calculateDataUsed;

@end

@implementation SKARunTestsController

@synthesize continuousTesting;
@synthesize appDelegate;
@synthesize resultsArray;
@synthesize delegate;

#pragma mark - Update Results Array Cache

- (void)updateResultsArray:(id)object key:(NSString*)key testType:(NSString*)testType
{
  @synchronized(self)
  {
    if (self.resultsArray)
    {
      for (NSMutableDictionary *dict in self.resultsArray)
      {
        if ([[dict objectForKey:@"TYPE"] isEqualToString:testType])
        {
          [dict setObject:object forKey:key];
        }
      }
    }
  }
}

#pragma mark - Autotest Delegate Methods

// CLOSEST TARGET /////////////////////////////////////////////////

- (void)aodClosestTargetTestDidStart
{
  [self.lblClosest setText:sSKCoreGetLocalisedString(@"TEST_Label_Finding_Best_Target")];
}

- (void)aodClosestTargetTestDidFail
{
#ifdef DEBUG
  NSLog(@"DEBUG: %s", __FUNCTION__);
#endif // DEBUG
  [self stopTestFromAlertResponse:NO];
  testsComplete = YES;
  [self.lblClosest setText:sSKCoreGetLocalisedString(@"TEST_Label_Closest_Failed")];
  
  NSIndexPath *ixp = [self getIndexPathForTest:@"latency"];
  SKALatencyTestCell *cell = (SKALatencyTestCell*)[self.tableView cellForRowAtIndexPath:ixp];
  NSString *statusString = [SKTransferOperation getStatusFailed];
  cell.lblLatencyResult.text = statusString;
  cell.lblLossResult.text = statusString;
  cell.lblJitterResult.text = statusString;
  
  // If we're running continuous testing, when the closest target fails... we must actually continue
  // the cycle of tests!
  if (self.continuousTesting == YES) {
    // Keep going!
    [self startToRunTheTests:YES];
  }
}

- (void)aodClosestTargetTestDidSucceed:(NSString*)target
{
  [SKAppBehaviourDelegate setClosestTarget:target];
 
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsBestTargetDisplaySupported]) {
    NSString *closest = [NSString stringWithFormat:@"%@ %@",
                         sSKCoreGetLocalisedString(@"TEST_Label_Closest_Target"),
                         [appDelegate.schedule getClosestTargetName:target]];
    
    [self.lblClosest setText:closest];
  }
}

// LATENCY //////////////////////////////////////////////////////

- (void)showFailedLatencyTest{
  NSIndexPath *ixp = [self getIndexPathForTest:@"latency"];
  SKALatencyTestCell *cell = (SKALatencyTestCell*)[self.tableView cellForRowAtIndexPath:ixp];
 
  NSString *statusString = nil;
  if (autoTest.udpClosestTargetTestSucceeded == YES) {
    // At least one UDP closest test was ... so UDP should be working, so if a UDP-based test failed,
    // we can assume it really failed. Show "Failed"
    statusString = [SKTransferOperation getStatusFailed];
  } else {
    // None of the UDP closest target tests succeed (we rolled-back to HTTP based), so we can assume
    // that UDP is completely blocked. Show "UDP Blocked"
    statusString = sSKCoreGetLocalisedString(@"UDP blocked");
  }
  
  if (nil != cell)
  {
    cell.latencyProgressView.hidden = YES;
    cell.lossProgressView.hidden = YES;
    cell.jitterProgressView.hidden = YES;
    
    cell.lblLatencyResult.hidden = NO;
    cell.lblLossResult.hidden = NO;
    cell.lblJitterResult.hidden = NO;
    
    cell.lblLatencyResult.text = statusString;
    cell.lblLossResult.text = statusString;
    cell.lblJitterResult.text = statusString;
  }
  
  [self updateResultsArray:[NSNumber numberWithBool:NO] key:@"HIDE_LABEL" testType:@"latency"];
  [self updateResultsArray:[NSNumber numberWithBool:YES] key:@"HIDE_SPINNER" testType:@"latency"];
  [self updateResultsArray:statusString key:@"RESULT_1" testType:@"latency"];
  [self updateResultsArray:statusString key:@"RESULT_2" testType:@"latency"];
  [self updateResultsArray:statusString key:@"RESULT_3" testType:@"latency"];
}

- (void)aodLatencyTestDidFail:(NSString*)messageIgnore
{
  [self showFailedLatencyTest];
}

- (void)aodLatencyTestDidStart {
  
}

- (void)aodLatencyTestDidSucceed:(SKLatencyTest*)latencyTest
{
  double latency = latencyTest.latency;
  double packetLoss = latencyTest.packetLoss;
  double jitter = latencyTest.jitter;
  
  NSString *resLatency = [NSString stringWithFormat:@"%@ ms", [SKGlobalMethods format2DecimalPlaces:latency]];
  NSString *resLoss = [NSString stringWithFormat:@"%d %%", (int)packetLoss];
  NSString *resJitter = [NSString stringWithFormat:@"%@ ms", [SKGlobalMethods format2DecimalPlaces:jitter]];
  
  NSIndexPath *ixp = [self getIndexPathForTest:@"latency"];
  SKALatencyTestCell *cell = (SKALatencyTestCell*)[self.tableView cellForRowAtIndexPath:ixp];
#ifdef DEBUG
  NSLog(@"DEBUG: [cell description]=%@", [cell description]);
#endif // DEBUG
  SK_ASSERT([cell class] == [SKALatencyTestCell class]);
  
  if (nil != cell)
  {
    cell.latencyProgressView.hidden = YES;
    cell.lossProgressView.hidden = YES;
    cell.jitterProgressView.hidden = YES;
    cell.lblLatencyResult.hidden = NO;
    cell.lblLossResult.hidden = NO;
    cell.lblJitterResult.hidden = NO;
    cell.lblLatencyResult.text = resLatency;
    cell.lblLossResult.text = resLoss;
    cell.lblJitterResult.text = resJitter;
  }
  
  [self updateResultsArray:[NSNumber numberWithBool:NO] key:@"HIDE_LABEL" testType:@"latency"];
  [self updateResultsArray:[NSNumber numberWithBool:YES] key:@"HIDE_SPINNER" testType:@"latency"];
  [self updateResultsArray:resLatency key:@"RESULT_1" testType:@"latency"];
  [self updateResultsArray:resLoss key:@"RESULT_2" testType:@"latency"];
  [self updateResultsArray:resJitter key:@"RESULT_3" testType:@"latency"];
}

- (void)aodLatencyTestUpdateStatus:(LatencyStatus)status
{
  //NSLog(@"aodLatencyTestUpdateStatus");
}

- (void)aodLatencyTestWasCancelled
{
  NSIndexPath *ixp = [self getIndexPathForTest:@"latency"];
  SKALatencyTestCell *cell = (SKALatencyTestCell*)[self.tableView cellForRowAtIndexPath:ixp];
  
  NSString *statusString = [SKTransferOperation getStatusFailed];
  if (autoTest.udpClosestTargetTestSucceeded == NO) {
    statusString = sSKCoreGetLocalisedString(@"UDP blocked");
  }
  
  if (nil != cell)
  {
    cell.latencyProgressView.hidden = YES;
    cell.lossProgressView.hidden = YES;
    cell.jitterProgressView.hidden = YES;
    cell.lblLatencyResult.hidden = NO;
    cell.lblLossResult.hidden = NO;
    cell.lblJitterResult.hidden = NO;
    cell.lblLatencyResult.text = statusString;
    cell.lblLossResult.text = statusString;
    cell.lblJitterResult.text = statusString;
  }
  
  [self updateResultsArray:[NSNumber numberWithBool:NO] key:@"HIDE_LABEL" testType:@"latency"];
  [self updateResultsArray:[NSNumber numberWithBool:YES] key:@"HIDE_SPINNER" testType:@"latency"];
  [self updateResultsArray:statusString key:@"RESULT_1" testType:@"latency"];
  [self updateResultsArray:statusString key:@"RESULT_2" testType:@"latency"];
  [self updateResultsArray:statusString key:@"RESULT_3" testType:@"latency"];
}

- (void)aodLatencyTestUpdateProgress:(float)progress latency:(float)latency
{
  dispatch_async(dispatch_get_main_queue(), ^{
    
    NSIndexPath *ixp = [self getIndexPathForTest:@"latency"];
    SKALatencyTestCell *cell = (SKALatencyTestCell*)[self.tableView cellForRowAtIndexPath:ixp];
    
    if (nil != cell)
    {
      SK_ASSERT([NSThread isMainThread]);
      [cell.latencyProgressView setProgress:progress/100 animated:YES];
      [cell.lossProgressView setProgress:progress/100 animated:YES];
      [cell.jitterProgressView setProgress:progress/100 animated:YES];
    }
    
    [self updateResultsArray:[NSNumber numberWithFloat:progress] key:@"PROGRESS" testType:@"latency"];
  });
}

// TRANSFER //////////////////////////////////////////////////////

- (void)aodTransferTestDidStart:(BOOL)isDownstream
{
  
}

- (void)aodTransferTestDidUpdateProgress:(float)progress isDownstream:(BOOL)isDownstream bitrate1024Based:(double)bitrate1024Based
{
  dispatch_async(dispatch_get_main_queue(), ^{
    
    NSString *test = isDownstream ? @"downstreamthroughput" : @"upstreamthroughput";
    NSIndexPath *ixp = [self getIndexPathForTest:test];
    SKATransferTestCell *cell = (SKATransferTestCell*)[self.tableView cellForRowAtIndexPath:ixp];
    
#ifdef DEBUG
    static int sDebugLastValue = 0;
    if ( ((int)progress) != sDebugLastValue) {
      NSLog(@"DEBUG: aodTransferTestDidUpdateProgress, test=%@, progress=%g", test, progress);
      sDebugLastValue = (int) progress;
    }
#endif // DEBUG
    
    if (nil != cell)
    {
      [cell.progressView setProgress:(progress/100.0F) animated:YES];
    }
    
    [self updateResultsArray:[NSNumber numberWithFloat:progress] key:@"PROGRESS" testType:test];
  });
}

- (void)aodTransferTestDidFail:(BOOL)isDownstream
{
  dispatch_async(dispatch_get_main_queue(), ^{
    
    NSString *test = isDownstream ? @"downstreamthroughput" : @"upstreamthroughput";
    
#ifdef DEBUG
    NSLog(@"%s aodTransferTestDidFail : %@", __FUNCTION__, test);
#endif // DEBUG
    
    NSIndexPath *ixp = [self getIndexPathForTest:test];
    SKATransferTestCell *cell = (SKATransferTestCell*)[self.tableView cellForRowAtIndexPath:ixp];
    
    if (nil != cell)
    {
      cell.lblResult.hidden = NO;
      cell.lblResult.text = [SKTransferOperation getStatusFailed];
      cell.progressView.hidden = YES;
    }
    
    [self updateResultsArray:[NSNumber numberWithBool:NO] key:@"HIDE_LABEL" testType:test];
    [self updateResultsArray:[NSNumber numberWithBool:YES] key:@"HIDE_SPINNER" testType:test];
    [self updateResultsArray:[SKTransferOperation getStatusFailed] key:@"RESULT_1" testType:test];
    
    [self stopTestFromAlertResponse:NO];
    testsComplete = YES;
  });
}

- (void)aodTransferTestDidCompleteTransfer:(SKHttpTest*)httpTest Bitrate1024Based:(double)bitrate1024Based
{
  dispatch_async(dispatch_get_main_queue(), ^{
    
    BOOL isDownstream = httpTest.isDownstream;
    
    NSString *result = [SKGlobalMethods bitrateMbps1024BasedToString:bitrate1024Based];
    
    NSString *test = isDownstream ? @"downstreamthroughput" : @"upstreamthroughput";
    
    NSLog(@"************ DEBUG: aodTransferTestDidCompleteTransfer - test=%@, bitrate=%@", test, result);
    
    NSIndexPath *ixp = [self getIndexPathForTest:test];
    SKATransferTestCell *cell = (SKATransferTestCell*)[self.tableView cellForRowAtIndexPath:ixp];
    
    if (cell == nil)
    {
      // This will occur if the cell is scrolled out of view (so the cell doesn't currently exist in the UI)
      // But for now, show a warning in the debugger just in case this is a symptom of something else.
      SK_ASSERT(false);
    }
    else
    {
      SK_ASSERT([NSThread isMainThread]);
      [cell.progressView setProgress:1 animated:YES];
      cell.lblResult.hidden = NO;
      cell.progressView.hidden = YES;
      cell.lblResult.text = result;
    }
    
    [self updateResultsArray:[NSNumber numberWithFloat:100] key:@"PROGRESS" testType:test];
    [self updateResultsArray:[NSNumber numberWithBool:NO] key:@"HIDE_LABEL" testType:test];
    [self updateResultsArray:[NSNumber numberWithBool:YES] key:@"HIDE_SPINNER" testType:test];
    [self updateResultsArray:result key:@"RESULT_1" testType:test];
  });
}

// ALL TESTS COMPLETE

- (void)aodAllTestsComplete
{
  dispatch_async(dispatch_get_main_queue(), ^{
    
    testsComplete = YES;
    
    [self setEndDataUsage];
    
    SK_ASSERT([NSThread isMainThread]);
    [self.tableView reloadData];
    
    [[self delegate] refreshGraphsAndTableData];
    [self.spinnerMain stopAnimating];
    
    if (self.continuousTesting == YES) {
      // Keep going!
      [self startToRunTheTests:YES];
    }
  });
}

- (void)aodDidStartTargetTesting {}
- (void)aodDidFinishAnotherTarget:(int)targetId withLatency:(double)latency withBest:(int)bestId {}

#pragma mark - Actions

- (void)stopTestFromAlertResponse:(BOOL)fromAlertResponse {
  if (testsComplete) {
    return;
  }
  
  if (nil != autoTest)
  {
    [autoTest stopTheTests];
  }
  
  [self cancelCurrentTests];
  [self setEndDataUsage];
  
  SK_ASSERT([NSThread isMainThread]);
  [self.tableView reloadData];
  
  [self.spinnerMain stopAnimating];
  testsComplete = YES;
  
  if ([appDelegate getIsConnected] == NO) {
    // On test stopped - if not connected, display an alert.
    // This covers e.g. if we lost connection and tests stopped automatically.
    // It will also stop a test re-running in the event of continuous testing.
    
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:nil
                               message:sSKCoreGetLocalisedString(@"Offline_message")
                              delegate:nil
                     cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_OK")
                     otherButtonTitles: nil];
    
    [alert show];
    
    return;
  }
  
  if (self.continuousTesting) {
    if (fromAlertResponse == NO) {
      // Stopped the test automatically for some reason - start the test going again!
      [self startToRunTheTests:YES];
    }
  }
}

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (buttonIndex != alertView.cancelButtonIndex) {
    // OK button pressed - try to stop the tests!
    [self stopTestFromAlertResponse:YES];
    if (self.continuousTesting == YES) {
      // In continuous testing mode, stopping the test automatically dismisses the view controller.
      [self dismissViewControllerAnimated:YES completion:nil];
    } else {
      // Tidy-up immediately.
      [autoTest stopTheTests];
      autoTest = nil;
    }
  }
}

-(BOOL) isTestStillRunningIfYesShowAlert {
  if (autoTest != nil)
  {
    if (autoTest.isRunning)
    {
      if (self.continuousTesting) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:sSKCoreGetLocalisedString(@"Continuous_Tests_Running_Title")
                              message:sSKCoreGetLocalisedString(@"Continuous_Tests_Running_Message")
                              delegate:self
                              cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")
                              otherButtonTitles:sSKCoreGetLocalisedString(@"MenuAlert_OK"),
                              nil];
        [alert show];
        
      } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:sSKCoreGetLocalisedString(@"Tests_Running_Title")
                              message:sSKCoreGetLocalisedString(@"Tests_Running_Message")
                              delegate:self
                              cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")
                              otherButtonTitles:sSKCoreGetLocalisedString(@"MenuAlert_OK"),
                              nil];
        [alert show];
      }
      
      return YES;
    }
  }
  
  return NO;
}

- (IBAction)done:(id)sender
{
  if ([self isTestStillRunningIfYesShowAlert]) {
    return;
  }
  
  if ([self.networkType isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
    if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isNetworkTypeWiFi]) {
      [[SKAMainResultsController getSKAMainResultsController] setNetworkTypeTo:self.networkType];
    }
  } else if ([self.networkType isEqualToString:C_NETWORKTYPEASSTRING_WIFI]) {
    if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isNetworkTypeMobile]) {
      [[SKAMainResultsController getSKAMainResultsController] setNetworkTypeTo:self.networkType];
    }
  } else {
    SK_ASSERT(false);
  }
  
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Methods

- (void)startBackgroundTask {
  btid = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    if (btid != UIBackgroundTaskInvalid) {
      [[UIApplication sharedApplication] endBackgroundTask:btid];
      btid = UIBackgroundTaskInvalid;
    }
  }];
}

- (void)finishBackgroundTask {
  if (btid != UIBackgroundTaskInvalid) {
    [[UIApplication sharedApplication] endBackgroundTask:btid];
    btid = UIBackgroundTaskInvalid;
  }
}

- (void)cancelCurrentTests
{
  [self updateResultsArray:[SKLatencyOperation getCancelledStatus] key:@"STATUS" testType:@"closestTarget"];
  
  NSArray *testTypes = [NSArray arrayWithObjects:@"latency", @"downstreamthroughput", @"upstreamthroughput", nil];
  
  for (int j=0; j<[testTypes count]; j++)
  {
    NSString *testType = [testTypes objectAtIndex:j];
    NSIndexPath *ixp = [self getIndexPathForTest:testType];
    
    if ([testType isEqualToString:@"latency"])
    {
      SKALatencyTestCell *cell = (SKALatencyTestCell*)[self.tableView cellForRowAtIndexPath:ixp];
      
      if (nil != cell)
      {
        BOOL updateResults = NO;
         
        NSString *statusString = [SKLatencyOperation getFailedStatus];
        if (autoTest.udpClosestTargetTestSucceeded == NO) {
          statusString = sSKCoreGetLocalisedString(@"UDP blocked");
        }
 
        if (cell.lblLatencyResult.hidden)
        {
          cell.lblLatencyResult.text = statusString;
          cell.lblLatencyResult.hidden = NO;
          cell.latencyProgressView.hidden = YES;
          updateResults = YES;
        }
        
        if (cell.lblLossResult.hidden)
        {
          cell.lblLossResult.text = statusString;
          cell.lblLossResult.hidden = NO;
          cell.lossProgressView.hidden = YES;
          updateResults = YES;
        }
        
        if (cell.lblJitterResult.hidden)
        {
          cell.lblJitterResult.text = statusString;
          cell.lblJitterResult.hidden = NO;
          cell.jitterProgressView.hidden = YES;
          updateResults = YES;
        }
        
        if (updateResults)
        {
          NSLog(@"updateResults");
          [self updateResultsArray:statusString key:@"RESULT_1" testType:testType];
          [self updateResultsArray:statusString key:@"RESULT_2" testType:testType];
          [self updateResultsArray:statusString key:@"RESULT_3" testType:testType];
          [self updateResultsArray:[NSNumber numberWithBool:NO] key:@"HIDE_LABEL" testType:testType];
          [self updateResultsArray:[NSNumber numberWithBool:YES] key:@"HIDE_SPINNER" testType:testType];
        }
      }
    }
    else
    {
      SKATransferTestCell *cell = (SKATransferTestCell*)[self.tableView cellForRowAtIndexPath:ixp];
      
      if (nil != cell)
      {
        if (cell.lblResult.hidden)
        {
          cell.lblResult.text = [SKLatencyOperation getFailedStatus];
          cell.lblResult.hidden = NO;
          cell.progressView.hidden = YES;
          
          [self updateResultsArray:[SKLatencyOperation getFailedStatus] key:@"RESULT_1" testType:testType];
          [self updateResultsArray:[SKLatencyOperation getFailedStatus] key:@"RESULT_2" testType:testType];
          [self updateResultsArray:[NSNumber numberWithBool:NO] key:@"HIDE_LABEL" testType:testType];
          [self updateResultsArray:[NSNumber numberWithBool:YES] key:@"HIDE_SPINNER" testType:testType];
        }
      }
    }
  }
}

- (void)statusChanged:(NSNotification*)notification
{
  [self setConnectionStatus];
}

- (void)setConnectionStatus
{
  if (appDelegate.connectionStatus == NONE)
  {
    
    if (nil != autoTest)
    {
      [autoTest stopTheTests];
    }
    testsComplete = YES;
    
    [self setEndDataUsage];
    [self cancelCurrentTests];
    [[self delegate] refreshGraphsAndTableData];
    [self.spinnerMain stopAnimating];
  }
}

- (NSIndexPath*)getIndexPathForTest:(NSString*)testType
{
  int index = 0;
  BOOL bFound = NO;
  
  for (NSDictionary *dict in self.resultsArray)
  {
    if ([[dict objectForKey:@"TYPE"] isEqualToString:testType])
    {
      bFound = YES;
      break;
    }
    
    index++;
  }
  
#ifdef DEBUG
  //NSLog(@"DEBUG: getIndexPathForTest, testType=%@ index%d", testType, index);
#endif // DEBUG
  
  if (bFound == NO) {
#ifdef DEBUG
    NSLog(@"DEBUG: getIndexPathForTest, testType=%@, not found!", testType);
#endif // DEBUG
    return nil;
  }
  
  NSIndexPath *ixp = [NSIndexPath indexPathForRow:index inSection:0];
  SK_ASSERT(ixp != nil);
  
  return ixp;
}

- (BOOL)testIsIncluded:(NSString*)type
{
  if (self.testType == ALL_TESTS)
  {
    return YES;
  }
  else
  {
    if (self.testType == DOWNLOAD_TEST && [type isEqualToString:@"downstreamthroughput"])
    {
      return YES;
    }
    else if (self.testType == UPLOAD_TEST && [type isEqualToString:@"upstreamthroughput"])
    {
      return YES;
    }
    else if (self.testType == LATENCY_TEST && [type isEqualToString:@"latency"])
    {
      return YES;
    }
    else if (self.testType == JITTER_TEST && [type isEqualToString:@"jitter"])
    {
      return YES;
    }
    else {
      //SK_ASSERT(false);
    }
    
  }
  
  return NO;
}

- (void)createDefaultResults
{
  NSArray *tests = appDelegate.schedule.tests;
  
  if (nil != tests)
  {
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    for (int j=0; j<[tests count]; j++)
    {
      NSDictionary *dict = [tests objectAtIndex:j];
      
      NSString *type = [dict objectForKey:@"type"];
      
      if (![type isEqualToString:@"closestTarget"] && [self testIsIncluded:type])
      {
        NSString *displayName = [dict objectForKey:@"displayName"];
        if (displayName == nil) {
          // Defend against this being nil, as otherwise the dictionary setObject would fail.
          SK_ASSERT(false);
          displayName = @"";
        }
        
        NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
        [tmpDict setObject:type forKey:@"TYPE"];
        [tmpDict setObject:@"" forKey:@"RESULT_1"];
        [tmpDict setObject:@"" forKey:@"RESULT_2"];
        [tmpDict setObject:@"" forKey:@"RESULT_3"];
        [tmpDict setObject:displayName forKey:@"DISPLAY_NAME"];
        [tmpDict setObject:[NSNumber numberWithFloat:0] forKey:@"PROGRESS"];
        [tmpDict setObject:[NSNumber numberWithBool:NO] forKey:@"HIDE_SPINNER"];
        [tmpDict setObject:[NSNumber numberWithBool:YES] forKey:@"HIDE_LABEL"];
        NSString* idleStatus = [SKLatencyOperation getIdleStatus];
        if (idleStatus == nil) {
          // Defend against this being nil, as otherwise the dictionary setObject would fail.
          // On some devices, this has been nil for some unexplained reason!
          SK_ASSERT(false);
          idleStatus = @"Idle";
        }
        [tmpDict setObject:idleStatus forKey:@"STATUS"];
        
        float height = 100.0F;
        if ( ([type isEqualToString:@"downstreamthroughput"]) ||
            ([type isEqualToString:@"upstreamthroughput"]) ) {
          height = 59.0F;
        } else {
          // Latency/loss/jitter!
          if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsJitterSupported]) {
            height = 150;
          }
        }
        
        // SKAInformationCell - 49, SKATransferTestCell - 59, SKALatencyTestCell - 100!
        [tmpDict setObject:[NSNumber numberWithFloat:height] forKey:@"HEIGHT"];
        
        
        [tmpArray addObject:tmpDict];
      }
    }
    
    self.resultsArray = tmpArray;
  }
}

- (void)setStartDataUsage
{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  dataStart = 0;
  
  if ([prefs valueForKey:[SKAppBehaviourDelegate sGet_Prefs_DataUsage]])
  {
    NSNumber *num = [prefs objectForKey:[SKAppBehaviourDelegate sGet_Prefs_DataUsage]];
    dataStart = [num longLongValue];
  }
  else
  {
    [prefs setValue:[NSNumber numberWithLongLong:0] forKey:[SKAppBehaviourDelegate sGet_Prefs_DataUsage]];
    [prefs synchronize];
  }
}

- (void)setEndDataUsage
{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  dataEnd = 0;
  
  if ([prefs valueForKey:[SKAppBehaviourDelegate sGet_Prefs_DataUsage]])
  {
    NSNumber *num = [prefs objectForKey:[SKAppBehaviourDelegate sGet_Prefs_DataUsage]];
    dataEnd = [num longLongValue];
  }
  
  [self calculateDataUsed];
}

- (void)calculateDataUsed
{
  //int64_t totalData = dataEnd - dataStart;
  
  //NSLog(@"Total Data Used : %d", totalData);
}

#pragma mark - View Cycle

// http://stackoverflow.com/questions/26147424/crash-in-uitableview-sending-message-to-deallocated-uiviewcontroller
- (void)dealloc {
  self.tableView.dataSource = nil;
  self.tableView.delegate = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StatusChanged" object:nil];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isSocialMediaExportSupported] == NO) {
    // Hide the toolbar, if social media export not supported!
    [self.navigationController setToolbarHidden:YES];
  }
  
  self.networkType = [SKGlobalMethods getNetworkTypeString];
  
  appDelegate = [SKAppBehaviourDelegate sGetAppBehaviourDelegate];
  
  dataStart = 0;
  dataEnd = 0;
  
  [self setLabelsOnViewLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(statusChanged:)
                                               name:@"StatusChanged"
                                             object:nil];
}

-(void) startToRunTheTests:(BOOL)fromContinuedTest {
  
  testsComplete = NO;
  
  if ((fromContinuedTest == NO) && ([appDelegate getIsConnected] == NO))
  {
    // User tried to kick-off tests, but we're not connected.
    testsComplete = YES;
  }
  else
  {
    if (sbViewIsVisible == NO)
    {
      // We're no longer visible - don't auto-run!
#ifdef DEBUG
      NSLog(@"DEBUG: SKARunTestController is no longer visible - don't auto-run the test!");
#endif // DEBUG
      return;
    }
    
    if ([appDelegate getIsConnected] == NO) {
      // We're not actually connected - don't run any tests until we are!
      [self.lblClosest setText:sSKCoreGetLocalisedString(@"ConnectionString_Offline")];
      [self.tableView reloadData];
      [self.spinnerMain startAnimating];
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startToRunTheTests:YES];
        // This prevents us from getting lots of dangling file handles!
      });
      return;
    }
    
    // Either user tried to kick-off tests when connected, or we're continuing a continuous test.
    // Handle this as a separate task, to prevent recursion, as we're running this from WITHIN a test.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      
      [self setStartDataUsage];
      [self createDefaultResults];
      
      SK_ASSERT([NSThread isMainThread]);
      [self.tableView reloadData];
      
      [self.spinnerMain startAnimating];
      
      // Defend against running tests more than once, simultaneously!
      if (autoTest != nil) {
        [autoTest stopTheTests];
        autoTest = nil;
      }
      
      autoTest = [[SKAutotest alloc] initAndRunWithAutotestManagerDelegate:appDelegate AndAutotestObserverDelegate:self AndTestType:self.testType IsContinuousTesting:self.continuousTesting];
    });
  }
  
}

static BOOL sbViewIsVisible;

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  sbViewIsVisible = YES;
  
  [self startToRunTheTests:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(udpTestFailedSkipTests:) name:kSKAAutoTest_UDPFailedSkipTests object: nil];
 
  self.networkType = [SKGlobalMethods getNetworkTypeString];
#ifdef DEBUG
  if (self.continuousTesting == YES) {
    SK_ASSERT([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] supportContinuousTesting]);
    
    // TODO - continuous testing - keep on running until Done pressed!!
  }
#endif // DEBUG
  
  [self setConnectionStatus];
  
  self.navigationController.navigationBarHidden = NO;
}

- (void)udpTestFailedSkipTests:(NSNotification*)note {
  [self showFailedLatencyTest];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kSKAAutoTest_UDPFailedSkipTests object:nil];
  
  sbViewIsVisible = NO;
 
  // Tidy-up!
  [autoTest stopTheTests];
  autoTest = nil;
}


- (void)setLabelsOnViewLoad {
 
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsThisTheNewApp] == YES) {
    SK_ASSERT(false);
  } else {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,45,45)];
    label.font = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getSpecialFontOfSize:17];
    label.textColor = [UIColor blackColor];
    
    label.backgroundColor = [UIColor clearColor];
    label.text = sSKCoreGetLocalisedString(@"TEST_Title");
    [label sizeToFit];
    self.navigationItem.titleView = label;
  }
  
  NSString *txt = (self.testType == ALL_TESTS) ?
  sSKCoreGetLocalisedString(@"TEST_Label_Multiple") :
  sSKCoreGetLocalisedString(@"TEST_Label_Single");
  
  [self.lblMain setText:txt];
  
  self.lblClosest.text = @"";
  
  self.lblClosest.adjustsFontSizeToFitWidth = YES;
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  int row = (int)indexPath.row;
  int section = (int)indexPath.section;
  
  if (section == 0)
  {
    NSDictionary *dict = (NSDictionary*)[self.resultsArray objectAtIndex:row];
    
    float height = [[dict objectForKey:@"HEIGHT"] floatValue];
    
    SK_ASSERT(height == 59 || height == 100 || height == 150);
    
    if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsJitterSupported]) {
      if (height == 100) {
        height = 150;
      }
    }
    
    return height;
  }
  else
  {
    // Information cell!
    return 59.0f;
  }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  switch (section) {
    case 0:
      SK_ASSERT(self.networkType != nil);
      if ([self.networkType isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
        return sSKCoreGetLocalisedString(@"ResultsTestHeader_ActiveMetrics_Mobile");
      }
      return sSKCoreGetLocalisedString(@"ResultsTestHeader_ActiveMetrics_WiFi");
      
    case 1:
    default:
      return sSKCoreGetLocalisedString(@"ResultsTestHeader_PassiveMetrics");
  }
  
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Active Metrics
  // Passive Metrics - only if currently on "Mobile" network
  
  SK_ASSERT(self.networkType != nil);
  if ([self.networkType isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
    return 2;
  }
  
  // Otherwise, show just active metrics.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0)
  {
    if (nil != self.resultsArray)
    {
      // Latency/loss/jitter are ALL ONE RESULT!
#ifdef DEBUG
      NSString *theDescription = [self.resultsArray description];
      NSLog(@"DEBUG: resultsArray = %@", theDescription);
#endif // DEBUG
      return [self.resultsArray count];
    }
    
    return 0;
  }
  else
  {
    // The passive metrics!
    return 7;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  int row = (int)indexPath.row;
  int section = (int)indexPath.section;
  
  if (section == 0)
  {
    NSDictionary *dict = nil;
    
    @synchronized(self)
    {
      dict = [self.resultsArray objectAtIndex:row];
    }
    
    NSString *type = [dict objectForKey:@"TYPE"];
    
    NSString *result1       = [dict objectForKey:@"RESULT_1"];
    NSString *result2       = [dict objectForKey:@"RESULT_2"];
    NSString *result3       = [dict objectForKey:@"RESULT_3"];
    NSString *displayName   = [dict objectForKey:@"DISPLAY_NAME"];
    float progress          = [[dict objectForKey:@"PROGRESS"] floatValue];
    BOOL hideLabel          = [[dict objectForKey:@"HIDE_LABEL"] boolValue];
    BOOL hideSpinner        = [[dict objectForKey:@"HIDE_SPINNER"] boolValue];
    
    if ([type isEqualToString:@"latency"])
    {
      // This is latency, loss... and possibly Jitter, as well!
      static NSString *CellIdentifier = @"SKALatencyTestCell";
      SKALatencyTestCell *cell = (SKALatencyTestCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      if (cell == nil) {
        cell = [[SKALatencyTestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      }
      
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      
      cell.lblLatencyResult.text = result1;
      cell.lblLossResult.text = result2;
      cell.lblJitterResult.text = result3;
      
      cell.lblLatency.text = sSKCoreGetLocalisedString(@"Test_Latency");
      cell.lblLoss.text = sSKCoreGetLocalisedString(@"Test_Loss");
      cell.lblJitter.text = sSKCoreGetLocalisedString(@"Test_Jitter");
      
      SK_ASSERT([NSThread isMainThread]);
      cell.latencyProgressView.progress = progress / 100;
      cell.lossProgressView.progress = progress / 100;
      cell.jitterProgressView.progress = progress / 100;
      
      cell.lblLatencyResult.hidden = hideLabel;
      cell.lblLossResult.hidden = hideLabel;
      cell.latencyProgressView.hidden = hideSpinner;
      cell.lossProgressView.hidden = hideSpinner;
      
      if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsJitterSupported] == NO) {
        cell.lblJitter.hidden = YES;
        cell.lblJitter = nil;
        cell.lblJitterResult = nil;
        cell.jitterProgressView = nil;
        hideLabel = YES;
        hideSpinner = YES;
        cell.jitterProgressView.hidden = YES;
      }
 
      cell.lblJitterResult.hidden = hideLabel;
      cell.jitterProgressView.hidden = hideSpinner;
      
      return cell;
    }
    else if ([type isEqualToString:@"downstreamthroughput"])
    {
      static NSString *CellIdentifier = @"SKATransferTestCell";
      SKATransferTestCell *cell = (SKATransferTestCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      if (cell == nil) {
        cell = [[SKATransferTestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      }
      
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      
      cell.lblResult.text = result1;
      cell.lblTest.text = displayName;
      SK_ASSERT([NSThread isMainThread]);
      cell.progressView.progress = progress / 100;
      cell.lblResult.hidden = hideLabel;
      cell.progressView.hidden = hideSpinner;
      
      return cell;
    }
    else if ([type isEqualToString:@"jitter"])
    {
      SK_ASSERT(false);
      //      static NSString *CellIdentifier = @"SKAJitterTestCell";
      //      SKAJitterTestCell *cell = (SKAJitterTestCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      //      if (cell == nil) {
      //        cell = [[SKAJitterTestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      //      }
      //      
      //      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      //      
      //      cell.lblResult.text = result1;
      //      cell.lblTest.text = displayName;
      //      cell.progressView.progress = progress / 100;
      //      cell.lblResult.hidden = hideLabel;
      //      cell.progressView.hidden = hideSpinner;
      
      return nil;
    }
    else
    {
      static NSString *CellIdentifier = @"SKATransferTestCell";
      SKATransferTestCell *cell = (SKATransferTestCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      if (cell == nil) {
        cell = [[SKATransferTestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      }
      
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      
      cell.lblResult.text = result1;
      cell.lblTest.text = displayName;
      SK_ASSERT([NSThread isMainThread]);
      cell.progressView.progress = progress / 100;
      cell.lblResult.hidden = hideLabel;
      cell.progressView.hidden = hideSpinner;
      
      return cell;
    }
  }
  else
  {
    static NSString *CellIdentifier = @"SKAInformationCell";
    SKAInformationCell *cell = (SKAInformationCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[SKAInformationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (row == 0)
    {
      cell.lblTitle.text = sSKCoreGetLocalisedString(@"Network_Type");
      cell.lblDetail.text = sSKCoreGetLocalisedString(@"Unknown");
      SK_ASSERT(self.networkType != nil);
      if ([self.networkType isEqualToString:C_NETWORKTYPEASSTRING_WIFI]) {
        cell.lblDetail.text = sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi");
      } else if ([self.networkType isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
        NSString *mobileString = sSKCoreGetLocalisedString(@"NetworkTypeMenu_Mobile");
        
        NSString *radioType = [SKGlobalMethods getNetworkType];
        NSString *theRadio = [SKGlobalMethods getNetworkTypeLocalized:radioType];
        if ([theRadio isEqualToString:sSKCoreGetLocalisedString(@"CTRadioAccessTechnologyUnknown")]) {
          cell.lblDetail.text = mobileString;
        } else {
          cell.lblDetail.text = [NSString stringWithFormat:@"%@ (%@)", mobileString, theRadio];
        }
      }
    }
    else if (row == 1)
    {
      cell.lblTitle.text = sSKCoreGetLocalisedString(@"Carrier_Name");
      cell.lblDetail.text = appDelegate.carrierName;
    }
    else if (row == 2)
    {
      cell.lblTitle.text = sSKCoreGetLocalisedString(@"Carrier_Country");
      cell.lblDetail.text = appDelegate.countryCode;
    }
    else if (row == 3)
    {
      cell.lblTitle.text = sSKCoreGetLocalisedString(@"Carrier_Network");
      cell.lblDetail.text = appDelegate.networkCode;
    }
    else if (row == 4)
    {
      cell.lblTitle.text = sSKCoreGetLocalisedString(@"Carrier_ISO");
      cell.lblDetail.text = appDelegate.isoCode;
    }
    else if (row == 5)
    {
      cell.lblTitle.text = sSKCoreGetLocalisedString(@"Phone");
      cell.lblDetail.text = [SKAArchivedResultsController platformString:appDelegate.deviceModel];
    }
    else if (row == 6)
    {
      cell.lblTitle.text = sSKCoreGetLocalisedString(@"OS");
      cell.lblDetail.text = [[UIDevice currentDevice] systemVersion];
    }
    else
    {
      SK_ASSERT(false);
    }
    
    return cell;
  }
}

-(NSString*) getTextForSocialMedia:(NSString*)socialNetwork {
  
  NSIndexPath *ixpDownload = [self getIndexPathForTest:@"downstreamthroughput"];
  SKATransferTestCell *cellDownload = (SKATransferTestCell*)[self.tableView cellForRowAtIndexPath:ixpDownload];
  NSIndexPath *ixpUpload = [self getIndexPathForTest:@"upstreamthroughput"];
  SKATransferTestCell *cellUpload = (SKATransferTestCell*)[self.tableView cellForRowAtIndexPath:ixpUpload];
  //  NSIndexPath *ixpLatencyLoss = [self getIndexPathForTest:@"latency"];
  //  SKALatencyTestCell *cellLatencyLoss = (SKALatencyTestCell*)[self.tableView cellForRowAtIndexPath:ixpLatencyLoss];
  
  NSString *download = nil;
  NSString *upload = nil;
  
  if (cellDownload.lblResult.hidden == NO)
  {
    download = cellDownload.lblResult.text;
  }
  
  if (cellUpload.lblResult.hidden == NO)
  {
    upload = cellUpload.lblResult.text;
  }
  
  //
  // Build-up the message!
  //
  
  return [SKAppBehaviourDelegate sBuildSocialMediaMessageForCarrierName:appDelegate.carrierName SocialNetwork:socialNetwork Upload:upload Download:download ThisDataIsAveraged:NO];
}

- (IBAction)actionButton:(id)sender {
  if ([self isTestStillRunningIfYesShowAlert]) {
    return;
  }
  
  if (![self.networkType isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
    UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:sSKCoreGetLocalisedString(@"Title_ShareUsingSocialMediaMobile")
     message:sSKCoreGetLocalisedString(@"Message_ShareUsingSocialMediaMobile")
     delegate:nil
     cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_OK")
     otherButtonTitles:nil];
    [alert show];
    return;
  }
  
  NSString *twitterString = [self getTextForSocialMedia:(NSString*)SLServiceTypeTwitter];
  NSString *facebookString = [self getTextForSocialMedia:(NSString*)SLServiceTypeFacebook];
  NSString *sinaWeiboString = [self getTextForSocialMedia:(NSString*)SLServiceTypeSinaWeibo];
  NSDictionary *dictionary = @{SLServiceTypeTwitter:twitterString, SLServiceTypeFacebook:facebookString, SLServiceTypeSinaWeibo:sinaWeiboString};
  
  // TODO - how do we extract the network type?!
  [SKAppBehaviourDelegate showActionSheetForSocialMediaExport:dictionary OnViewController:self];
}

@end
