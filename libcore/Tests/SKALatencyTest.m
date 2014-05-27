//
// SKALatencyTest.h
// SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

@implementation SKALatencyTest

// Must be overridden!
// http://qualitycoding.org/factory-method/
+(SKLatencyOperation*) createLatencyOperationWithTarget:(NSString*)_target 
                                                   port:(int)_port 
                                           numDatagrams:(int)_numDatagrams 
                                        interPacketTime:(double)_interPacketTime
                                           delayTimeout:(double)_delayTimeout
                                             percentile:(long)_percentile
                                       maxExecutionTime:(double)_maxExecutionTime
                                               threadId:(int)_threadId
                                                TheTest:(SKTest*)inTheTest
                               LatencyOperationDelegate:(id <SKLatencyOperationDelegate>)_delegate
{
  return [[SKALatencyOperation alloc] initWithTarget:_target
                                                port:_port
                                        numDatagrams:_numDatagrams
                                     interPacketTime:_interPacketTime
                                        delayTimeout:_delayTimeout
                                          percentile:_percentile
                                    maxExecutionTime:_maxExecutionTime
                                            threadId:_threadId
                                             TheTest:inTheTest
                            LatencyOperationDelegate:_delegate];
}

@end
