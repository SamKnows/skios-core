//
//  SKBSummaryViewMgr.m
//  SKCore
//
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBSummaryViewMgr.h"
#import "SKBSummaryTableViewCell.h"
#import "SKAGraphViewCell.h"

@interface SKBSummaryViewMgr()
@property SKGraphForResults *skGraphForResults;
@end

@implementation SKBSummaryViewMgr
{
  UIView* cellContentView2putBack;
  SKBSummaryTableViewCell* cell2putBack;
  //CGRect originalCellContentFrame;
  CGFloat mRestoreToY;
}

@synthesize skGraphForResults;

#define C_BUTTON_BASE_ALPHA 0.1
#define C_VIEWS_Y_FIRST 110

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialiseViewOnMasterView:(UIView*)masterView_
{
  SK_ASSERT(self.vChart != nil);
  
  currentChartType= -1;
  
  self.backgroundColor = [UIColor clearColor]; // #2B4195
  
  self.masterView = masterView_;
  
  [CActionSheet formatView:self.btNetworkType];
  [CActionSheet formatView:self.btPeriod];
  
  currentFilterNetworkType = C_FILTER_NETWORKTYPE_ALL;
  currentFilterPeriod = C_FILTER_PERIOD_1MONTH;
  
  // Ensure that the correct, localized text is shown.
  [self selectedNetworkTypeOption:C_FILTER_NETWORKTYPE_ALL];
  [self selectedTimePeriodOption:C_FILTER_PERIOD_1WEEK];
  
  // Set table to clear background colour!
  // http://stackoverflow.com/questions/18878258/uitableviewcell-show-white-background-and-cannot-be-modified-on-ios7
  [self.tvTests setBackgroundView:nil];
  [self.tvTests setBackgroundColor:[UIColor clearColor]];
  
  //TODO: Adjust button texts to these default values
  [self loadData];
  [self.tvTests reloadData];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateTestList:)
                                               name:@"TestListNeedsUpdate"
                                             object:nil];
}

static BOOL sbReloadTableAfterBack = NO;

-(void)updateTestList:(NSNotification *) notification
{
  if ([[notification name] isEqualToString:@"TestListNeedsUpdate"]) {
    
    if (self.btBack.userInteractionEnabled == YES) {
      dispatch_async(dispatch_get_main_queue(), ^{
        sbReloadTableAfterBack = YES;
        [self B_Back:nil];
      });
    } else {
      [self loadData];
    }
  }
}

-(void)setColoursAndShowHideElements {
  self.backgroundColor = [UIColor clearColor];
  
  self.vHeader.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
  self.vHeader.layer.cornerRadius = [SKAppColourScheme sGet_GUI_MULTIPLIER] * 3;
  self.vHeader.layer.borderWidth = 0.5;
  self.vHeader.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
  
  self.btNetworkType.backgroundColor = [SKAppColourScheme sGetSummaryGetMenuPanelBackgroundColour];
  self.btPeriod.backgroundColor = [SKAppColourScheme sGetSummaryGetMenuPanelBackgroundColour];
  self.vHeader.backgroundColor = [SKAppColourScheme sGetSummaryGetMenuPanelBackgroundColour];
 
  self.tvTests.separatorColor = [SKAppColourScheme sGetSummaryGetTableSeparatorColour];
  
  self.vChart.alpha = 0;
  self.vChart.backgroundColor = [SKAppColourScheme sGetGraphColourBackground];
  self.vChart.layer.cornerRadius = 10.0;
  // DEBUG!
  //self.vChart.backgroundColor = [UIColor greenColor];
}

// If you want the alerts to work in the iOS-standard manner, then use this option!
// Otherwise, they display in the ugly "New App" style.
//#define USE_IOS_STANDARD_ALERT 1

#ifdef USE_IOS_STANDARD_ALERT

#pragma mark UIActionSheetDelegate (begin)

#define ACTIONSHEET_NETWORK 0
#define ACTIONSHEET_PERIOD  1

static NSUInteger sWiFiButtonIndex = 0;
static NSUInteger sMobileButtonIndex = 0;
static NSUInteger sAllButtonIndex = 0;

static NSUInteger s1WeekButtonIndex = 0;
static NSUInteger s1MonthButtonIndex = 0;
static NSUInteger s3MonthButtonIndex = 0;
static NSUInteger s1YearButtonIndex = 0;

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
        [self selectedNetworkTypeOption:C_FILTER_NETWORKTYPE_GSM];
      } else if (buttonIndex == sAllButtonIndex) {
        [self selectedNetworkTypeOption:C_FILTER_NETWORKTYPE_ALL];
      } else {
        SK_ASSERT(false);
      }
      break;
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
 
  // Add a tick at the end!
  return [NSString stringWithFormat:@"%@ \u2713", basedOn];
  //return [NSString stringWithFormat:@"%@ \u2713 �", basedOn];
  // ANTENNA WITH BARS
  // Unicode: U+1F4F6 (U+D83D U+DCF6), UTF-8: F0 9F 93 B6
}


