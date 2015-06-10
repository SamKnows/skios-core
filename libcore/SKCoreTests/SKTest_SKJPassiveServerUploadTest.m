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
    SKAppBehaviourDelegate *ignore = [[SKAppBehaviourDelegate alloc] init];
  }
  
  // Set-up code here.
}

- (void)tearDown
{
  // Tear-down code here.
  
  [super tearDown];
}

- (void)testIt
{
  XCTAssertTrue(true);
  
  NSDictionary *paramDictionary = @{
                                    TARGET: @"samknows1.dal1.level3.net",
                                    PORT: @"8080",
                                    WARMUPMAXTIME: @"5000000",
                                    WARMUPMAXBYTES: @"2621440",
                                    TRANSFERMAXTIME: @"15000000",
                                    TRANSFERMAXBYTES: @"20971520",
                                    NTHREADS: @"3",
                                    BUFFERSIZE: @"512",
                                    SENDBUFFERSIZE: @"512",
                                    RECEIVEBUFFERSIZE: @"",
                                    SENDDATACHUNK: @"512",
                                    POSTDATALENGTH: @"10485760"};
  __block SKJPassiveServerUploadTest *theTest = [[SKJPassiveServerUploadTest alloc] initWithParams:paramDictionary];
  
  //XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];

  //Start an activity indicator here
  __block BOOL bStopNowFlag = false;
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    //Call your function or whatever work that needs to be done
    //Code in this part is run on a background thread
    [theTest execute];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      
      //Stop your activity indicator or anything else with the GUI
      //Code here is run on the main thread
      bStopNowFlag = true;
      //[expectation fulfill];
    });
  });

  const double cMaxTime = 60.0;
  NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:cMaxTime];
  
  for (;;) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    if ([timeoutDate timeIntervalSinceNow] < 0.0) {
      NSLog(@"**** TEST Timeout!!");
      break;
    }
    
    double uploadSpeed = [theTest getTransferBytesPerSecond];
    NSLog(@"****** TEST uploadSpeed=%g", uploadSpeed);
    
    if (bStopNowFlag == true) {
      break;
    }
  }

//  [self waitForExpectationsWithTimeout:cMaxTime handler:^(NSError *error) {
//    if (error) {
//      NSLog(@"**** TEST Timeout Error: %@", error);
//    }
//  }];
  
  double uploadSpeed = [theTest getTransferBytesPerSecond];
  NSLog(@"****** TEST uploadSpeed=%g AT END!", uploadSpeed);
  
  NSLog(@"Done!");
  [NSThread sleepForTimeInterval:1.0];
}

@end
