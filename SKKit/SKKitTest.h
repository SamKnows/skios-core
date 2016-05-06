//
//  SKKitTest.h
//  SKKit
//
//  Created by Pete Cole on 26/01/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//

// Swift-accessible that act as adaptors around the core tests
// (which are implemented (using Objective-C) in libcore)

#import <Foundation/Foundation.h>

//#import <SKKit/SKKit-Swift.h>

// Descriptors used to parse tests.

@interface SKKitTestDescriptor : NSObject
typedef enum SKKitTestType_t {
  SKKitTestType_Closest=0,
  SKKitTestType_Download=1,
  SKKitTestType_Upload=2,
  SKKitTestType_Latency=3
} SKKitTestType;

-(NSString *)getId;
-(SKKitTestType)getType;
-(NSString*)getDisplayName;
@end

@interface SKKitTestDescriptor_ClosestTarget : SKKitTestDescriptor
@property (nonatomic, retain) NSMutableArray * mTargetArray;
@end

@interface SKKitTestDescriptor_Download : SKKitTestDescriptor
@property (nonatomic, copy) NSString * mTarget;
@property (nonatomic) NSInteger mPort;
@property (nonatomic, copy) NSString * mFile;
@property (nonatomic) NSTimeInterval mWarmupMaxTimeSeconds;
@property (nonatomic) NSTimeInterval mTransferMaxTimeSeconds;
@property (nonatomic) NSInteger mWarmupMaxBytes;
@property (nonatomic) NSInteger mTransferMaxBytes;
@property (nonatomic) NSInteger mNumberOfThreads;
@property (nonatomic) NSInteger mBufferSizeBytes;
@end


@interface SKKitTestDescriptor_Latency : SKKitTestDescriptor
@property (nonatomic, copy) NSString * mTarget;
@property (nonatomic) NSInteger mPort;
@property (nonatomic) NSTimeInterval mInterPacketTimeSeconds;
@property (nonatomic) NSTimeInterval mDelayTimeoutSeconds;
@property (nonatomic) NSInteger mNumberOfPackets;
@property (nonatomic) NSInteger mPercentile;
@property (nonatomic) NSTimeInterval mMaxTimeSeconds;
@end


@interface SKKitTestDescriptor_Upload : SKKitTestDescriptor
@property (nonatomic, copy) NSString * mTarget;
@property (nonatomic) NSInteger mPort;
@property (nonatomic) NSTimeInterval mWarmupMaxTimeSeconds;
@property (nonatomic) NSTimeInterval mTransferMaxTimeSeconds;
@property (nonatomic) NSInteger mWarmupMaxBytes;
@property (nonatomic) NSInteger mTransferMaxBytes;
@property (nonatomic) NSInteger mNumberOfThreads;
@property (nonatomic) NSInteger mSendDataChunkSizeBytes;
@property (nonatomic) NSInteger mPostDataLengthBytes;
@end

@protocol SKKitTestProtocol <NSObject>
-(void) cancel;
-(NSDictionary*) getTestResultsDictionary;
@end

typedef void (^TSKDownloadTestProgressUpdate)(float progress0To100Percent, double bitrateMbps1024Based);
typedef void (^TSKUploadTestProgressUpdate)(float progress0To100Percent, double bitrateMbps1024Based);
typedef void (^TSKLatencyTestProgressUpdate)(BOOL finalResult, float progress, double latency, double packetLoss, double jitter);

@interface SKKitTestClosestTarget : NSObject<SKKitTestProtocol>
- (instancetype)initWithClosestTargetTestDescriptor:(SKKitTestDescriptor_ClosestTarget*)closestTarget;
// SKKitTestProtocol
- (void) cancel;
-(NSDictionary*) getTestResultsDictionary;
@end

@interface SKKitTestDownload : NSObject<SKKitTestProtocol>
@property (copy) TSKDownloadTestProgressUpdate mProgressBlock;

- (instancetype)initWithDownloadTestDescriptor:(SKKitTestDescriptor_Download*)downloadTest;
- (void) start:(TSKDownloadTestProgressUpdate)progressBlock;
// SKKitTestProtocol
- (void) cancel;
-(NSDictionary*) getTestResultsDictionary;
@end


@interface SKKitTestUpload : NSObject<SKKitTestProtocol>
@property (copy) TSKUploadTestProgressUpdate mProgressBlock;

- (instancetype)initWithUploadTestDescriptor:(SKKitTestDescriptor_Upload*)uploadTest;
- (void) start:(TSKUploadTestProgressUpdate)progressBlock;
-(CGFloat) getLatestSpeedAs1000BasedMbps;
// SKKitTestProtocol
- (void) cancel;
-(NSDictionary*) getTestResultsDictionary;
@end


@interface SKKitTestLatency : NSObject<SKKitTestProtocol>
@property (copy) TSKLatencyTestProgressUpdate mProgressBlock;

- (instancetype)initWithLatencyTestDescriptor:(SKKitTestDescriptor_Latency*)latencyTest;
- (void) start:(TSKLatencyTestProgressUpdate)progressBlock;
//- (double) getProgress0To100;
// SKKitTestProtocol
- (void) cancel;
-(NSDictionary*) getTestResultsDictionary;
@end