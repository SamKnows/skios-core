//
// SKAAutotest.h
// SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKAAutotest : SKAutotest

#define kSKAAutoTest_UDPFailedSkipTests @"kSKAAutoTest_UDPFailedSkipTests"

-(id) initAndRunWithAutotestManagerDelegate:(id<SKAutotestManagerDelegate>)inAutotestManagerDelegate AndAutotestObserverDelegate:(id<SKAutotestObserverDelegate>)inAutotestObserverDelegate AndTestType:(TestType)testType IsContinuousTesting:(BOOL)isContinuousTesting;

@end