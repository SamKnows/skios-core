//
//  SKKitTestClosestTarget.m
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
// Test: Closest Target - TODO - this has yet to be implemented fully.
//
@interface SKKitTestClosestTarget () <SKClosestTargetDelegate>
@property SKClosestTargetTest *mpClosestTargetTest;
//@property SKKitTestDescriptor_ClosestTarget *abc;
@end

@implementation SKKitTestClosestTarget

@synthesize mpClosestTargetTest;

- (instancetype)initWithClosestTargetTestDescriptor:(SKKitTestDescriptor_ClosestTarget*)closestTarget {
  self = [super init];
  
  if (self) {
    NSLog(@"DEBUG: SKKitTestClosestTarget - init");
    mpClosestTargetTest = [[SKClosestTargetTest alloc] initWithTargets:closestTarget.mTargetArray ClosestTargetDelegate:self NumDatagrams:0];
  }
  return self;
}

-(void)dealloc {
  NSLog(@"DEBUG: SKKitTestClosestTarget - dealloc");
  mpClosestTargetTest = nil;
}

- (void)ctdDidCompleteClosestTargetTest:(NSString*)target latency:(double)latency {
  // TODO
}

- (void)ctdTestDidFail {
  // TODO
}
- (void)ctdDidSendPacket:(NSUInteger)bytes {
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] amdDoUpdateDataUsage:bytes];
}

- (void)ctdDidStartTargetTesting {
  // TODO
}

- (void)ctdDidFinishAnotherTarget:(int)targetId withLatency:(double)latency withBest:(int)bestId {
  // TODO
}

- (void) cancel {
  // TODO!
  SK_ASSERT(false);
}

@end
