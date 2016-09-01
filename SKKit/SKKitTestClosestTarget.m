//
//  SKKitTestClosestTarget.m
//  SKKit
//
//  Created by Pete Cole on 26/01/2015.
//  Copyright (c) 2015-2016 SamKnows. All rights reserved.
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
// Test: Closest Target - TODO - this has yet to be implemented fully.
//
@interface SKKitTestClosestTarget () <SKClosestTargetDelegate>
@property SKClosestTargetTest *mpClosestTargetTest;
@property (nonatomic, retain) NSMutableArray * mTargetArray;
@property int completedTargets;
@property float mfProgress0To1;
@property NSString *mSelectedTarget;
//@property SKKitTestDescriptor_ClosestTarget *abc;
@end

@implementation SKKitTestClosestTarget

@synthesize mpClosestTargetTest;
@synthesize mProgressBlock;
@synthesize mTargetArray;
@synthesize completedTargets;
@synthesize mfProgress0To1;
@synthesize mSelectedTarget;

- (instancetype)initWithClosestTargetTestDescriptor:(SKKitTestDescriptor_ClosestTarget*)closestTarget {
  self = [super init];
  
  if (self) {
#ifdef _DEBUG
    NSLog(@"DEBUG: SKKitTestClosestTarget - init");
#endif // _DEBUG
    mTargetArray = closestTarget.mTargetArray;
    mpClosestTargetTest = [[SKClosestTargetTest alloc] initWithTargets:mTargetArray ClosestTargetDelegate:self NumDatagrams:0];
    mProgressBlock = nil;
    completedTargets = 0;
    mfProgress0To1 = 0.0F;
    mSelectedTarget = @"";
  }
  return self;
}

-(void)dealloc {
  NSLog(@"DEBUG: SKKitTestClosestTarget - dealloc");
  mpClosestTargetTest = nil;
}

- (void)ctdDidCompleteClosestTargetTest:(NSString*)target latency:(double)latency {
//  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    mProgressBlock(100.0, target);
//  });
}

- (void)ctdTestDidFail {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    mProgressBlock(100.0, nil);
  });
}
- (void)ctdDidSendPacket:(NSUInteger)bytes {
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] amdDoUpdateDataUsage:(int)bytes];
}

- (void)ctdDidStartTargetTesting {
  mProgressBlock(0.0, nil);
}

- (void)ctdDidFinishAnotherTarget:(int)targetId withLatency:(double)latency withBest:(int)bestId {
  // TODO
  completedTargets += 1;
  
  int divideBy = (int) mTargetArray.count;
  if (divideBy == 0) {
    SK_ASSERT(false);
    divideBy = 1;
  }
  
  float progressPercent = (100.0 * (float) completedTargets) / ((float)divideBy);
  
  if (progressPercent >= 99.0) {
    progressPercent = 99.0;
  }
  
  mfProgress0To1 = progressPercent;

  mProgressBlock(progressPercent, nil);
}

- (void) start:(TSKClosestTargetTestProgressUpdate)progressBlock {
  mProgressBlock = progressBlock;
  
	dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
  dispatch_async(backgroundQueue, ^{
    [mpClosestTargetTest startTest];
  });
}

// MARK: pragma SKKitTestProtocol

- (void) cancel {
  // TODO!
  SK_ASSERT(false);
}

- (float) getProgress0To1 {
  return mfProgress0To1;
}

-(SKKitTestType) getTestType {
  return SKKitTestType_Closest;
}

-(NSDictionary*) getTestResultsDictionary {
  // The underlying results are marked with the underlying "Latency Test" type.
  // We need to update this with the correct target type of "CLOSESTTARGET"
  SK_ASSERT(mpClosestTargetTest.outputResultsDictionary != nil);
  mpClosestTargetTest.outputResultsDictionary[@"type"] = CLOSESTTARGET;
  return mpClosestTargetTest.outputResultsDictionary;
}

-(NSString*) getTestResultValueString { // e.g. 17.2 Mbps
  // Not much use for Closest Target - should probably never be called  
  return mSelectedTarget;
}

@end
