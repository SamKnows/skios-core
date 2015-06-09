//
//  SKAutotestTests.m
//  SKAutotestTests
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "SKCore.h"

@interface SKLatencyOperation(TheTest)
@property int sentPackets;
@property int sentPacketAttempts;
@property BOOL bDidTimeoutSoIgnoreLastPacket;
-(void) getStats;
- (void)addEndTimes:(long)tag TheDate:(NSDate*)date;
- (void)addStartTimes:(long)tag TheDate:(NSDate*)date;
@end

@interface SKCoreTests : XCTestCase<SKLatencyOperationDelegate>

@end

@implementation SKCoreTests

- (void)setUp
{
  [super setUp];
  if ([SKAppBehaviourDelegate sGetAppBehaviourDelegateCanBeNil] == nil) {[[SKAppBehaviourDelegate alloc] init];}
}


- (void)tearDown
{
  [super tearDown];
}


- (void)testDateQueryAndManipulation {
  
  // Ensure we always start with the standard system date!
  XCTAssertTrue((fabs([[SKCore getToday] timeIntervalSinceNow]) <= 0.01), @"");
  
  // Ensure we can force the the internal date!
  NSDate *testDate = [NSDate dateFromString:@"2013-10-25" withFormat:@"yyyy-MM-dd"];
  [SKCore forceTodayTo:testDate];
  XCTAssertTrue([[SKCore getToday] isEqualToDate:testDate], @"");
  
  // Ensure we can restore use of the the system date!
  [SKCore forceTodayTo:nil];
  XCTAssertTrue((fabs([[SKCore getToday] timeIntervalSinceNow]) <= 1.0), @"");
}

//
// Latency operation testing...
//

static int        GLatencyOperation_DidSucceed_CallCount;
static double     GLatencyOperation_DidSucceed_Latency;
static int        GLatencyOperation_DidSucceed_PacketLoss;
static double     GLatencyOperation_DidSucceed_Jitter;
static double     GLatencyOperation_DidSucceed_StdDeviation;
static NSUInteger GLatencyOperation_DidSucceed_ThreadId;

static NSUInteger GLatencyOperation_DidFail_CallCount;

-(void) prepareLatencyOperationTest {
  GLatencyOperation_DidSucceed_CallCount = 0;
  GLatencyOperation_DidSucceed_Latency = -1.0;
  GLatencyOperation_DidSucceed_PacketLoss = -1;
  GLatencyOperation_DidSucceed_Jitter = -1.0;
  GLatencyOperation_DidSucceed_StdDeviation = -1.0;
  GLatencyOperation_DidSucceed_ThreadId = -1;
  
  GLatencyOperation_DidFail_CallCount = 0;
}

#pragma mark SKLatencyOperationDelegate

- (void)lodTestDidSendPacket:(NSUInteger)bytes {
  
}

- (void)lodTestDidFail:(NSUInteger)threadId {
  GLatencyOperation_DidFail_CallCount++;
}

- (void)lodTestDidSucceed:(double)latency_
               packetLoss:(int)packetLoss_
                   jitter:(double)jitter_
             stdDeviation:(double)stdDeviation_
                 threadId:(NSUInteger)threadId_ {
  
  GLatencyOperation_DidSucceed_CallCount++;
  GLatencyOperation_DidSucceed_Latency = latency_;
  GLatencyOperation_DidSucceed_PacketLoss = packetLoss_;
  GLatencyOperation_DidSucceed_Jitter = jitter_;
  GLatencyOperation_DidSucceed_StdDeviation = stdDeviation_;
  GLatencyOperation_DidSucceed_ThreadId = threadId_;
}

- (void)lodTestWasCancelled:(NSUInteger)threadId {
  
}

- (void)lodUpdateProgress:(float)progress_ threadId:(NSUInteger)threadId {
  
}
- (void)lodUpdateStatus:(LatencyStatus)status_ threadId:(NSUInteger)threadId {
  
}

