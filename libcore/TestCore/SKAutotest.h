//
// SKAutotest.h
// SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SKAutotestManagerDelegate;
@protocol SKAutotestObserverDelegate;

typedef enum
{
  ALL_TESTS = 0,
  DOWNLOAD_TEST,
  UPLOAD_TEST,
  LATENCY_TEST,
  JITTER_TEST,
  UNKNOWN_TEST
  
} TestType;

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
@property (nonatomic, retain) NSString *validTest;
@property (nonatomic, retain) id<SKAutotestManagerDelegate> autotestManagerDelegate;
@property (atomic, retain) id <SKAutotestObserverDelegate> autotestObserverDelegate;
@property (nonatomic, assign) BOOL udpClosestTargetTestSucceeded;

//
// Methods
//

-(id) initWithAutotestManagerDelegate:(id<SKAutotestManagerDelegate>)inAutotestManagerDelegate AndAutotestObserverDelegate:(id<SKAutotestObserverDelegate>)inAutotestObserverDelegate AndTestType:(TestType)testType  IsContinuousTesting:(BOOL)isContinuousTesting;

//@public
-(void)stopTheTests;

// @protected
-(void)runTheTests;
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

@end

#pragma mark - Delegates

@protocol SKAutotestObserverDelegate

- (void)aodClosestTargetTestDidStart;
- (void)aodClosestTargetTestDidFail;
- (void)aodClosestTargetTestDidSucceed:(NSString*)target;

- (void)aodLatencyTestWasCancelled;
- (void)aodLatencyTestDidFail:(NSString*)messageIgnore;
- (void)aodLatencyTestDidSucceed:(SKLatencyTest*)latencyTest;
- (void)aodLatencyTestUpdateStatus:(LatencyStatus)status;
- (void)aodLatencyTestUpdateProgress:(float)progress;

- (void)aodTransferTestDidFail:(BOOL)isDownstream;
- (void)aodTransferTestDidStart:(BOOL)isDownstream;
- (void)aodTransferTestDidUpdateProgress:(float)progress isDownstream:(BOOL)isDownstream;
//- (void)aodTransferTestDidFinish:(NSString*)message isDownstream:(BOOL)isDownstream;
- (void)aodTransferTestDidCompleteTransfer:(SKHttpTest*)httpTest Bitrate1024Based:(double)bitrate1024Based;

- (void)aodAllTestsComplete;

@end

@protocol SKAutotestManagerDelegate

-(double)       amdGetLatitude;
-(double)       amdGetLongitude;
-(SKScheduler*) amdGetSchedule;
-(NSString*)    amdGetClosestTarget;
-(void)         amdSetClosestTarget:(NSString*)inClosestTarget;
-(BOOL)         amdGetIsConnected;
-(NSInteger)    amdGetConnectionStatus;
-(NSString*)    amdGetFileUploadPath;
-(void)         amdDoSaveJSON:(NSString*)jsonString;
-(void)         amdDoUploadJSON;
-(void)         amdDoCreateUploadFile;
-(void)         amdDoUpdateDataUsage:(int)bytes;
-(int64_t)      amdGetDataUsageBytes;
-(void)         amdDoUploadLogFile;
-(void)         amdDoAppendOutputResultsArrayToLogFile:(NSMutableArray*)results networkType:(NSString*)networkType;
  
@end


