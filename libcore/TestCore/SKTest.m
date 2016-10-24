//
//  SKTest.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKTest.h"

@interface SKTest()
@property  SKKitTestLatencyDetailedResults *mpDetailedResults;
@end

@implementation SKTest

@synthesize outputResultsDictionary;

// Final test results
@synthesize latency;
@synthesize packetLoss;
@synthesize jitter;
@synthesize stdDeviation;

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.mpDetailedResults = [[SKKitTestLatencyDetailedResults alloc] init];
  }
  return self;
}

-(SKKitTestLatencyDetailedResults*) getDetailedLatencyResults {
  SK_ASSERT(self.mpDetailedResults != nil);
  return self.mpDetailedResults;
}

@end
