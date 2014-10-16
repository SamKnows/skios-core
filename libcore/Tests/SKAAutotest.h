//
// SKAAutotest.h
// SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKAAutotest : SKAutotest

#define kSKAAutoTest_UDPFailedSkipTests @"kSKAAutoTest_UDPFailedSkipTests"
#define kSKAAutoTest_GeneratedTestId @"kSKAAutoTest_GeneratedTestId"

-(id) initAndRunWithAutotestManagerDelegate:(id<SKAutotestManagerDelegate>)inAutotestManagerDelegate AndAutotestObserverDelegate:(id<SKAutotestObserverDelegate>)inAutotestObserverDelegate AndTestType:(TestType)testType IsContinuousTesting:(BOOL)isContinuousTesting;


//API API API **********************************************************
-(id) initAndRunWithAutotestManagerDelegateWithBitmask:(id<SKAutotestManagerDelegate>)inAutotestManagerDelegate autotestObserverDelegate:(id<SKAutotestObserverDelegate>)inAutotestObserverDelegate TestsToExecuteBitmask:(int)tests2execute isContinuousTesting:(BOOL)isContinuousTesting;

@end