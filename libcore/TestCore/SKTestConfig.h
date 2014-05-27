//
//  SKTestConfig.h
//  SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SKTestConfigDelegate

- (void)tcdSetCPUConditionResult:(int)maxCPU avgCPU:(int)avgCPU Success:(BOOL)bSuccess Type:(NSString*)type;

@end

@interface SKTestConfig : NSObject
{
    NSDictionary *info;
    
    NSString *type;
    NSString *conditionGroupId;
    NSString *displayName;
    
    NSMutableArray *executeTimes;
    
    NSMutableArray *params;
    NSMutableDictionary *output;
    NSMutableDictionary *conditions;
    
    id <SKTestConfigDelegate> testConfigDelegate;
}

@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *conditionGroupId;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSMutableArray *executeTimes;
@property (nonatomic, strong) NSMutableDictionary *output;
@property (nonatomic, strong) NSMutableDictionary *conditions;
@property (nonatomic, strong) NSMutableArray *params;
@property (atomic, strong) id <SKTestConfigDelegate> testConfigDelegate;

- (id)initWithDictionary:(NSDictionary*)dictionary;

- (id)paramObjectForKey:(NSString*)key;

- (NSMutableArray*)getTargets;

- (NSString*)getNetworkType;

- (BOOL)checkTestConditions;

@end
