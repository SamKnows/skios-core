//
//  SKASettingsController.m
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKASettingsControllerOld.h"
#import "SKAAppDelegate.h"
#import "SKAMainResultsController.h"

@interface SKASettingsControllerOld ()

@property (weak, nonatomic) IBOutlet UITableViewCell *aboutOrVersionTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *activateTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *exportResultsTableViewCell;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dataCapLabelToSwitchSpacingConstraint;

- (void)setLabels;

@end

@implementation SKASettingsControllerOld

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //SK_ASSERT(self.dateLabel != nil);
  //SK_ASSERT(self.dateValue != nil);
  
  [self setLabels];
  [self setDataAllowance];
  
  self.lblClearAllData.text = sSKCoreGetLocalisedString(@"Settings_ClearAllResults");
  self.lblActivate.text = sSKCoreGetLocalisedString(@"Settings_Activate");
  self.latitudeLabel.text = sSKCoreGetLocalisedString(@"latitude");
  self.longitudeLabel.text = sSKCoreGetLocalisedString(@"longitude");
  self.dateLabel.text = sSKCoreGetLocalisedString(@"date");
  
  // Added for new app
  self.exportResultsLabel.text = sSKCoreGetLocalisedString(@"Menu_Export");
  self.lblAboutCaption.text = sSKCoreGetLocalisedString(@"Storyboard_About_Title");
  NSString *appVersion = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  NSString *bundleVersion = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleVersion"];
  NSString *displayVersion = [NSString stringWithFormat:@"%@.%@", appVersion, bundleVersion];
  self.lblAboutVersion.text = displayVersion;
  
  NSString *theUrlString = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getNewAppUrlForHelpAbout];
  if (theUrlString != nil) {
    self.termsAndConditionsLabel.text = sSKCoreGetLocalisedString(@"About_Web_Server");
    displayVersion = [NSString stringWithFormat:@"%@: %@.%@", sSKCoreGetLocalisedString(@"About_Version"), appVersion, bundleVersion];
    self.lblAboutCaption.text = displayVersion;
    self.aboutOrVersionTableViewCell.accessoryType = UITableViewCellAccessoryNone;
  } else {
    self.termsAndConditionsLabel.text = sSKCoreGetLocalisedString(@"Menu_TermsOfUse");
  }
  
  BOOL canDisableDataCap = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] canDisableDataCap];
  self.datacapSwitch.hidden = !canDisableDataCap;
  if (self.datacapSwitch.hidden == YES) {
    // Move the hidden switch sideways, to give more room for the text!
    CGRect theFrame = self.datacapSwitch.frame;
    self.dataCapLabelToSwitchSpacingConstraint.constant -= theFrame.size.width;
  }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
  if ( (self.parentViewController == nil) ||
      (![[self.parentViewController.class description] isEqualToString:@"SKBSettingsTabViewController"])
      )
  {
    // Not embedded!
    //[super tableView:tableView willDisplayHeaderView:view forSection:section];
    return;
  }
  
#ifdef DEBUG
  NSLog(@"DEBUG: willDisplayHeaderView, view=%@", view.description);
#endif // DEBUG
  
  // If we've overridden viewForHeaderInSection and just returned a simple UIView,
  // that won't have a contentView selector. So, we must first check before
  // trying to access the contentView property!
  if ([view respondsToSelector:@selector(contentView)]) {
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [UIColor colorFromHexString:@"#EBEBF1"]; // Sampled from real screen!
    //header.textLabel.textColor = [UIColor blackColor];
    
    //    UIColor *x = header.textLabel.textColor;
    //    NSString *xAsString = [UIColor hexStringFromColor:x];
    //    NSLog(@"COLOR: %@", xAsString);
  }
}


