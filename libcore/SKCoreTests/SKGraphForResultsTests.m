//
//  SKGraphForResultsTests.m
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

// http://paulsolt.com/2012/12/unit-testing-static-libraries-with-kiwi-for-ios-development/
// Ideally, this test would be in the SKCore unit tests - but it cannot be, as it relies on UIKit!
// So, it was moved to the SamKnows application tests area.

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "SKGraphForResults.h"

@interface SKGraphForResultsTests : XCTestCase

@property UIView *hostView;
@property SKGraphForResults *graph;

@end

@implementation SKGraphForResultsTests

- (void)setUp {
  [super setUp];
  
  self.hostView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
  self.graph = [[SKGraphForResults alloc] init];
}

- (void)tearDown {
  // Tear-down code here.
  
  [super tearDown];
}
                   
- (void)testDummy {
  
  NSLog(@"Done!");
  [NSThread sleepForTimeInterval:1.0];
}

@end
