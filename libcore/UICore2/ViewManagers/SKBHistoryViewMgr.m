//
//  SKBHistoryViewMgr.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBHistoryViewMgr.h"
#import "SKTestResults.h"
#import "SKBTestResultsSharer.h"

#define C_SHARE_BUTTON_HEIGHT   ([SKAppColourScheme sGet_GUI_MULTIPLIER] * 40)
#define C_SHARE_BUTTON_WIDTH   ([SKAppColourScheme sGet_GUI_MULTIPLIER] * 40)

@interface SKBHistoryViewMgr()

@property (nonatomic, strong) SKBTestResultsSharer* mpSharer;

@end

@implementation SKBHistoryViewMgr

- (void)intialiseViewOnMasterViewController:(UIViewController*)masterViewController_
{
  self.mpSharer = [[SKBTestResultsSharer alloc] initWithViewController:masterViewController_];
  
  self.masterViewController = masterViewController_;
  self.masterView = masterViewController_.view;
  self.backgroundColor = [UIColor clearColor];
  
  self.tvTests.delegate = self;
  self.tvTests.dataSource = self;
  
  //    [cActionSheet formatButton:self.btNetworkType];
  //    [cActionSheet formatButton:self.btPeriod];
  //    [cActionSheet formatButton:self.btGraph];
  
  testHeight = 100;
  expandedRow = -1;
  self.btShare.alpha = 0;
  
  currentFilterNetworkType = C_FILTER_NETWORKTYPE_ALL;
  currentFilterPeriod = C_FILTER_PERIOD_3MONTHS;
  
  // Ensure that the back button is properly sized!
  //self.backButtonHeightConstraint.constant = [SKAppColourScheme sGet_GUI_MULTIPLIER] * 100;
  
  [self selectedOption:C_FILTER_NETWORKTYPE_ALL from:self.casNetworkType WithState:1];
  
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
  NSMutableArray * GArrayForResultsController = [SKDatabase getTestMetaDataWhereNetworkTypeEquals:[SKAAppDelegate getNetworkTypeString]];
  
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
  [cell setTest:[arrTestsList objectAtIndex:indexPath.row]];
  
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

- (IBAction)B_NetworkType:(id)sender {
  
  if (!self.casNetworkType)
  {
    self.casNetworkType = [[cActionSheet alloc] initOnView:self.masterView withDelegate:self mainTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")];
    [self.casNetworkType addOption:sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi") withImage:[UIImage imageNamed:@"swifi.png"] andTag:C_FILTER_NETWORKTYPE_WIFI];
    [self.casNetworkType addOption:sSKCoreGetLocalisedString(@"NetworkTypeMenu_Mobile") withImage:[UIImage imageNamed:@"sgsm.png"] andTag:C_FILTER_NETWORKTYPE_GSM];
    [self.casNetworkType addOption:sSKCoreGetLocalisedString(@"NetworkTypeMenu_All") withImage:nil andTag:C_FILTER_NETWORKTYPE_ALL];
  }
  
  [self.casNetworkType expand];
}

- (IBAction)B_Period:(id)sender {
  
  if (!self.casPeriod)
  {
    self.casPeriod = [[cActionSheet alloc] initOnView:self.masterView withDelegate:self mainTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")];
    [self.casPeriod addOption:sSKCoreGetLocalisedString(@"time_period_1week") withImage:nil andTag:C_FILTER_PERIOD_1WEEK];
    [self.casPeriod addOption:sSKCoreGetLocalisedString(@"time_period_1month") withImage:nil andTag:C_FILTER_PERIOD_1MONTH];
    [self.casPeriod addOption:sSKCoreGetLocalisedString(@"time_period_3months") withImage:nil andTag:C_FILTER_PERIOD_3MONTHS];
    [self.casPeriod addOption:sSKCoreGetLocalisedString(@"time_period_1year") withImage:nil andTag:C_FILTER_PERIOD_1YEAR];
  }
  
  [self.casPeriod expand];
}

-(void)selectedOption:(int)optionTag from:(cActionSheet*)sender WithState:(int)state {
  
  if (sender == self.casNetworkType)
  {
    currentFilterNetworkType = optionTag;
    
    switch (optionTag) {
      case C_FILTER_NETWORKTYPE_WIFI:
        [self.btNetworkType setTitle:sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi") forState:UIControlStateNormal];
        break;
      case C_FILTER_NETWORKTYPE_GSM:
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
  else if (sender == self.casPeriod)
  {
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
}

-(void)selectedMainButtonFrom:(cActionSheet *)sender
{
  
}


-(NSString*)getSelectedNetworkWord
{
  switch (currentFilterNetworkType) {
    case C_FILTER_NETWORKTYPE_WIFI:
      return @"network";
      break;
    case C_FILTER_NETWORKTYPE_GSM:
      return @"mobile";
      break;
    case C_FILTER_NETWORKTYPE_ALL:
      return @"all";
      break;
    default:
      break;
  }
  return nil;
}

-(void)loadData
{
  //    arrTestsList = [SKDatabase getTestDataForNetworkType:[SKAAppDelegate getNetworkTypeString]];
  arrTestsList = [SKDatabase getTestDataForNetworkType:[self getSelectedNetworkWord] afterDate:nil];
  [self.tvTests reloadData];
  
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
  
  NSArray *passiveResultsArray = [[SKAAppDelegate getAppDelegate] getPassiveMetricsToDisplay];
  
  for (NSString *thePassiveMetric in passiveResultsArray) {
    [self placeMetricsWithLocalizedText:testResult_.metricsDictionary[thePassiveMetric] withLocalizedLabelTextID:sSKCoreGetLocalisedString(thePassiveMetric)];
  }
  
//  [self placeMetricsWithLocalizedText:testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_DEVICE] withLocalizedLabelTextID:sSKCoreGetLocalisedString(@"Phone")];
//  [self placeMetricsWithLocalizedText:testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_OS] withLocalizedLabelTextID:sSKCoreGetLocalisedString(@"OS")];
//  [self placeMetricsWithLocalizedText:testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_CARRIER_NAME] withLocalizedLabelTextID:sSKCoreGetLocalisedString(@"Carrier_Name")];
//  [self placeMetricsWithLocalizedText:testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_CARRIER_COUNTRY] withLocalizedLabelTextID:sSKCoreGetLocalisedString(@"Carrier_Country")];
//  [self placeMetricsWithLocalizedText:testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_CARRIER_ISO] withLocalizedLabelTextID:sSKCoreGetLocalisedString(@"Carrier_ISO")];
//  [self placeMetricsWithLocalizedText:testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_CARRIER_NETWORK] withLocalizedLabelTextID:sSKCoreGetLocalisedString(@"Carrier_Network")];
//  [self placeMetricsWithLocalizedText:testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_PUBLIC_IP] withLocalizedLabelTextID:sSKCoreGetLocalisedString(@"Public_IP")];
//  [self placeMetricsWithLocalizedText:testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_SUBMISSION_ID] withLocalizedLabelTextID:sSKCoreGetLocalisedString(@"Submission_ID")];
  
  // Only allow MOBILE results to be shared!
  self.btShare.hidden = YES;
  [self sendSubviewToBack:self.btShare];
 
  NSString *theNetworkType = testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_NETWORK_TYPE];
  if (theNetworkType.length > 0)
  {
    NSString* networkType;
    networkType = sSKCoreGetLocalisedString(@"Unknown");
    if ([theNetworkType isEqualToString:@"network"]) {
      networkType = sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi");
    } else if ([theNetworkType isEqualToString:@"mobile"]) {
      
      // Only allow MOBILE results to be shared!
      self.btShare.hidden = NO;
      [self bringSubviewToFront:self.btShare];
    }
  }

  if ([[SKAAppDelegate getAppDelegate] showNetworkTypeAndTargetAtEndOfHistoryPassiveMetrics]) {
    
    if (theNetworkType.length > 0)
    {
      NSString* networkType;
      networkType = sSKCoreGetLocalisedString(@"Unknown");
      if ([theNetworkType isEqualToString:@"network"]) {
        networkType = sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi");
      } else if ([theNetworkType isEqualToString:@"mobile"]) {
        
        NSString *mobileString = sSKCoreGetLocalisedString(@"NetworkTypeMenu_Mobile");
        
        NSString *theRadio = [SKGlobalMethods getNetworkTypeLocalized:testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_RADIO_TYPE]];
        if ([theRadio isEqualToString:sSKCoreGetLocalisedString(@"CTRadioAccessTechnologyUnknown")]) {
          networkType = mobileString;
        } else {
          networkType = [NSString stringWithFormat:@"%@ (%@)", mobileString, theRadio];
        }
      }
      
      [self placeMetricsWithLocalizedText:networkType withLocalizedLabelTextID:sSKCoreGetLocalisedString(@"Network_Type")];
    }
    [self placeMetricsWithLocalizedText:testResult_.target withLocalizedLabelTextID:sSKCoreGetLocalisedString(@"Target")];
  }
}

-(void)placeMetricsWithLocalizedText:(NSString*)text_ withLocalizedLabelTextID:(NSString*)localizedLabelTextID_
{
  UILabel* label;
  if (text_.length > 0)
  {
    label = [[UILabel alloc] initWithFrame:CGRectMake([SKAppColourScheme sGet_GUI_MULTIPLIER] * 10, mPassiveMetricsY + self.bounds.size.height, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 155, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 18)];
    label.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 13];
    label.textColor = [SKAppColourScheme sGetMetricsTextColour];
    label.text = localizedLabelTextID_;
    [self addSubview:label];
    [arrPassiveLabelsAndValues addObject:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake([SKAppColourScheme sGet_GUI_MULTIPLIER] * 120, mPassiveMetricsY + self.bounds.size.height, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 210, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 18)];
    label.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 13];
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