-(void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  UIViewController *parentViewController = self.parentViewController;
  NSString *classDescription = [parentViewController.class description];
  NSString *theClassDescription = [NSString stringWithString:classDescription];
  if ([theClassDescription isEqualToString:@"SKBSettingsTabViewController"]) {
    // We're embedded - reveal the background when scrolling!
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
  }
  
  BOOL datacapEnabled = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isDataCapEnabled];
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
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSDictionary *loc = [prefs objectForKey:[SKAppBehaviourDelegate sGet_Prefs_LastLocation]];
  
  if (loc != nil) {
    double latitude = [loc[@"LATITUDE"] doubleValue];
    double longitude = [loc[@"LONGITUDE"] doubleValue];
    double dateAsTimeIntervalSince1970 = [loc[@"LOCATIONDATE"] doubleValue];
    
    self.latitudeValue.text = [SKGlobalMethods formatDouble:latitude DecimalPlaces:8];
    self.longitudeValue.text = [SKGlobalMethods formatDouble:longitude DecimalPlaces:8];
    
    if (dateAsTimeIntervalSince1970 == 0) {
      self.dateValue.text = sSKCoreGetLocalisedString(@"Unknown");
    } else {
      self.dateValue.text = [SKGlobalMethods formatDate:[NSDate dateWithTimeIntervalSince1970:dateAsTimeIntervalSince1970]];
    }
  } else {
    self.latitudeValue.text = sSKCoreGetLocalisedString(@"Unknown");
    self.longitudeValue.text = sSKCoreGetLocalisedString(@"Unknown");
    self.dateValue.text = sSKCoreGetLocalisedString(@"Unknown");
  }
  
  // And update the data usage value.
  SKAppBehaviourDelegate *delegate = [SKAppBehaviourDelegate sGetAppBehaviourDelegate];
  int64_t bytesUsed = [delegate amdGetDataUsageBytes];
  NSString *valueString = [SKGlobalMethods bytesToString:(double)bytesUsed];
  [self.lblDataMB setText:valueString];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  switch (section) {
  case 0:
    return sSKCoreGetLocalisedString(@"Storyboard_Settings_Configuration");

  case 1:
    return sSKCoreGetLocalisedString(@"Storyboard_Settings_MonthlyData");

  case 2:
    return sSKCoreGetLocalisedString(@"last_known_location_info");

  default:
    break;
  }

  SK_ASSERT(false);
  return nil;
}

- (void)setLabels
{
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsThisTheNewApp] == YES) {
  } else {
    // Old app!
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,45,45)];
    label.font = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getSpecialFontOfSize:17];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.text = sSKCoreGetLocalisedString(@"SETTINGS_Title");
    [label sizeToFit];
    self.navigationItem.titleView = label;
  }
  
  [self setTitle:sSKCoreGetLocalisedString(@"SETTINGS_Title")];
  [self.lblDataCap setText:sSKCoreGetLocalisedString(@"SETTINGS_Data_Cap")];
  [self.lblDataUsage setText:sSKCoreGetLocalisedString(@"SETTINGS_Data_Usage")];
  [self.lblConfig setText:sSKCoreGetLocalisedString(@"SETTINGS_Config")];
  
  SKAppBehaviourDelegate *delegate = [SKAppBehaviourDelegate sGetAppBehaviourDelegate];
  [self.lblVersion setText:delegate.schedule.scheduleVersion];
}


