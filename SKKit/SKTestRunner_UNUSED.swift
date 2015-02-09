//
//  SKTestRunner.swift
//  SKKit
//
//  Created by Pete Cole on 26/01/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//

// This file was written originally to be used within SKKit, but was re-written in Objective-C
// (see SKTestRunner.m etc.), in order to allow it to be used from within the static library.

import Foundation

@objc
public class SKTestRunner :NSObject {
  
  // The instance of SKTestRunner is only to be created by SKScheduleParser...
  // Hence, the default constructor is private.
//  private init() {
//  }
  
  public init(fromScheduleParser:SKScheduleParser) {
    
    // TODO: Given the parsed test schedule, create the actual test instances, which are at teh Objective-C level
    // in the current implementation.
    // TODO: Once we have these, we can run the test - JUST ONCE (it is a single-shot run-through)
    // Note that the SKScheduleParser guarantees the integrity of the test structure (i.e. test ordering etc.)
    
    for test in fromScheduleParser.getTestArray() {
      if let testDescriptor = test as? SKScheduleTest_Descriptor_ClosestTarget {
        let closestTest = SKKitTestClosestTarget(closestTargetTestDescriptor: testDescriptor)
      }
      else if let testDescriptor = test as? SKScheduleTest_Descriptor_Download {
        let downloadTest = SKKitTestDownload(downloadTestDescriptor: testDescriptor)
      }
      else if let testDescriptor = test as? SKScheduleTest_Descriptor_Upload {
        let uploadTest = SKKitTestUpload(uploadTestDescriptor: testDescriptor)
      }
      else if let testDescriptor = test as? SKScheduleTest_Descriptor_Latency {
        let latencyTest = SKKitTestLatency(latencyTestDescriptor: testDescriptor)
      } else {
        SK_ASSERT(false)
      }
    }
  }
  
  deinit {
  }
  
  // TODO - run the tests. There will be a delegate required, and/or possibly some some simple completion
  // block that is called as the final test has been called.
  // Note that this final completion, and the callbacks, are intended to be handled ONLY on the main
  // UI thread, and this API might enforce that - TBD.
  public func runTests() {
    
  }
}
