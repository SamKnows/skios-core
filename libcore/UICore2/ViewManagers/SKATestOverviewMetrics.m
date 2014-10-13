//
//  SKATestOverviewMetrics.m
//  SKCore
//
//  Created by Pete Cole on 17/09/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKATestOverviewMetrics.h"

@implementation SKATestOverviewMetrics

-(id)initWithMetricsNumber:(int)metricsNumber_
{
  if (self = [super init])
  {
    self.number = metricsNumber_;
    
    switch (self.number) {
      case C_DOWNLOAD_TEST:
        self.name = sSKCoreGetLocalisedString(@"Test_Download");
        break;
      case C_UPLOAD_TEST:
        self.name = sSKCoreGetLocalisedString(@"Test_Upload");
        break;
      case C_LATENCY_TEST:
        self.name = sSKCoreGetLocalisedString(@"Test_Latency");
        break;
      case C_LOSS_TEST:
        self.name = sSKCoreGetLocalisedString(@"Test_Loss");
        break;
      case C_JITTER_TEST:
        self.name = sSKCoreGetLocalisedString(@"Test_Jitter");
        break;
      default:
        switch (self.number - C_NUMBER_OF_TESTS) {
          case C_PM_CARRIER_NAME:
            self.name = sSKCoreGetLocalisedString(@"Carrier_Name");
            break;
          case C_PM_CARRIER_COUNTRY:
            self.name = sSKCoreGetLocalisedString(@"Carrier_Country");
            break;
          case C_PM_CARRIER_NETWORK:
            self.name = sSKCoreGetLocalisedString(@"Carrier_Network");
            break;
          case C_PM_CARRIER_ISO:
            self.name = sSKCoreGetLocalisedString(@"Carrier_ISO");
            break;
          case C_PM_PHONE:
            self.name = sSKCoreGetLocalisedString(@"Phone");
            break;
          case C_PM_OS:
            self.name = sSKCoreGetLocalisedString(@"OS");
            break;
          case C_PM_TARGET:
            self.name = sSKCoreGetLocalisedString(@"Target");
            break;
          default:
            break;
        }
        break;
    }
    
    self.value = nil;
  }
  
  return self;
}

@end
