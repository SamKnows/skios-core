//
//  SKAutotestTests.m
//  SKAutotestTests
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "SKAutotest.h"

static int GGetAutotestScheduleCalls = 0;
static int GCallsToRunNextTest = 0;
static int GLastTestIndexPassedToRunTheTests = -99;

@interface SKAutotestStubbed : SKAutotest

// Private members!
// Each one of these is a NSDictionary, describing the test!
@property (atomic, retain) NSMutableArray *autoTests;

@property (nonatomic, assign) BOOL isRunning;

@end

@implementation SKAutotestStubbed

// Stub implementation of SKAutotest - methods that might otherwise be overridden.
-(void)runTheTests {
  NSLog(@"SKAutotestStub::runTheTests - call super runTheTests");
  [super runTheTests];
}
-(void)stop {
  NSLog(@"SKAutotestStub::stopTheTests - call super stopTheTests");
  [super stopTheTests];
}

-(void)runNextTest:(int)testIndex {
  GCallsToRunNextTest ++;
  GLastTestIndexPassedToRunTheTests = testIndex;
  NSLog(@"SKAutotestStub::runNextTest, testIndex=%d - STUB", testIndex);
}
-(void)createLatencyTest:(SKTestConfig *)config target:(NSString *)target {
  NSLog(@"SKAutotestStub::createLatencyTest, config=%@ target=%@ - STUB", config, target);
}
-(void)createClosestTargetTest:(NSArray *)targets {
  NSLog(@"SKAutotestStub::createClosestTargetTest, targets=%@ - STUB", targets);
}
-(void)createHttpTest:(SKTestConfig *)config isDownload:(BOOL)isDownload file:(NSString *)file target:(NSString *)target {
  NSLog(@"SKAutotestStub::createHttpTest - STUB");
}
-(BOOL)shouldCallCheckConditions {
  NSLog(@"SKAutotestStub::shouldCallCheckConditions - STUB");
  return YES;
}
-(BOOL)shouldTestTypeIfIsIncluded {
  NSLog(@"SKAutotestStub::shouldTestTypeIfisIncluded - STUB");
  return YES;
}
-(BOOL)testIsIncluded:(NSString*)testType {
  NSLog(@"SKAutotestStub::testIsIncluded - STUB");
  return YES;
}
-(void)checkTestId {
  NSLog(@"SKAutotestStub::checkTestId - STUB");
}
-(void)runLatencyTest:(SKTestConfig*)config testIndex:(int)testIndex {
  NSLog(@"SKAutotestStub::runLatencyTest - STUB");
}
-(void)runTransferTest:(SKTestConfig*)config testIndex:(int)testIndex isDownload:(BOOL)isDownload {
  NSLog(@"SKAutotestStub::runTransferTest - STUB");
}
@end

@interface SKAutotest(MockTest)

// PRIVATE properties and methods that are to be tested.

// TODO - test this private method!
- (NSString*)parseTime:(NSString*)time;

@end

@interface SKAutotestTests : XCTestCase<SKAutotestManagerDelegate, SKAutotestObserverDelegate>

@end

@implementation SKAutotestTests

- (void)setUp
{
  [super setUp];
  
  // Set-up code here.
  GGetAutotestScheduleCalls = 0;
  GCallsToRunNextTest = 0;
  GLastTestIndexPassedToRunTheTests = -99;
}

- (void)tearDown
{
  // Tear-down code here.
  
  [super tearDown];
}


