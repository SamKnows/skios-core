//
//  SKASettingsController.m
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKASettingsController.h"
#import "SKAAppDelegate.h"
#import "SKAMainResultsController.h"
#import "SKSettingsCellValueWithLabel.h"
#import "SKSettingsDataCapCell.h"
#import "SKSettingsLinkCell.h"
#import "UIDeviceHardware.h"

@interface SKASettingsController ()

@property  NSString *lblAboutCaptionText;
@property  NSString *mAboutVersionTextXptYZ;
@property  BOOL mbShowAccessoryOnAboutOrVersion;
@property  (weak, atomic) SKSettingsDataCapCell *dataCapCell;
@property  NSString *termsAndConditionsLabelText;
@property  NSInteger mNumberOfSections;

#define SECTION_INDEX_MAIN 0
@property NSInteger SECTION_INDEX_DATACAP;
@property NSInteger SECTION_INDEX_PHONE_INFO;
@property NSInteger SECTION_INDEX_NETWORK_INFO;
@property NSInteger SECTION_INDEX_LOCATION;

- (void)setLabels;

@end

@implementation SKASettingsController

@synthesize lblAboutCaptionText;
@synthesize mAboutVersionTextXptYZ;
@synthesize mbShowAccessoryOnAboutOrVersion;
@synthesize dataCapCell;
@synthesize termsAndConditionsLabelText;
@synthesize SECTION_INDEX_DATACAP;
@synthesize SECTION_INDEX_PHONE_INFO;
@synthesize SECTION_INDEX_NETWORK_INFO;
@synthesize SECTION_INDEX_LOCATION;
@synthesize mNumberOfSections;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  SK_ASSERT(SECTION_INDEX_MAIN == 0);
  SECTION_INDEX_DATACAP = -1;
  SECTION_INDEX_PHONE_INFO = -1;
  SECTION_INDEX_NETWORK_INFO = -1;
  SECTION_INDEX_LOCATION = -1;
  
  NSInteger lastUsedIndexSlot = SECTION_INDEX_MAIN;
 
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isDataCapEnabled] == YES) {
    lastUsedIndexSlot++;
    SECTION_INDEX_DATACAP = lastUsedIndexSlot;
  }
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] canViewPhoneInfoInSettings] == YES) {
    lastUsedIndexSlot++;
    SECTION_INDEX_PHONE_INFO = lastUsedIndexSlot;
  }
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] canViewNetworkInfoInSettings] == YES) {
    lastUsedIndexSlot++;
    SECTION_INDEX_NETWORK_INFO = lastUsedIndexSlot;
  }
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] canViewLocationInSettings] == YES) {
    lastUsedIndexSlot++;
    SECTION_INDEX_LOCATION = lastUsedIndexSlot;
  }
  
  mNumberOfSections = lastUsedIndexSlot + 1;
  
  //SK_ASSERT(self.dateLabel != nil);
  //SK_ASSERT(self.dateValue != nil);
  
  [self setLabels];
  
  // Added for new app
//  self.exportResultsLabel.text = sSKCoreGetLocalisedString(@"Menu_Export");
  self.lblAboutCaptionText = sSKCoreGetLocalisedString(@"Storyboard_About_Title");
  NSString *appVersion = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  NSString *bundleVersion = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleVersion"];
  NSString *displayVersion = [NSString stringWithFormat:@"%@.%@", appVersion, bundleVersion];
  self.mAboutVersionTextXptYZ = displayVersion;
  
  NSString *theUrlString = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getNewAppUrlForHelpAbout];
  if (theUrlString != nil) {
    self.termsAndConditionsLabelText = sSKCoreGetLocalisedString(@"About_Web_Server");
    displayVersion = [NSString stringWithFormat:@"%@: %@.%@", sSKCoreGetLocalisedString(@"About_Version"), appVersion, bundleVersion];
    self.lblAboutCaptionText = displayVersion;
    mbShowAccessoryOnAboutOrVersion = NO;
  } else {
    self.termsAndConditionsLabelText = sSKCoreGetLocalisedString(@"Menu_TermsOfUse");
    mbShowAccessoryOnAboutOrVersion = YES;
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
  
  SK_ASSERT(self.tableView != nil);
  [self.tableView reloadData];
  
  [self letBackgroundColourShowThroughTheTableBackground];
}

