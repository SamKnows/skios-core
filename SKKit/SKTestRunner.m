//
//  SKTestRunner.m
//  SKKit
//
//  Created by Pete Cole on 26/01/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKTestRunner.h"

// https://developer.apple.com/library/mac/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html
// This is how you access Swift class code!
//#import <SKKit/SKKit-Swift.h>

#import "SKCore.h"
#import "SKKitTestDescriptor.h"
#import "SKKitTest.h"

@interface SKTestRunner()
@end

@implementation SKTestRunner
- (instancetype)initFromScheduleParser:(SKScheduleParser *)fromScheduleParser
{
  self = [super init];
  if (self) {
    NSMutableArray *testArray = [fromScheduleParser getTestArray];
    
    for (SKKitTestDescriptor *testDescriptor in testArray) {
      switch ([testDescriptor getType]) {
        case SKKitTestType_Closest:
        {
          SKKitTestClosestTarget *closestTest = [[SKKitTestClosestTarget alloc] initWithClosestTargetTestDescriptor:(SKKitTestDescriptor_ClosestTarget*)testDescriptor];
          // TODO!
          SK_ASSERT(closestTest != nil);
        }
          break;
        case SKKitTestType_Download:
        {
          SKKitTestDownload *downloadTest = [[SKKitTestDownload alloc] initWithDownloadTestDescriptor:(SKKitTestDescriptor_Download*)testDescriptor];
          // TODO!
          SK_ASSERT(downloadTest != nil);
        }
          break;
        case SKKitTestType_Upload:
        {
          SKKitTestUpload *uploadTest = [[SKKitTestUpload alloc] initWithUploadTestDescriptor:(SKKitTestDescriptor_Upload*)testDescriptor];
          // TODO!
          SK_ASSERT(uploadTest != nil);
        }
          break;
        case SKKitTestType_Latency:
        {
          SKKitTestLatency *latencyTest = [[SKKitTestLatency alloc] initWithLatencyTestDescriptor:(SKKitTestDescriptor_Latency*)testDescriptor];
          // TODO!
          SK_ASSERT(latencyTest != nil);
        }
          break;
        default:
          SK_ASSERT(false);
      }
    }
  }
  return self;
}
@end
