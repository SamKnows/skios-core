//
//  SKBHistoryViewMgr.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBHistoryViewMgr.h"
#import "SKTestResults.h"
#import "SKBTestResultsSharer.h"
#import "SKBHistoryViewController.h"

#define C_SHARE_BUTTON_HEIGHT   ([SKAppColourScheme sGet_GUI_MULTIPLIER] * 40)
#define C_SHARE_BUTTON_WIDTH   ([SKAppColourScheme sGet_GUI_MULTIPLIER] * 40)

@interface SKBHistoryViewMgr()

@property (nonatomic, strong) SKBTestResultsSharer* mpSharer;

// This buttons is not used at the moment... but the could be added to the user interface.
@property (nonatomic, weak) UIButton* btNetworkType;
//@property (nonatomic, weak) UIButton* btPeriod;

@end

@implementation SKBHistoryViewMgr

- (void)dealloc
{
  // http://stackoverflow.com/questions/26147424/crash-in-uitableview-sending-message-to-deallocated-uiviewcontroller
  self.tvTests.dataSource = nil;
  self.tvTests.delegate = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialiseViewOnMasterViewController:(SKBHistoryViewController*)masterViewController_
{
  self.mpSharer = [[SKBTestResultsSharer alloc] initWithViewController:masterViewController_];
  
  self.masterViewController = masterViewController_;
  self.masterView = masterViewController_.view;
  self.backgroundColor = [UIColor clearColor];
  
  self.tvTests.delegate = self;
  self.tvTests.dataSource = self;
  
  //    [CActionSheet formatButton:self.btNetworkType];
  //    [CActionSheet formatButton:self.btPeriod];
  //    [CActionSheet formatButton:self.btGraph];
  
  testHeight = 100;
  expandedRow = -1;
  self.btShare.alpha = 0;
  
  currentFilterNetworkType = C_FILTER_NETWORKTYPE_ALL;
  //currentFilterPeriod = C_FILTER_PERIOD_3MONTHS;
  
  // Ensure that the back button is properly sized!
  //self.backButtonHeightConstraint.constant = [SKAppColourScheme sGet_GUI_MULTIPLIER] * 100;
 
  // Ensure that the localized text is shown.
  [self selectedNetworkTypeOption:C_FILTER_NETWORKTYPE_ALL];
  //[self selectedTimePeriodOption:C_FILTER_PERIOD_1WEEK];
  
  [self loadData];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateTestList:)
                                               name:@"TestListNeedsUpdate"
                                             object:nil];
}

-(void)updateTestList:(NSNotification *) notification
{
  if ([[notification name] isEqualToString:@"TestListNeedsUpdate"])
  {
    [self loadData];
    
    if (self.btBack.userInteractionEnabled) {
      [self B_Back:self.btBack];
    }
  }
}

-(void)setColoursAndShowHideElements {
  self.backgroundColor = [UIColor clearColor];
  self.btShare.hidden = YES;
}

-(void)performLayout
{
  //self.tvTests.frame = CGRectMake(0, 20, self.bounds.size.width, self.bounds.size.height - 20);
  
  [self setColoursAndShowHideElements];
}

-(BOOL) canViewArchivedResults {
  NSMutableArray * GArrayForResultsController = [SKDatabase getTestMetaDataWhereNetworkTypeEquals:[SKAppBehaviourDelegate getNetworkTypeString]];
  
  if (GArrayForResultsController != nil)
  {
    if ([GArrayForResultsController count] > 0)
    {
      return YES;
    }
    GArrayForResultsController = nil;
  }
  return NO;
}