- (IBAction)B_NetworkType:(id)sender {
  
  UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel") destructiveButtonTitle:nil  otherButtonTitles:nil];
  alert.tag = ACTIONSHEET_NETWORK;
  
  // TODO - what about WiFi/Mobile icons, if any, via Unicode?
  
  // Note tha the CANCEL BUTTON has index ZERO!
  
  sWiFiButtonIndex = [alert addButtonWithTitle:[self getStringBasedOn:@"NetworkTypeMenu_WiFi" WithTickAtIfTrue:(currentFilterNetworkType == C_FILTER_NETWORKTYPE_WIFI)]]; //  withImage:[UIImage imageNamed:@"swifi.png"] andTag:C_FILTER_NETWORKTYPE_WIFI];
  
  sMobileButtonIndex = [alert addButtonWithTitle:[self getStringBasedOn:@"NetworkTypeMenu_Mobile" WithTickAtIfTrue:(currentFilterNetworkType == C_FILTER_NETWORKTYPE_GSM)]]; //  withImage:[UIImage imageNamed:@"swifi.png"] andTag:C_FILTER_NETWORKTYPE_WIFI];
  
  sAllButtonIndex = [alert addButtonWithTitle:[self getStringBasedOn:@"NetworkTypeMenu_All" WithTickAtIfTrue:(currentFilterNetworkType == C_FILTER_NETWORKTYPE_ALL)]]; //  withImage:[UIImage imageNamed:@"swifi.png"] andTag:C_FILTER_NETWORKTYPE_WIFI];
  
  [alert showInView:self];
}

