//
//  SKKitTestDescriptor.h
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

@interface SKScheduleParser : NSObject <NSXMLParserDelegate>
- (instancetype)initFromXMLString:(NSString *)fromXMLString;
- (NSMutableArray *)getHostArray;
- (NSMutableArray *)getTestArray;
- (double)getDataCapMbps;
-(SKTestRunner*)createTestRunner;
- (void)helloWorld;
@end