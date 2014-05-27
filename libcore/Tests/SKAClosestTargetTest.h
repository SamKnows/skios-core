//
// SKAClosestTargetTest.h
// SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

@interface SKAClosestTargetTest : SKClosestTargetTest

// Must be overridden!
+(SKLatencyOperation*) createLatencyOperationWithTarget:(NSString*)_target 
  port:(int)_port 
  numDatagrams:(int)_numDatagrams 
  interPacketTime:(double)_interPacketTime
  delayTimeout:(double)_delayTimeout
  percentile:(long)_percentile
  maxExecutionTime:(double)_maxExecutionTime
  threadId:(int)_threadId
  TheTest:(SKTest*)inTheTest
  LatencyOperationDelegate:(id<SKLatencyOperationDelegate>)_delegate;

@end