#pragma mark SKAutotestManagerDelegate
-(double)       amdGetLatitude {
  NSLog(@"SKAutotestManagerDelegate::amdGetLatitude");
  return 1.0;
}
-(double)       amdGetLongitude {
  NSLog(@"SKAutotestManagerDelegate::amdGetLongitude");
  return 2.0;
}
-(double)       amdGetDateAsTimeIntervalSince1970 {
  NSLog(@"SKAutotestManagerDelegate::amdGetDateAsTimeIntervalSince1970");
  return 1.0;
}
-(SKScheduler*) amdGetSchedule {
  NSLog(@"SKAutotestManagerDelegate::amdGetSchedule");
  GGetAutotestScheduleCalls++;
  //return [[SKScheduler alloc] initWithXmlData]; // TODO!
  return [[SKScheduler alloc] init];
}
-(NSString*)    amdGetClosestTarget {
  NSLog(@"SKAutotestManagerDelegate::amdGetClosestTarget");
  return @"closestTarget";
}
-(void)         amdSetClosestTarget:(NSString*)inClosestTarget {
  NSLog(@"SKAutotestManagerDelegate::amdSetClosestTarget, inClosestTarget=%@", inClosestTarget);
}
-(BOOL)         amdGetIsConnected {
  NSLog(@"SKAutotestManagerDelegate::amdGetIsConnected");
  return YES;
}
-(NSInteger)    amdGetConnectionStatus {
  NSLog(@"SKAutotestManagerDelegate::amdGetConnectionStatus");
  return 0;
}
//-(NSString*)    getAutotestDeviceModel {
//  NSLog(@"SKAutotestManagerDelegate::getAutotestDeviceModel");
//  return @"deviceModel";
//}
//-(NSString*)    getAutotestDevicePlatform {
//  NSLog(@"SKAutotestManagerDelegate::getAutotestPlatform");
//  return @"devicePlatform";
//}
//-(NSString*)    getAutotestCarrierName {
//  NSLog(@"SKAutotestManagerDelegate::getAutotestCarrierName");
//  return @"deviceCarrierName";
//}
//-(NSString*)    getAutotestCountryCode {
//  NSLog(@"SKAutotestManagerDelegate::getAutotestCountryCode");
//  return @"deviceCountryCode";
//}
//-(NSString*)    getAutotestNetworkCode {
//  NSLog(@"SKAutotestManagerDelegate::getAutotestNetworkCode");
//  return @"deviceNetworkCode";
//}
//-(NSString*)    getAutotestIsoCode {
//  NSLog(@"SKAutotestManagerDelegate::getAutotestIsoCode");
//  return @"deviceIsoCode";
//}
-(NSString*)    amdGetFileUploadPath {
  NSLog(@"SKAutotestManagerDelegate::amdGetFileUploadPath");
  return @"fileUploadPath";
}
-(void)         amdDoSaveJSON:(NSString*)jsonString {
  NSLog(@"SKAutotestManagerDelegate::amdDoSaveJSON=%@", jsonString);
}
-(void)         amdDoUploadJSON {
  NSLog(@"SKAutotestManagerDelegate::amdDoUploadJSON");
}
-(void)         amdDoCreateUploadFile {
  NSLog(@"SKAutotestManagerDelegate::amdDoCreateUploadFile");
}
-(void)         amdDoUpdateDataUsage:(int)bytes {
  NSLog(@"SKAutotestManagerDelegate::doAutotestUpdateDataUsing=%d", bytes);
}
-(int64_t)   amdGetDataUsageBytes {
  NSLog(@"SKAutotestManagerDelegate::amdGetDataUsageBytes");
  return 100;
}
-(void)         amdDoAppendOutputResultsArrayToLogFile:(NSMutableArray*)results networkType:(NSString*)networkType {
  NSLog(@"SKAutotestManagerDelegate::amdDoAppendOutputResultsArrayToLogFile, results==%@, networkType=%@", results, networkType);
}

#pragma mark SKAutotestObserverDelegate