#pragma mark TabelView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return arrTestsList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == expandedRow) {
    return testHeight;
  }
  
  return [SKAppColourScheme sGet_GUI_MULTIPLIER] * 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  SKBTestOverviewCell *cell;
  static NSString *CellIdentifier = @"SKBTestOverviewCell";
  
  cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    
    cell = [[SKBTestOverviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  [cell initCell];
  [cell setTest:arrTestsList[indexPath.row]];
  
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getRevealPassiveMetricsOnArchiveResultsPanel] == NO) {
    return;
  }
  
  selectedTest = arrTestsList[indexPath.row];
  cell2putBack = (SKBTestOverviewCell*)[tableView cellForRowAtIndexPath:indexPath];
  view2putBack = [cell2putBack getView];
  originalCellFrame = cell2putBack.frame;
  
  [view2putBack removeFromSuperview];
  view2putBack.frame = CGRectMake(cell2putBack.frame.origin.x, self.tvTests.frame.origin.y, cell2putBack.frame.size.width, cell2putBack.frame.size.height);
  [self addSubview:view2putBack];
  
  self.btBack.userInteractionEnabled = YES;
  [self bringSubviewToFront:self.btBack];
  
  // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
  [self layoutIfNeeded];
  self.shareButtonTopOffsetConstraint.constant = self.masterView.frame.size.height + 1;
  // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
  [self layoutIfNeeded];
  
  self.btShare.alpha = 0;
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [UIView animateWithDuration:0.3 animations:^{
      self.tvTests.alpha = 0;
      self.tvTests.frame = CGRectMake(- self.tvTests.frame.size.width, self.tvTests.frame.origin.y, self.tvTests.frame.size.width, self.tvTests.frame.size.height);
    } completion:^(BOOL finished) {
      [self printPassiveMetrics:(arrTestsList[indexPath.row])];
      
      // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
      [self layoutIfNeeded];
      
      [UIView animateWithDuration:1.0
                            delay:0.0
           usingSpringWithDamping:1
            initialSpringVelocity:13
                          options:UIViewAnimationOptionCurveEaseIn
       
                       animations:^{
                         view2putBack.frame = CGRectMake(0, 20, view2putBack.frame.size.width, view2putBack.frame.size.height);
                         self.shareButtonTopOffsetConstraint.constant = mPassiveMetricsY + [SKAppColourScheme sGet_GUI_MULTIPLIER] * 10;
                         //self.btShare.frame = CGRectMake([SKAppColourScheme sGet_GUI_MULTIPLIER] * 10, y + [SKAppColourScheme sGet_GUI_MULTIPLIER] * 10, C_SHARE_BUTTON_WIDTH, C_SHARE_BUTTON_HEIGHT);
                         
                         self.btShare.alpha = 1;
                         [self showMetrics];
                         
                         // Bring share button to front, in case required!
                         [self bringSubviewToFront:self.btShare];
                         
                         // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
                         [self layoutIfNeeded];
                         
                       } completion:^(BOOL finished) {
                       }];
    }];
  });
  
  return;
}

#pragma mark UIActionSheetDelegate (begin)

#define ACTIONSHEET_NETWORK 0
//#define ACTIONSHEET_PERIOD  1

static NSUInteger sWiFiButtonIndex = 0;
static NSUInteger sMobileButtonIndex = 0;
static NSUInteger sAllButtonIndex = 0;

//static NSUInteger s1WeekButtonIndex = 0;
//static NSUInteger s1MonthButtonIndex = 0;
//static NSUInteger s3MonthButtonIndex = 0;
//static NSUInteger s1YearButtonIndex = 0;

