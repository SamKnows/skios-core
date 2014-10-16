//
//  SKATestResultValue.m
//  SKCore
//
//  Created by Pete Cole on 17/09/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKATestResultValue.h"

@implementation SKATestResultValue

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
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_CARRIER_ISO]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_PHONE]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_OS]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_TARGET]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_PUBLIC_IP]) {
    } else if ([resultIdentifier isEqualToString: SKB_TESTVALUERESULT_C_PM_SUBMISSION_ID]) {
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
