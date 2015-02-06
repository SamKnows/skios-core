//
//  SKTestConfig.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKTestConfig.h"

@interface SKTestConfig ()

@end

@implementation SKTestConfig

@synthesize info;
@synthesize type;
@synthesize conditionGroupId;
@synthesize displayName;
@synthesize executeTimes;
@synthesize params;
@synthesize output;
@synthesize conditions;
@synthesize testConfigDelegate;

- (BOOL)checkTestConditions
{
  // After discussion with Sam on 02/10/2013, it was decided to remove the CPU measurement
  // condition check on iOS, as the intention was ONLY to use this for BACKGROUND tests;
  // which do not apply on iOS (where we only allow manual tests!).
  // And as the CPU measurement condition was the only remaining condition test used on iOS,
  // this method now simply returns YES...
  return YES;
  
  /*
   if (conditions == nil) {
   // if there are no conditions for this test, then pass it!
   return YES;
   }
   
   NSArray *cnds = [conditions objectForKey:@"condition_types"];
   
   if (cnds == nil)
   {
   // if there are no conditions for this test, then pass it!
   return YES;
   }
   
   for (int m=0; m<[cnds count]; m++)
   {
   NSDictionary *cond = [cnds objectAtIndex:m];
   
   if (cond == nil)
   {
   continue;
   }
   
   NSString *condType = [cond objectForKey:@"type"];
   if (condType == nil) {
   continue;
   }
   
   if ([condType isEqualToString:@"CpuActivity"])
   {
   if ([cond objectForKey:@"maxAvg"])
   {
   int maxCpu = [[cond objectForKey:@"maxAvg"] intValue];
   int currentCpu = (int)[SKGlobalMethods getCpuUsage];
   NSLog(@"Max CPU: %d, Current CPU: %d", maxCpu, currentCpu);
   
   BOOL bSuccess = YES;
   if (currentCpu > maxCpu)
   {
   // On a iPhone 5, run just as a test has completed, the CPU test can return a value
   // of 50...
   // when the maximum allowed by a condition might only be 25; that can lead to
   // a condition test failure; which can lead to tests not being run, for
   // reasons that would never be clear to the end user!
   
   // It is essential to SLEEP for a bit; otherwise, the other threads interfere to give
   // a misleading CPU measurement on iOS - which can lead tests to fail, leading to much
   // confusion for the end user.
   // The CPU measurement is intended to be a measure of how much the overall device
   // is under load; repeating this measurement, after a very short sleep, gives a much
   // more useful measurement of this value.
   // Bottom line - there is no way that a 25% CPU threshold check should cause a
   // lightly-loaded iPhone 5 to fail the test due to the CPU usage check!
   [NSThread sleepForTimeInterval:0.5];
   currentCpu = (int)[SKGlobalMethods getCpuUsage];
   NSLog(@"Max CPU: %d, re-measured CPU: %d", maxCpu, currentCpu);
   }
   
   if (currentCpu > maxCpu) {
   bSuccess = NO;
   NSLog(@"Failed CPU condition (!): Max CPU: %d, Current CPU: %d", maxCpu, currentCpu);
   }
   
   //NSLog(@"***** HORRIBLE HACK FOR TESTING!"); bSuccess = NO;
   
   if (nil != self.testConfigDelegate)
   {
   [self.testConfigDelegate tcdSetCPUConditionResult:maxCpu avgCPU:currentCpu Success:bSuccess  Type:condType];
   }
   
   if (bSuccess == NO)
   {
   // FAILED!
   return NO;
   }
   }
   }
   }
   
   // Passed.
   return YES;
   */
}

// Special case for closestTarget test, return all the targets
- (NSMutableArray*)getTargets
{
  if ([type isEqualToString:@"closestTarget"])
  {
    if (nil != params)
    {
      if ([params count] > 0)
      {
        NSMutableArray *targets = [[NSMutableArray alloc] init];
        
        for (int j=0; j<[params count]; j++)
        {
          NSDictionary *d = [params objectAtIndex:j];
          
          if (nil != d)
          {
            NSString *target = [d objectForKey:@"target"];
            
            if (nil != target)
            {
              [targets addObject:target];
            }
          }
        }
        
        return targets;
      }
    }
  }
  
  return nil;
}

- (NSString*)getNetworkType
{
  NSString *netType = nil;
  
  if (nil != conditions)
  {
    if ([conditions count] > 0)
    {
      if ([conditions objectForKey:@"condition_types"])
      {
        NSArray *condTypes = [conditions objectForKey:@"condition_types"];
        
        if (condTypes)
        {
          if ([condTypes count] > 0)
          {
            for (int m=0; m<[condTypes count]; m++)
            {
              NSDictionary *d = [condTypes objectAtIndex:m];
              
              if (d)
              {
                if ([d objectForKey:@"networkType"])
                {
                  NSLog(@"GOT networkType : %@", [d objectForKey:@"networkType"]);
                  netType = [d objectForKey:@"networkType"];
                }
              }
            }
          }
        }
      }
    }
  }
  
  return netType;
}

- (id)paramObjectForKey:(NSString*)key
{
  if (nil == params) return nil;
  if ([params count] == 0) return nil;
  
  for (NSDictionary *dictionary in params)
  {        
    if ([dictionary objectForKey:key])
    {
      return [dictionary objectForKey:key];
    }
  }
  
  return nil;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
  self = [super init];
  
  if (self)
  {
    info = [dictionary copy];
    
    if (nil != info)
    {
      if ([info objectForKey:@"type"])
      {
        type = [[NSString alloc] initWithString:[info objectForKey:@"type"]];
      }
      
      if ([info objectForKey:@"condition_group_id"])
      {
        conditionGroupId = [[NSString alloc] initWithString:[info objectForKey:@"condition_group_id"]];
      }
      
      if ([info objectForKey:@"displayName"])
      {
        displayName = [[NSString alloc] initWithString:[info objectForKey:@"displayName"]];
      }
      
      if ([info objectForKey:@"executeAt"])
      {
        executeTimes = [[NSMutableArray alloc] initWithArray:[info objectForKey:@"executeAt"]];
      }
      
      if ([info objectForKey:@"params"])
      {
        params = [[NSMutableArray alloc] initWithArray:[info objectForKey:@"params"]];
      }
      
      if ([info objectForKey:@"output"])
      {
        output = [[NSMutableDictionary alloc] initWithDictionary:[info objectForKey:@"output"]];
      }
      
      if ([info objectForKey:@"conditions"])
      {
        conditions = [[NSMutableDictionary alloc] initWithDictionary:[info objectForKey:@"conditions"]];
      }
    }
  }
  
  return self;
}


@end
