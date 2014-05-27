//
// SKAHttpTest.m
// SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#pragma mark - Interface

@interface SKAHttpTest ()

@end

#pragma mark - Implementation

@implementation SKAHttpTest

@synthesize outputResultsDictionary;

- (id)initWithTarget:(NSString*)_target
                port:(int)_port
                file:(NSString*)_file
        isDownstream:(BOOL)_isDownstream
       warmupMaxTime:(double)_warmupMaxTime
      warmupMaxBytes:(double)_warmupMaxBytes
     TransferMaxTimeMicroseconds:(SKTimeIntervalMicroseconds)_transferMaxTimeMicroseconds
    transferMaxBytes:(double)_transferMaxBytes
            nThreads:(int)_nThreads
            HttpTestDelegate:(id <SKHttpTestDelegate>)_delegate
{
  return [super initWithTarget:_target
                          port:_port
                          file:_file
                  isDownstream:_isDownstream
                 warmupMaxTime:(double)_warmupMaxTime
                warmupMaxBytes:(double)_warmupMaxBytes
               TransferMaxTimeMicroseconds:(double)_transferMaxTimeMicroseconds
              transferMaxBytes:(double)_transferMaxBytes
                      nThreads:_nThreads
                      HttpTestDelegate:_delegate
             runAsynchronously:NO];
}


- (void)storeOutputResults
{
    //    "type": "JHTTPPOSTMT",
    //    "bytes_sec": "167995",
    //    "datetime": "Fri Jan 25 15:35:36 GMT 2013",
    //    "number_of_threads": "3",
    //    "success": "true",
    //    "target": "n1-the1.samknows.com",
    //    "target_ipaddress": "46.17.56.234",
    //    "timestamp": "1359128136",
    //    "transfer_bytes": "1944064",
    //    "transfer_time": "11572113",
    //    "warmup_bytes": "114176",
    //    "warmup_time": "1496460"
    
    outputResultsDictionary = [[NSMutableDictionary alloc] init];
    
    if (self.isDownstream)
    {
        NSString *type = (self.nThreads == 1) ? DOWNSTREAMSINGLE : DOWNSTREAMMULTI;
        
        [outputResultsDictionary setObject:type
                          forKey:@"type"];
    }
    else
    {
        NSString *type = (self.nThreads == 1) ? UPSTREAMSINGLE : UPSTREAMMULTI;
        
        [outputResultsDictionary setObject:type
                          forKey:@"type"];
    }
    
    [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", [self getBytesPerSecond]]
                      forKey:@"bytes_sec"];
    
    [outputResultsDictionary setObject:[NSDate sGetDateAsIso8601String:[SKCore getToday]] forKey:@"datetime"];
    
    [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", self.nThreads]
                      forKey:@"number_of_threads"];
    
    [outputResultsDictionary setObject:self.testOK ? @"true" : @"false"
                      forKey:@"success"];
    
    [outputResultsDictionary setObject:self.target
                      forKey:@"target"];
    
    [outputResultsDictionary setObject:[SKIPHelper hostIPAddress:self.target]
                      forKey:@"target_ipaddress"];
    
    [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)([[SKCore getToday] timeIntervalSince1970])]
                      forKey:@"timestamp"];
    
    [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)self.testTransferBytes]
                      forKey:@"transfer_bytes"];
    
    [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)(self.testTransferTimeMicroseconds)]
                      forKey:@"transfer_time"];
    
    [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)self.testWarmupBytes]
                      forKey:@"warmup_bytes"];
    
    [outputResultsDictionary setObject:[NSString stringWithFormat:@"%d", (int)((self.testWarmupEndTime - self.testWarmupStartTime) * 1000000)]
                      forKey:@"warmup_time"];
}

@end
