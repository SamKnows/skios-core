//
//  SKSchedulerTests.m
//  SKSchedulerTests
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SKJPassiveServerUploadTest.h"

@interface SKTest_SKJPassiveServerUploadTest : XCTestCase

@end

@implementation SKTest_SKJPassiveServerUploadTest

- (void)setUp
{
  [super setUp];
  
  if ([SKAppBehaviourDelegate sGetAppBehaviourDelegateCanBeNil] == nil) {
    __unused SKAppBehaviourDelegate *ignore = [[SKAppBehaviourDelegate alloc] init];
  }
  
  // Set-up code here.
}

- (void)tearDown
{
  // Tear-down code here.
  
  [super tearDown];
}

-(NSDictionary*) getDictionaryForLocalTest {
  NSDictionary *paramDictionary = @{
                                    TARGET: @"nbs3.samknows",
                                    PORT: @"80",
                                    WARMUPMAXTIME: @"2000000",
                                    TRANSFERMAXTIME: @"5000000",
                                    NTHREADS: @"3",
                                    BUFFERSIZE: @"512",
                                    SENDBUFFERSIZE: @"200000", // This can give HIGHER score if > 32768!
                                    RECEIVEBUFFERSIZE: @"32768",
                                    SENDDATACHUNK: @"32768",   // This appears to make no difference
                                    POSTDATALENGTH: @"10485760"};

  return paramDictionary;
}

-(NSDictionary*) getDictionaryForRemoteTest {
  NSDictionary *paramDictionary = @{
                                    TARGET: @"samknows2.nyc2.level3.net",
                                    PORT: @"8080",
                                    WARMUPMAXTIME: @"2000000",
                                    TRANSFERMAXTIME: @"5000000",
                                    NTHREADS: @"3",
                                    BUFFERSIZE: @"512",
                                    SENDBUFFERSIZE: @"200000", // This can give HIGHER score if > 32768!
                                    RECEIVEBUFFERSIZE: @"32768",
                                    SENDDATACHUNK: @"32768",   // This appears to make no difference
                                    POSTDATALENGTH: @"10485760"};

  return paramDictionary;
}

- (void)testIt
{
  XCTAssertTrue(true);
  
  //NSDictionary *paramDictionary = [self getDictionaryForLocalTest];
  NSDictionary *paramDictionary = [self getDictionaryForRemoteTest];
  
  __block SKJPassiveServerUploadTest *theTest = [[SKJPassiveServerUploadTest alloc] initWithParams:paramDictionary];
  
  //XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];

  //Start an activity indicator here
  __block BOOL bStopNowFlag = false;
  
  //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
  
  dispatch_async(queue, ^{
    
    //Call your function or whatever work that needs to be done
    //Code in this part is run on a background thread
    [theTest execute];
    
    bStopNowFlag = true;
  });

  const double cMaxTime = 60.0;
  NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:cMaxTime];
  
  for (;;) {
    sleep(1);
//    //[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
//    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0F]];
    if ([timeoutDate timeIntervalSinceNow] < 0.0) {
#ifdef DEBUG
      NSLog(@"**** DEBUG: TEST Timeout!!");
#endif // DEBUG
      break;
    }
    
    int progress = [theTest getProgress];
    double uploadSpeed = [theTest getTransferBytesPerSecond];
    double uploadSpeedMpbs = [SKJHttpTest sGetLatestSpeedForExternalMonitorAsMbps];
#ifdef DEBUG
    NSLog(@"****** DEBUG: TEST progress=%d, uploadSpeed bytes persec=%g, mbps=%g", progress, uploadSpeed, uploadSpeedMpbs);
#endif // DEBUG
    
    if (bStopNowFlag == true) {
      break;
    }
  }

//  [self waitForExpectationsWithTimeout:cMaxTime handler:^(NSError *error) {
//    if (error) {
//      NSLog(@"**** TEST Timeout Error: %@", error);
//    }
//  }];
  
  int progress = [theTest getProgress];
  double uploadSpeed = [theTest getTransferBytesPerSecond];
  double uploadSpeedMpbs = [SKJHttpTest sGetLatestSpeedForExternalMonitorAsMbps];
#ifdef DEBUG
  NSLog(@"****** DEBUG: TEST progress=%d, uploadSpeed bytes persec=%g, mbps=%g AT END", progress, uploadSpeed, uploadSpeedMpbs);
  
  NSLog(@"DEBUG: SKTest_SKJPassiveServerUploadTest Done!");
#endif // DEBUG
  [NSThread sleepForTimeInterval:1.0];
}

@end