-(void) letBackgroundColourShowThroughTheTableBackground {
  // If we keep this in, we get an ugly blue draw-through for the SK Speed Test app.
//  UIViewController *parentViewController = self.parentViewController;
//  NSString *classDescription = [parentViewController.class description];
//  NSString *theClassDescription = [NSString stringWithString:classDescription];
//  if ([theClassDescription isEqualToString:@"SKBSettingsTabViewController"]) {
//    // We're embedded - reveal the background when scrolling!
//    [self.tableView setBackgroundView:nil];
//    [self.tableView setBackgroundColor:[UIColor clearColor]];
//  }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (section == SECTION_INDEX_MAIN) {
    //  return sSKCoreGetLocalisedString(@"Storyboard_Settings_Configuration");
    // "Version 1.04"
    return [NSString stringWithFormat:@"%@ %@", sSKCoreGetLocalisedString(@"About_Version"), self.mAboutVersionTextXptYZ];
  } else if (section == SECTION_INDEX_DATACAP) {
    return sSKCoreGetLocalisedString(@"Storyboard_Settings_MonthlyData");
  } else if (section == SECTION_INDEX_PHONE_INFO) {
    return sSKCoreGetLocalisedString(@"phone_info");
  } else if (section == SECTION_INDEX_NETWORK_INFO) {
    return sSKCoreGetLocalisedString(@"network_info");
  } else if (section == SECTION_INDEX_LOCATION) {
    return sSKCoreGetLocalisedString(@"last_known_location_info");
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
//  [self.lblConfig setText:sSKCoreGetLocalisedString(@"SETTINGS_Config")];
  
//  SKAppBehaviourDelegate *delegate = [SKAppBehaviourDelegate sGetAppBehaviourDelegate];
//  [self.lblVersion setText:delegate.schedule.scheduleVersion];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  
  if (alertView.tag == ALERT_DATACAP) {
    
    if (buttonIndex == alertView.cancelButtonIndex) {
      // Nothing to do!
    } else {
      
      UITextField *textField = [alertView textFieldAtIndex:0];
      SK_ASSERT(textField != nil);
      SK_ASSERT(textField.text != nil);
      
      NSString *stringValue = textField.text;
      int64_t value = [stringValue longLongValue];
      
      dataCapCell.txtDataCap.text = [NSString stringWithFormat:@"%ld", (long)value];
      
      [self validateText];
    }
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

enum {
  ALERT_DATACAP = 1,
  ALERT_WIPEDATA = 2,
};

- (void)showDataCapEditor {
  
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
  
  if (indexPath.section != SECTION_INDEX_MAIN) {
    return;
  }
  
  NSInteger useRowAs = indexPath.row;
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getShowAboutVersionInSettingsLinksToAboutScreen] == NO) {
    useRowAs++;
  }
  
  
  switch (useRowAs) {
    case 0: { // About
      if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getShowAboutVersionInSettingsLinksToAboutScreen] == NO) {
        return;
      }
 
      SK_ASSERT ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getShowAboutVersionInSettingsLinksToAboutScreen] == YES);
      if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        [self performSegueWithIdentifier:@"segueFromSettingsToAbout" sender:self];
      }
    }
      break;
    case 1: { // Terms
      NSString *theUrlString = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getNewAppUrlForHelpAbout];
      if (theUrlString != nil) {
        // View a specific URL!
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:theUrlString]];
      } else {
        [self SKSafePerformSegueWithIdentifier:@"segueFromSettingsToTerms" sender:self];
      }
    }
      break;
    case 2: { // Clear
      // NSLog(@"Optionally, clear the database!");
      
      UIAlertView *alert = [[UIAlertView alloc]
                            initWithTitle:sSKCoreGetLocalisedString(@"Settings_ClearAllResults_Title")
                            message:sSKCoreGetLocalisedString(@"Settings_ClearAllResults_Message")
                            delegate:self
                            cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")
                            otherButtonTitles:sSKCoreGetLocalisedString(@"MenuAlert_OK"),
                            nil];
      alert.tag = ALERT_WIPEDATA;
      [alert show];
    }
      break;
    case 3: { // Export
      UIViewController *fromThisVC = self;
      id<MFMailComposeViewControllerDelegate> thisMailDelegate = self;
      
      [SKAMainResultsController sMenuSelectedExportResults:thisMailDelegate fromThisVC:fromThisVC];
    }
      break;
    default:
      SK_ASSERT(false);
      return;
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

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//  int sections = 3;
//  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isDataCapEnabled] == NO) {
//    sections--;
//  }
//  
//  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] canViewLocationInSettings] == NO)
//  {
//    sections--;
//  }
//  
//  return sections;
//}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return mNumberOfSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == SECTION_INDEX_MAIN) {
    int rows = 4; // We NEVER display ACTIVATE any more!
    if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getShowAboutVersionInSettingsLinksToAboutScreen] == NO) {
      rows--;
    }
    if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] supportExportMenuItem] == NO) {
      rows--;
    }
    return rows;
  } else if (section == SECTION_INDEX_DATACAP) {
    SK_ASSERT([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isDataCapEnabled] == YES);
    return 2;
  } else if (section == SECTION_INDEX_PHONE_INFO) {
    return 2; // Phone type, Operating system
  } else if (section == SECTION_INDEX_NETWORK_INFO) {
    return 2; // Network type, network operator
  } else if (section == SECTION_INDEX_LOCATION) {
    SK_ASSERT([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] canViewLocationInSettings] == YES);
    return 3;
  } else {
    SK_ASSERT(false);
    return [super tableView:tableView numberOfRowsInSection:section];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

static BOOL sbDidConstraint = NO;

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  int section = (int)indexPath.section;
  
  if (section == SECTION_INDEX_MAIN) {
    SK_ASSERT(indexPath.row >= 0);
    SK_ASSERT(indexPath.row <= 4);
    // The version!
    
    static NSString *CellIdentifier = @"SKSettingsLinkCell";
    
    SKSettingsLinkCell *cell = (SKSettingsLinkCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[SKSettingsLinkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSInteger useRowAs = indexPath.row;
    if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getShowAboutVersionInSettingsLinksToAboutScreen] == NO) {
      useRowAs++;
    }
    
   
    switch (useRowAs) {
      case 0:
        if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getShowAboutVersionInSettingsLinksToAboutScreen] == NO) {
          cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.mLabel.text = lblAboutCaptionText;
        break;
      case 1:
        cell.mLabel.text = self.termsAndConditionsLabelText;
        if (self.mbShowAccessoryOnAboutOrVersion == NO) {
          //cell.accessoryType = UITableViewCellAccessoryNone;
        }
        break;
      case 2:
        cell.mLabel.text = sSKCoreGetLocalisedString(@"Settings_ClearAllResults");
        break;
      case 3:
        cell.mLabel.text = sSKCoreGetLocalisedString(@"Menu_Export");
        break;
      default:
        SK_ASSERT(false);
        break;
    }
    
    return cell;
  } else if (section == SECTION_INDEX_DATACAP) {
    switch (indexPath.row) {
      case 0: {
        static NSString *CellIdentifier = @"SKSettingsDataCapCell";
        
        SKSettingsDataCapCell *cell = (SKSettingsDataCapCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
          cell = [[SKSettingsDataCapCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.mpParentSettingsController = self;
        dataCapCell = cell;
        
        [cell.lblDataCap setText:sSKCoreGetLocalisedString(@"SETTINGS_Data_Cap")];
        
        BOOL datacapEnabled = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isDataCapEnabled];
        cell.datacapSwitch.on = datacapEnabled;
        cell.txtDataCap.enabled = datacapEnabled;
        [cell setDataAllowance];
        
        if (self.uniqueIdLabel != nil) {
          self.uniqueIdLabel.text = [[UIDevice currentDevice] uniqueDeviceIdentifier];
        }
        
        if (datacapEnabled == YES) {
          cell.txtDataCap.alpha = 1.0;
        } else {
          cell.txtDataCap.alpha = 0.3;
        }
        
        BOOL canDisableDataCap = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] canDisableDataCap];
        cell.datacapSwitch.hidden = !canDisableDataCap;
        if (cell.datacapSwitch.hidden == YES) {
          // Move the hidden switch sideways, to give more room for the text!
          if (sbDidConstraint == NO) {
            sbDidConstraint = YES;
            CGRect theFrame = cell.datacapSwitch.frame;
            //cell.dataCapLabelToSwitchSpacingConstraint.active = false;// .constant = 10; // -= theFrame.size.width;
            cell.dataCapLabelToSwitchSpacingConstraint.constant -= theFrame.size.width;
            [cell updateConstraints];
          }
        }
        
        return cell;
      }
      case 1: {
        static NSString *CellIdentifier = @"SKSettingsCellValueWithLabel";
        
        SKSettingsCellValueWithLabel *cell = (SKSettingsCellValueWithLabel*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
          cell = [[SKSettingsCellValueWithLabel alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell.mLabel setText:sSKCoreGetLocalisedString(@"SETTINGS_Data_Usage")];
        
        // And update the data usage value.
        SKAppBehaviourDelegate *delegate = [SKAppBehaviourDelegate sGetAppBehaviourDelegate];
        int64_t bytesUsed = [delegate amdGetDataUsageBytes];
        NSString *valueString = [SKGlobalMethods bytesToString:(double)bytesUsed];
        [cell.mValue setText:valueString];
        
        return cell;
      }
        
      default:
        SK_ASSERT(false);
        return nil;
    }
  } else if (section == SECTION_INDEX_PHONE_INFO) {
    static NSString *CellIdentifier = @"SKSettingsCellValueWithLabel";
    
    SKSettingsCellValueWithLabel *cell = (SKSettingsCellValueWithLabel*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[SKSettingsCellValueWithLabel alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Populate the cell, according to what bit of Phone Info we're interested in!
    
    // Phone type, Operating system
    switch (indexPath.row) {
      case 0:
      {
        //NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        //NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        //NSString *deviceModel = [[UIDevice currentDevice] localizedModel];
        //NSString *osVersion  = [[UIDevice currentDevice] systemVersion];
        NSString *phoneText = [SKGlobalMethods getDeviceModel];
        
        [cell.mLabel setText:sSKCoreGetLocalisedString(@"Phone")];
        [cell.mValue setText:phoneText];
      }
        break;
        
      case 1:
      default:
      {
        NSString *osVersion  = [[UIDevice currentDevice] systemVersion];
        
        NSString *osString = [NSString stringWithFormat:@"iOS %@", osVersion];
        
        [cell.mLabel setText:sSKCoreGetLocalisedString(@"OS")];
        [cell.mValue setText:osString];
      }
        break;
    }
    
    return cell;
    
  } else if (section == SECTION_INDEX_NETWORK_INFO) {
    static NSString *CellIdentifier = @"SKSettingsCellValueWithLabel";
    
    SKSettingsCellValueWithLabel *cell = (SKSettingsCellValueWithLabel*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[SKSettingsCellValueWithLabel alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Network type (e.g. LTE), Network Operator (e.g. Vodafone)
    switch (indexPath.row) {
      case 0:
      {
        [cell.mLabel setText:sSKCoreGetLocalisedString(@"Network_Type")];
        NSString *radioType = [SKGlobalMethods getNetworkType];
        NSString *radioTypeToShow = [SKGlobalMethods getNetworkTypeLocalized:radioType];
        if ([radioTypeToShow isEqualToString:sSKCoreGetLocalisedString(@"NA")]) {
          radioTypeToShow = sSKCoreGetLocalisedString(@"Unknown");
        }
        [cell.mValue setText:radioTypeToShow];
      }
        break;
        
      case 1:
      default:
      {
        [cell.mLabel setText:sSKCoreGetLocalisedString(@"Network_Operator")];
        
        NSString *carrierName = [SKGlobalMethods getCarrierName];
        if (carrierName.length == 0) {
          carrierName = sSKCoreGetLocalisedString(@"Unknown");
        }
        [cell.mValue setText:carrierName];
      }
        break;
    }
    
    return cell;
    
  } else if (section == SECTION_INDEX_LOCATION) {
    
    static NSString *CellIdentifier = @"SKSettingsCellValueWithLabel";
    
    SKSettingsCellValueWithLabel *cell = (SKSettingsCellValueWithLabel*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[SKSettingsCellValueWithLabel alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *loc = [prefs objectForKey:[SKAppBehaviourDelegate sGet_Prefs_LastLocation]];
    
    NSString *dataValueText = nil;
    NSString *longitudeValueText = nil;
    NSString *latitudeValueText = nil;
    if (loc != nil) {
      double latitude = [loc[@"LATITUDE"] doubleValue];
      double longitude = [loc[@"LONGITUDE"] doubleValue];
      double dateAsTimeIntervalSince1970 = [loc[@"LOCATIONDATE"] doubleValue];
      
      latitudeValueText = [SKGlobalMethods formatDouble:latitude DecimalPlaces:8];
      longitudeValueText = [SKGlobalMethods formatDouble:longitude DecimalPlaces:8];
      
      if (dateAsTimeIntervalSince1970 == 0) {
        dataValueText = sSKCoreGetLocalisedString(@"Unknown");
      } else {
        dataValueText = [SKGlobalMethods formatDate:[NSDate dateWithTimeIntervalSince1970:dateAsTimeIntervalSince1970]];
      }
    } else {
      latitudeValueText = sSKCoreGetLocalisedString(@"Unknown");
      longitudeValueText = sSKCoreGetLocalisedString(@"Unknown");
      dataValueText = sSKCoreGetLocalisedString(@"Unknown");
    }
    
    switch (indexPath.row) {
      case 0:
        [cell.mLabel setText: sSKCoreGetLocalisedString(@"latitude")];
        [cell.mValue setText:latitudeValueText];
        break;
      case 1:
        [cell.mLabel setText: sSKCoreGetLocalisedString(@"longitude")];
        [cell.mValue setText:longitudeValueText];
        break;
      case 2:
        [cell.mLabel setText:sSKCoreGetLocalisedString(@"date")];
        [cell.mValue setText:dataValueText];
        break;
      default:
        break;
    }
    
    return cell;
  } else {
    SK_ASSERT(false);
    return nil;
  }
}


-(void) validateText {
  if ([dataCapCell.txtDataCap.text length] == 0)
  {
    dataCapCell.txtDataCap.text = @"1";
  }
  else
  {
    int64_t value = [dataCapCell.txtDataCap.text longLongValue];
    
    if (value <= 0)
    {
      dataCapCell.txtDataCap.text = @"1";
    }
  }
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSLog(@"Sizeof long = %d", (int)sizeof(long));
  NSLog(@"Sizeof int64_t = %d", (int)sizeof(int64_t));
  int64_t theValue = (int64_t)[dataCapCell.txtDataCap.text longLongValue];
  theValue *= CBytesInAMegabyte;
  [prefs setObject:@(theValue) forKey:[SKAppBehaviourDelegate sGet_Prefs_DataCapLimitBytes]];
  [prefs synchronize];
}


@end
