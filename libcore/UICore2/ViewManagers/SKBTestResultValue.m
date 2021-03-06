//
//  SKBTestResultValue.m
//  SKCore
//
//  Created by Pete Cole on 17/09/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBTestResultValue.h"

@implementation SKBTestResultValue

-(id)initWithResultIdentifier:(NSString*)resultIdentifier
{
  if (self = [super init])
  {
#ifdef DEBUG
    if ([resultIdentifier isEqualToString:SKB_TESTVALUERESULT_C_DOWNLOAD_TEST]) {
    } else if ([resultIdentifier isEqualToString:SKB_TESTVALUERESULT_C_UPLOAD_TEST]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_LATENCY_TEST]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_LOSS_TEST]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_JITTER_TEST]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_CARRIER_NAME]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_CARRIER_COUNTRY]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_CARRIER_NETWORK]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_ISO_COUNTRY_CODE]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_DEVICE]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_OS]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_TARGET]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_PUBLIC_IP]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_SUBMISSION_ID]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_NETWORK_TYPE]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_MUNICIPALITY]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_WLAN_CARRIER]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_WIFI_SSID]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_COUNTRY_NAME]) {
    } else {
      SK_ASSERT(false);
    }
#endif // DEBUG
    
    //self.number = metricsNumber_;
    
    self.mNonlocalizedIdentifier = resultIdentifier;
    self.mLocalizedIdentifier = sSKCoreGetLocalisedString(resultIdentifier);
    
    self.value = nil;
  }
  
  return self;
}

@end