- (void)aodClosestTargetTestDidStart {
  NSLog(@"SKAutotestObserverDelegate::aodClosestTargetTestDidStart");
}
- (void)aodClosestTargetTestDidFail {
  NSLog(@"SKAutotestObserverDelegate::aodClosestTargetTestDidFail");
}
- (void)aodClosestTargetTestDidSucceed:(NSString*)target {
  NSLog(@"SKAutotestObserverDelegate::aodClosestTargetTestDidSucceed");
}
- (void)aodLatencyTestWasCancelled {
  NSLog(@"SKAutotestObserverDelegate::aodLatencyTestWasCancelled");
}
- (void)aodLatencyTestDidFail:(NSString*)messageIgnore {
  NSLog(@"SKAutotestObserverDelegate::aodLatencyTestDidFail");
}
- (void)aodLatencyTestDidSucceed:(SKLatencyTest*)latencyTest {
  NSLog(@"SKAutotestObserverDelegate::aodLatencyTestDidSucceed");
}
- (void)aodLatencyTestUpdateStatus:(LatencyStatus)status {
  NSLog(@"SKAutotestObserverDelegate::aodLatencyTestUpdateStatus");
}
- (void)aodTransferTestDidFail:(BOOL)isDownstream {
  NSLog(@"SKAutotestObserverDelegate::aodTransferTestDidFail");
}
- (void)aodTransferTestDidStart:(BOOL)isDownstream {
  NSLog(@"SKAutotestObserverDelegate::transferTestDidStart");
}
- (void)aodTransferTestDidUpdateProgress:(float)progress isDownstream:(BOOL)isDownstream bitrate1024Based:(double)bitrate1024Based {
  NSLog(@"SKAutotestObserverDelegate::aodTransferTestDidUpdateProgress");
}
- (void)aodTransferTestDidCompleteTransfer:(SKHttpTest*)httpTest Bitrate1024Based:(double)bitrate1024Based {
  NSLog(@"SKAutotestObserverDelegate::transferTestDidComplete");
}

- (void)aodAllTestsComplete {
  NSLog(@"SKAutotestObserverDelegate::aodAllTestsComplete");
}

//=====

#define failIfThisMethodCalled andDo:^(NSInvocation *invocation) { STFail(@"Should not have called this method!"); }

- (void)testSKAutotestInitNoOtherMethodsCalled
{
  SKAutotest *autotest = [[SKAutotestStubbed alloc] init];
  
  id mock = [OCMockObject partialMockForObject:autotest];
 
  // OCMock doesn't currently support loose matching of primitive arguments! 
  // int dummyTestIndex = 1;
  // http://stackoverflow.com/questions/6325289/passing-primitives-to-an-ocmocks-stub
  //[[[mock stub] failIfThisMethodCalled] runNextTest:OCMOCK_VALUE(dummyTestIndex)];
  //[[mock reject] createClosestTargetTest:OCMOCK_ANY];
  //[[mock reject] checkTestId];
  //[[mock reject] runTheTests];
  //[[mock reject] stopTheTests];
  //[[mock expect] checkTestId];
  
  [mock verify]; //should pass, as our rejected methods should not be called.
  
  NSLog(@"Done!");
  [NSThread sleepForTimeInterval:1.0];
}

// GIVEN: [autotest initAndRunWithAutotestManagerDelegate]
// WHEN: [autotest runTheTests]
// THEN: the delegate's getAutoTestSchedule is called
// Note that for this test, we simplify things by passing-in an empty schedule.
- (void)testSKAutotestInitWithAutotestManagerDelegate_runTheTests_Calls_getAutotestSchedule
{
  SKScheduler *scheduler = [[SKScheduler alloc] init];
  id mockScheduler = [OCMockObject partialMockForObject:scheduler];
  
  OCMockObject *mockManagerDelegate = [OCMockObject niceMockForProtocol:@protocol(SKAutotestManagerDelegate)];
  [[[mockManagerDelegate stub] andReturn:mockScheduler] amdGetSchedule];
  
  OCMockObject *mockObserverDelegate = [OCMockObject niceMockForProtocol:@protocol(SKAutotestObserverDelegate)];
  
  SKAutotest *autotest = [[SKAutotestStubbed alloc] initWithAutotestManagerDelegate:(id<SKAutotestManagerDelegate>)mockManagerDelegate AndAutotestObserverDelegate:(id<SKAutotestObserverDelegate>)mockObserverDelegate AndTestType:ALL_TESTS IsContinuousTesting:NO];
  id autotestMock = [OCMockObject partialMockForObject:autotest];
  
  XCTAssertTrue(autotest.autotestManagerDelegate == (id<SKAutotestManagerDelegate>)mockManagerDelegate, @"");
  XCTAssertTrue(autotest.autotestObserverDelegate == (id<SKAutotestObserverDelegate>)mockObserverDelegate, @"");
  
  [[mockScheduler expect] getArrayOfTests];
 
  // We need to run this manually...
  [autotestMock runTheTests];
  
  [autotestMock verify];
  [mockScheduler verify];
  [mockManagerDelegate verify];
  [mockObserverDelegate verify];
  
  NSLog(@"Done!");
  [NSThread sleepForTimeInterval:1.0];
}

