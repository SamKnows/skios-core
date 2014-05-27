//
//  SKTestCommon.m
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "SKTestCommon.h"

@implementation DummyLatencyTest

- (void)lodTestDidSendPacket:(NSUInteger)bytes {
}

- (void)lodTestDidFail:(NSUInteger)threadId {
}


- (void)lodTestDidSucceed:(double)latency_
               packetLoss:(int)packetLoss_
                   jitter:(double)jitter_
             stdDeviation:(double)stdDeviation_
                 threadId:(NSUInteger)threadId_ {
}


- (void)lodTestWasCancelled:(NSUInteger)threadId {
}


- (void)lodUpdateProgress:(float)progress_ threadId:(NSUInteger)threadId {
}

- (void)lodUpdateStatus:(LatencyStatus)status_ threadId:(NSUInteger)threadId {
}
@end

@implementation DummyClosestTargetTest

- (void)ctdDidCompleteClosestTargetTest:(NSString*)target latency:(double)latency {
}
  
- (void)ctdTestDidFail {
}
  
- (void)ctdDidSendPacket:(NSUInteger)bytes {
}
@end
