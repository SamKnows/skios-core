//
// Scheduler.h
// SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKScheduler : NSObject
{
    // Schedule xml
    NSData *xmlData;
    
    // Global
    NSString *scheduleVersion;
    NSString *submit_dcs;
    NSString *tests_alarm_type;
    NSString *location_service;
    NSMutableDictionary *onfail_test_action;
    int64_t dataCapMB;
    NSMutableArray *original_tests;
    NSMutableArray *hosts;
    NSMutableArray *communications;
    
    // Data collector. Android only?
    NSMutableDictionary *data_collector;
    
    // Conditions
    NSMutableArray *conditions;
    
    // Tests
    NSMutableArray *tests;
    NSMutableArray *displayTests;
        
    NSMutableArray *autoTests;
    
    BOOL bShouldRunAutoTests;
}

// Scheduler xml
@property (nonatomic, strong) NSData *xmlData;

// Global - TODO - how many of these are ACTUALLY required to be globally visible;
// other than by the mock tests?
@property (nonatomic, strong) NSString *scheduleVersion;
@property (nonatomic, strong) NSString *submit_dcs;
@property (nonatomic, strong) NSString *tests_alarm_type;
@property (nonatomic, strong) NSString *location_service;
@property (nonatomic, strong) NSMutableDictionary *onfail_test_action;
@property (nonatomic, assign) int64_t dataCapMB;
@property (nonatomic, strong) NSMutableArray *original_tests;
@property (nonatomic, strong) NSMutableArray *hosts;
@property (nonatomic, strong) NSMutableArray *communications;
@property (nonatomic, strong) NSMutableDictionary *data_collector;
@property (nonatomic, strong) NSMutableArray *conditions;
@property (nonatomic, strong) NSMutableArray *tests;
@property (nonatomic, strong) NSMutableArray *displayTests;
@property (nonatomic, assign) BOOL bShouldRunAutoTests;

- (id)initWithXmlData:(NSData*)xmlData_;

- (BOOL)hasValidInitTests;
- (int)getInitTestCount;
- (NSString*)getInitTestName:(int)index;
- (NSDictionary*)getCommunication:(NSString*)id_;
- (NSArray*)getTestsAndTimes;
- (NSString*)getClosestTargetName:(NSString*)dns;
- (SKTestConfig*)getTestConfig:(NSString*)type_;
- (SKTestConfig*)getTestConfig:(NSString*)type_ name:(NSString*)name_;

-(BOOL) shouldSortTests;
-(BOOL) shouldStoreScheduleVersion;

@end
