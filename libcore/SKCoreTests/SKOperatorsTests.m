//
//  SKOperatorsTests.m
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "SKOperators.h"

@interface SKOperatorsTests : XCTestCase

@property UIView *hostView;
@property SKOperators *operators;

@end

@implementation SKOperatorsTests

- (void)setUp {
  [super setUp];
  if ([SKAppBehaviourDelegate sGetAppBehaviourDelegateCanBeNil] == nil) {[[SKAppBehaviourDelegate alloc] init];}
}

- (void)tearDown {
  // Tear-down code here.
  
  [super tearDown];
}

- (void)testThrottledQueryResultConstructor {
  SKThrottledQueryResult *result = [SKThrottledQueryResult new];
  
  XCTAssertTrue(result.returnCode == SKOperators_Return_NoThrottleQuery, @"");
  XCTAssertTrue(result.timestamp != nil, @"");
  XCTAssertTrue(result.datetimeUTCSimple != nil, @"");
  XCTAssertTrue(result.datetimeUTCSimple.length > 0, @"");
  XCTAssertTrue(result.carrier == nil, @"");
}

- (void)testSingleton {
 
  // This is singleton access...
  SKOperators *operators = [SKOperators getInstance];
  XCTAssertTrue(operators != nil, @"");
  SKOperators *operators2 = [SKOperators getInstance];
  XCTAssertTrue(operators == operators2, @"");
  
  NSLog(@"Done!");
  [NSThread sleepForTimeInterval:1.0];
}

- (void)testThrottleQuery {
  // So far as we can, test that the query operation works as expected.
  // It really would be a lot of work to try to fully mock this out, as that would require
  // several layers of mocking; because the query is actually run asynchronously!
  
  SKOperators *operators = [SKOperators getInstance];
  
  SKThrottledQueryResult *result = [operators fireThrottledWebServiceQueryWithCallback:^(NSError *error, NSInteger responseCode, NSMutableData *responseData, NSString *responseDataAsString, NSDictionary *responseHeaders) {
    // In practise, this is never actually reached; as the call is asynchronous!
    XCTAssertTrue(error != nil);
    XCTAssertTrue(responseData != nil);
    XCTAssertTrue(responseDataAsString != nil);
    XCTAssertTrue(responseHeaders != nil);
  }];
  
  XCTAssertTrue(result.returnCode == SKOperators_Return_NoThrottleQuery, @"");
  XCTAssertTrue(result.timestamp != nil, @"");
  XCTAssertTrue(result.datetimeUTCSimple != nil, @"");
  XCTAssertTrue(result.datetimeUTCSimple.length > 0, @"");
  XCTAssertTrue(result.carrier == nil, @"");
  
  NSLog(@"Done!");
  [NSThread sleepForTimeInterval:1.0];
}

@end