#pragma mark UIActionSheetDelegate (begin)
// Called when a button is clicked. The view will be automatically dismissed after this call returns
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    return;
  }
  
  //NSString *theButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
  
  switch (actionSheet.tag) {
    case ACTIONSHEET_NETWORK:
      if (buttonIndex == sWiFiButtonIndex) {
        [self selectedNetworkTypeOption:C_FILTER_NETWORKTYPE_WIFI];
      } else if (buttonIndex == sMobileButtonIndex) {
        [self selectedNetworkTypeOption:C_FILTER_NETWORKTYPE_MOBILE];
      } else if (buttonIndex == sAllButtonIndex) {
        [self selectedNetworkTypeOption:C_FILTER_NETWORKTYPE_ALL];
      } else {
        SK_ASSERT(false);
      }
      break;
      /*
    case ACTIONSHEET_PERIOD:
      if (buttonIndex == s1WeekButtonIndex) {
        [self selectedTimePeriodOption:C_FILTER_PERIOD_1WEEK];
      } else if (buttonIndex == s1MonthButtonIndex) {
        [self selectedTimePeriodOption:C_FILTER_PERIOD_1MONTH];
      } else if (buttonIndex == s3MonthButtonIndex) {
        [self selectedTimePeriodOption:C_FILTER_PERIOD_3MONTHS];
      } else if (buttonIndex == s1YearButtonIndex) {
        [self selectedTimePeriodOption:C_FILTER_PERIOD_1YEAR];
      } else {
        SK_ASSERT(false);
      }
      break;
       */
    default:
      SK_ASSERT(false);
      break;
  }
}
#pragma mark UIActionSheetDelegate (end)

-(NSString*)getStringBasedOn:(NSString*)basedOn WithTickAtIfTrue:(BOOL) value {
  
  basedOn = sSKCoreGetLocalisedString(basedOn);
  
  if (value == NO) {
    return basedOn;
  }
  
  return [NSString stringWithFormat:@"%@ \u2713", basedOn];
}


-(void)selectedOption:(int)optionTag from:(CActionSheet *)sender WithState:(int)state
{
  SK_ASSERT(sender != nil);
  
  if (sender == self.casNetworkType)
  {
    [self selectedNetworkTypeOption:(C_FILTER_NETWORKTYPE)optionTag];
  } else {
    SK_ASSERT(false);
  }
}

