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
#import "SKKitTest.h"

// TODO - this class is incomplete, as it doesn't yet run!

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
          __unused SKKitTestClosestTarget *closestTest = [[SKKitTestClosestTarget alloc] initWithClosestTargetTestDescriptor:(SKKitTestDescriptor_ClosestTarget*)testDescriptor];
          // TODO!
          SK_ASSERT(closestTest != nil);
          SK_ASSERT(false); // Not yet Used!
        }
          break;
        case SKKitTestType_Download:
        {
          __unused SKKitTestDownload *downloadTest = [[SKKitTestDownload alloc] initWithDownloadTestDescriptor:(SKKitTestDescriptor_Download*)testDescriptor];
          // TODO!
          SK_ASSERT(downloadTest != nil);
          SK_ASSERT(false); // Not yet Used!
        }
          break;
        case SKKitTestType_Upload:
        {
          __unused SKKitTestUpload *uploadTest = [[SKKitTestUpload alloc] initWithUploadTestDescriptor:(SKKitTestDescriptor_Upload*)testDescriptor];
          // TODO!
          SK_ASSERT(uploadTest != nil);
          SK_ASSERT(false); // Not yet Used!
        }
          break;
        case SKKitTestType_Latency:
        {
          __unused SKKitTestLatency *latencyTest = [[SKKitTestLatency alloc] initWithLatencyTestDescriptor:(SKKitTestDescriptor_Latency*)testDescriptor];
          // TODO!
          SK_ASSERT(latencyTest != nil);
          SK_ASSERT(false); // Not yet Used!
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
