//
//  SKAArchivedResultsController.m
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKAArchivedResultsController.h"

@interface SKAArchivedResultsController ()
{
  NSMutableArray *resultsArray;
  NSMutableDictionary *metricsDictionary;
}

- (void)populateResults;
- (void)addSwipeGesture;
- (void)swipeLeft;
- (void)swipeRight;
- (void)setLabels;

- (void)goToMain;

@property (nonatomic, strong) NSMutableArray *resultsArray;
@property (nonatomic, strong) NSMutableDictionary *metricsDictionary;

@property (nonatomic, strong) NSNumber *testId;

@property (nonatomic, strong) NSString *device;
@property (nonatomic, strong) NSString *os;
@property (nonatomic, strong) NSString *carrierName;
@property (nonatomic, strong) NSString *carrierCountryCode;
@property (nonatomic, strong) NSString *carrierNetworkCode;
@property (nonatomic, strong) NSString *carrierIsoCode;
@property (nonatomic, strong) NSString *networkType;
@property (nonatomic, strong) NSString *radioType;

@end

@implementation SKAArchivedResultsController

@synthesize viewBG;
@synthesize lblMain;
@synthesize lblDate;
@synthesize lblClosest;
@synthesize lblCount;
@synthesize tableView;
@synthesize testMetaData;
@synthesize resultsArray;
@synthesize metricsDictionary;

@synthesize device;
@synthesize os;
@synthesize carrierName;
@synthesize carrierCountryCode;
@synthesize carrierNetworkCode;
@synthesize carrierIsoCode;
@synthesize networkType;
@synthesize radioType;


// http://stackoverflow.com/questions/26147424/crash-in-uitableview-sending-message-to-deallocated-uiviewcontroller
- (void)dealloc {
  self.tableView.dataSource = nil;
  self.tableView.delegate = nil;
}
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isSocialMediaExportSupported] == NO) {
    // Hide the toolbar, if social media export not supported!
    [self.uiToolbar setHidden:YES];
  }

  self.title = sSKCoreGetLocalisedString(@"Storyboard_ArchivedResults_Title");
  self.lblMain.text = sSKCoreGetLocalisedString(@"Storyboard_ArchivedResults_Archived_Result");
  self.lblMain.text = sSKCoreGetLocalisedString(@"Storyboard_ArchivedResults_Archived_Result");
  
//  self.navigationController.delegate = self;
  
  self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

  
  SK_ASSERT(self.tableView != nil);
  
  [self addSwipeGesture];
}

// http://stackoverflow.com/questions/8303811/toolbar-in-navigation-controller
//#pragma mark UINavigationControllerDelegate (begin)
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//  BOOL shouldHide = ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isSocialMediaExportSupported] == NO);
//  [navigationController setToolbarHidden:shouldHide animated:animated];
//}
//#pragma mark UINavigationControllerDelegate (end)

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self populateResults];
  [self setLabels];
  
  [self.tableView reloadData];
  
  self.showOlderResultsButton.enabled = [self isThereOlderDataToShow];
  
  self.navigationController.navigationBarHidden = NO;
}

-(BOOL) isThereOlderDataToShow{
  int newIndex = self.testIndex + 1;
  
  if (newIndex <= [self.testMetaData count]-1)
  {
    return YES;
  }

  return NO;
}

- (IBAction)showOlderResultsButton:(id)sender {
  [self swipeLeft];
}

- (void)addSwipeGesture
{
  UISwipeGestureRecognizer *swipeL = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(swipeLeft)];
  
  swipeL.direction = UISwipeGestureRecognizerDirectionLeft;
  [self.tableView addGestureRecognizer:swipeL];
  
  
  UISwipeGestureRecognizer *swipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(swipeRight)];
  
  swipeR.direction = UISwipeGestureRecognizerDirectionRight;
  [self.tableView addGestureRecognizer:swipeR];
  
}