- (void)showNetworkTypeFilterActionSheet {
  //if (!self.casNetworkType)
  {
    self.casNetworkType = [[CActionSheet alloc] initOnView:self.masterView withDelegate:self mainTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel") WithMultiSelection:NO];
    [self.casNetworkType addOption:sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi") withImage:[UIImage imageNamed:@"swifi.png"] andTag:C_FILTER_NETWORKTYPE_WIFI AndSelected:(currentFilterNetworkType == C_FILTER_NETWORKTYPE_WIFI)];
    [self.casNetworkType addOption:sSKCoreGetLocalisedString(@"NetworkTypeMenu_Mobile") withImage:[UIImage imageNamed:@"sgsm.png"] andTag:C_FILTER_NETWORKTYPE_MOBILE  AndSelected:(currentFilterNetworkType == C_FILTER_NETWORKTYPE_MOBILE)];
    [self.casNetworkType addOption:sSKCoreGetLocalisedString(@"NetworkTypeMenu_All") withImage:nil andTag:C_FILTER_NETWORKTYPE_ALL  AndSelected:(currentFilterNetworkType == C_FILTER_NETWORKTYPE_ALL)];
  }
  
  [self.casNetworkType expand];
  
//  UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel") destructiveButtonTitle:nil  otherButtonTitles:nil];
//  alert.tag = ACTIONSHEET_NETWORK;
//  
//  // TODO - what about WiFi/Mobile icons, if any, via Unicode?
//  
//  // Note tha the CANCEL BUTTON has index ZERO!
//  
//  sWiFiButtonIndex = [alert addButtonWithTitle:[self getStringBasedOn:@"NetworkTypeMenu_WiFi" WithTickAtIfTrue:(currentFilterNetworkType == C_FILTER_NETWORKTYPE_WIFI)]]; //  withImage:[UIImage imageNamed:@"swifi.png"] andTag:C_FILTER_NETWORKTYPE_WIFI];
//  
//  sMobileButtonIndex = [alert addButtonWithTitle:[self getStringBasedOn:@"NetworkTypeMenu_Mobile" WithTickAtIfTrue:(currentFilterNetworkType == C_FILTER_NETWORKTYPE_MOBILE)]]; //  withImage:[UIImage imageNamed:@"swifi.png"] andTag:C_FILTER_NETWORKTYPE_WIFI];
//  
//  sAllButtonIndex = [alert addButtonWithTitle:[self getStringBasedOn:@"NetworkTypeMenu_All" WithTickAtIfTrue:(currentFilterNetworkType == C_FILTER_NETWORKTYPE_ALL)]]; //  withImage:[UIImage imageNamed:@"swifi.png"] andTag:C_FILTER_NETWORKTYPE_WIFI];
//  
//  [alert showInView:self];
}

/*
- (IBAction)B_Period:(id)sender {
  UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel") destructiveButtonTitle:nil  otherButtonTitles:nil];
  
  alert.tag = ACTIONSHEET_PERIOD;
  
  s1WeekButtonIndex = [alert addButtonWithTitle:[self getStringBasedOn:@"time_period_1week" WithTickAtIfTrue:(currentFilterPeriod == C_FILTER_PERIOD_1WEEK)]];
  s1MonthButtonIndex = [alert addButtonWithTitle:[self getStringBasedOn:@"time_period_1month" WithTickAtIfTrue:(currentFilterPeriod == C_FILTER_PERIOD_1MONTH)]];
  s3MonthButtonIndex = [alert addButtonWithTitle:[self getStringBasedOn:@"time_period_3months" WithTickAtIfTrue:(currentFilterPeriod == C_FILTER_PERIOD_3MONTHS)]];
  s1YearButtonIndex = [alert addButtonWithTitle:[self getStringBasedOn:@"time_period_1year" WithTickAtIfTrue:(currentFilterPeriod == C_FILTER_PERIOD_1YEAR)]];
  
  [alert showInView:self];
}
*/

-(void)selectedNetworkTypeOption:(C_FILTER_NETWORKTYPE)optionTag {
  
  currentFilterNetworkType = optionTag;
 
  switch (optionTag) {
    case C_FILTER_NETWORKTYPE_WIFI:
      [self.btNetworkType setTitle:sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi") forState:UIControlStateNormal];
      break;
    case C_FILTER_NETWORKTYPE_MOBILE:
      [self.btNetworkType setTitle:sSKCoreGetLocalisedString(@"NetworkTypeMenu_Mobile") forState:UIControlStateNormal];
      break;
    case C_FILTER_NETWORKTYPE_ALL:
      [self.btNetworkType setTitle:sSKCoreGetLocalisedString(@"NetworkTypeMenu_All") forState:UIControlStateNormal];
      break;
    default:
      break;
  }
  
  [self loadData];
}

  /*
-(void)selectedTimePeriodOption:(C_FILTER_PERIOD)optionTag {
  currentFilterPeriod = optionTag;

  switch (optionTag) {
    case C_FILTER_PERIOD_1WEEK:
      [self.btPeriod setTitle:sSKCoreGetLocalisedString(@"time_period_1week") forState:UIControlStateNormal];
      break;
    case C_FILTER_PERIOD_1MONTH:
      [self.btPeriod setTitle:sSKCoreGetLocalisedString(@"time_period_1month") forState:UIControlStateNormal];
      break;
    case C_FILTER_PERIOD_3MONTHS:
      [self.btPeriod setTitle:sSKCoreGetLocalisedString(@"time_period_3months") forState:UIControlStateNormal];
      break;
    case C_FILTER_PERIOD_1YEAR:
      [self.btPeriod setTitle:sSKCoreGetLocalisedString(@"time_period_1year") forState:UIControlStateNormal];
      break;
    default:
      break;
  }
  
  [self loadData];
}
  */

-(NSString*)getSelectedNetworkWord
{
  switch (currentFilterNetworkType) {
    case C_FILTER_NETWORKTYPE_WIFI:
      return C_NETWORKTYPEASSTRING_WIFI;
      break;
    case C_FILTER_NETWORKTYPE_MOBILE:
      return C_NETWORKTYPEASSTRING_MOBILE;
      break;
    case C_FILTER_NETWORKTYPE_ALL:
      return C_NETWORKTYPEASSTRING_ALL;
      break;
    default:
      break;
  }
  return nil;
}

-(void)loadData
{
  //    arrTestsList = [SKDatabase getTestDataForNetworkType:[SKAppBehaviourDelegate getNetworkTypeString]];
  arrTestsList = [SKDatabase getTestDataForNetworkType:[self getSelectedNetworkWord] afterDate:nil];
  [self.tvTests reloadData];

  // Show or hide the label behind!
  [self.masterViewController childTableViewRowsUpdated:arrTestsList.count];
  if (arrTestsList.count == 0) {
    // Reveal the label behind!
    self.tvTests.hidden = YES;
  } else {
    // Hide the label behind!
    self.tvTests.hidden = NO;
  }
  
  return;
}

static SKATestResults* testToShareExternal = nil;
+(SKATestResults *) sCreateNewTstToShareExternal {
  testToShareExternal = [[SKATestResults alloc] init];
  return testToShareExternal;
}

+(SKATestResults *) sGetTstToShareExternal {
  SK_ASSERT(testToShareExternal != nil);
  //  if (testToShareExternal == nil) {
  //      testToShareExternal = [[SKATestResults alloc] init];
  //  }
  return testToShareExternal;
}

-(void)shareTest:(SKATestResults*)testResult
{
  selectedTest = testResult;
  
  [self.mpSharer shareTest:selectedTest];
}

- (IBAction)B_Back:(id)sender {
  // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
  [self layoutIfNeeded];
  
  self.btBack.userInteractionEnabled = NO;
  [self sendSubviewToBack:self.btBack];
  [self sendSubviewToBack:self.btShare];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    
    [UIView animateWithDuration:0.3 animations:^{
      
      view2putBack.frame = CGRectMake(cell2putBack.frame.origin.x, cell2putBack.frame.origin.y - self.tvTests.contentOffset.y + self.tvTests.frame.origin.y, cell2putBack.frame.size.width, cell2putBack.frame.size.height);
      
      [self hideMetrics];
      self.btShare.frame = CGRectMake([SKAppColourScheme sGet_GUI_MULTIPLIER] * 10, self.masterView.bounds.size.height + 1, C_SHARE_BUTTON_WIDTH, C_SHARE_BUTTON_HEIGHT);
      self.btShare.alpha = 0;
      
      
    } completion:^(BOOL finished) {
      
      self.tvTests.frame = CGRectMake(- self.tvTests.frame.size.width, self.tvTests.frame.origin.y, self.tvTests.frame.size.width, self.tvTests.frame.size.height);
      
      float tableAnimationTime = 0.3;
      
      [UIView animateWithDuration:tableAnimationTime animations:^{
        self.tvTests.alpha = 1;
        self.tvTests.frame = CGRectMake(0, self.tvTests.frame.origin.y, self.tvTests.frame.size.width, self.tvTests.frame.size.height);
      } completion:^(BOOL finished) {
        
        [view2putBack removeFromSuperview];
        [cell2putBack addSubview:view2putBack];
        
        view2putBack.frame = cell2putBack.bounds;
        self.btShare.hidden = YES;
        
        [self destroyMetrics];
      }];
    }];
  });
}

-(void)printPassiveMetrics:(SKATestResults*)testResult_
{
  // We should only "print" the passive metrics that are an intersection of the following sets:
  // Those values for which we have tests results, in the metricsDictionary
  // Those values which are in the set or results that the app is interested in displaying!
 
  // TODO - for now, show the COMPLETE set if available.
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    mPassiveMetricsY = [SKAppColourScheme sGet_GUI_MULTIPLIER] * 110;
  }
  else {
    mPassiveMetricsY = [SKAppColourScheme sGet_GUI_MULTIPLIER] * 120;
  }
  
  arrPassiveLabelsAndValues = [[NSMutableArray alloc] initWithCapacity:0];
 
  BOOL bIsWiFi = NO;
  NSString *theNetworkType = testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_NETWORK_TYPE];
  //SK_ASSERT([theNetworkType isEqualToString:C_NETWORKTYPEASSTRING_WIFI] || [theNetworkType isEqualToString:C_NETWORKTYPEASSTRING_MOBILE] ||[theNetworkType isEqualToString:@"NA"]);
  if (theNetworkType.length > 0)
  {
//    NSString* networkType = sSKCoreGetLocalisedString(@"Unknown");
    if (([theNetworkType isEqualToString:C_NETWORKTYPEASSTRING_WIFI]) ||
        ([theNetworkType isEqualToString: sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi")])
       )
    {
      bIsWiFi = YES;
    }
  }
  
  NSArray *passiveResultsArray = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getPassiveMetricsToDisplayWiFiFlag:bIsWiFi];
  
  for (NSString *thePassiveMetric in passiveResultsArray) {
    if (bIsWiFi) {
      // If WiFi, do NOT show the mobile network metrics!
      if ([thePassiveMetric isEqualToString:SKB_TESTVALUERESULT_C_PM_CARRIER_NAME]) {
        continue;
      }
      if ([thePassiveMetric isEqualToString:SKB_TESTVALUERESULT_C_PM_CARRIER_COUNTRY]) {
        continue;
      }
      if ([thePassiveMetric isEqualToString:SKB_TESTVALUERESULT_C_PM_CARRIER_NETWORK]) {
        continue;
      }
      if ([thePassiveMetric isEqualToString:SKB_TESTVALUERESULT_C_PM_ISO_COUNTRY_CODE]) {
        continue;
      }
    } else {
      // Mobile test...
      // If Mobile, do NOT show the WiFi SSID!
      if ([thePassiveMetric isEqualToString:SKB_TESTVALUERESULT_C_PM_WIFI_SSID]) {
        continue;
      }
    }
   
    if ([thePassiveMetric isEqualToString:SKB_TESTVALUERESULT_C_PM_TARGET]) {
      if (testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_TARGET] == nil) {
        testResult_.metricsDictionary[thePassiveMetric] = testResult_.target;
      }
    }
    // C_NETWORKTYPEASSTRING_WIFI
    if ([thePassiveMetric isEqualToString:SKB_TESTVALUERESULT_C_PM_DEVICE]) {
      if (testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_DEVICE] == nil) {
        testResult_.metricsDictionary[thePassiveMetric] = [SKAppBehaviourDelegate sGetAppBehaviourDelegate].deviceModel;
      }
    }
    
    [self placeMetricsWithLocalizedText:testResult_.metricsDictionary[thePassiveMetric] withLocalizedLabelTextID:sSKCoreGetLocalisedString(thePassiveMetric)];
  }
  
  // Only allow MOBILE results to be shared!
  self.btShare.hidden = YES;
  [self sendSubviewToBack:self.btShare];
 
  if (theNetworkType.length > 0)
  {
//    NSString* networkType = sSKCoreGetLocalisedString(@"Unknown");
    if ([theNetworkType isEqualToString:C_NETWORKTYPEASSTRING_WIFI]) {
//      networkType = sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi");
    } else if ([theNetworkType isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
      
      // Only allow MOBILE results to be shared - provided social media sharing is enabled!
      
      if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isSocialMediaExportSupported] == YES) {
        self.btShare.hidden = NO;
        [self bringSubviewToFront:self.btShare];
      }
    }
  }

  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] showNetworkTypeAndTargetAtEndOfHistoryPassiveMetrics]) {
    
    if (theNetworkType.length > 0)
    {
      NSString* networkType = sSKCoreGetLocalisedString(@"Unknown");
      if ([theNetworkType isEqualToString:C_NETWORKTYPEASSTRING_WIFI]) {
        networkType = sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi");
      } else if ([theNetworkType isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
        
        NSString *mobileString = sSKCoreGetLocalisedString(@"NetworkTypeMenu_Mobile");
        
        NSString *theRadio = [SKGlobalMethods getNetworkTypeLocalized:testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_RADIO_TYPE]];
        if ([theRadio isEqualToString:sSKCoreGetLocalisedString(@"CTRadioAccessTechnologyUnknown")]) {
          networkType = mobileString;
        } else {
          //networkType = [NSString stringWithFormat:@"%@ (%@)", mobileString, theRadio];
          networkType = [NSString stringWithFormat:@"%@ (%@)", mobileString, theRadio];
          
// // Get the mobile string as (localized) e.g. "Mobile (LTE)" or "Mobile (LTE, mytelco)"
//          NSString *carrierName = [SKGlobalMethods getNetworkTypeLocalized:testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_CARRIER_NAME]];
//          if (carrierName != nil && carrierName.length > 0) {
//            networkType = [NSString stringWithFormat:@"%@ (%@, %@)", mobileString, theRadio, carrierName];
//          }
        }
      }
      
      [self placeMetricsWithLocalizedText:networkType withLocalizedLabelTextID:sSKCoreGetLocalisedString(@"Network_Type")];
    }
    [self placeMetricsWithLocalizedText:testResult_.target withLocalizedLabelTextID:sSKCoreGetLocalisedString(@"Target")];
  }
}

