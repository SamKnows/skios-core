//
//  SKTestCommon.h
//

#import <XCTest/XCTest.h>

@interface DummyLatencyTest : SKTest<SKLatencyOperationDelegate>
@end

@interface DummyClosestTargetTest : SKClosestTargetTest<SKClosestTargetDelegate>
@end
