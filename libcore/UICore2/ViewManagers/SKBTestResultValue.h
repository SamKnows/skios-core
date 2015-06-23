//
//  SKBTestResultValue.h
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

#define SKB_TESTVALUERESULT_C_DOWNLOAD_TEST @"Test_Download"
#define SKB_TESTVALUERESULT_C_UPLOAD_TEST @"Test_Upload"
#define SKB_TESTVALUERESULT_C_LATENCY_TEST @"Test_Latency"
#define SKB_TESTVALUERESULT_C_LOSS_TEST @"Test_Loss"
#define SKB_TESTVALUERESULT_C_JITTER_TEST @"Test_Jitter"
#define SKB_TESTVALUERESULT_C_PM_CARRIER_NAME @"Carrier_Name"
#define SKB_TESTVALUERESULT_C_PM_CARRIER_COUNTRY @"Carrier_Country"
#define SKB_TESTVALUERESULT_C_PM_CARRIER_NETWORK @"Carrier_Network"
#define SKB_TESTVALUERESULT_C_PM_NETWORK_TYPE @"Network_Type"
#define SKB_TESTVALUERESULT_C_PM_RADIO_TYPE @"Radio_Type"
#define SKB_TESTVALUERESULT_C_PM_ISO_COUNTRY_CODE @"Carrier_ISO"
#define SKB_TESTVALUERESULT_C_PM_DEVICE @"Phone"
#define SKB_TESTVALUERESULT_C_PM_OS @"OS"
#define SKB_TESTVALUERESULT_C_PM_TARGET @"Target"
#define SKB_TESTVALUERESULT_C_PM_PUBLIC_IP @"Public_IP"
#define SKB_TESTVALUERESULT_C_PM_SUBMISSION_ID @"Submission_ID"

#define SKB_TESTVALUERESULT_C_PM_MUNICIPALITY  @"Municipality"
#define SKB_TESTVALUERESULT_C_PM_WLAN_CARRIER  @"WLAN Carrier"
#define SKB_TESTVALUERESULT_C_PM_WIFI_SSID     @"SSID"
#define SKB_TESTVALUERESULT_C_PM_COUNTRY_NAME  @"Country"


@interface SKBTestResultValue : NSObject

//@property (nonatomic) int number;
//@property (nonatomic) int status;
@property (nonatomic, strong) NSString* mNonlocalizedIdentifier;
@property (nonatomic, strong) NSString* mLocalizedIdentifier;
@property (nonatomic, strong) NSString* value;

-(id)initWithResultIdentifier:(NSString*)resultIdentifier;

@end