-(NSData*) getTheTestSchedule {
  NSBundle *bundle = [NSBundle bundleForClass:self.class];
  XCTAssertNotNil(bundle, @"");
  
  NSString *file = [bundle pathForResource:@"SCHEDULE" ofType:@"xml"];
  XCTAssertNotNil(file, @"");
  
  NSData *data = [NSData dataWithContentsOfFile:file];
  XCTAssertNotNil(data, @"");
  
  return data;
}

// GIVEN: [autotest initAndRunWithAutotestManagerDelegate]
// WHEN: [autotest runTheTests]
// THEN: the delegate's getAutoTestSchedule is called
// Note that for this test, we pass-in a real schedule!
- (void)testSKAutotestInitWithAutotestManagerDelegate_runTheTests_WithRealSchedule {
  
  // Load-up the scheduler with real test data!
  SKScheduler *scheduler = [[SKScheduler alloc] initWithXmlData:[self getTheTestSchedule]];
  id mockScheduler = [OCMockObject partialMockForObject:scheduler];
  
  OCMockObject *mockDelegate = [OCMockObject niceMockForProtocol:@protocol(SKAutotestManagerDelegate)];
  [[[mockDelegate stub] andReturn:mockScheduler] amdGetSchedule];
  
  OCMockObject *mockObserverDelegate = [OCMockObject niceMockForProtocol:@protocol(SKAutotestObserverDelegate)];
  
  SKAutotestStubbed *autotest = [[SKAutotestStubbed alloc] initWithAutotestManagerDelegate:(id<SKAutotestManagerDelegate>)mockDelegate AndAutotestObserverDelegate:(id<SKAutotestObserverDelegate>)mockObserverDelegate AndTestType:ALL_TESTS IsContinuousTesting:NO];
  id autotestMock = [OCMockObject partialMockForObject:autotest];
  
  XCTAssertTrue(autotest.autotestManagerDelegate == (id<SKAutotestManagerDelegate>)mockDelegate, @"");
 
  // Do not intercept this call, as it results in many other important calls we need to verify.
  //[[mockScheduler expect] getArrayOfTests];
  // TODO - monitor for other methods being called!

  // The runNextTest method is next expected to be called - once - with an initial index of -1.
  // But, as OCMock doesn't allow mocking of primitive arguments, we handle this a bit differently,
  // with an assertion about GCallsToRunNextTest and GLastTestIndexPassedToRunTheTests
  // (see later in the test).
  //int theValue = -1;
  //[[autotestMock expect] runNextTest:OCMOCK_VALUE(theValue)];
  
  // We need to run this manually...
  [autotestMock runTheTests];
  
  XCTAssertTrue(GCallsToRunNextTest == 1, @"");
  XCTAssertTrue(GLastTestIndexPassedToRunTheTests == -1, @"");
  XCTAssertTrue(autotest.autoTests.count == 4, @"");
  XCTAssertTrue(autotest.isRunning == YES, @"");
  XCTAssertTrue(autotest.isCancelled == NO, @"");

  // Verify that calling stopTheTests has the expected behaviour.
  // Note: we verify that this calls stopTest on the child tests in a SEPARATE test.
  [autotestMock stopTheTests];

  XCTAssertTrue(autotest.isRunning == NO, @"");
  XCTAssertTrue(autotest.isCancelled == YES, @"");
  
  [autotestMock verify];
  [mockScheduler verify];
  [mockDelegate verify];
  
  NSLog(@"Done!");
  [NSThread sleepForTimeInterval:1.0];
}

