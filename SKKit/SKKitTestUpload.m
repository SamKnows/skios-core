//
//  SKKitTestUpload.m
//  SKKit
//
//  Created by Pete Cole on 26/01/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//

#import "SKKitTest.h"

#import "../../skios-core/libcore/SKCore.h"
#import "../../skios-core/libcore/TestCore/SKClosestTargetTest.h"
#import "../../skios-core/libcore/TestCore/SKJHttpTest.h"

// Without this call, we can't use Swift classes from our objective C.
// The file is AUTO-GENERATED and is under the build folder, you won't find it in the project area!
// Note that *only* swift code marked with @objc is put in this file...
//#import <SKKit/SKKit-Swift.h>

//
// Test: Upload
//

@interface SKKitTestUpload () <SKHttpTestDelegate>
@property SKKitTestResultStatus mStatus;
@property SKHttpTest *mpUploadTest;
@property double mLatestBitrateMbps1024Based;

@end

@implementation SKKitTestUpload

@synthesize mStatus;
@synthesize mpUploadTest;
@synthesize mProgressBlock;
@synthesize mLatestBitrateMbps1024Based;

- (instancetype)initWithUploadTestDescriptor:(SKKitTestDescriptor_Upload*)uploadTest {
  self = [super init];
  
  if (self) {
#ifdef _DEBUG
    NSLog(@"DEBUG: SKKitTestUpload - init");
#endif // _DEBUG
    mStatus = SKKitTestResultStatus_Unknown;
    
    mpUploadTest = [[SKHttpTest alloc]
                    initWithTarget:uploadTest.mTarget
                    port:(int)uploadTest.mPort
                    file:@"" // uploadTest.mFile
                    isDownstream:NO
                    warmupMaxTime:uploadTest.mWarmupMaxTimeSeconds*1000000.0
                    warmupMaxBytes:0
                    TransferMaxTimeMicroseconds:uploadTest.mTransferMaxTimeSeconds*1000000.0
                    transferMaxBytes:0
                    nThreads:(int)uploadTest.mNumberOfThreads
                    HttpTestDelegate:self];
  }
  return self;
}

-(void)dealloc {
  NSLog(@"DEBUG: SKKitTestUpload - dealloc");
  mpUploadTest = nil;
}

- (void) start:(TSKUploadTestProgressUpdate)progressBlock {
  self.mProgressBlock = progressBlock;
  [mpUploadTest startTest];
}

-(CGFloat) getLatestSpeedAs1000BasedMbps {
  return [SKJHttpTest sGetLatestSpeedForExternalMonitorAsMbps];
}

// MARK: pragma SKKitTestProtocol

- (void) cancel {
  [mpUploadTest cancel];
}

-(SKKitTestType) getTestType {
  return SKKitTestType_Upload;
}

-(NSDictionary*) getTestResultsDictionary {
  SK_ASSERT( mpUploadTest.outputResultsDictionary != nil);
  return mpUploadTest.outputResultsDictionary;
}

-(void)setMockTestResultsDictionary:(NSDictionary*)mockResults {
  mpUploadTest.outputResultsDictionary = [NSMutableDictionary dictionaryWithDictionary:mockResults];
}

-(NSString*) getTestResultValueString { // e.g. 17.2 Mbps
  
  if (mLatestBitrateMbps1024Based < 0) {
    return @"Failed";
  }
  return [SKGlobalMethods bitrateMbps1024BasedToString:mLatestBitrateMbps1024Based];
}

-(SKKitTestResultStatus) getTestResultStatus { // e.g. SKKitTestResultStatus_Passed_Green
  return mStatus;
}

// MARK: pragma SKHttpTestDelegate

- (void)htdUpdateStatus:(TransferStatus)status
               threadId:(NSUInteger)threadId {
  switch (status) {
    case FAILED:
#ifdef DEBUG
      NSLog(@"DEBUG: SKKitTestDownload - failed!");
#endif // DEBUG
      mStatus = SKKitTestResultStatus_Failed_Red;
      mLatestBitrateMbps1024Based = -1.0;
      mProgressBlock(100.0, -1.0);
      break;
    case CANCELLED:
      mStatus = SKKitTestResultStatus_Warning_Yellow;
      break;
    case INITIALIZING:
    case WARMING:
    case TRANSFERRING:
    case COMPLETE:
    case FINISHED:
    case IDLE:
    default:
      break;
  }
}

- (void)htdUpdateDataUsage:(NSUInteger)totalBytes
                     bytes:(NSUInteger)bytes
                  progress:(float)progress {
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] amdDoUpdateDataUsage:(int)bytes];
}

- (void)htdDidUpdateTotalProgressPercent:(float)progress0To100Percent BitrateMbps1024Based:(double)bitrateMbps1024Based {
  // We must NOT allow the test to complete until htdDidCompleteHttpTest is called;
  // as only at that point is the output result available.
  if (progress0To100Percent >= 99.0) {
    progress0To100Percent = 99.0;
  }

  mLatestBitrateMbps1024Based = bitrateMbps1024Based;
  
  mProgressBlock(progress0To100Percent, bitrateMbps1024Based);
}

- (void)htdDidCompleteHttpTest:(double)bitrateMbps1024Based
            ResultIsFromServer:(BOOL)resultIsFromServer
               TestDisplayName:(NSString *)testDisplayName

{
  if (mStatus == SKKitTestResultStatus_Unknown) {
    // TODO - mStatus = SKKitTestResultStatus_Warning_Yellow?
    mStatus = SKKitTestResultStatus_Passed_Green;
  }
  
  mLatestBitrateMbps1024Based = bitrateMbps1024Based;

  mProgressBlock(100.0, bitrateMbps1024Based);
}
@end
