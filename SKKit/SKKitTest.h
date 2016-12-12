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

typedef enum SKKitTestResultStatus_ {
  SKKitTestResultStatus_Unknown=0,
  SKKitTestResultStatus_Passed_Green=1,
  SKKitTestResultStatus_Failed_Red=2,
  SKKitTestResultStatus_Warning_Yellow=3,
  SKKitTestResultStatus_Clear=4
} SKKitTestResultStatus;

typedef enum SKKitTestType_t {
  SKKitTestType_Closest=0,
  SKKitTestType_Download=1,
  SKKitTestType_Upload=2,
  SKKitTestType_Latency=3,
  SKKitTestType_Html=4,
  SKKitTestType_Netflix=5,
  SKKitTestType_YouTube=6,
  SKKitTestType_Ping=7
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
-(SKKitTestType) getTestType;
-(NSDictionary*) getTestResultsDictionary;
-(NSString*) getTestResultValueString; // e.g. 17.2 Mbps
-(SKKitTestResultStatus) getTestResultStatus; // e.g. SKKitTestResultStatus_Passed_Green
@end

typedef void (^TSKClosestTargetTestProgressUpdate)(float progress0To100Percent, NSString *closestTarget);
typedef void (^TSKDownloadTestProgressUpdate)(float progress0To100Percent, double bitrateMbps1024Based);
typedef void (^TSKUploadTestProgressUpdate)(float progress0To100Percent, double bitrateMbps1024Based);
typedef void (^TSKLatencyTestProgressUpdate)(BOOL finalResult, float progress, double latency, double packetLoss, double jitter);

@interface SKKitTestClosestTarget : NSObject<SKKitTestProtocol>
@property (copy) TSKClosestTargetTestProgressUpdate mProgressBlock;

- (instancetype)initWithClosestTargetTestDescriptor:(SKKitTestDescriptor_ClosestTarget*)closestTarget;
- (void) start:(TSKClosestTargetTestProgressUpdate)progressBlock;
- (float) getProgress0To1;
// SKKitTestProtocol
- (void) cancel;
-(SKKitTestType) getTestType;
-(NSDictionary*) getTestResultsDictionary;
-(NSString*) getTestResultValueString; // e.g. ""
-(SKKitTestResultStatus) getTestResultStatus; // e.g. SKKitTestResultStatus_Passed_Green
@end

@interface SKKitTestDownload : NSObject<SKKitTestProtocol>
@property (copy) TSKDownloadTestProgressUpdate mProgressBlock;

- (instancetype)initWithDownloadTestDescriptor:(SKKitTestDescriptor_Download*)downloadTest;
- (void) start:(TSKDownloadTestProgressUpdate)progressBlock;
// SKKitTestProtocol
- (void) cancel;
-(SKKitTestType) getTestType;
-(NSDictionary*) getTestResultsDictionary;
-(NSString*) getTestResultValueString; // e.g. "my target"
-(SKKitTestResultStatus) getTestResultStatus; // e.g. SKKitTestResultStatus_Passed_Green
// Following is used for mock testing only...
-(void)setMockTestResultsDictionary:(NSDictionary*)mockResults;
@end


@interface SKKitTestUpload : NSObject<SKKitTestProtocol>
@property (copy) TSKUploadTestProgressUpdate mProgressBlock;

- (instancetype)initWithUploadTestDescriptor:(SKKitTestDescriptor_Upload*)uploadTest;
- (void) start:(TSKUploadTestProgressUpdate)progressBlock;
-(CGFloat) getLatestSpeedAs1000BasedMbps;
// SKKitTestProtocol
- (void) cancel;
-(SKKitTestType) getTestType;
-(NSDictionary*) getTestResultsDictionary;
-(NSString*) getTestResultValueString; // e.g. 17.2 Mbps
-(SKKitTestResultStatus) getTestResultStatus; // e.g. SKKitTestResultStatus_Passed_Green
// Following is used for mock testing only...
-(void)setMockTestResultsDictionary:(NSDictionary*)mockResults;
@end

@interface SKKitTestLatencyDetailedResults : NSObject
@property int mRttAvg;
@property int mRttMin;
@property int mRttMax;
@property int mPacketsSent;
@property int mPacketsReceived;
@property int mJitter;
@end

@interface SKKitTestLatency : NSObject<SKKitTestProtocol>
@property (copy) TSKLatencyTestProgressUpdate mProgressBlock;

- (instancetype)initWithLatencyTestDescriptor:(SKKitTestDescriptor_Latency*)latencyTest;
- (void) start:(TSKLatencyTestProgressUpdate)progressBlock;
//- (double) getProgress0To100;
// SKKitTestProtocol
- (void) cancel;
-(SKKitTestType) getTestType;
-(NSDictionary*) getTestResultsDictionary;
-(NSString*) getTestResultValueString; // e.g. 5 ms
-(SKKitTestResultStatus) getTestResultStatus; // e.g. SKKitTestResultStatus_Passed_Green
// Following is used for mock testing only...
-(void)setMockTestResultsDictionary:(NSDictionary*)mockResults;

-(SKKitTestLatencyDetailedResults*) getDetailedLatencyResults;
-(NSTimeInterval) getDurationSeconds;
-(NSNumber*) getPacketLossPercent;
-(NSNumber*) getJitterMilliseconds;

@end
