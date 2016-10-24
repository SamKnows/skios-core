//
//  SKTest.h
//  SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKTest : NSObject

// Test string list results
@property (atomic, strong) NSMutableArray *outputResultsArray;
@property (atomic, strong) NSMutableDictionary *outputResultsDictionary;

// Final test results
@property (atomic, assign) double latency;
@property (atomic, assign) int packetLoss;
@property (atomic, assign) double jitter;
@property (atomic, assign) double stdDeviation;


-(SKKitTestLatencyDetailedResults*) getDetailedLatencyResults;

@end
