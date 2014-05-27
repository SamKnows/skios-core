//
//  SKTransferOperation.h
//  SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SKTransferOperation.h"

#define HTTP_DOWNLOAD_TIMEOUT 45

typedef enum { INITIALIZING, WARMING, TRANSFERRING, COMPLETE, CANCELLED, FAILED, FINISHED, IDLE } TransferStatus;

@protocol SKTransferOperationDelegate;
@class SKAutotest;

@interface SKTransferOperation : NSOperation<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSURLConnection *urlConnection;
    NSMutableURLRequest *urlRequest;
    
    UIBackgroundTaskIdentifier btid;
    
    BOOL _Finished;
    BOOL _Executing;
    
    int port;
    NSString *target;
    NSString *file;
    
    NSTimeInterval warmupMaxTime;
    NSTimeInterval transferMaxTime;
    NSTimeInterval startTime;
    SKTimeIntervalMicroseconds transferTimeMicroseconds;
    
    int warmupMaxBytes;
    int transferMaxBytes;
    
    int nThreads;
    int threadId;
    
    BOOL isDownstream;
    
    NSTimer *cancelTimer;
}

@property (nonatomic, strong) NSString *target;
@property (nonatomic, assign) int port;
@property (nonatomic, strong) NSString *file;
@property (nonatomic, assign) NSTimeInterval warmupMaxTime;
@property (nonatomic, assign) SKTimeIntervalMicroseconds transferMaxTimeMicroseconds;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) SKTimeIntervalMicroseconds transferTimeMicroseconds;
@property (nonatomic, assign) int warmupMaxBytes;
@property (nonatomic, assign) int transferMaxBytes;
@property (nonatomic, assign) int nThreads;
@property (nonatomic, assign) int threadId;
@property (nonatomic, assign) BOOL isDownstream;

@property (atomic, strong) id <SKTransferOperationDelegate> transferOperationDelegate;

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
            threadId:(int)_threadId
            TransferOperationDelegate:(id <SKTransferOperationDelegate>)_delegate
            asyncFlag:(BOOL)_asyncFlag;

#pragma mark - Instance Methods

-(void)start;
-(BOOL)getAsyncFlag;

// Put in a method, so we can mock it out when required under testing!
- (NSURLConnection *)newAsynchronousRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate>)theDelegate startImmediately:(NSNumber*)inStartImmediately;

// static methods used simply to get NSStrings describing different states.
+(NSString*) getUpStream;
+(NSString*) getDownStream;
+(NSString*) getStatusInitializing;
+(NSString*) getStatusWarming;
+(NSString*) getStatusTransferring;
+(NSString*) getStatusComplete;
+(NSString*) getStatusCancelled;
+(NSString*) getStatusFailed;
+(NSString*) getStatusFinished;
+(NSString*) getStatusIdle;

// Used by the owning SKAutotest, to let the SKTransferOperation know what the owning autotest is...
-(void) setSKAutotest:(SKAutotest*)inSkAutotest;

@end

#pragma mark - Delegate

@protocol SKTransferOperationDelegate

- (void)todIncrementWarmupDoneCounter;
- (int)todGetWarmupDoneCounter;
- (void)todAddWarmupBytes:(NSUInteger)bytes;
- (void)todAddWarmupTimes:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;

- (void)todUpdateStatus:(TransferStatus)status
            threadId:(NSUInteger)threadId;

- (void)todDidTransferData:(NSUInteger)totalBytes
                  bytes:(NSUInteger)bytes
               progress:(float)progress
               threadId:(NSUInteger)threadId;

- (void)todDidCompleteTransferOperation:(SKTimeIntervalMicroseconds)transferTimeMicroseconds
              transferBytes:(NSUInteger)transferBytes
                 totalBytes:(NSUInteger)totalBytes
                   threadId:(NSUInteger)threadId;

@end

