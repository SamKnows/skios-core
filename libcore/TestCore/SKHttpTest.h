//
//  SKHttpTest.h
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAXNTHREADS 20

FOUNDATION_EXPORT NSString *const DOWNSTREAMSINGLE;
FOUNDATION_EXPORT NSString *const DOWNSTREAMMULTI;
FOUNDATION_EXPORT NSString *const UPSTREAMSINGLE;
FOUNDATION_EXPORT NSString *const UPSTREAMMULTI;

@protocol SKHttpTestDelegate;

@class SKAutotest;

@interface SKHttpTest : NSObject <SKTransferOperationDelegate>

@property (nonatomic, assign) int port;
@property (nonatomic, strong) NSString *target;
@property (nonatomic, strong) NSString *file;
@property (nonatomic, assign) NSTimeInterval warmupMaxTime;
@property (nonatomic, assign) SKTimeIntervalMicroseconds transferMaxTimeMicroseconds;
@property (nonatomic, assign) int warmupMaxBytes;
@property (nonatomic, assign) int transferMaxBytes;
@property (nonatomic, assign) int nThreads;

@property (readwrite) BOOL isDownstream;

@property (nonatomic, assign) int postDataLength;
@property (nonatomic, assign) int sendDataChunkSize;

@property (nonatomic, strong) NSString *networkType;

@property (nonatomic, strong) NSString *displayName;

@property (atomic, assign) BOOL isRunning;
@property (atomic, strong) NSMutableArray *statusArray;
@property (atomic, strong) id <SKHttpTestDelegate> httpRequestDelegate;

@property (atomic, readwrite) int warmupDoneCounter;    // make this atomic for thread safety

@property (nonatomic, assign) int testIndex;

@property (readwrite) BOOL runAsynchronously;

@property (nonatomic, assign) BOOL testOK;
@property NSUInteger testTransferBytes;
@property SKTimeIntervalMicroseconds testTransferTimeMicroseconds;
@property NSUInteger testWarmupBytes;
@property NSTimeInterval testWarmupStartTime;
@property NSTimeInterval testWarmupEndTime;

#pragma mark - Init

- (id)initWithTarget:(NSString*)_target
                port:(int)_port
                file:(NSString*)_file
        isDownstream:(BOOL)_isDownstream
       warmupMaxTime:(double)_warmupMaxTime
      warmupMaxBytes:(double)_warmupMaxBytes
     TransferMaxTimeMicroseconds:(SKTimeIntervalMicroseconds)_transferMaxTimeMicroseconds
    transferMaxBytes:(double)_transferMaxBytes
            nThreads:(int)_nThreads
            HttpTestDelegate:(id <SKHttpTestDelegate>)_delegate
   runAsynchronously:(BOOL)_runAsynchronously;

#pragma mark - Public Methods

- (BOOL)isReady;
- (void)startTest;
- (void)stopTest;
- (void)reset;
- (void)setDirection:(NSString*)direction;
- (BOOL)isSuccessful;
- (int)getBytesPerSecond;

//- (void)incrementCounter;
//- (void)addWarmupBytes:(NSUInteger)bytes;
//- (void)addWarmupTimes:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;

-(BOOL) getTestIsAsyncFlag;

-(void) setSKAutotest:(SKAutotest*)skAutotest;

@end

#pragma mark - Delegate

@protocol SKHttpTestDelegate

- (void)htdUpdateStatus:(TransferStatus)status
            threadId:(NSUInteger)threadId;

- (void)htdDidTransferData:(NSUInteger)totalBytes
                  bytes:(NSUInteger)bytes
               progress:(float)progress
               threadId:(NSUInteger)threadId;

- (void)htdDidUpdateTotalProgress:(float)progress;

- (void)htdDidCompleteHttpTest:(SKTimeIntervalMicroseconds)transferTimeMicroseconds
              transferBytes:(NSUInteger)transferBytes
                 totalBytes:(NSUInteger)totalBytes
                   threadId:(NSUInteger)threadId;

@end