- (void)setDataAllowance
{
  int64_t mb = [[[NSUserDefaults standardUserDefaults] objectForKey:[SKAppBehaviourDelegate sGet_Prefs_DataCapLimitBytes]] longLongValue];
  
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
  [prefs setObject:@(theValue) forKey:[SKAppBehaviourDelegate sGet_Prefs_DataCapLimitBytes]];
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
      
      // Delete any saved JSON files!
      [SKKitJSONDataCaptureAndUpload sDeleteAllSavedJSONFiles];
      [SKKitJSONDataCaptureAndUpload sDeleteAllArchivedJSONFiles];
      
      // Notify the rest of the UI!
      [[NSNotificationCenter defaultCenter]
       postNotificationName:@"TestListNeedsUpdate"
       object:self];
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
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] setIsDataCapEnabled:self.datacapSwitch.on];
  
  BOOL datacapEnabledNow = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isDataCapEnabled];
  
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
  
  BOOL datacapEnabled = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isDataCapEnabled];
  if (datacapEnabled == NO) {
    // Datacap not enabled - don't allow editing!
    return;
  }
  
  UIAlertView *alert =
  [[UIAlertView alloc]
   initWithTitle:sSKCoreGetLocalisedString(@"Title_MonthlyDataCap")
   message:nil
   delegate:self
   cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")
   otherButtonTitles:sSKCoreGetLocalisedString(@"MenuAlert_OK"),
   nil];
  alert.tag = ALERT_DATACAP;
  
  alert.alertViewStyle = UIAlertViewStylePlainTextInput;
  UITextField *textField = [alert textFieldAtIndex:0];
  
  textField.keyboardType = UIKeyboardTypeNumberPad;
  // http://stackoverflow.com/questions/10307561/uikeyboardtypenumberpad-ipad
  textField.delegate = self;
  
  int64_t mb = [[[NSUserDefaults standardUserDefaults] objectForKey:[SKAppBehaviourDelegate sGet_Prefs_DataCapLimitBytes]] longLongValue];
  
  mb = mb / CBytesInAMegabyte;
  
  textField.text = [NSString stringWithFormat:@"%d", (int)mb];
  textField.placeholder = sSKCoreGetLocalisedString(@"Settings_DataCap_Placeholder");
  
  [alert show];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
  cell.selected = NO;
  if ([cell.reuseIdentifier isEqualToString:@"clear_all_results"]) {
    // Optionally - clear the database - TODO!
    NSLog(@"TODO - optionally, clear the database!");
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:sSKCoreGetLocalisedString(@"Settings_ClearAllResults_Title")
                          message:sSKCoreGetLocalisedString(@"Settings_ClearAllResults_Message")
                          delegate:self
                          cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")
                          otherButtonTitles:sSKCoreGetLocalisedString(@"MenuAlert_OK"),
                          nil];
    alert.tag = ALERT_WIPEDATA;
    [alert show];
  } else if ([cell.reuseIdentifier isEqualToString:@"activate"]) {
    
    SK_ASSERT(false); // This is ONLY in the old-style apps, now!
    
    /*
     SKAppBehaviourDelegate *appDelegate = [SKAppBehaviourDelegate sGetAppBehaviourDelegate];
     if ([appDelegate getIsConnected] == NO) {
     // If not connected, display an alert, and do not try to activate.
     // This covers e.g. if we lost connection and tests stopped automatically.
     // It will also stop a test re-running in the event of continuous testing.
     
     UIAlertView *alert =
     [[UIAlertView alloc] initWithTitle:nil
     message:sSKCoreGetLocalisedString(@"Offline_message")
     delegate:nil
     cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_OK")
     otherButtonTitles: nil];
     
     [alert show];
     
     return;
     }
     
     [SKAppBehaviourDelegate setIsActivated:NO];
     
     //UIViewController *doSequeFrom = nil;
     //if (self.parentViewController != nil) {
     //}
     [self SKSafePerformSegueWithIdentifier:@"segueToActivateFromSettings" sender:self];
     */
  } else if ([cell.reuseIdentifier isEqualToString:@"terms_and_conditions"]) {
    SK_ASSERT(false);
    [self SKSafePerformSegueWithIdentifier:@"segueFromSettingsToTerms" sender:self];
  } else if ([cell.reuseIdentifier isEqualToString:@"export_results"]) {
    UIViewController *fromThisVC = self;
    id<MFMailComposeViewControllerDelegate> thisMailDelegate = self;
    
    [SKAMainResultsController sMenuSelectedExportResults:thisMailDelegate fromThisVC:fromThisVC];
  } else if ([cell.reuseIdentifier isEqualToString:@"terms_or_about_url"]) {
    
    NSString *theUrlString = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getNewAppUrlForHelpAbout];
    if (theUrlString != nil) {
      // View a specific URL!
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:theUrlString]];
    } else {
      [self SKSafePerformSegueWithIdentifier:@"segueFromSettingsToTerms" sender:self];
    }
  } else if (cell == self.aboutOrVersionTableViewCell) {
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
      [self performSegueWithIdentifier:@"segueFromSettingsToAbout" sender:self];
    }
  }
}


//
//
//


// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  // In your own app, you could use the delegate to track whether the user sent or canceled the email by examining the value in the result parameter.
  [self dismissViewControllerAnimated:YES completion:nil];
}

//
// http://code-ninja.org/blog/2012/02/29/ios-quick-tip-programmatically-hiding-sections-of-a-uitableview-with-static-cells/
//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if(section == 1)
  {
    if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isDataCapEnabled] == NO)
    {
      // Hide it!
      return 0;
    }
  }
  
  return [super tableView:tableView numberOfRowsInSection:section];
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  if(section == 1)
  {
    if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isDataCapEnabled] == NO) {
      return [[UIView alloc] initWithFrame:CGRectZero];
    }
  }
  
  return [super tableView:tableView viewForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  if(section == 1)
  {
    if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isDataCapEnabled] == NO) {
      return 0.01f;
    }
  }
  
  return [super tableView:tableView heightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
  
  if (cell == self.activateTableViewCell) {
    // Hide the activation row?
    if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isActivationSupported] == NO) {
      return 0;
    }
  } else if (cell == self.exportResultsTableViewCell) {
    // ALWAYS hide the the export results row, as that is deprecated behaviour
    // (the files are always deleted after uploading)
    return 0;
  }
  
  return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
  if(section == 1)
  {
    if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isDataCapEnabled] == NO) {
      return 0.01f;
    }
  }
  
  if (self.parentViewController == nil) {
    // Not embedded!
    return [super tableView:tableView heightForFooterInSection:section];
  }
  
  return 0.01f;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
  if(section == 1)
  {
    if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isDataCapEnabled] == NO) {
      return [[UIView alloc] initWithFrame:CGRectZero];
    }
  }
  
  return [super tableView:tableView viewForFooterInSection:section];
}

@end
