//
//  SKTestConfig.h
//  SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

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
}

@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *conditionGroupId;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSMutableArray *executeTimes;
@property (nonatomic, strong) NSMutableDictionary *output;
@property (nonatomic, strong) NSMutableDictionary *conditions;
@property (nonatomic, strong) NSMutableArray *params;

- (id)initWithDictionary:(NSDictionary*)dictionary;

- (id)paramObjectForKey:(NSString*)key;

- (NSMutableArray*)getTargets;

- (NSString*)getNetworkType;

- (BOOL)checkTestConditions;

@end