-(void)placeMetricsWithLocalizedText:(NSString*)text_ withLocalizedLabelTextID:(NSString*)localizedLabelTextID_
{
  if ([text_ isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
    text_ = sSKCoreGetLocalisedString(@"NetworkTypeMenu_Mobile");
  } else if ([text_ isEqualToString:C_NETWORKTYPEASSTRING_WIFI]) {
    text_ = sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi");
  }
  
  UILabel* label;
  if (text_.length > 0)
  {
    label = [[UILabel alloc] initWithFrame:CGRectMake([SKAppColourScheme sGet_GUI_MULTIPLIER] * 10, mPassiveMetricsY + self.bounds.size.height, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 85, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 18)];
    label.adjustsFontSizeToFitWidth = YES;
    label.font = [SKAppColourScheme sGetFontWithName:@"RobotoCondensed-Regular" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 13];
    label.textColor = [SKAppColourScheme sGetMetricsTextColour];
    label.text = localizedLabelTextID_;
    [self addSubview:label];
    [arrPassiveLabelsAndValues addObject:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake([SKAppColourScheme sGet_GUI_MULTIPLIER] * 100, mPassiveMetricsY + self.bounds.size.height, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 220, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 18)];
    label.adjustsFontSizeToFitWidth = YES;
    label.font = [SKAppColourScheme sGetFontWithName:@"RobotoCondensed-Regular" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 13];
    label.textColor = [SKAppColourScheme sGetMetricsTextColour];
    label.text = text_;
    [self addSubview:label];
    [arrPassiveLabelsAndValues addObject:label];
    mPassiveMetricsY += [SKAppColourScheme sGet_GUI_MULTIPLIER] * 15;
  }
}

-(void)destroyMetrics
{
  for (UILabel* l in arrPassiveLabelsAndValues) {
    [l removeFromSuperview];
  }
  [arrPassiveLabelsAndValues removeAllObjects];
}

-(void)hideMetrics
{
  for (UILabel* l in arrPassiveLabelsAndValues) {
    l.frame = CGRectMake(l.frame.origin.x, self.bounds.size.height + l.frame.origin.y, l.frame.size.width, l.frame.size.height);
  }
  //self.btBack.userInteractionEnabled = NO;
}

-(void)showMetrics
{
  for (UILabel* l in arrPassiveLabelsAndValues) {
    l.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y - self.bounds.size.height, l.frame.size.width, l.frame.size.height);
  }
  //self.btBack.userInteractionEnabled = YES;
}

- (IBAction)B_Share:(id)sender
{
  //if ([SKAppColourScheme globalInstance].selectedTab != C_TABINDX_HISTORY) //Call from another tab
  //[self shareTest:self.testToShareExternal];
  //else
  [self shareTest:selectedTest];
}

-(void)activate
{
}

-(void)deactivate
{
}

@end
