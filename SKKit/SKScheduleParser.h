//
//  SKScheduleParser.h
//  SKKit
//
//  Created by Pete Cole on 26/01/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//

#import <Foundation/Foundation.h>

//===

#import "SKTestRunner.h"

@interface SKScheduleHost : NSObject
- (NSString *)getDnsName;
- (NSString *)getDisplayName;
@end

@interface SKScheduleTest : NSObject
typedef enum SKTestType_t {
  SKTestType_Closest=0,
  SKTestType_Download=1,
  SKTestType_Upload=2,
  SKTestType_Latency=3
} SKTestType;

-(NSString *)getId;
-(SKTestType)getType;
-(NSString*)getDisplayName;
@end

@interface SKScheduleTest_Descriptor_ClosestTarget : SKScheduleTest
@property (nonatomic, retain) NSMutableArray * mTargetArray;
@end

@interface SKScheduleTest_Descriptor_Download : SKScheduleTest
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


@interface SKScheduleTest_Descriptor_Latency : SKScheduleTest
@property (nonatomic, copy) NSString * mTarget;
@property (nonatomic) NSInteger mPort;
@property (nonatomic) NSTimeInterval mInterPacketTimeSeconds;
@property (nonatomic) NSTimeInterval mDelayTimeoutSeconds;
@property (nonatomic) NSInteger mNumberOfPackets;
@property (nonatomic) NSInteger mPercentile;
@property (nonatomic) NSTimeInterval mMaxTimeSeconds;
@end


@interface SKScheduleTest_Descriptor_Upload : SKScheduleTest
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

@interface SKScheduleParser : NSObject <NSXMLParserDelegate>
- (instancetype)initFromXMLString:(NSString *)fromXMLString;
- (NSMutableArray *)getHostArray;
- (NSMutableArray *)getTestArray;
- (double)getDataCapMbps;
-(SKTestRunner*)createTestRunner;
- (void)helloWorld;
@end