//
//  SKTestCommon.h
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

@interface DummyLatencyTest : SKTest<SKLatencyOperationDelegate>
@end

@interface DummyClosestTargetTest : SKClosestTargetTest<SKClosestTargetDelegate>
@end