- (IBAction)B_Period:(id)sender {
  UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel") destructiveButtonTitle:nil  otherButtonTitles:nil];
  
  alert.tag = ACTIONSHEET_PERIOD;
  
  s1WeekButtonIndex = [alert addButtonWithTitle:[self getStringBasedOn:@"time_period_1week" WithTickAtIfTrue:(currentFilterPeriod == C_FILTER_PERIOD_1WEEK)]];
  s1MonthButtonIndex = [alert addButtonWithTitle:[self getStringBasedOn:@"time_period_1month" WithTickAtIfTrue:(currentFilterPeriod == C_FILTER_PERIOD_1MONTH)]];
  s3MonthButtonIndex = [alert addButtonWithTitle:[self getStringBasedOn:@"time_period_3months" WithTickAtIfTrue:(currentFilterPeriod == C_FILTER_PERIOD_3MONTHS)]];
  s1YearButtonIndex = [alert addButtonWithTitle:[self getStringBasedOn:@"time_period_1year" WithTickAtIfTrue:(currentFilterPeriod == C_FILTER_PERIOD_1YEAR)]];
  
  [alert showInView:self];
}
#else  // USE_IOS_STANDARD_ALERT
- (IBAction)B_NetworkType:(id)sender {
  
  //if (!self.casNetworkType)
  {
    self.casNetworkType = [[CActionSheet alloc] initOnView:self.masterView withDelegate:self mainTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel") WithMultiSelection:NO];
    [self.casNetworkType addOption:sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi") withImage:[UIImage imageNamed:@"swifi.png"] andTag:C_FILTER_NETWORKTYPE_WIFI AndSelected:(currentFilterNetworkType == C_FILTER_NETWORKTYPE_WIFI)];
    [self.casNetworkType addOption:sSKCoreGetLocalisedString(@"NetworkTypeMenu_Mobile") withImage:[UIImage imageNamed:@"sgsm.png"] andTag:C_FILTER_NETWORKTYPE_GSM  AndSelected:(currentFilterNetworkType == C_FILTER_NETWORKTYPE_GSM)];
    [self.casNetworkType addOption:sSKCoreGetLocalisedString(@"NetworkTypeMenu_All") withImage:nil andTag:C_FILTER_NETWORKTYPE_ALL  AndSelected:(currentFilterNetworkType == C_FILTER_NETWORKTYPE_ALL)];
  }
  
  [self.casNetworkType expand];
  
}

- (IBAction)B_Period:(id)sender {
  
  //if (!self.casPeriod)
  {
    self.casPeriod = [[CActionSheet alloc] initOnView:self.masterView withDelegate:self mainTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel") WithMultiSelection:NO];
    [self.casPeriod addOption:sSKCoreGetLocalisedString(@"time_period_1day") withImage:nil andTag:C_FILTER_PERIOD_1DAY AndSelected:(currentFilterPeriod == C_FILTER_PERIOD_1DAY)];
    [self.casPeriod addOption:sSKCoreGetLocalisedString(@"time_period_1week") withImage:nil andTag:C_FILTER_PERIOD_1WEEK AndSelected:(currentFilterPeriod == C_FILTER_PERIOD_1WEEK)];
    [self.casPeriod addOption:sSKCoreGetLocalisedString(@"time_period_1month") withImage:nil andTag:C_FILTER_PERIOD_1MONTH AndSelected:(currentFilterPeriod == C_FILTER_PERIOD_1MONTH)];
    [self.casPeriod addOption:sSKCoreGetLocalisedString(@"time_period_3months") withImage:nil andTag:C_FILTER_PERIOD_3MONTHS AndSelected:(currentFilterPeriod == C_FILTER_PERIOD_3MONTHS)];
    [self.casPeriod addOption:sSKCoreGetLocalisedString(@"time_period_1year") withImage:nil andTag:C_FILTER_PERIOD_1YEAR AndSelected:(currentFilterPeriod == C_FILTER_PERIOD_1YEAR)];
  }
  
  [self.casPeriod expand];
}


-(void)selectedOption:(int)optionTag from:(CActionSheet *)sender WithState:(int)state
{
  SK_ASSERT(sender != nil);
  
  if (sender == self.casNetworkType)
  {
    [self selectedNetworkTypeOption:(C_FILTER_NETWORKTYPE)optionTag];
  }
  else if (sender == self.casPeriod)
  {
    [self selectedTimePeriodOption:(C_FILTER_PERIOD)optionTag];
  } else {
    SK_ASSERT(false);
  }
}

#endif // USE_IOS_STANDARD_ALERT


-(void)selectedNetworkTypeOption:(C_FILTER_NETWORKTYPE)optionTag
{
  currentFilterNetworkType = (int)optionTag;
  
  switch (optionTag) {
    case C_FILTER_NETWORKTYPE_WIFI:
      [[SKAAppDelegate getAppDelegate] switchNetworkTypeToWiFi];
      [self.btNetworkType setTitle:sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi") forState:UIControlStateNormal];
      break;
    case C_FILTER_NETWORKTYPE_GSM:
      [[SKAAppDelegate getAppDelegate] switchNetworkTypeToMobile];
      [self.btNetworkType setTitle:sSKCoreGetLocalisedString(@"NetworkTypeMenu_Mobile") forState:UIControlStateNormal];
      break;
    case C_FILTER_NETWORKTYPE_ALL:
      [[SKAAppDelegate getAppDelegate] switchNetworkTypeToAll];
      [self.btNetworkType setTitle:sSKCoreGetLocalisedString(@"NetworkTypeMenu_All") forState:UIControlStateNormal];
      break;
    default:
      SK_ASSERT(false);
      break;
  }
  [self loadData];
}

-(void)selectedTimePeriodOption:(C_FILTER_PERIOD)optionTag
{
  currentFilterPeriod = (int)optionTag;
  
  switch (optionTag) {
    case C_FILTER_PERIOD_1DAY:
      [self.btPeriod setTitle:sSKCoreGetLocalisedString(@"time_period_1day") forState:UIControlStateNormal];
      currentFilterPeriod = C_FILTER_PERIOD_1DAY;
      break;
    case C_FILTER_PERIOD_1WEEK:
      [self.btPeriod setTitle:sSKCoreGetLocalisedString(@"time_period_1week") forState:UIControlStateNormal];
      currentFilterPeriod = C_FILTER_PERIOD_1WEEK;
      break;
    case C_FILTER_PERIOD_1MONTH:
      [self.btPeriod setTitle:sSKCoreGetLocalisedString(@"time_period_1month") forState:UIControlStateNormal];
      currentFilterPeriod = C_FILTER_PERIOD_1MONTH;
      break;
    case C_FILTER_PERIOD_3MONTHS:
      [self.btPeriod setTitle:sSKCoreGetLocalisedString(@"time_period_3months") forState:UIControlStateNormal];
      currentFilterPeriod = C_FILTER_PERIOD_3MONTHS;
      break;
    case C_FILTER_PERIOD_1YEAR:
      [self.btPeriod setTitle:sSKCoreGetLocalisedString(@"time_period_1year") forState:UIControlStateNormal];
      currentFilterPeriod = C_FILTER_PERIOD_1YEAR;
      break;
    default:
      SK_ASSERT(false);
      break;
  }
  [self loadData];
}

-(void)loadData
{
  [self clearFields];
  
  dateTo = [NSDate date];
  
  switch (currentFilterPeriod) {
    case C_FILTER_PERIOD_1DAY:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-1*24*3600];
      break;
    case C_FILTER_PERIOD_1WEEK:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-7*24*3600];
      break;
    case C_FILTER_PERIOD_1MONTH:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-31*24*3600];
      break;
    case C_FILTER_PERIOD_3MONTHS:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-31*3*24*3600];
      break;
    case C_FILTER_PERIOD_1YEAR:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-364*24*3600];
      break;
    default:
      break;
  }
  
  arrTestsList = [SKDatabase getTestDataForNetworkType:[self getSelectedNetworkWord] afterDate:previousDate];
  
  downloadSUM = 0;
  downloadCNT = 0;
  downloadBEST = -1;
  uploadSUM = 0;
  uploadCNT = 0;
  uploadBEST = -1;
  latencySUM = 0;
  latencyCNT = 0;
  latencyBEST = -1;
  lossSUM = 0;
  lossCNT = 0;
  lossBEST = -1;
  jitterSUM = 0;
  jitterCNT = 0;
  jitterBEST = -1;
  
  for (SKATestResults* tr in arrTestsList) {
    
    if (tr.downloadSpeed >= 0) //If the test was executed
    {
      downloadCNT++;
      downloadSUM += tr.downloadSpeed;
      if (downloadBEST < 0 || downloadBEST < tr.downloadSpeed) downloadBEST = tr.downloadSpeed;
    }
    
    if (tr.uploadSpeed >= 0) //If the test was executed
    {
      uploadCNT++;
      uploadSUM += tr.uploadSpeed;
      if (uploadBEST < 0 || uploadBEST < tr.uploadSpeed) uploadBEST = tr.uploadSpeed;
    }
    
    if (tr.latency >= 0) //If the test was executed
    {
      latencyCNT++;
      latencySUM += tr.latency;
      if (latencyBEST < 0 || latencyBEST > tr.latency) latencyBEST = tr.latency;
    }
    
    if (tr.loss >= 0) //If the test was executed
    {
      lossCNT++;
      lossSUM += tr.loss;
      if (lossBEST < 0 || lossBEST > tr.loss) lossBEST = tr.loss;
    }
    
    if (tr.jitter >= 0) //If the test was executed
    {
      jitterCNT++;
      jitterSUM += tr.jitter;
      if (jitterBEST < 0 || jitterBEST > tr.jitter) jitterBEST = tr.jitter;
    }
  }
  
  if (downloadCNT > 0)
  {
    self.lDownloadAvg = [SKBTestOverviewCell sGet3DigitsNumber:downloadSUM / downloadCNT];
    self.lDownloadBst = [SKBTestOverviewCell sGet3DigitsNumber:downloadBEST];
  }
  else
  {
    self.lDownloadAvg = @"-";
    self.lDownloadBst = @"-";
  }
  
  if (uploadCNT > 0)
  {
    self.lUploadAvg = [SKBTestOverviewCell sGet3DigitsNumber:uploadSUM / uploadCNT];
    self.lUploadBst = [SKBTestOverviewCell sGet3DigitsNumber:uploadBEST];
  }
  else
  {
    self.lUploadAvg = @"-";
    self.lUploadBst = @"-";
  }
  
  if (latencyCNT > 0)
  {
    self.lLatencyAvg = [NSString stringWithFormat:@"%.0f", latencySUM / latencyCNT];
    self.lLatencyBst = [NSString stringWithFormat:@"%.0f", latencyBEST];
  }
  else
  {
    self.lLatencyAvg = @"-";
    self.lLatencyBst = @"-";
  }
  
  if (lossCNT > 0)
  {
    self.lLossAvg = [NSString stringWithFormat:@"%.0f", lossSUM / lossCNT];
    self.lLossBst = [NSString stringWithFormat:@"%.0f", lossBEST];
  }
  else
  {
    self.lLossAvg = @"-";
    self.lLossBst = @"-";
  }
  
  if (jitterCNT > 0)
  {
    self.lJitterAvg = [NSString stringWithFormat:@"%.0f", jitterSUM / jitterCNT];
    self.lJitterBst = [NSString stringWithFormat:@"%.0f", jitterBEST];
  }
  else
  {
    self.lJitterAvg = @"-";
    self.lJitterBst = @"-";
  }
  
  self.lNumberOfRecords.text = [NSString stringWithFormat:@"%lu", (unsigned long)arrTestsList.count];
 
  // Do NOT reload the table view, as that might screw-up the current post-animation state!
  //[self.tvTests reloadData];
  NSInteger rows = [self.tvTests numberOfRowsInSection:0];
  for (NSInteger i = 0; i < rows; i++) {
    [self refreshCellAtIndex:i];
  }
  
  [self prepareDataForChart];
  [self.vChart setNeedsDisplay];
  self.lNumberOfRecords.alpha = 1;
}