- (void)swipeLeft
{
  int newIndex = self.testIndex + 1;
  
  if (newIndex <= [self.testMetaData count]-1)
  {
    SK_ASSERT([self isThereOlderDataToShow]);
    
    // This is how you perform a seque to self with a storyboard...
    // http://stackoverflow.com/questions/9226983/storyboard-segue-from-view-controller-to-itself
    UIStoryboard *storyboard = [SKAAppDelegate getStoryboard];
    SKAArchivedResultsController *dest = [storyboard instantiateViewControllerWithIdentifier:@"SKAArchivedResultsController"];
    dest.testIndex = newIndex;
    dest.testMetaData = self.testMetaData;
    [self SKSafePushViewController:dest animated:YES];
    
  } else {
    SK_ASSERT(![self isThereOlderDataToShow]);
  }
}

- (void)swipeRight
{
  [self SKSafePopViewControllerAnimated:YES];
}

- (void)setLabels
{
  self.navigationItem.title = sSKCoreGetLocalisedString(@"RESULT_Title");

  
  [self.lblMain setText:sSKCoreGetLocalisedString(@"RESULT_Label")];
  
  NSString *txt = [NSString stringWithFormat:@"%d %@ %d",
                   (int)self.testIndex+1,
                   sSKCoreGetLocalisedString(@"Storyboard_ArchivedResults_Of_Separator"),
                   (int)[self.testMetaData count]];
  [self.lblCount setText:txt];
}

