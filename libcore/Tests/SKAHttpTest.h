//
// SKAHttpTest.h
// SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

@interface SKAHttpTest : SKHttpTest

@property (atomic, strong) NSMutableDictionary *outputResultsDictionary;

- (id)initWithTarget:(NSString*)_target
                port:(int)_port
                file:(NSString*)_file
        isDownstream:(BOOL)_isDownstream
       warmupMaxTime:(double)_warmupMaxTime
       warmupMaxBytes:(double)_warmupMaxBytes
     TransferMaxTimeMicroseconds:(SKTimeIntervalMicroseconds)_transferMaxTimeMicroseconds
     transferMaxBytes:(double)_transferMaxBytes
            nThreads:(int)_nThreads
            HttpTestDelegate:(id <SKHttpTestDelegate>)_delegate;

@end