//- (SKLatencyTest *)createLatencyTestInstance {
//  SKLatencyTest *latencyTest = [[SKLatencyTest alloc] initWithTarget:@"localhost"
//                                                                port:0
//                                                        numDatagrams:4
//                                                     interPacketTime:0.0
//                                                        delayTimeout:0.0
//                                                          percentile:10
//                                                    maxExecutionTime:1.0
//                                                 LatencyTestDelegate:self];
//  return latencyTest;
//}

const int cTheThreadId = 123;

- (SKLatencyOperation *)createLatencyOperationInstance {
  SKLatencyOperation *latencyOperation = [[SKLatencyOperation alloc]
                                           initWithTarget:@"localhost"
                                           port:0
                                           numDatagrams:4
                                           interPacketTime:0.0
                                           delayTimeout:0.0
                                           percentile:10
                                           maxExecutionTime:1.0
                                           threadId:cTheThreadId
                                           TheTest:[[SKTest alloc] init]
                                           LatencyOperationDelegate:self];
  return latencyOperation;
}


-(void)testLatencyOperationNoResults {
  
  // Test that getStats correctly returns the expected %packet loss!
  
  // This first call should fail, as we have no results.
  [self prepareLatencyOperationTest];
  
  SKLatencyOperation *latencyOperation = [self createLatencyOperationInstance];
  [latencyOperation getStats];
  
  XCTAssertTrue(GLatencyOperation_DidFail_CallCount == 1, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_CallCount == 0, @"");
}

-(void)testLatencyOperationSend2Receive2 {
  //
  // This test should succeed, as we have at least one result.
  //
  [self prepareLatencyOperationTest];
  
  SKLatencyOperation *latencyOperation = [self createLatencyOperationInstance];
  
  const long tag = 0;
  NSDate *startTime = [NSDate date];
  latencyOperation.sentPackets = 2;
  latencyOperation.sentPacketAttempts = 2;
  latencyOperation.bDidTimeoutSoIgnoreLastPacket = NO;
  
  [latencyOperation addStartTimes:tag   TheDate:[NSDate dateWithTimeInterval:0.0 sinceDate:startTime]];
  [latencyOperation addEndTimes:tag     TheDate:[NSDate dateWithTimeInterval:5.0 sinceDate:startTime]];
  
  [latencyOperation addStartTimes:tag+1 TheDate:[NSDate dateWithTimeInterval:5.0 sinceDate:startTime]];
  [latencyOperation addEndTimes:tag+1   TheDate:[NSDate dateWithTimeInterval:10.0 sinceDate:startTime]];
  
  [latencyOperation getStats];
  
  XCTAssertTrue(GLatencyOperation_DidFail_CallCount == 0, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_CallCount == 1, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_Latency == 5000, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_PacketLoss == 0, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_Jitter == 0.0, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_StdDeviation == 0.0, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_ThreadId == cTheThreadId, @"");
  
  // TODO - try more test, get sensible values!
}

-(void)testLatencyOperationSend2Receive1ShouldGive50PercentPacketLoss {
  //
  // This test should succeed, as we have at least one result.
  //
  [self prepareLatencyOperationTest];
  
  SKLatencyOperation *latencyOperation = [self createLatencyOperationInstance];
  
  const long tag = 0;
  NSDate *startTime = [NSDate date];
  latencyOperation.sentPackets = 2;
  latencyOperation.sentPacketAttempts = 2;
  latencyOperation.bDidTimeoutSoIgnoreLastPacket = NO;
  
  [latencyOperation addStartTimes:tag   TheDate:[NSDate dateWithTimeInterval:0.0 sinceDate:startTime]];
  [latencyOperation addEndTimes:tag     TheDate:[NSDate dateWithTimeInterval:5.0 sinceDate:startTime]];
  
  //[latencyOperation addStartTimes:tag+1 TheDate:[NSDate dateWithTimeInterval:5.0 sinceDate:startTime]];
  //[latencyOperation addEndTimes:tag+1   TheDate:[NSDate dateWithTimeInterval:10.0 sinceDate:startTime]];
  
  [latencyOperation getStats];
  
  XCTAssertTrue(GLatencyOperation_DidFail_CallCount == 0, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_CallCount == 1, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_Latency == 5000, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_PacketLoss == 50, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_Jitter == 0.0, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_StdDeviation == 0.0, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_ThreadId == cTheThreadId, @"");
}