- (void)goToMain
{
  [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)populateResults
{
  NSDictionary *testData = self.testMetaData[self.testIndex];
  
  NSMutableArray *tmpArray = [NSMutableArray array];
  
  if (nil != testData)
  {
    self.testId = testData[@"TEST_ID"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[testData[@"DATE"] doubleValue]];
    
    self.lblDate.text = [SKGlobalMethods formatDate:date];
    
    self.metricsDictionary = [SKDatabase getMetricsForTestId:self.testId];
    
    if (self.metricsDictionary[@"DEVICE"])
    {
      self.device = self.metricsDictionary[@"DEVICE"];
    }
    
    if (self.metricsDictionary[@"OS"])
    {
      self.os = self.metricsDictionary[@"OS"];
    }
    
    if (self.metricsDictionary[@"CARRIER_NAME"])
    {
      self.carrierName = self.metricsDictionary[@"CARRIER_NAME"];
    }
    
    if (self.metricsDictionary[@"COUNTRY_CODE"])
    {
      self.carrierCountryCode = self.metricsDictionary[@"COUNTRY_CODE"];
    }
    
    if (self.metricsDictionary[@"ISO_CODE"])
    {
      self.carrierIsoCode = self.metricsDictionary[@"ISO_CODE"];
    }
    
    if (self.metricsDictionary[@"NETWORK_CODE"])
    {
      self.carrierNetworkCode = self.metricsDictionary[@"NETWORK_CODE"];
    }
    
    if (self.metricsDictionary[@"NETWORK_TYPE"])
    {
      self.networkType = self.metricsDictionary[@"NETWORK_TYPE"];
    }
    
    if (self.metricsDictionary[@"RADIO_TYPE"])
    {
      self.radioType = self.metricsDictionary[@"RADIO_TYPE"];
    }
    
    NSString *target = testData[@"TARGET"];
    
    self.lblClosest.text = target;
    
    // DOWNLOAD ////////////////////////////////////////////////////////////////////////////////////////////////
    
    NSDictionary *downloadData = [SKDatabase getDownloadResultsForTestId:self.testId];
    
    if ([downloadData count] > 0)
    {
      double bitrateMbps1024Based = [downloadData[@"RESULT"] doubleValue];
      NSString *result = [SKGlobalMethods bitrateMbps1024BasedToString:bitrateMbps1024Based];
      
      NSMutableDictionary *tmpDict1 = [NSMutableDictionary dictionary];
      tmpDict1[@"TYPE"] = @(DOWNLOAD_DATA);
      tmpDict1[@"RESULT_1"] = result;
      tmpDict1[@"RESULT_2"] = @"NA";
      tmpDict1[@"RESULT_3"] = @"NA";
      tmpDict1[@"DISPLAY_NAME"] = downloadData[@"DISPLAY_NAME"];
      
       // SKAInformationCell - 49, SKATransferTestCell - 59, SKALatencyTestCell - 100!
      [tmpDict1 setObject:@59.0F forKey:@"HEIGHT"];
      
      
      tmpDict1[@"RESULT_1"] = result;
      tmpDict1[@"DISPLAY_NAME"] = downloadData[@"DISPLAY_NAME"];
      
      [tmpArray addObject:tmpDict1];
    }
    
    
    // UPLOAD //////////////////////////////////////////////////////////////////////////////////////////////////
    
    NSDictionary *uploadData = [SKDatabase getUploadResultsForTestId:self.testId];
    
    if ([uploadData count] > 0)
    {
      double bitrateMbps1024Based = [uploadData[@"RESULT"] doubleValue];
      NSString *result = [SKGlobalMethods bitrateMbps1024BasedToString:bitrateMbps1024Based];
      
      NSMutableDictionary *tmpDict2 = [NSMutableDictionary dictionary];
      tmpDict2[@"TYPE"] = @(UPLOAD_DATA);
      tmpDict2[@"RESULT_1"] = result;
      tmpDict2[@"RESULT_2"] = @"NA";
      tmpDict2[@"RESULT_3"] = @"NA";
      tmpDict2[@"DISPLAY_NAME"] = uploadData[@"DISPLAY_NAME"];
      
      // SKAInformationCell - 49, SKATransferTestCell - 59, SKALatencyTestCell - 100!
      [tmpDict2 setObject:@59.0F forKey:@"HEIGHT"];
      
      [tmpArray addObject:tmpDict2];
    }
    
    
    // LATENCY / LOSS / JITTER
    
    NSDictionary *latencyData = [SKDatabase getLatencyResultsForTestId:self.testId];
    NSDictionary *lossData = [SKDatabase getLossResultsForTestId:self.testId];
    NSDictionary *jitterData = [SKDatabase getJitterResultsForTestId:self.testId];
    
    if ([latencyData count] > 0 && [lossData count] > 0)
    {
      double latency = [latencyData[@"RESULT"] doubleValue];
      double loss = [lossData[@"RESULT"] doubleValue];
      double jitter = [jitterData[@"RESULT"] doubleValue];
      
      NSString *strLatency = [NSString stringWithFormat:@"%@ ms", [SKGlobalMethods format2DecimalPlaces:latency]];
      NSString *strLoss = [NSString stringWithFormat:@"%d %%", (int)loss];
      NSString *strJitter = [NSString stringWithFormat:@"%@ ms", [SKGlobalMethods format2DecimalPlaces:jitter]];
      
      NSMutableDictionary *tmpDict3 = [NSMutableDictionary dictionary];
      tmpDict3[@"TYPE"] = @(LATENCY_DATA);
      tmpDict3[@"RESULT_1"] = strLatency;
      tmpDict3[@"RESULT_2"] = strLoss;
      tmpDict3[@"RESULT_3"] = strJitter;
      tmpDict3[@"DISPLAY_NAME"] = @"NA";
      
      // SKAInformationCell - 49, SKATransferTestCell - 59, SKALatencyTestCell - 100!
      [tmpDict3 setObject:@100.0F forKey:@"HEIGHT"];
      
      [tmpArray addObject:tmpDict3];
    }
  }
  
  self.resultsArray = tmpArray;
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  int row = (int)indexPath.row;
  int section = (int)indexPath.section;
  
  if (section == 0)
  {
    NSDictionary *dict = (NSDictionary*) self.resultsArray[row];
    
    float height = [dict[@"HEIGHT"] floatValue];
    
    SK_ASSERT(height == 59 || height == 100);
    
    if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsJitterSupported]) {
      if (height == 100) {
        height = 150;
      }
    }
    
    return height;
  }
  else
  {
    // SKA Information cell!
    return 59.0f;
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  if ([self.metricsDictionary count] > 0)
  {
    // If Mobile, show both passive and active metrics.
    NSString *theType = (NSString*) self.metricsDictionary[@"NETWORK_TYPE"];
    if ([theType isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
      return 2;
    }
    
    // Otherwise, show just active metrics.
    return 1;
  }
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0)
  {
    if (nil != self.resultsArray)
    {
      return [self.resultsArray count];
    }
    
    return 0;
  }
  else
  {
    return 7;
  }
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  switch (section) {
    case 0:
    {
      // e.g. "Active Metrics"
      NSMutableString *activeMetricsText = [NSMutableString stringWithString:sSKCoreGetLocalisedString(@"Label_Active")];
      // e.g. "Active Metrics (Mobile)" or "Active Metrics (Wifi)"
      NSString *theType = (NSString*) self.metricsDictionary[@"NETWORK_TYPE"];
      if ([theType isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
        theType = sSKCoreGetLocalisedString(@"NetworkTypeMenu_Mobile");
      } else {
        theType = sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi");
      }
      [activeMetricsText appendString:[NSString stringWithFormat:@" (%@)", theType]];
      
      return activeMetricsText;
    }
      
    case 1:
    default:
      return @"Passive Metrics";
  }
  
}

// https://gist.github.com/tuoxie007/6723865
// http://stackoverflow.com/questions/18854244/what-is-platform-string-for-iphone-5s-5c

+ (NSString *) platformString:(NSString*)platform{
  if ([platform isEqualToString:@"iPhone1"])  return @"iPhone 1G";
  if ([platform hasPrefix:@"iPhone1"])        return @"iPhone 3G";
  if ([platform hasPrefix:@"iPhone2"])        return @"iPhone 3GS";
  if ([platform hasPrefix:@"iPhone3"])        return @"iPhone 4";
  if ([platform hasPrefix:@"iPhone4"])        return @"iPhone 4s";
  if ([platform hasPrefix:@"iPhone5,1"])      return @"iPhone 5";
  if ([platform hasPrefix:@"iPhone5,2"])      return @"iPhone 5";
  if ([platform hasPrefix:@"iPhone5,3"])      return @"iPhone 5c";
  if ([platform hasPrefix:@"iPhone5,4"])      return @"iPhone 5c";
  //if ([platform hasPrefix:@"iPhone5,3"])      return @"iPhone 5C (GSM)";
  //if ([platform hasPrefix:@"iPhone5,4"])      return @"iPhone 5C (Global)";
  if ([platform hasPrefix:@"iPhone6,1"])      return @"iPhone 5S (GSM)";
  if ([platform hasPrefix:@"iPhone6,2"])      return @"iPhone 5S (Global)";
  if ([platform hasPrefix:@"iPhone6"])        return @"iPhone 5c";
  if ([platform hasPrefix:@"iPod1"])          return @"iPod touch 1G";
  if ([platform hasPrefix:@"iPod2"])          return @"iPod touch 2G";
  if ([platform hasPrefix:@"iPod3"])          return @"iPod touch 3G";
  if ([platform hasPrefix:@"iPod4"])          return @"iPod touch 4G";
  if ([platform hasPrefix:@"iPod5"])          return @"iPod touch 5G";
  if ([platform hasPrefix:@"iPad1"])          return @"iPad";
  if ([platform hasPrefix:@"iPad2,1"])        return @"iPad 2";
  if ([platform hasPrefix:@"iPad2,2"])        return @"iPad 2";
  if ([platform hasPrefix:@"iPad2,3"])        return @"iPad 2";
  if ([platform hasPrefix:@"iPad2,4"])        return @"iPad 2";
  if ([platform hasPrefix:@"iPad2,5"])        return @"iPad mini";
  if ([platform hasPrefix:@"iPad2,6"])        return @"iPad mini";
  if ([platform hasPrefix:@"iPad2,7"])        return @"iPad mini";
  if ([platform hasPrefix:@"iPad3"])          return @"iPad 3";
  if ([platform hasPrefix:@"iPad4"])          return @"iPad 4";
  if ([platform hasPrefix:@"i386"])           return @"Simulator";
  if ([platform hasPrefix:@"x86_64"])         return @"Simulator";
  return platform;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  int row = (int)indexPath.row;
  int section = (int)indexPath.section;
  
  if (section == 0)
  {
    NSDictionary *dict = nil;
    
    @synchronized(self)
    {
      dict = self.resultsArray[row];
    }
    
    TestDataType type       = (TestDataType)[dict[@"TYPE"] integerValue];
    NSString *result1       = dict[@"RESULT_1"];
    NSString *result2       = dict[@"RESULT_2"];
    NSString *result3       = dict[@"RESULT_3"];
    NSString *displayName   = dict[@"DISPLAY_NAME"];
    
    if (type == LATENCY_DATA)
    {
      // Latency/loss/jitter!
      static NSString *CellIdentifier = @"SKALatencyTestCell";
      SKALatencyTestCell *cell = (SKALatencyTestCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      if (cell == nil) {
        cell = [[SKALatencyTestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      }
      
      cell.lblLatencyResult.hidden = NO;
      cell.lblLossResult.hidden = NO;
      cell.lblJitterResult.hidden = !([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsJitterSupported]);
      cell.lblJitter.hidden = !([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsJitterSupported]);
      cell.latencyProgressView.hidden = YES;
      cell.lossProgressView.hidden = YES;
      cell.jitterProgressView.hidden = YES;
      
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      
      cell.lblLatencyResult.text = result1;
      cell.lblLossResult.text = result2;
      cell.lblJitterResult.text = result3;
      
      cell.lblLatency.text = sSKCoreGetLocalisedString(@"Test_Latency");
      cell.lblLoss.text = sSKCoreGetLocalisedString(@"Test_Loss");
      cell.lblJitter.text = sSKCoreGetLocalisedString(@"Test_Jitter");
      
      return cell;
    }
    else if (type == DOWNLOAD_DATA)
    {
      static NSString *CellIdentifier = @"SKATransferTestCell";
      SKATransferTestCell *cell = (SKATransferTestCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      if (cell == nil) {
        cell = [[SKATransferTestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      }
      
      cell.lblResult.hidden = NO;
      cell.progressView.hidden = YES;
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.lblResult.text = result1;
      cell.lblTest.text = displayName;
      
      return cell;
    }
    else if (type == JITTER_DATA)
    {
      SK_ASSERT(false);
      return [UITableViewCell new];
    }
    else
    {
      static NSString *CellIdentifier = @"SKATransferTestCell";
      SKATransferTestCell *cell = (SKATransferTestCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      if (cell == nil) {
        cell = [[SKATransferTestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      }
      
      cell.lblResult.hidden = NO;
      cell.progressView.hidden = YES;
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      
      cell.lblResult.text = result1;
      cell.lblTest.text = displayName;
      
      return cell;
    }
  }
  else
  {
    static NSString *CellIdentifier = @"SKAInformationCell";
    SKAInformationCell *cell = (SKAInformationCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[SKAInformationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (row == 0) {
      cell.lblTitle.text = sSKCoreGetLocalisedString(@"Network_Type");
      cell.lblDetail.text = sSKCoreGetLocalisedString(@"Unknown");
      if ([self.networkType isEqualToString:C_NETWORKTYPEASSTRING_WIFI]) {
        cell.lblDetail.text = sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi");
      } else if ([self.networkType isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
        
        NSString *mobileString = sSKCoreGetLocalisedString(@"NetworkTypeMenu_Mobile");
       
        NSString *theRadio =[SKGlobalMethods getNetworkTypeLocalized:self.radioType];
        if ([theRadio isEqualToString:sSKCoreGetLocalisedString(@"CTRadioAccessTechnologyUnknown")]) {
          cell.lblDetail.text = mobileString;
        } else {
          cell.lblDetail.text = [NSString stringWithFormat:@"%@ (%@)", mobileString, theRadio];
        }
      }
    }
    else if (row == 1)
    {
      cell.lblTitle.text = sSKCoreGetLocalisedString(@"Carrier_Name");
      cell.lblDetail.text = self.carrierName;
    }
    else if (row == 2)
    {
      cell.lblTitle.text = sSKCoreGetLocalisedString(@"Carrier_Country");
      cell.lblDetail.text = self.carrierCountryCode;
    }
    else if (row == 3)
    {
      cell.lblTitle.text = sSKCoreGetLocalisedString(@"Carrier_Network");
      cell.lblDetail.text =self.carrierNetworkCode;
    }
    else if (row == 4)
    {
      cell.lblTitle.text = sSKCoreGetLocalisedString(@"Carrier_ISO");
      cell.lblDetail.text = self.carrierIsoCode;
    }
    else if (row == 5)
    {
      cell.lblTitle.text = sSKCoreGetLocalisedString(@"Phone");
      cell.lblDetail.text = [SKAArchivedResultsController platformString:self.device];
    }
    else if (row == 6)
    {
      cell.lblTitle.text = sSKCoreGetLocalisedString(@"OS");
      cell.lblDetail.text = self.os;
    }
    else
    {
      SK_ASSERT(false);
    }
    
    
    return cell;
  }
}

//
//
//

-(NSString*) getTextForSocialMedia:(NSString*)socialNetwork {
  
  NSDictionary *testData = testMetaData[self.testIndex];
  
  if (testData == nil) {
    SK_ASSERT(false);
    return nil;
  }
  
  NSNumber *testId = testData[@"TEST_ID"];
  
  NSString *download = nil;
  NSString *upload = nil;
  
  // DOWNLOAD
  
  NSDictionary *downloadData = [SKDatabase getDownloadResultsForTestId:testId];
  
  if ([downloadData count] > 0)
  {
    double bitrateMbps1024Based = [downloadData[@"RESULT"] doubleValue];
    download = [SKGlobalMethods bitrateMbps1024BasedToString:bitrateMbps1024Based];
  }
  
  // UPLOAD
  
  NSDictionary *uploadData = [SKDatabase getUploadResultsForTestId:testId];
  
  if ([uploadData count] > 0)
  {
    double bitrateMbps1024Based = [uploadData[@"RESULT"] doubleValue];
    upload = [SKGlobalMethods bitrateMbps1024BasedToString:bitrateMbps1024Based];
    
  }
  
  /*
  // LATENCY and LOSS
  
  NSDictionary *latencyData = [SKDatabase getLatencyResultsForTestId:testId];
  NSDictionary *lossData = [SKDatabase getLossResultsForTestId:testId];
  
  if ([latencyData count] > 0 && [lossData count] > 0)
  {
    double latency = [[latencyData objectForKey:@"RESULT"] doubleValue];
    double loss = [[lossData objectForKey:@"RESULT"] doubleValue];
    
    strLatency = [NSString stringWithFormat:@"%@ ms", [SKGlobalMethods format2DecimalPlaces:latency]];
    strLoss = [NSString stringWithFormat:@"%d %%", (int)loss];
    
  }
  */
  
  return [SKAppBehaviourDelegate sBuildSocialMediaMessageForCarrierName:carrierName SocialNetwork:socialNetwork Upload:upload Download:download ThisDataIsAveraged:NO];
}

- (IBAction)actionButton:(id)sender {
  
//#if TARGET_IPHONE_SIMULATOR
//#else // TARGET_IPHONE_SIMULATOR
  if (![self.networkType isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
    UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:sSKCoreGetLocalisedString(@"Title_ShareUsingSocialMediaMobile")
     message:sSKCoreGetLocalisedString(@"Message_ShareUsingSocialMediaMobile")
     delegate:nil
     cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_OK")
     otherButtonTitles:nil];
    [alert show];
    return;
  }
//#endif // TARGET_IPHONE_SIMULATOR
  
  NSString *twitterString = [self getTextForSocialMedia:(NSString*)SLServiceTypeTwitter];
  NSString *facebookString = [self getTextForSocialMedia:(NSString*)SLServiceTypeFacebook];
  NSString *sinaWeiboString = [self getTextForSocialMedia:(NSString*)SLServiceTypeSinaWeibo];
  NSDictionary *dictionary = @{SLServiceTypeTwitter:twitterString, SLServiceTypeFacebook:facebookString, SLServiceTypeSinaWeibo:sinaWeiboString};
  
  [SKAppBehaviourDelegate showActionSheetForSocialMediaExport:dictionary OnViewController:self];
}

@end
