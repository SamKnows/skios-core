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

- (BOOL)checkTestConditions
{
  // After discussion with Sam on 02/10/2013, it was decided to remove the CPU measurement
  // condition check on iOS, as the intention was ONLY to use this for BACKGROUND tests;
  // which do not apply on iOS (where we only allow manual tests!).
  // And as the CPU measurement condition was the only remaining condition test used on iOS,
  // this method now simply returns YES...
  return YES;
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
          NSDictionary *d = params[j];
          
          if (nil != d)
          {
            NSString *target = d[@"target"];
            
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
      if (conditions[@"condition_types"])
      {
        NSArray *condTypes = conditions[@"condition_types"];
        
        if (condTypes)
        {
          if ([condTypes count] > 0)
          {
            for (int m=0; m<[condTypes count]; m++)
            {
              NSDictionary *d = condTypes[m];
              
              if (d)
              {
                if (d[@"networkType"])
                {
                  NSLog(@"GOT networkType : %@", d[@"networkType"]);
                  netType = d[@"networkType"];
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
    if (dictionary[key])
    {
      return dictionary[key];
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
      if (info[@"type"])
      {
        type = [[NSString alloc] initWithString:info[@"type"]];
      }
      
      if (info[@"condition_group_id"])
      {
        conditionGroupId = [[NSString alloc] initWithString:info[@"condition_group_id"]];
      }
      
      if (info[@"displayName"])
      {
        displayName = [[NSString alloc] initWithString:info[@"displayName"]];
      }
      
      if (info[@"executeAt"])
      {
        executeTimes = [[NSMutableArray alloc] initWithArray:info[@"executeAt"]];
      }
      
      if (info[@"params"])
      {
        params = [[NSMutableArray alloc] initWithArray:info[@"params"]];
      }
      
      if (info[@"output"])
      {
        output = [[NSMutableDictionary alloc] initWithDictionary:info[@"output"]];
      }
      
      if (info[@"conditions"])
      {
        conditions = [[NSMutableDictionary alloc] initWithDictionary:info[@"conditions"]];
      }
    }
  }
  
  return self;
}


@end