-(void)testLatencyOperationSend2Receive1ButIgnoreLastOneDueToTimeoutShouldGive0PercentPacketLoss {
  //
  // This test should succeed, as we have at least one result.
  //
  [self prepareLatencyOperationTest];
  
  SKLatencyOperation *latencyOperation = [self createLatencyOperationInstance];
  
  const long tag = 0;
  NSDate *startTime = [NSDate date];
  latencyOperation.sentPackets = 2;
  latencyOperation.sentPacketAttempts = 2;
  latencyOperation.bDidTimeoutSoIgnoreLastPacket = YES;
  
  [latencyOperation addStartTimes:tag   TheDate:[NSDate dateWithTimeInterval:0.0 sinceDate:startTime]];
  [latencyOperation addEndTimes:tag     TheDate:[NSDate dateWithTimeInterval:5.0 sinceDate:startTime]];
  
  //[latencyOperation addStartTimes:tag+1 TheDate:[NSDate dateWithTimeInterval:5.0 sinceDate:startTime]];
  //[latencyOperation addEndTimes:tag+1   TheDate:[NSDate dateWithTimeInterval:10.0 sinceDate:startTime]];
  
  [latencyOperation getStats];
  
  XCTAssertTrue(GLatencyOperation_DidFail_CallCount == 0, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_CallCount == 1, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_Latency == 5000, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_PacketLoss == 0, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_Jitter == 0.0, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_StdDeviation == 0.0, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_ThreadId == cTheThreadId, @"");
}

-(void)testLatencyOperationSend4Receive4MeasureJitterEtc {
  //
  // This test should succeed, as we have at least one result.
  //
  [self prepareLatencyOperationTest];
  
  SKLatencyOperation *latencyOperation = [self createLatencyOperationInstance];
  
  const long tag = 0;
  NSDate *startTime = [NSDate date];
  latencyOperation.sentPackets = 4;
  latencyOperation.sentPacketAttempts = 4;
  latencyOperation.bDidTimeoutSoIgnoreLastPacket = NO;
  
  [latencyOperation addStartTimes:tag   TheDate:[NSDate dateWithTimeInterval:0.0 sinceDate:startTime]];
  [latencyOperation addEndTimes:tag     TheDate:[NSDate dateWithTimeInterval:1.0 sinceDate:startTime]];
  
  [latencyOperation addStartTimes:tag+1 TheDate:[NSDate dateWithTimeInterval:5.0 sinceDate:startTime]];
  [latencyOperation addEndTimes:tag+1   TheDate:[NSDate dateWithTimeInterval:7.0 sinceDate:startTime]];
  
  [latencyOperation addStartTimes:tag+2 TheDate:[NSDate dateWithTimeInterval:10.0 sinceDate:startTime]];
  [latencyOperation addEndTimes:tag+2   TheDate:[NSDate dateWithTimeInterval:14.0 sinceDate:startTime]];
  
  [latencyOperation addStartTimes:tag+3 TheDate:[NSDate dateWithTimeInterval:14.0 sinceDate:startTime]];
  [latencyOperation addEndTimes:tag+3   TheDate:[NSDate dateWithTimeInterval:22.0 sinceDate:startTime]];

  // Average latency:
  // (1 + 2 + 4 + 8) / 4 = 15 / 4 = 3.75
  // Jitter = average - minimum, = 3.75 - 1, = 2.75, or 2750 milliseconds.
  
  [latencyOperation getStats];
  
  XCTAssertTrue(GLatencyOperation_DidFail_CallCount == 0, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_CallCount == 1, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_Latency == 3750, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_PacketLoss == 0, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_Jitter == 2750, @"");
  XCTAssertTrue(truncf(GLatencyOperation_DidSucceed_StdDeviation) == 3095.0, @"");
  XCTAssertTrue(GLatencyOperation_DidSucceed_ThreadId == cTheThreadId, @"");
}

// TODO - try more tests, get sensible values!

@end