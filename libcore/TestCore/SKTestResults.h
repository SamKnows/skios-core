//
//  SKTestResults.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SKATestResults : NSObject

@property (nonatomic) long testId;
@property (nonatomic, strong) NSDate* testDateTime;
@property (nonatomic, strong) NSString* target;
@property (nonatomic) double downloadSpeed;
@property (nonatomic) double uploadSpeed;
@property (nonatomic) double latency;
@property (nonatomic) double loss;
@property (nonatomic) double jitter;

@property (nonatomic, strong) NSString *device;
@property (nonatomic, strong) NSString *os;
@property (nonatomic, strong) NSString *carrier_name;
@property (nonatomic, strong) NSString *country_code;
@property (nonatomic, strong) NSString *iso_country_code;
@property (nonatomic, strong) NSString *network_code;
@property (nonatomic, strong) NSString *network_type;
@property (nonatomic, strong) NSString *radio_type;

+(UIImage*)generateSocialShareImage:(SKATestResults*)testResults_;
+(void)placeText:(NSString*)text_ intoRect:(CGRect)rectangle_ withFont:(UIFont*)font_;
-(int)numberOfOptionalMetrics;
-(NSString*)getTextForSocialMedia:(NSString*)socialNetwork;

@end