-(void)clearFields
{
  self.lNumberOfRecords.text = nil;
  self.lDownloadAvg = nil;
  self.lDownloadAvgUnit = sSKCoreGetLocalisedString(@"Graph_Suffix_Mbps");
  self.lDownloadBst = nil;
  self.lDownloadBstUnit = sSKCoreGetLocalisedString(@"Graph_Suffix_Mbps");
  self.lUploadAvg = nil;
  self.lUploadAvgUnit = sSKCoreGetLocalisedString(@"Graph_Suffix_Mbps");
  self.lUploadBst = nil;
  self.lUploadBstUnit = sSKCoreGetLocalisedString(@"Graph_Suffix_Mbps");
  self.lLatencyAvg = nil;
  self.lLatencyAvgUnit = sSKCoreGetLocalisedString(@"Graph_Suffix_Ms");
  self.lLatencyBst = nil;
  self.lLatencyBstUnit = sSKCoreGetLocalisedString(@"Graph_Suffix_Ms");
  self.lLossAvg = nil;
  self.lLossAvgUnit = sSKCoreGetLocalisedString(@"Graph_Suffix_Percent");
  self.lLossBst = nil;
  self.lLossBstUnit = sSKCoreGetLocalisedString(@"Graph_Suffix_Percent");
  self.lJitterAvg = nil;
  self.lJitterAvgUnit = sSKCoreGetLocalisedString(@"Graph_Suffix_Ms");
  self.lJitterBst = nil;
  self.lJitterBstUnit = sSKCoreGetLocalisedString(@"Graph_Suffix_Ms");
  
//  [UIView animateWithDuration:0.5 animations:^{
//    self.lNumberOfRecords.alpha = 0;
//
//    if (currentChartType >= 0) {
//      self.vChart.alpha = 0;
//    }
//  }];
}