// GIVEN: [autotest initAndRunWithAutotestManagerDelegate]
// WHEN: [autotest stopTheTests]
// THEN: the child http etc. tests have stopTest called
- (void)testSKAutotestStopsTheChildTests {
  
  // Load-up the scheduler with real test data!
  SKScheduler *scheduler = [[SKScheduler alloc] initWithXmlData:[self getTheTestSchedule]];
  id mockScheduler = [OCMockObject partialMockForObject:scheduler];
  
  OCMockObject *mockDelegate = [OCMockObject niceMockForProtocol:@protocol(SKAutotestManagerDelegate)];
  [[[mockDelegate stub] andReturn:mockScheduler] amdGetSchedule];
  
  OCMockObject *mockObserverDelegate = [OCMockObject niceMockForProtocol:@protocol(SKAutotestObserverDelegate)];
  
  SKAutotestStubbed *autoTest = [[SKAutotestStubbed alloc] initWithAutotestManagerDelegate:(id<SKAutotestManagerDelegate>)mockDelegate AndAutotestObserverDelegate:(id<SKAutotestObserverDelegate>)mockObserverDelegate AndTestType:ALL_TESTS IsContinuousTesting:NO];
  id autotestMock = [OCMockObject partialMockForObject:autoTest];

  // Set the mock test objects in the autotest.
  autoTest.latencyTest = [[SKLatencyTest alloc] init];
  OCMockObject *mockLatencyTest = [OCMockObject partialMockForObject:autoTest.latencyTest];
  autoTest.targetTest = [[SKClosestTargetTest alloc] init];
  OCMockObject *mockTargetTest = [OCMockObject partialMockForObject:autoTest.targetTest];
  autoTest.httpTest = [[SKHttpTest alloc] init];
  OCMockObject *mockHttpTest = [OCMockObject partialMockForObject:autoTest.httpTest];

  [[mockLatencyTest expect] stopTest];
  [[mockTargetTest expect] stopTest];
  [[mockHttpTest expect] stopTest];
  
  // Run the test manually.
  [autotestMock runTheTests];

  XCTAssertTrue(autoTest.isRunning == YES, @"");
  XCTAssertTrue(autoTest.isCancelled == NO, @"");
  
  // Verify that calling stopTheTests calls stopTest on the child tests.
  [autotestMock stopTheTests];

  XCTAssertTrue(autoTest.isRunning == NO, @"");
  XCTAssertTrue(autoTest.isCancelled == YES, @"");
  
  [autotestMock verify];
  [mockScheduler verify];
  [mockDelegate verify];
  [mockLatencyTest verify];
  [mockTargetTest verify];
  [mockHttpTest verify];
  
  NSLog(@"Done!");
  [NSThread sleepForTimeInterval:1.0];
}

// The following methods have mock tests in place:
// - initWithAutotestManagerDelegate
// - stopTheTests
//
// TODO: The following methods should have tests added.
// - (void)testDidFail;
// - (void)didCompleteTest:(NSString*)target latency:(double)latency
// - (void)createLatencyTest:(SKTestConfig *)config target:(NSString *)target
// - (void)createClosestTargetTest:(NSArray *)targets
// - (void)createHttpTest:(SKTestConfig *)config isDownload:(BOOL)isDownload file:(NSString *)file target:(NSString *)target
// - (BOOL)shouldCallCheckConditions
// -(BOOL) shouldTestTypeIfIsIncluded
// - (BOOL)testIsIncluded:(NSString*)testType
// - (void)didSendPacket:(NSUInteger)bytes
// - (void)checkTestId
// - (void)runClosestTargetTest:(SKTestConfig*)config testIndex:(int)testIndex;
// - (void)runTransferTest:(SKTestConfig*)config testIndex:(int)testIndex isDownload:(BOOL)isDownload
// - (void)htdDidCompleteHttpTest
// - (void)todDidTransferData:(NSUInteger)totalBytes bytes:(NSUInteger)bytes progress:(float)progress threadId:(NSUInteger)threadId
// - (void)didUpdateTotalProgress:(float)progress
// - (void)runLatencyTest:(SKTestConfig*)config testIndex:(int)testIndex
// - (void)udpTestDidFail
// - (void)udpTestWasCancelled
// - (void)udpUpdateProgress:(float)progress
// - (void)udpUpdateStatus:(LatencyStatus)status
// - (void)udpTestDidSendPacket:(NSUInteger)bytes
// - (NSString*)getValidTestType:(TestType)testType



@end
