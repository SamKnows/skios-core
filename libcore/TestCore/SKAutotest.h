//
// SKAutotest.h
// SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKThrottledQueryResult;
@protocol SKAutotestManagerDelegate;
@protocol SKAutotestObserverDelegate;

typedef enum
{
  ALL_TESTS = 0,
  DOWNLOAD_TEST,
  UPLOAD_TEST,
  LATENCY_TEST,
  JITTER_TEST
  //UNKNOWN_TEST
  
} TestType;

#define CTTBM_CLOSESTTARGET  1   //Constant Test Type Bit Mask
#define CTTBM_DOWNLOAD  2
#define CTTBM_UPLOAD  4
#define CTTBM_LATENCYLOSSJITTER  8

#define CTTBM_ALL  31


@interface SKAutotest : NSObject <SKClosestTargetDelegate, SKLatencyTestDelegate, SKHttpTestDelegate, SKTestConfigDelegate>

//
// Properties
//

// @protected
@property UIBackgroundTaskIdentifier btid;
@property (atomic, retain) NSMutableArray *autoTests;
@property (atomic, retain) SKLatencyTest *latencyTest;
@property (atomic, retain) SKClosestTargetTest *targetTest;
@property (atomic, retain) SKHttpTest *httpTest;
@property (atomic, retain) NSMutableArray *requestedTests;
@property (atomic, retain) NSMutableArray *conditionBreaches;

// @public
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) BOOL isCancelled;
@property (nonatomic, retain) NSNumber *testId;

@property (nonatomic, assign) BOOL runAllTests;
@property (nonatomic, copy)   NSString *validTest;

@property (nonatomic, retain) id<SKAutotestManagerDelegate> autotestManagerDelegate;
@property (atomic, retain) id <SKAutotestObserverDelegate> autotestObserverDelegate;
@property (nonatomic, assign) BOOL udpClosestTargetTestSucceeded; // Default is NO, set to YES if it worked

@property (nonatomic, strong) NSString* selectedTarget;

@property (nonatomic, retain) SKThrottledQueryResult *mpThrottledQueryResult;
@property (nonatomic, retain) NSString *mpThrottleResponse;
@property (nonatomic, retain) NSMutableDictionary *jsonDictionary;
@property (nonatomic, retain) NSMutableDictionary *cpuCondition;
@property (nonatomic, retain) NSMutableArray *accumulatedNetworkTypeLocationMetrics;
@property BOOL mbIsContinuousTesting;

//
// Methods
//


#define kSKAAutoTest_UDPFailedSkipTests @"kSKAAutoTest_UDPFailedSkipTests"
#define kSKAAutoTest_GeneratedTestId @"kSKAAutoTest_GeneratedTestId"

// NEW api methods...
-(id) initAndRunWithAutotestManagerDelegate:(id<SKAutotestManagerDelegate>)inAutotestManagerDelegate AndAutotestObserverDelegate:(id<SKAutotestObserverDelegate>)inAutotestObserverDelegate AndTestType:(TestType)testType IsContinuousTesting:(BOOL)isContinuousTesting;
-(id) initAndRunWithAutotestManagerDelegateWithBitmask:(id<SKAutotestManagerDelegate>)inAutotestManagerDelegate autotestObserverDelegate:(id<SKAutotestObserverDelegate>)inAutotestObserverDelegate TestsToExecuteBitmask:(int)tests2execute isContinuousTesting:(BOOL)isContinuousTesting;

-(id) initWithAutotestManagerDelegate:(id<SKAutotestManagerDelegate>)inAutotestManagerDelegate AndAutotestObserverDelegate:(id<SKAutotestObserverDelegate>)inAutotestObserverDelegate AndTestType:(TestType)testType  IsContinuousTesting:(BOOL)isContinuousTesting;

//@public
-(void)markTestAsStopped; // Only called by child class!
-(void)stopTheTests;

// @protected
// Internal - run all the tests
-(void)runTheTests;
// Internal - run just a sub-set of tests
-(void)runTheTestsWithBitmask:(int)bitMaskForRequestedTests_;

-(void)runNextTest:(int)testIndex;
-(void)createLatencyTest:(SKTestConfig *)config target:(NSString *)target;
-(void)createClosestTargetTest:(NSArray *)targets NumDatagrams:(int)numDatagrams;
-(void)createHttpTest:(SKTestConfig *)config isDownload:(BOOL)isDownload file:(NSString *)file target:(NSString *)target;
-(BOOL)shouldCallCheckConditions;
-(BOOL)shouldTestTypeIfIsIncluded;
-(BOOL)testIsIncluded:(NSString*)testType;
-(void)checkTestId;
-(void)runLatencyTest:(SKTestConfig*)config testIndex:(int)testIndex;
-(void)runTransferTest:(SKTestConfig*)config testIndex:(int)testIndex isDownload:(BOOL)isDownload;
// This must only be called by the child classes's htdDidCompleteHttpTest:... method.
-(void)htdDidCompleteHttpTest;

//@protected
- (void)runClosestTargetTest:(SKTestConfig*)config testIndex:(int)testIndex;

+(BOOL) sGetIsTestRunning;

@end

#pragma mark - Delegates

@protocol SKAutotestObserverDelegate <NSObject> //###HG

- (void)aodClosestTargetTestDidStart;
- (void)aodClosestTargetTestDidFail;
- (void)aodClosestTargetTestDidSucceed:(NSString*)target;

- (void)aodLatencyTestDidStart;
- (void)aodLatencyTestWasCancelled;
- (void)aodLatencyTestDidFail:(NSString*)messageIgnore;
- (void)aodLatencyTestDidSucceed:(SKLatencyTest*)latencyTest;
- (void)aodLatencyTestUpdateStatus:(LatencyStatus)status;
- (void)aodLatencyTestUpdateProgress:(float)progress latency:(float)latency;

- (void)aodTransferTestDidFail:(BOOL)isDownstream;
- (void)aodTransferTestDidStart:(BOOL)isDownstream;
- (void)aodTransferTestDidUpdateProgress:(float)progress isDownstream:(BOOL)isDownstream bitrate1024Based:(double)bitrate1024Based;

//- (void)aodTransferTestDidFinish:(NSString*)message isDownstream:(BOOL)isDownstream;
- (void)aodTransferTestDidCompleteTransfer:(SKHttpTest*)httpTest Bitrate1024Based:(double)bitrate1024Based;

- (void)aodAllTestsComplete;

//### HG
- (void)aodDidStartTargetTesting;
- (void)aodDidFinishAnotherTarget:(int)targetId withLatency:(double)latency withBest:(int)bestId;

@end

@protocol SKAutotestManagerDelegate

-(double)       amdGetLatitude;
-(double)       amdGetLongitude;
-(NSTimeInterval)       amdGetDateAsTimeIntervalSince1970;
  
-(SKScheduler*) amdGetSchedule;
-(NSString*)    amdGetClosestTarget;
-(void)         amdSetClosestTarget:(NSString*)inClosestTarget;
-(BOOL)         amdGetIsConnected;
-(NSInteger)    amdGetConnectionStatus;
-(NSString*)    amdGetFileUploadPath;
-(void)         amdDoUploadJSON;
-(void)         amdDoCreateUploadFile;
-(void)         amdDoUpdateDataUsage:(int)bytes;
-(int64_t)      amdGetDataUsageBytes;
-(void)         amdDoUploadLogFile;
-(void)         amdDoAppendOutputResultsArrayToLogFile:(NSMutableArray*)results networkType:(NSString*)networkType;
 
@end


