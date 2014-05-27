//
//  SKASettingsController.m
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKASettingsController.h"
#import "SKAAppDelegate.h"


@interface SKASettingsController ()

- (void)setLabels;

@end

@implementation SKASettingsController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self addBackButton];
  [self setLabels];
  [self setDataAllowance];
  
  if (self.lblClearAllData != nil) {
    self.lblClearAllData.text = NSLocalizedString(@"Settings_ClearAllResults",nil);
  }
  
  if (self.lblActivate != nil) {
    self.lblActivate.text = NSLocalizedString(@"Settings_Activate",nil);
  }

}

-(void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
 
  BOOL canDisableDataCap = [[SKAAppDelegate getAppDelegate] canDisableDataCap];
  BOOL datacapEnabled = [[SKAAppDelegate getAppDelegate] isDataCapEnabled];
  self.datacapSwitch.hidden = !canDisableDataCap;
  self.datacapSwitch.on = datacapEnabled;
  self.txtDataCap.enabled = datacapEnabled;
 
  if (self.uniqueIdLabel != nil) {
    self.uniqueIdLabel.text = [[UIDevice currentDevice] uniqueDeviceIdentifier];
  }
  
  if (datacapEnabled == YES) {
    self.txtDataCap.alpha = 1.0;
  } else {
    self.txtDataCap.alpha = 0.3;
  }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  switch (section)
  {
    case 0:
    return NSLocalizedString(@"Storyboard_Settings_Configuration",nil);
    
    case 1:
    return NSLocalizedString(@"Storyboard_Settings_MonthlyData",nil);
  }
 
  SK_ASSERT(false);
  return nil;
}

- (void)addBackButton
{
  // The following code leads, eventually, to the "back" button disappearing through the whole app,
  // on iOS 7!
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                          [UIColor whiteColor],UITextAttributeTextColor,
//                          [[SKAAppDelegate getAppDelegate] getSpecialFontOfSize:12.0],UITextAttributeFont,
//                          nil];
//    
//    [[UIBarButtonItem appearance] setTitleTextAttributes:dict forState:UIControlStateNormal];
}

- (void)setLabels
{
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,45,45)];
  label.font = [[SKAAppDelegate getAppDelegate] getSpecialFontOfSize:17];
  label.textColor = [UIColor blackColor];
  
  label.backgroundColor = [UIColor clearColor];
  label.text = NSLocalizedString(@"SETTINGS_Title", nil);
  [label sizeToFit];
  self.navigationItem.titleView = label;
  
  [self setTitle:NSLocalizedString(@"SETTINGS_Title", nil)];
  [self.lblDataCap setText:NSLocalizedString(@"SETTINGS_Data_Cap", nil)];
  [self.lblDataUsage setText:NSLocalizedString(@"SETTINGS_Data_Usage", nil)];
  [self.lblConfig setText:NSLocalizedString(@"SETTINGS_Config", nil)];
  
  SKAAppDelegate *delegate = (SKAAppDelegate*)[UIApplication sharedApplication].delegate;
  int64_t bytesUsed = [delegate amdGetDataUsageBytes];
  
  NSString *valueString = [SKGlobalMethods bytesToString:(double)bytesUsed];
  
  [self.lblDataMB setText:valueString];
  
  [self.lblVersion setText:delegate.schedule.scheduleVersion];
}


- (void)setDataAllowance
{
    int64_t mb = [[[NSUserDefaults standardUserDefaults] objectForKey:Prefs_DataCapValueBytes] longLongValue];
    
    mb = mb / CBytesInAMegabyte;
    
    [self.txtDataCap setText:[NSString stringWithFormat:@"%d", (int)mb]];
}

