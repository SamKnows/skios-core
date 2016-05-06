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
