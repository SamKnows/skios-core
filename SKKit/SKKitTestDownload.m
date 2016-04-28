//
//  SKKitTestDownload.m
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
// Test: Download
//
@interface SKKitTestDownload () <SKHttpTestDelegate>
@property SKHttpTest *mpDownloadTest;
@end

@implementation SKKitTestDownload

@synthesize mpDownloadTest;
@synthesize mProgressBlock;

- (instancetype)initWithDownloadTestDescriptor:(SKKitTestDescriptor_Download*)downloadTest {
  self = [super init];
  
  if (self) {
    NSLog(@"DEBUG: SKKitTestDownload - init");
    mpDownloadTest = [[SKHttpTest alloc]
                      initWithTarget:downloadTest.mTarget
                      port:(int)downloadTest.mPort
                      file:downloadTest.mFile
                      isDownstream:YES
                      warmupMaxTime:downloadTest.mWarmupMaxTimeSeconds*1000000.0
                      warmupMaxBytes:0
                      TransferMaxTimeMicroseconds:downloadTest.mTransferMaxTimeSeconds*1000000.0
                      transferMaxBytes:0
                      nThreads:(int)downloadTest.mNumberOfThreads
                      HttpTestDelegate:self];
  }
  return self;
}

-(void)dealloc {
#ifdef DEBUG
  NSLog(@"DEBUG: SKKitTestDownload - dealloc");
#endif // DEBUG
  
  mpDownloadTest = nil;
}

- (void) start:(TSKDownloadTestProgressUpdate)progressBlock {
  self.mProgressBlock = progressBlock;
  [mpDownloadTest startTest];
}

- (void) cancel {
  [mpDownloadTest cancel];
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