-(void) validateText {
  if ([self.txtDataCap.text length] == 0)
  {
    self.txtDataCap.text = @"1";
  }
  else
  {
    int64_t value = [self.txtDataCap.text longLongValue];
    
    if (value <= 0)
    {
      self.txtDataCap.text = @"1";
    }
  }
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSLog(@"Sizeof long = %d", (int)sizeof(long));
  NSLog(@"Sizeof int64_t = %d", (int)sizeof(int64_t));
  int64_t theValue = (int64_t)[self.txtDataCap.text longLongValue];
  theValue *= CBytesInAMegabyte;
  [prefs setObject:[NSNumber numberWithLongLong:theValue] forKey:Prefs_DataCapValueBytes];
  [prefs synchronize];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  
  if (alertView.tag == ALERT_DATACAP) {
    
    // after animation
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    SK_ASSERT(textField != nil);
    SK_ASSERT(textField.text != nil);
    
    NSString *stringValue = textField.text;
    int64_t value = [stringValue longLongValue];
    
    self.txtDataCap.text = [NSString stringWithFormat:@"%ld", (long)value];
    
    [self validateText];
  } else if (alertView.tag == ALERT_WIPEDATA) {
    if (buttonIndex == alertView.cancelButtonIndex) {
      // Nothing to do!
    } else {
      // Empty the database
      [SKDatabase sEmptyTheDatabase];
      // Delete any archived files!
      [SKAAppDelegate deleteAllArchivedJSONFiles];
    }
  } else {
    SK_ASSERT(false);
  }
}

// http://stackoverflow.com/questions/10307561/uikeyboardtypenumberpad-ipad
// This can also be used to filter-out characters from an external keyboard.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
  
  //NSString *validRegEx =@"^[0-9.]*$"; //change this regular expression as your requirement
  NSString *validRegEx =@"^[0-9]*$"; //change this regular expression as your requirement
  NSPredicate *regExPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", validRegEx];
  BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:string];
  if (myStringMatchesRegEx)
    return YES;
  else
    return NO;
}

- (IBAction)datacapSwitch:(id)sender {
  [[SKAAppDelegate getAppDelegate] setIsDataCapEnabled:self.datacapSwitch.on];
  
  BOOL datacapEnabledNow = [[SKAAppDelegate getAppDelegate] isDataCapEnabled];
  
  if (datacapEnabledNow == YES) {
    self.txtDataCap.alpha = 1.0;
  } else {
    self.txtDataCap.alpha = 0.3;
  }
}

enum {
  ALERT_DATACAP = 1,
  ALERT_WIPEDATA = 2,
};

- (IBAction)showDataCapEditor:(id)sender {
  
  BOOL datacapEnabled = [[SKAAppDelegate getAppDelegate] isDataCapEnabled];
  if (datacapEnabled == NO) {
    // Datacap not enabled - don't allow editing!
    return;
  }
  
  UIAlertView *alert =
  [[UIAlertView alloc]
   initWithTitle:NSLocalizedString(@"Title_MonthlyDataCap",nil)
   message:nil
   delegate:self
   cancelButtonTitle:NSLocalizedString(@"MenuAlert_Cancel",nil)
   otherButtonTitles:NSLocalizedString(@"MenuAlert_OK",nil), nil];
  alert.tag = ALERT_DATACAP;
 
  alert.alertViewStyle = UIAlertViewStylePlainTextInput;
  UITextField *textField = [alert textFieldAtIndex:0];
  
  textField.keyboardType = UIKeyboardTypeNumberPad;
  // http://stackoverflow.com/questions/10307561/uikeyboardtypenumberpad-ipad
  textField.delegate = self;
  
  int64_t mb = [[[NSUserDefaults standardUserDefaults] objectForKey:Prefs_DataCapValueBytes] longLongValue];
  
  mb = mb / CBytesInAMegabyte;
  
  textField.text = [NSString stringWithFormat:@"%d", (int)mb];
  textField.placeholder = NSLocalizedString(@"Settings_DataCap_Placeholder",nil);
  
  [alert show];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
  cell.selected = NO;
  if ([cell.reuseIdentifier isEqualToString:@"clear_all_results"]) {
    // Optionally - clear the database - TODO!
    NSLog(@"TODO - optionally, clear the database!");
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Settings_ClearAllResults_Title", nil)
                          message:NSLocalizedString(@"Settings_ClearAllResults_Message", nil)
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"MenuAlert_Cancel",nil)
                          otherButtonTitles:NSLocalizedString(@"MenuAlert_OK",nil),nil];
    alert.tag = ALERT_WIPEDATA;
    [alert show];
  } else if ([cell.reuseIdentifier isEqualToString:@"activate"]) {
    [SKAAppDelegate setIsActivated:NO];
    [self performSegueWithIdentifier:@"segueToActivateFromSettings" sender:self];
  }
}

@end