-(void)viewTouched:(UIButton*)button_
{
  switch (button_.tag) {
    case 0:
      self.vDownload.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
      break;
    case 1:
      self.vUpload.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
      break;
    case 2:
      self.vLatency.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
      break;
    case 3:
      if ([[SKAAppDelegate getAppDelegate] getIsLossSupported]) {
        self.vLoss.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
      } else {
        self.vJitter.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
      }
      break;
    case 4:
      self.vJitter.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
      break;
  }
}

-(void)viewUntouched:(UIButton*)button_
{
  switch (button_.tag) {
    case 0:
      self.vDownload.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
      break;
    case 1:
      self.vUpload.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
      break;
    case 2:
      self.vLatency.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
      break;
    case 3:
      if ([[SKAAppDelegate getAppDelegate] getIsLossSupported]) {
        self.vLoss.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
      } else {
        self.vJitter.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
      }
      break;
    case 4:
      self.vJitter.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
      break;
  }
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

-(void)activate
{
    self.vDownload.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vUpload.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vLatency.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vLoss.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vJitter.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
}

-(void)deactivate
{
    self.vDownload.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vUpload.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vLatency.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vLoss.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vJitter.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
}


- (NSString*)getDateRangeText:(DATERANGE_1w1m3m1y) curDateFilter
{
  switch (curDateFilter) {
    case DATERANGE_1w1m3m1y_ONE_WEEK:
      return sSKCoreGetLocalisedString(@"RESULTS_Label_Date_1_Week");
    case DATERANGE_1w1m3m1y_ONE_MONTH:
      return sSKCoreGetLocalisedString(@"RESULTS_Label_Date_1_Month");
    case DATERANGE_1w1m3m1y_THREE_MONTHS:
      return sSKCoreGetLocalisedString(@"RESULTS_Label_Date_3_Months");
    case DATERANGE_1w1m3m1y_SIX_MONTHS:
      return sSKCoreGetLocalisedString(@"RESULTS_Label_Date_6_Months");
    case DATERANGE_1w1m3m1y_ONE_YEAR:
      return sSKCoreGetLocalisedString(@"RESULTS_Label_Date_1_Year");
    case DATERANGE_1w1m3m1y_ONE_DAY:
      return sSKCoreGetLocalisedString(@"RESULTS_Label_Date_1_Day");
    default:
      SK_ASSERT(false);
      return sSKCoreGetLocalisedString(@"RESULTS_Label_Date_1_Week");
  }
}

- (void)refreshLocalData
{
  //NSDate *previousDate = nil;
  
  DATERANGE_1w1m3m1y curDateFilter;
  
  switch (currentFilterPeriod) {
    case C_FILTER_PERIOD_1DAY:
      curDateFilter = DATERANGE_1w1m3m1y_ONE_DAY;
      break;
    case C_FILTER_PERIOD_1WEEK:
      curDateFilter = DATERANGE_1w1m3m1y_ONE_WEEK;
      break;
    case C_FILTER_PERIOD_1MONTH:
      curDateFilter = DATERANGE_1w1m3m1y_ONE_MONTH;
      break;
    case C_FILTER_PERIOD_3MONTHS:
      curDateFilter = DATERANGE_1w1m3m1y_THREE_MONTHS;
      break;
    case C_FILTER_PERIOD_1YEAR:
    default:
      curDateFilter = DATERANGE_1w1m3m1y_ONE_YEAR;
      break;
  }
  
  switch (curDateFilter)
  {
    case DATERANGE_1w1m3m1y_ONE_WEEK:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-7*24*60*60];
      break;
      
    case DATERANGE_1w1m3m1y_ONE_MONTH:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-30*24*60*60];
      break;
      
    case DATERANGE_1w1m3m1y_THREE_MONTHS:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-3*30*24*60*60];
      break;
      
    case DATERANGE_1w1m3m1y_SIX_MONTHS:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-6*30*24*60*60];
      break;
      
    case DATERANGE_1w1m3m1y_ONE_YEAR:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-12*30*24*60*60];
      break;
      
    case DATERANGE_1w1m3m1y_ONE_DAY:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-1*24*60*60];
      break;
      
    default:
      SK_ASSERT(false);
      return;
  }
 
  NSString *testType = @"";
  switch (currentChartType) {
    case -1:
    case 0:
      testType = @"downstream_mt";
      break;
    case 1:
      testType = @"upstream_mt";
      break;
    case 2:
      testType = @"latency";
      break;
    case 3:
      if ([[SKAAppDelegate getAppDelegate] getIsLossSupported]) {
        testType = @"packetloss";
      } else {
        testType = @"jitter";
      }
      break;
    case 4:
      testType = @"jitter";
      break;
    default:
      SK_ASSERT(false);
      break;
  }
  
  NSDate *dateNow = [SKCore getToday];
  
  NSString *rootPath = NSTemporaryDirectory();
  NSString *testString = [self getDateRangeText:curDateFilter];
  NSString *dataFilename = [NSString stringWithFormat:@"data_%d_%@.json", curDateFilter, testString];
  NSString *dataPath = [rootPath stringByAppendingPathComponent:dataFilename];
  NSString *infoPath = [rootPath stringByAppendingPathComponent:@"info.json"];
  NSString *info = [NSString stringWithFormat:@"{\"file\":\"%@\",\"test\":\"%@\"}", dataFilename, testString];
  
  NSFileManager *filemgr = [NSFileManager defaultManager];
  if (![filemgr createFileAtPath:infoPath contents:[info dataUsingEncoding:NSASCIIStringEncoding] attributes:nil])
  {
    NSLog(@"Failed");
  }
  
  NSDictionary *graphDataForDateRange = [SKAGraphViewCell sFetchGraphDataTestType:testType
                                                                        ForDateRange:curDateFilter
                                                                            FromDate:previousDate
                                                                              ToDate:dateNow
                                                                            DataPath:dataPath];
  
  if (graphDataForDateRange != nil)
  {
    if ([graphDataForDateRange count] == 2)
    {
      NSError *err = nil;
      NSData *json = [NSJSONSerialization dataWithJSONObject:graphDataForDateRange
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&err];
      
      //[SKGlobalMethods printNSData:json];
      
      if (nil == err)
      {
        SK_ASSERT([NSThread isMainThread]);
        
        // Update the CORE PLOT!
        if (self.skGraphForResults == nil) {
          self.skGraphForResults = [[SKGraphForResults alloc] init];
        }
       
        CGRect frame = self.vChart.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        [self.skGraphForResults updateGraphWithTheseResults:json OnParentView:self.vChart InFrame:frame StartHidden:NO WithDateFilter:curDateFilter];
        
        return;
      }
      else
      {
        NSLog(@"Error : %@", [err localizedDescription]);
      }
    }
  }
}

