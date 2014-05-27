//
//  SKSchedulerTests.m
//  SKSchedulerTests
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

@interface SKScheduler(MockTest)

// PRIVATE properties and methods that are to be tested.

// TODO - test this private method!
- (NSString*)parseTime:(NSString*)time;

@end

@interface SKSchedulerTests : XCTestCase

@end

@implementation SKSchedulerTests

- (void)setUp
{
  [super setUp];
  
  // Set-up code here.
}

- (void)tearDown
{
  // Tear-down code here.
  
  [super tearDown];
}

- (void)testSKSchedulerOverrides
{
  SKScheduler *scheduler = [[SKScheduler alloc] init];
  
  XCTAssertFalse([scheduler shouldSortTests], @"");
  XCTAssertTrue([scheduler shouldStoreScheduleVersion], @"");
  
  NSLog(@"Done!");
  [NSThread sleepForTimeInterval:1.0];
}

@end
