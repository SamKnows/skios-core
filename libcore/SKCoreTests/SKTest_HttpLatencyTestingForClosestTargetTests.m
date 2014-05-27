//
//  SKTest_HttpLatencyTestingForClosestTargetTests.m
//  SKTest_HttpLatencyTestingForClosestTargetTests
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "SKCore.h"

@interface SKClosestTargetTest(TheTest)
// This method is OVERRIDDEN for mock testing.
-(void) fireAsyncHttpQueryForHttpLatencyTest:(NSString*)urlString Callback:(SKQueryCompleted)callback;

// This (private) method is called directly by the mock test - to verify that it works!
-(void) tryHttpClosestTargetTestIfUdpTestFails;
@end

// Store the result here
static NSString *GpSelectedTestTarget = @"";
static double    GSelectedTestTargetLatency = 0.0;
static int    GSelectedAsyncQueryCount = 0;

// If the HTTP queries are supposed to succeed, or not.
static bool  GbShouldHttpQueriesSucceed = true;


@implementation SKClosestTargetTest(TheTest)

-(void) fireAsyncHttpQueryForHttpLatencyTest:(NSString*)urlString Callback:(SKQueryCompleted)callback {
  
  GSelectedAsyncQueryCount++;
  
  NSError *error = nil;
  NSInteger responseCode = 200;
  NSMutableData *responseData = nil;
  NSString *responseDataAsString = @"wow";
  NSDictionary *responseHeaders = nil;
  
  // Always take a short sleep time, as this simulates a slight delay.
  // Randomize this value, to give a delay between 0.01 and 0.06 second.
  double sleepSeconds = ((double)(1 + (rand() % 5))) * 0.01;
  SK_ASSERT(sleepSeconds >= 0.01);
  SK_ASSERT(sleepSeconds <= 0.06);
  
  [NSThread sleepForTimeInterval:sleepSeconds];
  
  if (GbShouldHttpQueriesSucceed == false) {
    error = [NSError errorWithDomain:@"world" code:200 userInfo:nil];
  }
  
  callback(error, responseCode, responseData, responseDataAsString, responseHeaders);
}

@end

@interface SKTest_HttpLatencyTestingForClosestTargetTests : XCTestCase

@end

@implementation SKTest_HttpLatencyTestingForClosestTargetTests

- (void)setUp
{
  [super setUp];
  
  GpSelectedTestTarget = @"";
  GSelectedTestTargetLatency = 0.0;
  GSelectedAsyncQueryCount = 0;
  GbShouldHttpQueriesSucceed = true;
}

- (void)tearDown
{
  [super tearDown];
}

#pragma mark SKClosestTargetDelegate (begin)

- (void)ctdDidCompleteClosestTargetTest:(NSString*)target latency:(double)latency {
  SK_ASSERT(GbShouldHttpQueriesSucceed == true);
  
  NSLog(@"TEST: ctdDidCompleteClosestTargetTest:(NSString*)target latency:(double)latency");
  SK_ASSERT(target != nil);
  SK_ASSERT(target.length > 0);
  SK_ASSERT(latency > 0.0);

  // Store the test results, these are asserted separately...
  GpSelectedTestTarget = target;
  GSelectedTestTargetLatency = latency;
}

- (void)ctdTestDidFail {
  NSLog(@"TEST: ctdTestDidFail");
  SK_ASSERT(GbShouldHttpQueriesSucceed == false);
}

- (void)ctdDidSendPacket:(NSUInteger)bytes {
  NSLog(@"TEST: ctdDidSendPacket:(NSUInteger)bytes");
  SK_ASSERT(false);
}

#pragma mark SKClosestTargetDelegate (end)

-(void)doTestLatencyOperationSuccess:(NSArray*)testTargets {
 
  SKClosestTargetTest *closestTargetTest = [[SKAClosestTargetTest alloc]
                                            initWithTargets:testTargets ClosestTargetDelegate:self NumDatagrams:4];
  
  // Test that the methods work as expected.
  [closestTargetTest tryHttpClosestTargetTestIfUdpTestFails];
  
  XCTAssertTrue(GpSelectedTestTarget.length > 0);
  
  // By definition, the tests are supposed to run for 3 times per target!
  XCTAssertTrue(GSelectedAsyncQueryCount == (3 * testTargets.count));
 
  NSString *foundTarget = nil;
  for (NSString *value in testTargets) {
    if ([value isEqualToString:GpSelectedTestTarget]) {
      foundTarget = value;
      break;
    }
  }
  XCTAssertTrue(foundTarget != nil);
  
  XCTAssertTrue(GSelectedTestTargetLatency > 0.0);
}

-(void)testLatencyOperationSuccessOneTarget {
  
  NSArray *testTargets = @[@"http://target1"];
  [self doTestLatencyOperationSuccess:testTargets];
}

-(void)testLatencyOperationSuccessThreeTargets {
  
  NSArray *testTargets = @[@"http://target1", @"http://target2", @"http://target3"];
  [self doTestLatencyOperationSuccess:testTargets];
}


-(void)doTestLatencyOperationFail:(NSArray*)testTargets {
  
  GbShouldHttpQueriesSucceed = false;
  
  SKClosestTargetTest *closestTargetTest = [[SKAClosestTargetTest alloc]
                                            initWithTargets:testTargets ClosestTargetDelegate:self NumDatagrams:4];
  
  // Test that the methods work as expected.
  [closestTargetTest tryHttpClosestTargetTestIfUdpTestFails];
  
  XCTAssertTrue(GpSelectedTestTarget.length == 0);
  XCTAssertTrue(GSelectedTestTargetLatency == 0.0);
}

-(void)testLatencyOperationQueriesFailOneTarget {
  NSArray *testTargets = @[@"http://target1"];
  [self doTestLatencyOperationFail:testTargets];
}

-(void)testLatencyOperationQueriesFailThreeTargets {
  NSArray *testTargets = @[@"http://target1", @"http://target2", @"http://target3"];
  [self doTestLatencyOperationFail:testTargets];
}

@end