- (void)prepareDataForChart
{
  [self refreshLocalData];
}

#pragma mark TabelView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // This is at least 3, but up to 5.
  // FUTURE: in app variants requiring less tests, we'd return a different number!
  int rows = 3;
  if ([[SKAAppDelegate getAppDelegate] getIsJitterSupported]) {
    rows++;
  }
  if ([[SKAAppDelegate getAppDelegate] getIsJitterSupported]) {
    rows++;
  }
  return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 70;
}

// http://stackoverflow.com/questions/14460772/how-to-hide-remove-separator-line-if-cells-are-empty
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
  // To "clear" the footer view
  return [UIView new];
}

-(void) refreshCellAtIndex:(NSInteger)row {
  
  SKBSummaryTableViewCell *cell = (SKBSummaryTableViewCell*)[self.tvTests cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
  
  cell.contentView.backgroundColor = [SKAppColourScheme sGetSummaryGetCellBackgroundColour];
  
  switch (row) {
    case 0:
      [cell prepareWithTopLeftImage:[UIImage imageNamed:@"ga.png"]
                       TopLeftTitle:sSKCoreGetLocalisedString(@"Test_Download")
                   LeftAverageValue:self.lDownloadAvg
                   LeftAverageUnits:self.lDownloadAvgUnit
                     RightBestValue:self.lDownloadBst
                     RightBestUnits:self.lDownloadBstUnit
       ];
      break;
    case 1:
      [cell prepareWithTopLeftImage:[UIImage imageNamed:@"ra.png"]
                       TopLeftTitle:sSKCoreGetLocalisedString(@"Test_Upload")
                   LeftAverageValue:self.lUploadAvg
                   LeftAverageUnits:self.lUploadAvgUnit
                     RightBestValue:self.lUploadBst
                     RightBestUnits:self.lUploadBstUnit
       ];
      break;
    case 2:
      [cell prepareWithTopLeftImage:nil
                       TopLeftTitle:sSKCoreGetLocalisedString(@"Test_Latency")
                   LeftAverageValue:self.lLatencyAvg
                   LeftAverageUnits:self.lLatencyAvgUnit
                     RightBestValue:self.lLatencyBst
                     RightBestUnits:self.lLatencyBstUnit
       ];
      break;
    case 3:
      if ([[SKAAppDelegate getAppDelegate] getIsLossSupported]) {
        [cell prepareWithTopLeftImage:nil
                         TopLeftTitle:sSKCoreGetLocalisedString(@"Test_Loss")
                     LeftAverageValue:self.lLossAvg
                     LeftAverageUnits:self.lLossAvgUnit
                       RightBestValue:self.lLossBst
                       RightBestUnits:self.lLossBstUnit
         ];
      } else {
        [cell prepareWithTopLeftImage:nil
                         TopLeftTitle:sSKCoreGetLocalisedString(@"Test_Jitter")
                     LeftAverageValue:self.lJitterAvg
                     LeftAverageUnits:self.lJitterAvgUnit
                       RightBestValue:self.lJitterBst
                       RightBestUnits:self.lJitterBstUnit
         ];
      }
      //if ([[SKAAppDelegate getAppDelegate] getIsJitterSupported]) {
      break;
    case 4:
    default:
      [cell prepareWithTopLeftImage:nil
                       TopLeftTitle:sSKCoreGetLocalisedString(@"Test_Jitter")
                   LeftAverageValue:self.lJitterAvg
                   LeftAverageUnits:self.lJitterAvgUnit
                     RightBestValue:self.lJitterBst
                     RightBestUnits:self.lJitterBstUnit
       ];
      break;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  SKBSummaryTableViewCell *cell;
  static NSString *CellIdentifier = @"SKBSummaryTableViewCell";
  
  cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    
    cell = [[SKBSummaryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  [self refreshCellAtIndex:indexPath.row];

  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.row) {
    case 0:
      currentChartType = 0;
      break;
    case 1:
      currentChartType = 1;
      break;
    case 2:
      currentChartType = 2;
      break;
    case 3:
      if ([[SKAAppDelegate getAppDelegate] getIsLossSupported]) {
        currentChartType = 3;
      } else {
        currentChartType = 4;
      }
      break;
    case 4:
      currentChartType = 4;
      break;
    default:
      SK_ASSERT(false);
      break;
  }
  [self prepareDataForChart];
  [self.vChart setNeedsDisplay];
  
  cell2putBack = (SKBSummaryTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
  
  CGRect cellFrame = cell2putBack.frame;
  
  cellContentView2putBack = cell2putBack.contentView;
  mRestoreToY = self.tvTests.frame.origin.y;
  
  CGFloat chartMoveUpToY = self.tvTests.frame.origin.y + cellFrame.size.height;
  SK_ASSERT(chartMoveUpToY >= 20.0);
  // Account for TOOLBAR!
  const CGFloat cUITabBarHeight = 20.0; // 56.0;
  CGFloat chartHeight = (self.frame.size.height - cUITabBarHeight) - chartMoveUpToY;
  [cellContentView2putBack removeFromSuperview];
  
  // Immediately position at the top of the table.
  cellContentView2putBack.frame = CGRectMake(cell2putBack.frame.origin.x, mRestoreToY, cell2putBack.frame.size.width, cell2putBack.frame.size.height);
  [self addSubview:cellContentView2putBack];
  
  // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
  [self layoutIfNeeded];
  
  // Move chart to off bottom of screen...
  self.vChart.alpha = 0.0;
  self.chartHeightConstraint.constant = 0.0F;
  self.vChart.hidden = YES;
  //[self prepareDataForChart];
  //[self.vChart setNeedsDisplay];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [UIView animateWithDuration:0.3 animations:^{
      // Animation, to slide the table view LEFT!
      self.tvTests.alpha = 0;
      self.tvTests.frame = CGRectMake(-self.tvTests.frame.size.width, self.tvTests.frame.origin.y, self.tvTests.frame.size.width, self.tvTests.frame.size.height);
    } completion:^(BOOL finished) {
      
      [UIView animateWithDuration:1.0
                            delay:0.0
           usingSpringWithDamping:1
            initialSpringVelocity:13
                          options:UIViewAnimationOptionCurveEaseIn
       
                       animations:^{
                         // Animation, to move the detached cell content view UP!
                         cellContentView2putBack.frame = CGRectMake(0, mRestoreToY, cellFrame.size.width, cellFrame.size.height);
                         //self.vChart.frame = CGRectMake(0, chartMoveUpToY, chartWidth, chartHeight);
                         self.chartHeightConstraint.constant = chartHeight;
                         //self.vChart.alpha = 1.0;
                         //[self.vChart setNeedsDisplay];
                         
                       } completion:^(BOOL finished) {
                         // Animation, to put the button in the same place.
                         //self.btBack.frame = cellContentView2putBack.frame;
                         //self.backButtonTopOffsetConstraint.constant = 0; // Align to the top of the table view!
                         // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
                         [self layoutIfNeeded];
                         
                         //[self.vChart setNeedsDisplay];
                         self.btBack.userInteractionEnabled = YES;
                         [self bringSubviewToFront:self.btBack];
                         
                         //self.vChart.frame = CGRectMake(200, 200, 200, 200);
                         //[self.vChart setNeedsDisplay];
                         
                         [self prepareDataForChart];
                         self.vChart.alpha = 1.0;
                         self.vChart.hidden = NO;
                         [self.vChart setNeedsDisplay];
                       }];
    }];
  });
  
  return;
}

