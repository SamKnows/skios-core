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
        self.name = NSLocalizedString(@"Test_Download",nil);
        break;
      case C_UPLOAD_TEST:
        self.name = NSLocalizedString(@"Test_Upload",nil);
        break;
      case C_LATENCY_TEST:
        self.name = NSLocalizedString(@"Test_Latency",nil);
        break;
      case C_LOSS_TEST:
        self.name = NSLocalizedString(@"Test_Loss",nil);
        break;
      case C_JITTER_TEST:
        self.name = NSLocalizedString(@"Test_Jitter",nil);
        break;
      default:
        switch (self.number - C_NUMBER_OF_TESTS) {
          case C_PM_CARRIER_NAME:
            self.name = NSLocalizedString(@"Carrier_Name", nil);
            break;
          case C_PM_CARRIER_COUNTRY:
            self.name = NSLocalizedString(@"Carrier_Country", nil);
            break;
          case C_PM_CARRIER_NETWORK:
            self.name = NSLocalizedString(@"Carrier_Network", nil);
            break;
          case C_PM_CARRIER_ISO:
            self.name = NSLocalizedString(@"Carrier_ISO", nil);
            break;
          case C_PM_PHONE:
            self.name = NSLocalizedString(@"Phone", nil);
            break;
          case C_PM_OS:
            self.name = NSLocalizedString(@"OS", nil);
            break;
          case C_PM_TARGET:
            self.name = NSLocalizedString(@"Target", nil);
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
