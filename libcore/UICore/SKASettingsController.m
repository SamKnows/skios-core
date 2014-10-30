//
//  SKASettingsController.m
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKASettingsController.h"
#import "SKAAppDelegate.h"
#import "SKAMainResultsController.h"

@interface SKASettingsController ()

- (void)setLabels;

@end

@implementation SKASettingsController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //SK_ASSERT(self.dateLabel != nil);
  //SK_ASSERT(self.dateValue != nil);
  
  [self addBackButton];
  [self setLabels];
  [self setDataAllowance];
  
  self.lblClearAllData.text = sSKCoreGetLocalisedString(@"Settings_ClearAllResults");
  self.lblActivate.text = sSKCoreGetLocalisedString(@"Settings_Activate");
  self.latitudeLabel.text = sSKCoreGetLocalisedString(@"latitude");
  self.longitudeLabel.text = sSKCoreGetLocalisedString(@"longitude");
  self.dateLabel.text = sSKCoreGetLocalisedString(@"date");
  
  // Added for new app
  self.exportResultsLabel.text = sSKCoreGetLocalisedString(@"Menu_Export");
  self.termsAndConditionsLabel.text = sSKCoreGetLocalisedString(@"Menu_TermsOfUse");
  self.lblAboutCaption.text = sSKCoreGetLocalisedString(@"About_Version");
  NSString *appVersion = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  NSString *bundleVersion = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleVersion"];
  NSString *displayVersion = [NSString stringWithFormat:@"%@.%@", appVersion, bundleVersion];
  self.lblAboutVersion.text = displayVersion;
  
  self.lblAboutWebServer.text =sSKCoreGetLocalisedString(@"About_Web_Server");
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
  
  // Text Color
  UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
  header.contentView.backgroundColor = [UIColor colorFromHexString:@"#EBEBF1"]; // Sampled from real screen!
  header.textLabel.textColor = [UIColor blackColor];
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
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSDictionary *loc = [prefs objectForKey:Prefs_LastLocation];
  
  if (loc != nil) {
    double latitude = [[loc objectForKey:@"LATITUDE"] doubleValue];
    double longitude = [[loc objectForKey:@"LONGITUDE"] doubleValue];
    double dateAsTimeIntervalSince1970 = [[loc objectForKey:@"LOCATIONDATE"] doubleValue];
    
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
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  switch (section)
  {
    case 0:
      return sSKCoreGetLocalisedString(@"Storyboard_Settings_Configuration");
      
    case 1:
      return sSKCoreGetLocalisedString(@"Storyboard_Settings_MonthlyData");
      
    case 2:
      return sSKCoreGetLocalisedString(@"last_known_location_info");
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
  label.text = sSKCoreGetLocalisedString(@"SETTINGS_Title");
  [label sizeToFit];
  self.navigationItem.titleView = label;
  
  [self setTitle:sSKCoreGetLocalisedString(@"SETTINGS_Title")];
  [self.lblDataCap setText:sSKCoreGetLocalisedString(@"SETTINGS_Data_Cap")];
  [self.lblDataUsage setText:sSKCoreGetLocalisedString(@"SETTINGS_Data_Usage")];
  [self.lblConfig setText:sSKCoreGetLocalisedString(@"SETTINGS_Config")];
  
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
  
  int64_t mb = [[[NSUserDefaults standardUserDefaults] objectForKey:Prefs_DataCapValueBytes] longLongValue];
  
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
    [SKAAppDelegate setIsActivated:NO];
   
    //UIViewController *doSequeFrom = nil;
    //if (self.parentViewController != nil) {
    //}
    [self SKSafePerformSegueWithIdentifier:@"segueToActivateFromSettings" sender:self];
  } else if ([cell.reuseIdentifier isEqualToString:@"terms_and_conditions"]) {
    [self SKSafePerformSegueWithIdentifier:@"segueFromSettingsToTerms" sender:self];
  } else if ([cell.reuseIdentifier isEqualToString:@"export_results"]) {
    UIViewController *fromThisVC = self;
    id<MFMailComposeViewControllerDelegate> thisMailDelegate = self;
    
    [SKAMainResultsController sMenuSelectedExportResults:thisMailDelegate fromThisVC:fromThisVC];
  } else if ([cell.reuseIdentifier isEqualToString:@"about_url"]) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://speedtest3.ofca.gov.hk/about-sk.html"]];
  }
}


//
//
//


// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  // In your own app, you could use the delegate to track whether the user sent or canceled the email by examining the value in the result parameter.
  [self dismissModalViewControllerAnimated:YES];
}

//
// http://code-ninja.org/blog/2012/02/29/ios-quick-tip-programmatically-hiding-sections-of-a-uitableview-with-static-cells/
//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if(section == 1)
  {
    if ([[SKAAppDelegate getAppDelegate] isDataCapEnabled] == NO)
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
    if ([[SKAAppDelegate getAppDelegate] isDataCapEnabled] == NO) {
      return [[UIView alloc] initWithFrame:CGRectZero];
    }
  }
  
  return [super tableView:tableView viewForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  if(section == 1)
  {
    if ([[SKAAppDelegate getAppDelegate] isDataCapEnabled] == NO) {
      return 0.01f;
    }
  }
  
  return [super tableView:tableView heightForHeaderInSection:section];
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
  if(section == 1)
  {
    if ([[SKAAppDelegate getAppDelegate] isDataCapEnabled] == NO) {
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
    if ([[SKAAppDelegate getAppDelegate] isDataCapEnabled] == NO) {
      return [[UIView alloc] initWithFrame:CGRectZero];
    }
  }
  
  return [super tableView:tableView viewForFooterInSection:section];
}

@end
