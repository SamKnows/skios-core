//
//  SKATestOverviewMetrics.h
//  SKCore
//
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ACTION_RUN      1
#define ACTION_RANGE    2
#define ACTION_ALREADY_EXCEEDED_PRESS_OK_TO_CONTINUE   3
#define ACTION_NETWORKTYPE   4
#define ACTION_MENU   5
#define ACTION_WILL_BE_EXCEEDED_PRESS_OK_TO_CONTINUE   6
#define ACTION_CANCEL_CONFIRMATION  7

#define C_NUMBER_OF_PASSIVE_METRICS 7
#define C_NUMBER_OF_METRICS (C_NUMBER_OF_TESTS + C_NUMBER_OF_PASSIVE_METRICS)
#define C_NUMBER_OF_TESTS    5
#define C_DOWNLOAD_TEST 0
#define C_UPLOAD_TEST   1
#define C_LATENCY_TEST  2
#define C_LOSS_TEST 3
#define C_JITTER_TEST 4

#define C_PM_CARRIER_NAME   0
#define C_PM_CARRIER_COUNTRY    1
#define C_PM_CARRIER_NETWORK    2
#define C_PM_CARRIER_ISO    3
#define C_PM_PHONE  4
#define C_PM_OS 5
#define C_PM_TARGET 6

//#define C_METRICS_STATUS_EMPTY  0
//#define C_METRICS_STATUS_OK 1
//#define C_METRICS_STATUS_CANCELLED  2
//#define C_METRICS_STATUS_ERROR  3
#define C_GUI_UPDATE_INTERVAL   0.2


@interface SKATestOverviewMetrics : NSObject

@property (nonatomic) int number;
//@property (nonatomic) int status;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* value;

-(id)initWithMetricsNumber:(int)metricsNumber;

@end
