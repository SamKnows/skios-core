//
//  SKGlobalMethodsTests.m
//  SKGlobalMethodsTests
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "SKGlobalMethods.h"

@interface SKGlobalMethodsTests : XCTestCase

@end

@implementation SKGlobalMethodsTests

- (void)setUp
{
  [super setUp];
  if ([SKAppBehaviourDelegate sGetAppBehaviourDelegateCanBeNil] == nil) {[[SKAppBehaviourDelegate alloc] init];}
}

- (void)tearDown
{
  // Tear-down code here.
  
  [super tearDown];
}


- (void)testDeviceEtcPropertyQueries {
  
  XCTAssertNotNil([SKGlobalMethods getCarrierName], @"");
  XCTAssertNotNil([SKGlobalMethods getCarrierMobileCountryCode], @"");
  XCTAssertNotNil([SKGlobalMethods getCarrierNetworkCode], @"");
  XCTAssertNotNil([SKGlobalMethods getCarrierIsoCountryCode], @"");
  XCTAssertNotNil([SKGlobalMethods getDeviceModel], @"");
  XCTAssertNotNil([SKGlobalMethods getDevicePlatform], @"");
  
  NSLog(@"Done!");
  [NSThread sleepForTimeInterval:1.0];
}

-(void) testMbpsConversion {
  double bytesPerSecond = 1000000.0;
  // Database stores as 1024-based MBPs
  double bitrateMbps1024Based = bytesPerSecond * 8.0 / (1024.0 * 1024.0);
  double bitrateMbps1000Based = [SKGlobalMethods convertMbps1024BasedToMBps1000Based:bitrateMbps1024Based];
  double bytesPerSecondResult = 1000.0 * 1000.0 * (bitrateMbps1000Based / 8.0);
  XCTAssertTrue(bytesPerSecondResult == bytesPerSecond);
}

-(void) testMbpsConversion2 {
  double seconds = 1.0;
  double microseconds = seconds * 1000000.0;
  double bytes = 4.0 * 1024.0 * 1024.0;
  
  double resultMbps1024Based = [SKGlobalMethods getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:microseconds transferBytes:bytes];
  
  XCTAssertTrue(resultMbps1024Based == 8.0 * 4.0);
}

// bitrateMbps1024BasedToString
-(void) testMbpsConversion3 {
  double bytes = 1000000.0;
  double seconds = 1.0;
  double microseconds = seconds * 1000000.0;
  
  double bitrateMbps1024Based = [SKGlobalMethods getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:microseconds transferBytes:bytes];
  
  NSString *result = [SKGlobalMethods bitrateMbps1024BasedToString:bitrateMbps1024Based];
  XCTAssertTrue([result isEqualToString:@"8.00 Mbps"]);
}

-(void) testMbpsConversion4 {
  double bytes = 500.0;
  double seconds = 1.0;
  double microseconds = seconds * 1000000.0;
  
  double bitrateMbps1024Based = [SKGlobalMethods getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:microseconds transferBytes:bytes];
  
  NSString *result = [SKGlobalMethods bitrateMbps1024BasedToString:bitrateMbps1024Based];
  XCTAssertTrue([result isEqualToString:@"4.00 Kbps"]);
}

-(void) testMbpsConversion5 {
  double bytes = 100.0;
  double seconds = 1.0;
  double microseconds = seconds * 1000000.0;
  
  double bitrateMbps1024Based = [SKGlobalMethods getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:microseconds transferBytes:bytes];
  
  NSString *result = [SKGlobalMethods bitrateMbps1024BasedToString:bitrateMbps1024Based];
  XCTAssertTrue([result isEqualToString:@"800.00 bps"]);
}

@end
