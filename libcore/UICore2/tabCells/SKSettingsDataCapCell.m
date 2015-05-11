//
//  SKSettingsDataCapCell.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKSettingsDataCapCell.h"
#import "SKASettingsController.h"

@implementation SKSettingsDataCapCell

- (void)setDataAllowance
{
    int64_t mb = [[[NSUserDefaults standardUserDefaults] objectForKey:[SKAppBehaviourDelegate sGet_Prefs_DataCapValueBytes]] longLongValue];
    
    mb = mb / CBytesInAMegabyte;
    
    [self.txtDataCap setText:[NSString stringWithFormat:@"%d", (int)mb]];
}

- (IBAction)showDataCapEditor:(id)sender {
  [self.mpParentSettingsController showDataCapEditor];
}

- (IBAction)datacapSwitch:(id)sender {
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] setIsDataCapEnabled:self.datacapSwitch.on];
  
  BOOL datacapEnabledNow = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isDataCapEnabled];
  
  if (datacapEnabledNow == YES) {
    self.txtDataCap.alpha = 1.0;
  } else {
    self.txtDataCap.alpha = 0.3;
  }
}

@end