- (IBAction)B_Back:(id)sender {
  
  // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
  [self layoutIfNeeded];
  
  self.btBack.userInteractionEnabled = NO;
  [self sendSubviewToBack:self.btBack];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    
    [UIView animateWithDuration:0.3 animations:^{
      
      cellContentView2putBack.frame = CGRectMake(cell2putBack.frame.origin.x, cell2putBack.frame.origin.y - self.tvTests.contentOffset.y + self.tvTests.frame.origin.y, cell2putBack.frame.size.width, cell2putBack.frame.size.height);
      
      //self.vChart.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 0);
      self.chartHeightConstraint.constant = 0.0;
      SK_ASSERT(self.vChart != nil);
      self.vChart.alpha = 0;
      self.vChart.hidden = YES;
      
    } completion:^(BOOL finished) {
      // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
      [self layoutIfNeeded];
      
      self.tvTests.frame = CGRectMake(- self.tvTests.frame.size.width, self.tvTests.frame.origin.y, self.tvTests.frame.size.width, self.tvTests.frame.size.height);
      
      float tableAnimationTime = 0.3;
      
      [UIView animateWithDuration:tableAnimationTime animations:^{
        self.tvTests.alpha = 1;
        self.tvTests.frame = CGRectMake(0, self.tvTests.frame.origin.y, self.tvTests.frame.size.width, self.tvTests.frame.size.height);
      } completion:^(BOOL finished) {
        
        [cellContentView2putBack removeFromSuperview];
        [cell2putBack addSubview:cellContentView2putBack];
        
        cellContentView2putBack.frame = cell2putBack.bounds;
        
        if (sbReloadTableAfterBack == YES) {
          sbReloadTableAfterBack = NO;
          [self loadData];
        }
      }];
    }];
  });
}
@end
