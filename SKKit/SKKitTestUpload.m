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
@property SKHttpTest *mpUploadTest;
@end

@implementation SKKitTestUpload

@synthesize mpUploadTest;
@synthesize mProgressBlock;

- (instancetype)initWithUploadTestDescriptor:(SKKitTestDescriptor_Upload*)uploadTest {
  self = [super init];
  
  if (self) {
    NSLog(@"DEBUG: SKKitTestUpload - init");
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

- (void) cancel {
  [mpUploadTest cancel];
}

-(CGFloat) getLatestSpeedAs1000BasedMbps {
  return [SKJHttpTest sGetLatestSpeedForExternalMonitorAsMbps];
}


// Pragma SKHttpTestDelegate

- (void)htdUpdateStatus:(TransferStatus)status
               threadId:(NSUInteger)threadId {
  switch (status) {
    case FAILED:
#ifdef DEBUG
      NSLog(@"DEBUG: SKKitTestDownload - failed!");
#endif // DEBUG
      mProgressBlock(100.0, -1.0);
      break;
    case CANCELLED:
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
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] amdDoUpdateDataUsage:bytes];
}

- (void)htdDidUpdateTotalProgress:(float)progress BitrateMbps1024Based:(double)bitrateMbps1024Based {
  mProgressBlock(progress, bitrateMbps1024Based);
}

- (void)htdDidCompleteHttpTest:(double)bitrateMbps1024Based
            ResultIsFromServer:(BOOL)resultIsFromServer
               TestDisplayName:(NSString *)testDisplayName
{
  mProgressBlock(100.0, bitrateMbps1024Based);
}
@end
