//
// SKALatencyOperation.m
// SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//



#pragma mark - Interface

@interface SKALatencyOperation ()

@property SKTest *theTest;
@property NSMutableDictionary *outputResultsDictionary;

@end

@implementation SKALatencyOperation

@synthesize theTest;
@synthesize outputResultsDictionary;

#pragma mark - Init

- (id)initWithTarget:(NSString*)_target
                port:(int)_port
        numDatagrams:(int)_numDatagrams
     interPacketTime:(double)_interPacketTime
        delayTimeout:(double)_delayTimeout
          percentile:(long)_percentile
    maxExecutionTime:(double)_maxExecutionTime
            threadId:(int)_threadId
             TheTest:(SKTest*)inTheTest
            LatencyOperationDelegate:(id<SKLatencyOperationDelegate>)_delegate
{
  self = [super initWithTarget:_target
                          port:_port
                  numDatagrams:_numDatagrams
               interPacketTime:_interPacketTime
                  delayTimeout:_delayTimeout
                    percentile:_percentile
              maxExecutionTime:_maxExecutionTime
                      threadId:_threadId
                       TheTest:inTheTest
      LatencyOperationDelegate:_delegate
          ];
  
  if (self)
  {
    outputResultsDictionary = [[NSMutableDictionary alloc] init];
    theTest = inTheTest;
    
    if (![inTheTest.class isSubclassOfClass:[SKTest class]]) {
      SK_ASSERT(false);
      return nil;
    }
  }
  
  return self;
}

#pragma mark - Dealloc

- (void)tearDown
{
  [super tearDown];

  if (nil != outputResultsDictionary)
  {
    outputResultsDictionary = nil;
  }
}

- (void)outputResults
{
  [outputResultsDictionary removeAllObjects];
  
  //    "type": "JUDPLATENCY"
  //    "datetime": "Fri Jan 25 15:36:07 GMT 2013",
  //    "lost_packets": "1",
  //    "received_packets": "53",
  //    "rtt_avg": "255144",
  //    "rtt_max": "1488525",
  //    "rtt_min": "68023",
  //    "rtt_stddev": "243171",
  //    "success": "true",
  //    "target": "n1-the1.samknows.com",
  //    "target_ipaddress": "46.17.56.234",
  //    "timestamp": "1359128167"
  
  [outputResultsDictionary setObject:@"JUDPLATENCY"
                              forKey:@"type"];
  
  [outputResultsDictionary setObject:[NSDate sGetDateAsIso8601String:[SKCore getToday]] forKey:@"datetime"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", totalPacketsLost]
                              forKey:@"lost_packets"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", totalPacketsReceived]
                              forKey:@"received_packets"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)(averagePacketTime * ONE_MILLION)]
                              forKey:@"rtt_avg"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)(maximumTripTime * ONE_MILLION)]
                              forKey:@"rtt_max"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)(minimumTripTime * ONE_MILLION)]
                              forKey:@"rtt_min"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)(standardDeviation * ONE_MILLION)]
                              forKey:@"rtt_stddev"];
  
  [outputResultsDictionary setObject:testOK ? @"true" : @"false"
                              forKey:@"success"];
  
  [outputResultsDictionary setObject:target
                              forKey:@"target"];
  
  [outputResultsDictionary setObject:[SKIPHelper hostIPAddress:target]
                              forKey:@"target_ipaddress"];
  
  [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)([[SKCore getToday] timeIntervalSince1970])]
                              forKey:@"timestamp"];
  
  theTest.outputResultsDictionary = outputResultsDictionary;
}

@end
