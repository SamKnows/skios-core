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
#import "SKScheduleParser.h"
#import "SKKitTestAdaptor.h"

@interface SKTestRunner()
@end

@implementation SKTestRunner
- (instancetype)initFromScheduleParser:(SKScheduleParser *)fromScheduleParser
{
  self = [super init];
  if (self) {
    NSMutableArray *testArray = [fromScheduleParser getTestArray];
    
    for (SKScheduleTest *testDescriptor in testArray) {
      switch ([testDescriptor getType]) {
        case SKTestType_Closest:
        {
          SKKitTestClosestTarget *closestTest = [[SKKitTestClosestTarget alloc] initWithClosestTargetTestDescriptor:(SKScheduleTest_Descriptor_ClosestTarget*)testDescriptor];
          // TODO!
          SK_ASSERT(closestTest != nil);
        }
          break;
        case SKTestType_Download:
        {
          SKKitTestDownload *downloadTest = [[SKKitTestDownload alloc] initWithDownloadTestDescriptor:(SKScheduleTest_Descriptor_Download*)testDescriptor];
          // TODO!
          SK_ASSERT(downloadTest != nil);
        }
          break;
        case SKTestType_Upload:
        {
          SKKitTestUpload *uploadTest = [[SKKitTestUpload alloc] initWithUploadTestDescriptor:(SKScheduleTest_Descriptor_Upload*)testDescriptor];
          // TODO!
          SK_ASSERT(uploadTest != nil);
        }
          break;
        case SKTestType_Latency:
        {
          SKKitTestLatency *latencyTest = [[SKKitTestLatency alloc] initWithLatencyTestDescriptor:(SKScheduleTest_Descriptor_Latency*)testDescriptor];
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
