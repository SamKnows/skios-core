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

@interface DebugTiming : NSObject

@property (copy) NSString *mDescription;
@property int       threadIndex;
@property NSTimeInterval  time;
@property double currentSpeed;
//		public DebugTiming(String description, int threadIndex, Long time, int currentSpeed) {
//			super();
//			this.description = description;
//			this.threadIndex = threadIndex;
//			this.time = time;
//			this.currentSpeed = currentSpeed;
//		}
//	}
@end


@interface SKHttpTest : NSObject

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

//###HG This array keeps data for all running
@property (atomic, strong) NSMutableArray *arrTransferOperations;

@property (atomic, strong) id <SKHttpTestDelegate> httpRequestDelegate;

@property (atomic, readwrite) int warmupDoneCounter;    // make this atomic for thread safety

@property (nonatomic, assign) int testIndex;

@property (readwrite) BOOL runAsynchronously;

@property (nonatomic, assign) BOOL testOK;
@property NSUInteger testTransferBytes;
@property NSUInteger testTransferBytes_New;
@property SKTimeIntervalMicroseconds testTransferTimeMicroseconds;
@property (atomic, retain) NSDate *testTransferTimeFirstBytesAt;
@property NSUInteger testWarmupBytes;
@property NSTimeInterval testWarmupStartTime;
@property NSTimeInterval testWarmupEndTime;

@property (atomic, strong) NSMutableDictionary *outputResultsDictionary;

// The following are shared ACROSS ALL THREADS...
// ... and therefore are accessed (in a synchronized way) by the SKTransferOperation instances...
@property BOOL mbMoveToTransferring;
@property NSTimeInterval mStartWarmup;
@property NSTimeInterval mWarmupTime;
@property NSTimeInterval mStartTransfer;
@property int mWarmupBytes;
@property int mTransferBytes;
@property NSUInteger mTotalBytes;
@property SKTimeIntervalMicroseconds mTransferTimeMicroseconds;

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
    HttpTestDelegate:(id <SKHttpTestDelegate>)_delegate;
-(void) prepareForTest;

#pragma mark - Public Methods

- (BOOL)isReady;
- (void)startTest;
- (void)stopTest;
- (void)reset;
- (BOOL)isSuccessful;
- (int)getBytesPerSecond;
- (double)getBytesPerSecondRealTimeUpload;

//- (void)incrementCounter;
//- (void)addWarmupBytes:(NSUInteger)bytes;
//- (void)addWarmupTimes:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;

-(BOOL) getTestIsAsyncFlag;

-(void) setSKAutotest:(SKAutotest*)skAutotest;

+(void) sAddDebugTimingWithDescription:(NSString*)inDescription ThreadIndex:(int)inThreadIndex Time:(NSTimeInterval)inTime CurrentSpeed:(double)inCurrentSpeed;

-(int)  getProgress;
-(BOOL) getIsWarmupDone:(int)bytes;
-(BOOL) isTransferDone:(int)bytes;
-(int) getBytesPerSecond:(NSInteger)TotalBytesWritten;
- (BOOL)isUploadTransferDoneBytesThisTime:(int)bytesThisTime TotalBytes:(int)inTotalBytes TotalBytesToTransfer:(int)inTotalBytesToTransfer;

// Was a delegate, some time ago ... SKTransferOperationDelegate
- (void)todIncrementWarmupDoneCounter;
- (int)todGetWarmupDoneCounter;
- (void)todAddWarmupBytes:(NSUInteger)bytes;
- (void)todAddWarmupTimes:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;
- (void)todAddTransferBytes:(NSUInteger)bytes;

- (void)todUpdateStatus:(TransferStatus)status
               threadId:(NSUInteger)threadId;

//###HG
-(void) todDidTransferData:(NSUInteger)totalBytes
         bytes:(NSUInteger)bytes
                          transferBytes:(NSUInteger)transferBytes
                               progress:(float)progress
                               threadId:(NSUInteger)threadId
                          operationTime:(SKTimeIntervalMicroseconds)transferTime;

- (void)todUploadTestCompletedNotAServeResponseYet:(SKTimeIntervalMicroseconds)transferTimeMicroseconds
                                     transferBytes:(NSUInteger)transferBytes
                                        totalBytes:(NSUInteger)totalBytes;

- (void)todDidCompleteTransferOperation:(SKTimeIntervalMicroseconds)transferTimeMicroseconds
                          transferBytes:(NSUInteger)transferBytes
                             totalBytes:(NSUInteger)totalBytes
       ForceThisBitsPerSecondFromServer:(double)bitrateMpbs1024Based // If > 0, use this instead!
                               threadId:(NSUInteger)threadId;

// End of what was once a delegate

@end

#pragma mark - Delegate

@protocol SKHttpTestDelegate

- (void)htdUpdateStatus:(TransferStatus)status
            threadId:(NSUInteger)threadId;

- (void)htdDidTransferData:(NSUInteger)totalBytes
                  bytes:(NSUInteger)bytes
               progress:(float)progress
               threadId:(NSUInteger)threadId;

- (void)htdDidUpdateTotalProgress:(float)progress currentBitrate:(double)currentBitrate;

- (void)htdDidCompleteHttpTest:(double)bitrateMpbs1024Based
            ResultIsFromServer:(BOOL)resultIsFromServer;
//(SKTimeIntervalMicroseconds)transferTimeMicroseconds
//              transferBytes:(NSUInteger)transferBytes
//                 totalBytes:(NSUInteger)totalBytes
//                   threadId:(NSUInteger)threadId;

@end

//###HG
@interface SKTransferOperationStatus : NSObject

@property (nonatomic) int threadId;
@property (nonatomic) float progress;
@property (nonatomic) int status;
//@property (nonatomic) int totalTransferBytes;
@property (nonatomic) SKTimeIntervalMicroseconds transferTimeMicroseconds;

-(void)resetProperties;

@end
