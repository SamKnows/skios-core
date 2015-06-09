//
//  SKSchedulerTests.m
//  SKSchedulerTests
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface SKTest_SKJPassiveServerUploadTest : XCTestCase

@end

@implementation SKTest_SKJPassiveServerUploadTest

- (void)setUp
{
  [super setUp];
  
  if ([SKAppBehaviourDelegate sGetAppBehaviourDelegateCanBeNil] == nil) {[[SKAppBehaviourDelegate alloc] init];}
  
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
  
  SKTest_SKJPassiveServerUploadTest *theTest = [[SKTest_SKJPassiveServerUploadTest alloc] init];
  
  NSLog(@"Done!");
  [NSThread sleepForTimeInterval:1.0];
}

@end
