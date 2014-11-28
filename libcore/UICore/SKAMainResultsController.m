//
//  SKAMainResultsController.m
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKAMainResultsController.h"
#import "SKAArchivedResultsController.h"
#import "SKAAppDelegate.h"
#import "SKATermsAndConditionsController.h"
#import "SKAMainResultControllerSection1Cell.h"
#import "SKAMainResultTestHeaderCell.h"
#import "SKASettingsController.h"
#import "UIViewController+SKSafeSegue.h"
#import "SKAFooterCell.h"

// For simulating crashes!
#import <HockeySDK/HockeySDK.h>

#define ACTION_RUN      1
#define ACTION_RANGE    2
#define ACTION_ALREADY_EXCEEDED_PRESS_OK_TO_CONTINUE   3
#define ACTION_NETWORKTYPE   4
#define ACTION_MENU   5
#define ACTION_WILL_BE_EXCEEDED_PRESS_OK_TO_CONTINUE   6
#define ACTION_SHARE   7

static SKAMainResultsController *spSKAMainResultsController = nil;

@interface SKAMainResultsController ()
{
  int limitDownload;
  int limitUpload;
  int limitLatency;
  int limitLoss;
  
  BOOL mySections[10];
  
  NSMutableArray *dataForGraphs;
  
  int mSections;
}

@property BOOL mbContinuousTesting;
@property int mSectionIndexForFooter; // -1 if not used!

- (void)range;
- (void)addSwipeGesture;
- (void)swipeLeft;
- (void)setLabels;
- (void)checkConfig;
- (void)setDateLabel;
- (void)refreshGraphTableData;
- (void)showTestPicker;

- (DATERANGE_1w1m3m1y)getDateRange;
- (NSString*)getDateRangeText;
- (NSString*)getTestString:(int)section;
- (TestDataType)getTestType:(int)section;
- (NSString*)getTestCellText:(int)section;

- (void)runTests:(TestType)type;

@end

@implementation SKAMainResultsController

@synthesize mbContinuousTesting;
@synthesize mSectionIndexForFooter; // -1 if not used!
//@synthesize btnRun;
//@synthesize btnRange;
@synthesize lblMain;
@synthesize tableView;
@synthesize lblAlert;
@synthesize lblLastDate;
@synthesize imgviewAlert;
@synthesize viewBG;

-(int) calculateSections {
  SKAAppDelegate *appDelegate = [SKAAppDelegate getAppDelegate];
  NSArray *tests = appDelegate.schedule.tests;
 
  int lRows = 2; // Header, footer etc. - and tests (4 or 5 usually...) 6 for FCC.
  
  for (int j=0; j<[tests count]; j++)
  {
    NSDictionary *dict = [tests objectAtIndex:j];
    NSString *type = [dict objectForKey:@"type"];
    
    if ([type isEqualToString:@"closestTarget"])
    {
    }
    else if ([type isEqualToString:@"downstreamthroughput"])
    {
      lRows++;
      NSString *displayName = [dict objectForKey:@"displayName"];
      NSLog(@"Type=%@, displayName=%@", type, displayName);
    }
    else if ([type isEqualToString:@"upstreamthroughput"])
    {
      lRows++;
      NSString *displayName = [dict objectForKey:@"displayName"];
      NSLog(@"Type=%@, displayName=%@", type, displayName);
    }
    else if ([type isEqualToString:@"latency"])
    {
      if ([[SKAAppDelegate getAppDelegate] getIsJitterSupported] == NO) {
        lRows += 2;
        // latency/loss!
      } else {
        lRows += 3;
        // latency/loss/jitter!
      }
      NSString *displayName = [dict objectForKey:@"displayName"];
      NSLog(@"Type=%@, displayName=%@", type, displayName);
    }
  }
  
  mSections = lRows;
  
  mSectionIndexForFooter = -1;
  if ([[SKAAppDelegate getAppDelegate] getIsFooterSupported] == YES) {
    mSectionIndexForFooter = mSections;
    SK_ASSERT(mSectionIndexForFooter > 0);
  }
  
  // Jitter is reported, as well!!
  return lRows;
}

-(int) getResultsRows {
  if ([[SKAAppDelegate getAppDelegate] getIsJitterSupported] == NO) {
    return 4;
  }
  
  // Jitter is supported?
  SK_ASSERT ([[SKAAppDelegate getAppDelegate] getIsJitterSupported]);
  return 5;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = sSKCoreGetLocalisedString(@"Storyboard_SKAMainResultsController_Title");
  
  spSKAMainResultsController = self;
  
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  
  [self calculateSections];
 
  int sections = mSections;
  for (int j=0; j < sections; j++)
  {
    mySections[j] = NO;
    
    limitDownload = 1;
    limitUpload = 1;
    limitLatency = 1;
    limitLoss = 1;
  }
  
  [self checkConfig];
  [self addSwipeGesture];
  
  SK_ASSERT(self.tableView != nil);
  
  SKAAppDelegate *delegate = (SKAAppDelegate*)[UIApplication sharedApplication].delegate;
  SK_ASSERT ([delegate hasAgreed]);
  SK_ASSERT ([delegate isActivated]);
  
  // http://stackoverflow.com/questions/11664766/cell-animation-stop-fraction-must-be-greater-than-start-fraction
  tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  
  self.networkTypeButton.titleLabel.textColor = [UIColor blackColor];
  
  self.networkTypeButton.titleLabel.text = sSKCoreGetLocalisedString(@"ShowingResults_Mobile");
  [self setNetworkTypeTo:@"mobile"];
}

+(SKAMainResultsController*)getSKAMainResultsController {
  return spSKAMainResultsController;
}

-(void) doPerformSegueWithIdentifier:(NSString*)identifier {
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  [self SKSafePerformSegueWithIdentifier:identifier sender:self];
}

-(void) setNetworkTypeTo:(NSString*)toNetworkType {
  if ([toNetworkType isEqualToString:@"mobile"]) {
    [[SKAAppDelegate getAppDelegate] switchNetworkTypeToMobile];
    self.networkTypeLabel.text = sSKCoreGetLocalisedString(@"ShowingResults_Mobile"); // : @"WiFi results");
  } else if ([toNetworkType isEqualToString:@"network"]) {
    [[SKAAppDelegate getAppDelegate] switchNetworkTypeToWiFi];
    self.networkTypeLabel.text = sSKCoreGetLocalisedString(@"ShowingResults_WiFi"); // : @"WiFi results");
  } else if ([toNetworkType isEqualToString:@"all"]) {
    [[SKAAppDelegate getAppDelegate] switchNetworkTypeToAll];
    self.networkTypeLabel.text = sSKCoreGetLocalisedString(@"ShowingResults_All"); // : @"WiFi results");
  } else {
    SK_ASSERT(false);
    return;
  }
  
  // Re-query everything!
  [self refreshGraphsAndTableData];
}

// Re-query everything!
-(void) refreshGraphsAndTableData {
   // Show or hide the button to show archived results!
  self.showArchivedResultsButton.hidden = ![self canViewArchivedResults];
  [self refreshGraphTableData];
  [self setDateLabel];
  [self setLabels];
  [self.tableView reloadData];
}

// If the switch is ON, we show MOBILE (the default!)
- (IBAction)networkTypeButton:(id)sender {
  
  UIActionSheet *action =[[UIActionSheet alloc] initWithTitle:sSKCoreGetLocalisedString(@"Title_SelectResultsToShow")
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:nil];
  
  NSArray *array = [[NSArray alloc] initWithObjects:
                    sSKCoreGetLocalisedString(@"NetworkTypeMenu_Mobile"),
                    sSKCoreGetLocalisedString(@"NetworkTypeMenu_WiFi"),
                    sSKCoreGetLocalisedString(@"NetworkTypeMenu_All"),
                    nil];
  
  for (int j=0; j<[array count]; j++)
  {
    [action addButtonWithTitle:[array objectAtIndex:j]];
  }
  
  [action addButtonWithTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")];
  [action setCancelButtonIndex:[array count]];
  [action setTag:ACTION_NETWORKTYPE];
  [action setActionSheetStyle:UIActionSheetStyleDefault];
  [action showInView:self.view];
}


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.mbContinuousTesting = NO;
  
  // Whenever we re-display the view controller (e.g. returning from archived results screen), perform
  // a full refresh of the graphs!
  [self refreshGraphTableData];
  
  // We must update the date label; in case we're returning to the screen after running a test,
  // in which case it is likely to have updated the "Test Last Run" result!
  [self setDateLabel];
  
  // required for this to look good in iOS 7!
  self.navigationController.navigationBar.translucent = NO;
  
  // As we might have returned from the settings screen having deleted the table - upload the table again!
  [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];

  // Show or hide the button to show archived results!
  self.showArchivedResultsButton.hidden = ![self canViewArchivedResults];
  
  [self performSelectorInBackground:@selector(checkDataUsage) withObject:nil];
}

- (void)addSwipeGesture
{
  UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(swipeLeft)];
  
  swipe.direction = UISwipeGestureRecognizerDirectionLeft;
  [self.tableView addGestureRecognizer:swipe];
  
}

NSMutableArray *GArrayForResultsController;

-(BOOL) canViewArchivedResults {
  GArrayForResultsController = [SKDatabase getTestMetaDataWhereNetworkTypeEquals:[SKAAppDelegate getNetworkTypeString]];
  
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

- (IBAction)showArchivedResultsButton:(id)sender {
  [self swipeLeft];
}

- (IBAction)actionBarButtonItem:(id)sender {
  
  if (self.navigationController.topViewController != self) {
    SK_ASSERT(false);
    return;
  }
  
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:sSKCoreGetLocalisedString(@"Title_SelectOption")
                                                      delegate:self
                                             cancelButtonTitle:nil
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:nil];
  
  
  NSMutableArray *array = [NSMutableArray new];
  
  [array addObject:sSKCoreGetLocalisedString(@"Menu_Settings")];
  [array addObject:sSKCoreGetLocalisedString(@"Menu_About")];
  [array addObject:sSKCoreGetLocalisedString(@"Menu_TermsOfUse")];
  
  if ([[SKAAppDelegate getAppDelegate] supportExportMenuItem]) {
    [array addObject:sSKCoreGetLocalisedString(@"Menu_Export")];
  }
  
  [array addObject:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")];
  
  int i;
  for (i = 0; i < array.count; i++)
  {
    [actionSheet addButtonWithTitle:array[i]];
  }
  
  actionSheet.cancelButtonIndex = [array count] - 1;
  actionSheet.tag = ACTION_MENU; //  Magic identifiying tag, on the base UIView
  actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
  
  [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
  
  // Calling with showFromToolbar seems to make no difference!
  //[actionSheet showFromToolbar:self.uiToolbar];
  [actionSheet showInView:self.view];
}


-(NSString*) getTextForSocialMedia:(NSString*)socialNetwork {
  
  NSString *download = nil;
  NSString *upload = nil;
  
  double result = 0;
  //NSString *str = nil;
  
  int retCount = 0;
  
  result = [SKAAppDelegate getAverageTestData:[self getDateRange] testDataType:DOWNLOAD_DATA RetCount:&retCount];
  download = [SKGlobalMethods bitrateMbps1024BasedToString:result];
  
  result = [SKAAppDelegate getAverageTestData:[self getDateRange] testDataType:UPLOAD_DATA RetCount:&retCount];
  upload = [SKGlobalMethods bitrateMbps1024BasedToString:result];
  
  /*
   // LATENCY and LOSS
   result = [SKAAppDelegate getAverageTestData:[self getDateRange] testDataType:LATENCY_DATA RetCount:&retCount];
   str = [NSString stringWithFormat:@"%@ ms", [SKGlobalMethods format2DecimalPlaces:result]];
   
   result = [SKAAppDelegate getAverageTestData:[self getDateRange] testDataType:LOSS_DATA RetCount:&retCount];
   str = [NSString stringWithFormat:@"%d %%", (int)result];
   
   result = [SKAAppDelegate getAverageTestData:[self getDateRange] testDataType:JITTER_DATA RetCount:&retCount];
   str = [NSString stringWithFormat:@"%@ ms", [SKGlobalMethods format2DecimalPlaces:result]];
   */
  
  NSString *carrierName = [SKGlobalMethods getCarrierName];
  return [SKAAppDelegate sBuildSocialMediaMessageForCarrierName:carrierName SocialNetwork:socialNetwork Upload:upload Download:download ThisDataIsAveraged:YES];
}


- (IBAction)shareButton:(id)sender {
  if (![[SKAAppDelegate getAppDelegate] isNetworkTypeMobile]) {
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
  
  NSDate *dateLastRun = [SKDatabase getLastRunDateWhereNetworkTypeEquals:[SKAAppDelegate getNetworkTypeString]];
  if (dateLastRun == nil) {
    UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:sSKCoreGetLocalisedString(@"Title_ShareUsingSocialMediaInfo")
     message:sSKCoreGetLocalisedString(@"RESULTS_Label_Data")
     delegate:nil
     cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_OK")
     otherButtonTitles:nil];
    [alert show];
    return;
    
  }

  
  NSString *twitterString = [self getTextForSocialMedia:(NSString*)SLServiceTypeTwitter];
  NSString *facebookString = [self getTextForSocialMedia:(NSString*)SLServiceTypeFacebook];
  NSString *sinaWeiboString = [self getTextForSocialMedia:(NSString*)SLServiceTypeSinaWeibo];
  
  NSDictionary *dictionary = @{SLServiceTypeTwitter:twitterString, SLServiceTypeFacebook:facebookString, SLServiceTypeSinaWeibo:sinaWeiboString};
  
  [SKAAppDelegate showActionSheetForSocialMediaExport:dictionary OnViewController:self];
}

- (void)swipeLeft
{
  if ([self canViewArchivedResults]) {
    [self SKSafePerformSegueWithIdentifier:@"segueToArchivedResultsController" sender:self];
  }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  
  // NSLog(@"MPC segue.identifier=%@", segue.identifier);
  
  if ([segue.identifier isEqualToString:@"segueToArchivedResultsController"]) {
    // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
    
//    UINavigationController *nc = (UINavigationController*)segue.destinationViewController;
//    UIViewController *vc = (UIViewController*)nc.viewControllers[0];
//    SK_ASSERT([vc class] == [SKAArchivedResultsController class]);
//    SKAArchivedResultsController *cnt = (SKAArchivedResultsController*)vc;
    SKAArchivedResultsController *cnt = (SKAArchivedResultsController*)segue.destinationViewController;
    cnt.testIndex = 0;
    SK_ASSERT(GArrayForResultsController != nil);
    cnt.testMetaData = GArrayForResultsController;
    GArrayForResultsController = nil;
  } else if ([segue.identifier isEqualToString:@"segueFromMainToSettingsController"]) {
    // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
    
  } else if ([segue.identifier isEqualToString:@"segueFromMainToTAndCController"]) {
    // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  } else if ([segue.identifier isEqualToString:@"segueFromMainToAbout"]) {
    // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
    
  } else if ([segue.identifier isEqualToString:@"segueToRunTestsController"]) {
    // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
    
    UINavigationController *nc = (UINavigationController *)segue.destinationViewController;
    SKARunTestsController *tc = (SKARunTestsController *)nc.viewControllers[0];
    tc.delegate = self;
    tc.testType = GRunTheTestWithThisType;
    tc.continuousTesting = self.mbContinuousTesting;
  } else {
    SK_ASSERT(false);
  }
}

- (void)checkDataUsage
{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSDate *date = [prefs objectForKey:Prefs_DataDate];
  NSDate *dateNow = [SKCore getToday];
  
  NSTimeInterval interval = [dateNow timeIntervalSinceDate:date];
  
  NSTimeInterval oneMonth = 30 * 24 * 60 * 60; // 2592000 seconds in 30 days
  
  if (interval > oneMonth)
  {
    // reset the data usage
    [prefs setValue:dateNow forKey:Prefs_DataDate];
    [prefs setValue:[NSNumber numberWithLongLong:0] forKey:Prefs_DataUsage];
    [prefs synchronize];
  }
}

- (void)setLabels
{
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,45,45)];
  label.font = [[SKAAppDelegate getAppDelegate] getSpecialFontOfSize:17];
  
  label.textColor = [UIColor blackColor];
  
  label.backgroundColor = [UIColor clearColor];
  label.text = sSKCoreGetLocalisedString(@"RESULTS_Title");
  [label sizeToFit];
  self.navigationItem.titleView = label;
  
  [self.lblMain setText:sSKCoreGetLocalisedString(@"RESULTS_Label")];
  [self.lblAlert setText:sSKCoreGetLocalisedString(@"RESULTS_Label_Data")];
  //    [self.btnRun setTitle:sSKCoreGetLocalisedString(@"RESULTS_Label_Run") forState:UIControlStateNormal];
  //    [self.btnRange setTitle:[self getDateRangeText] forState:UIControlStateNormal];
  
  [self setDateLabel];
}

- (void)setDateLabel
{
  // NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  //NSDate *dateLastRun = [prefs objectForKey:Prefs_LastTestDate];
  NSDate *dateLastRun = [SKDatabase getLastRunDateWhereNetworkTypeEquals:[SKAAppDelegate getNetworkTypeString]];
  if (dateLastRun != nil)
  {
    NSString *strDateLastRun = [SKGlobalMethods formatDate:dateLastRun];
    NSString *txt = [NSString stringWithFormat:@"%@%@", sSKCoreGetLocalisedString(@"RESULTS_Label_Date_Last_Run"), strDateLastRun];
    self.lblLastDate.text = txt;
    
    self.lblLastDate.hidden = NO;
    self.lblAlert.hidden = YES;
    self.imgviewAlert.hidden = YES;
  }
  else
  {
    self.lblLastDate.hidden = YES;
    self.lblAlert.hidden = NO;
    self.imgviewAlert.hidden = NO;
  }
}

#pragma mark - Alert View Delegate

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (buttonIndex == alertView.cancelButtonIndex) {
    return;
  }
  
  if (alertView.tag == ACTION_ALREADY_EXCEEDED_PRESS_OK_TO_CONTINUE) {
    [self showTestPicker];
  } else if (alertView.tag == ACTION_WILL_BE_EXCEEDED_PRESS_OK_TO_CONTINUE) {
    [self selfRunTestAfterUserApprovedToDataCapChecks];
  }
}

+ (bool)sLaunchEmailWithAttachment:(NSString *)PpMailAddress subject:(NSString *)PpSubject bodyText:(NSString *)PpBodyText fileToAttach:(NSString *)PFileToAttach attachWithName:(NSString *)inAttachWithName FromThisViewController:(UIViewController*)fromThisViewController WithThisMailDelegate:(id<MFMailComposeViewControllerDelegate>)withThisDelegate
{
  // Defend against weird problem we sometimes see on HockeyApp...
  // Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'Application tried to present a nil modal view controller on target <SKASettingsController: 0x....>.'
  if ([MFMailComposeViewController canSendMail] == NO) {
    return false;
  }
  
  MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
  picker.mailComposeDelegate = withThisDelegate;
  
  [picker setSubject:PpSubject];
  
  [picker setMessageBody:PpBodyText isHTML:NO];
  
  /*
   // Set up the recipients.
   NSArray *toRecipients = [NSArray arrayWithObjects:@"first@example.com",
   nil];
   NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com",
   @"third@example.com", nil];
   NSArray *bccRecipients = [NSArray arrayWithObjects:@"four@example.com",
   nil];
   [picker setToRecipients:toRecipients];
   [picker setCcRecipients:ccRecipients];
   [picker setBccRecipients:bccRecipients];
   */
  
//  int lItems = (int)PFilesToAttach.count;
//  int i;
//  for (i = 0; i < lItems; i++)
  {
    //NSString *theFile = PFilesToAttach[i];
    NSString *theFile = PFileToAttach;
    SK_ASSERT(theFile != nil);
    NSURL *url = [NSURL fileURLWithPath:theFile];
    SK_ASSERT(url != nil);
    NSString *extension = [url pathExtension];
 
    NSString *nsMimeType = @"application/octet-stream";

    if ([extension isEqualToString:@"zip"]) {
      nsMimeType = @"application/zip";
    }
    
    // Use an autorelease pool to avoid leaks!
    @autoreleasepool {
      
      //NSData *myData = [NSData dataWithContentsOfFile:PFilesToAttach[i]];
      NSData *myData = [NSData dataWithContentsOfFile:PFileToAttach];
      
      NSString *lpFileNameWithExtension = [[url pathComponents] lastObject];
      
      if (inAttachWithName != nil) {
        lpFileNameWithExtension = inAttachWithName;
      }
      
      [picker addAttachmentData:myData mimeType:nsMimeType fileName:lpFileNameWithExtension];
    }
  }
  
  // Present the mail composition interface.
//  UIViewController *vc = [UIViewController sKGetTopMostController];
//  SK_ASSERT(vc != nil);
//  if (vc != nil) {
//    fromThisViewController = vc;
//  }
  [fromThisViewController presentViewController:picker animated:YES completion:nil];
  // Can safely release the controller now.
  
  return true;
}

// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  // In your own app, you could use the delegate to track whether the user sent or canceled the email by examining the value in the result parameter.
  [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Action Sheet Delegate

+ (void)sMenuSelectedExportResults:(id<MFMailComposeViewControllerDelegate>)thisMailDelegate fromThisVC:(UIViewController *)fromThisVC
{
  if (![MFMailComposeViewController canSendMail]) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:sSKCoreGetLocalisedString(@"Email not enabled")
                                                    message:sSKCoreGetLocalisedString(@"In order to send emails, you must first configure email on your device.")
                                                   delegate:nil
                                          cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_OK")
                                          otherButtonTitles:nil];
    [alert show];
    return;
  }
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:sSKCoreGetLocalisedString(@"Export_Title")
                                                  message:sSKCoreGetLocalisedString(@"Export_Body")
                                                 delegate:nil
                                        cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")
                                        otherButtonTitles:sSKCoreGetLocalisedString(@"MenuAlert_OK"), nil];
  
  [alert showWithBlock:^(UIAlertView *inView, NSInteger buttonIndex) {
    int items = 0;
    
    if ([SKAAppDelegate exportArchivedJSONFilesToZip:&items] == NO) {
      UIAlertView *alert = [[UIAlertView alloc]
                            initWithTitle:sSKCoreGetLocalisedString(@"Export_Failed_Title")
                            message:sSKCoreGetLocalisedString(@"Export_Failed_Body")
                            delegate:nil
                            cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_OK")
                            otherButtonTitles:nil];
      [alert show];
    } else {
      // Succeeded!
      // If there are no items, tell the user - otherwise, the zip file is malformed!
      if (items == 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:sSKCoreGetLocalisedString(@"Export_NoItems_Title")
                              message:sSKCoreGetLocalisedString(@"Export_NoItems_Body")
                              delegate:nil
                              cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_OK")
                              otherButtonTitles:nil];
        [alert show];
      } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        
        NSDate *now = [NSDate date];
        NSString *lpReadableDate = [dateFormatter stringFromDate:now];
        
        NSString *zipPath = [SKAAppDelegate getJSONArchiveZipFilePath];
        NSString *lpFileNameWithExtension = [NSString stringWithFormat:@"export_%@.zip",lpReadableDate];
        // Ensure that there are no :/, characters in the name!
        lpFileNameWithExtension = [lpFileNameWithExtension stringByReplacingOccurrencesOfString:@":" withString:@"_"];
        lpFileNameWithExtension = [lpFileNameWithExtension stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        lpFileNameWithExtension = [lpFileNameWithExtension stringByReplacingOccurrencesOfString:@"," withString:@"_"];
        lpFileNameWithExtension = [lpFileNameWithExtension stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        lpFileNameWithExtension = [lpFileNameWithExtension stringByReplacingOccurrencesOfString:@"__" withString:@"_"];
        
        [SKAMainResultsController sLaunchEmailWithAttachment:@""
                                                     subject:[NSString stringWithFormat:@"%@ - %@", sSKCoreGetLocalisedString(@"MenuExport_Mail_Subject"), lpReadableDate]
                                                    bodyText:[NSString stringWithFormat:@"%@\n\n%@", sSKCoreGetLocalisedString(@"MenuExport_Mail_Body"), lpFileNameWithExtension]
                                                fileToAttach:zipPath
                                              attachWithName:lpFileNameWithExtension
                                      FromThisViewController:fromThisVC
                                        WithThisMailDelegate:thisMailDelegate];
      }
    }
  } cancelBlock:^(UIAlertView *inView) {
    // Nothing to do!
  }];
}

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)index {
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)index {
  if (index == [actionSheet cancelButtonIndex]) {
    return;
  }
  
  NSString *selectedString = [actionSheet buttonTitleAtIndex:index];
  
  if (actionSheet.tag == ACTION_RUN) {
    if ([selectedString isEqualToString:sSKCoreGetLocalisedString(@"Test_Run_Download")]) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runTests:DOWNLOAD_TEST];
      });
    }
    else if ([selectedString isEqualToString:sSKCoreGetLocalisedString(@"Test_Run_Upload")]) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runTests:UPLOAD_TEST];
      });
    }
    else if ([selectedString isEqualToString:sSKCoreGetLocalisedString(@"Test_Run_LatencyLoss")]) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runTests:LATENCY_TEST];
      });
    }
    else if ([selectedString isEqualToString:sSKCoreGetLocalisedString(@"Test_Run_Jitter")]) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self runTests:JITTER_TEST];
      });
    }
    else if ([selectedString isEqualToString:sSKCoreGetLocalisedString(@"Test_Run_All")]) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self runTests:ALL_TESTS];
      });
    } else {
      SK_ASSERT(false);
    }
  } else if (actionSheet.tag == ACTION_RANGE) {
    
    DATERANGE_1w1m3m1y range = DATERANGE_1w1m3m1y_ONE_WEEK;
    
    if ([selectedString isEqualToString:sSKCoreGetLocalisedString(@"time_period_1week")]) {
      range = DATERANGE_1w1m3m1y_ONE_WEEK;
    } else if ([selectedString isEqualToString:sSKCoreGetLocalisedString(@"time_period_1month")]) {
      range = DATERANGE_1w1m3m1y_ONE_MONTH;
    } else if ([selectedString isEqualToString:sSKCoreGetLocalisedString(@"time_period_3months")]) {
      range = DATERANGE_1w1m3m1y_THREE_MONTHS;
    } else if ([selectedString isEqualToString:sSKCoreGetLocalisedString(@"time_period_1year")]) {
      range = DATERANGE_1w1m3m1y_ONE_YEAR;
    } else if ([selectedString isEqualToString:sSKCoreGetLocalisedString(@"time_period_1day")]) {
      range = DATERANGE_1w1m3m1y_ONE_DAY;
    } else {
      SK_ASSERT(false);
      return;
    }

    switch (range)
    {
      case DATERANGE_1w1m3m1y_ONE_WEEK:
      case DATERANGE_1w1m3m1y_ONE_MONTH:
      case DATERANGE_1w1m3m1y_THREE_MONTHS:
      case DATERANGE_1w1m3m1y_ONE_YEAR:
      case DATERANGE_1w1m3m1y_ONE_DAY:
        [self setDateRange:range];
        // Re-query everything!
        [self refreshGraphsAndTableData];
        //[self.btnRange setTitle:[self getDateRangeText] forState:UIControlStateNormal];
        break;
        
      default:
        SK_ASSERT(false);
        break;
    }
  } else if (actionSheet.tag == ACTION_NETWORKTYPE) {
    // TODO!
    switch (index) {
      case 0: // Mobile
        [self setNetworkTypeTo:@"mobile"];
        break;
      case 1: // WiFi
        [self setNetworkTypeTo:@"network"];
        break;
      case 2: // All
        [self setNetworkTypeTo:@"all"];
        break;
      default:
        break;
    }
  } else if (actionSheet.tag == ACTION_SHARE) {
    // TODO!
    NSString *buttonText = [actionSheet buttonTitleAtIndex:index];
    if ([buttonText isEqualToString:SLServiceTypeTwitter]) {
      // TODO!
    } else if ([buttonText isEqualToString:SLServiceTypeFacebook]) {
      // TODO!
//    } else if ([buttonText isEqualToString:SLServiceTypeSinaWeibo]) {
//      // TODO!
    } else {
      SK_ASSERT(false);
    }
  } else if (actionSheet.tag == ACTION_MENU) {
    
    NSString *buttonText = [actionSheet buttonTitleAtIndex:index];
    
    // TODO!
    if ([buttonText isEqualToString:sSKCoreGetLocalisedString(@"Menu_Settings")]) {
      // Settings
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self SKSafePerformSegueWithIdentifier:@"segueFromMainToSettingsController" sender:self];
      });
    } else if ([buttonText isEqualToString:sSKCoreGetLocalisedString(@"Menu_About")]) {
        // About
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self SKSafePerformSegueWithIdentifier:@"segueFromMainToAbout" sender:self];
      });
    } else if ([buttonText isEqualToString:sSKCoreGetLocalisedString(@"Menu_TermsOfUse")]) {
      // Terms of Use
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self SKSafePerformSegueWithIdentifier:@"segueFromMainToTAndCController" sender:self];
      });
    } else if ([buttonText isEqualToString:sSKCoreGetLocalisedString(@"Menu_Export")]) {
      
      UIViewController *fromThisVC = self;
      id<MFMailComposeViewControllerDelegate> thisMailDelegate = self;
      
      [SKAMainResultsController sMenuSelectedExportResults:thisMailDelegate fromThisVC:fromThisVC];
    } else {
      // Unexpected menu item!
      SK_ASSERT(false);
    }
  }
 
}

#pragma mark - Run All Tests

static TestType GRunTheTestWithThisType;

- (void)runTests:(TestType)type
{
  
  if ([[SKAAppDelegate getAppDelegate] amdGetFileUploadPath] == nil) {
    // File not yet ready - TODO add an alerts to say "Please wait"...?
    SK_ASSERT(false);
    return;
  }
  
  GRunTheTestWithThisType = type;
  
  if (sbHaveAlreadyAskedUserAboutDataCapExceededSinceButtonPress == YES) {
    // Do NOT warn the user twice!
  } else {
    if ([self checkIfTestWillExceedDataCapForTestType:type]) {
      UIAlertView *alert =
      [[UIAlertView alloc] initWithTitle:sSKCoreGetLocalisedString(@"Data_Might_Be_Exceeded")
                                 message:sSKCoreGetLocalisedString(@"Data_Exceed_Msg")
                                delegate:nil
                       cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")
                       otherButtonTitles:sSKCoreGetLocalisedString(@"MenuAlert_OK"),nil];
      [alert setTag:ACTION_WILL_BE_EXCEEDED_PRESS_OK_TO_CONTINUE];
      [alert setDelegate:self];
      [alert show];
      
      return;
    }
  }
  
  [self selfRunTestAfterUserApprovedToDataCapChecks];
}

-(void) selfRunTestAfterUserApprovedToDataCapChecks {

  SKAAppDelegate *delegate = (SKAAppDelegate*)[UIApplication sharedApplication].delegate;

  if ([delegate getIsConnected])
  {
    [self SKSafePerformSegueWithIdentifier:@"segueToRunTestsController" sender:self];
  }
  else
  {
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:nil
                               message:sSKCoreGetLocalisedString(@"Offline_message")
                              delegate:nil
                     cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_OK")
                     otherButtonTitles: nil];
    
    [alert show];
  }
}


#pragma mark - Header delegate methods

-(BOOL) checkIfTestWillExceedDataCapForTestType:(TestType)type {
  
  // If we're currently WiFi, there is nothing to run!
  if ([SKAAppDelegate getIsUsingWiFi]) {
    return NO;
  }
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  int64_t dataUsed = [[prefs objectForKey:Prefs_DataUsage] longLongValue];
  
  int64_t dataAllowed = [[prefs objectForKey:Prefs_DataCapValueBytes] longLongValue];
  
  // For all selected tests, add-up the expected amount of data to use.
  // And if data consumed + expected data > dataAllowed, present a warning to the user!
  
  int64_t dataWillBeUsed = 0;
 
  // TODO - add-in the correct value here!
  for (NSDictionary *testDict in [SKAAppDelegate getAppDelegate].schedule.tests) {
    NSString *thisTestType = [testDict objectForKey:@"type"];
    
    NSArray *params = testDict[@"params"];
    int theCount = (int)params.count;
    
    int paramIndex;
    for (paramIndex=0; paramIndex<theCount; paramIndex++)
    {
      NSDictionary *theParam = params[paramIndex];
      
      int64_t thisTestBytes = 0;
      if (theParam[@"numberOfPackets"]) {
        NSString *theValue = theParam[@"numberOfPackets"];
        thisTestBytes += [theValue longLongValue] * 16;
      } else if (theParam[@"warmupmaxbytes"]) {
        NSString *theValue = theParam[@"warmupmaxbytes"];
        thisTestBytes += [theValue longLongValue];
      } else if (theParam[@"transfermaxbytes"]) {
        NSString *theValue = theParam[@"transfermaxbytes"];
        thisTestBytes += [theValue longLongValue];
      }
      
      if (thisTestBytes <= 0) {
        continue;
      }
      
      switch (type) {
        case ALL_TESTS:
          dataWillBeUsed += thisTestBytes;
          break;
        case DOWNLOAD_TEST:
          if ([thisTestType isEqualToString:@"downstreamthroughput"]) {
            dataWillBeUsed += thisTestBytes;
          }
          break;
        case UPLOAD_TEST:
          if ([thisTestType isEqualToString:@"upstreamthroughput"]) {
            dataWillBeUsed += thisTestBytes;
          }
          break;
        case LATENCY_TEST:
          if ([thisTestType isEqualToString:@"latency"]) {
            dataWillBeUsed += thisTestBytes;
          }
          break;
        case JITTER_TEST:
          if ([thisTestType isEqualToString:@"jitter"]) {
            dataWillBeUsed += thisTestBytes;
          }
          break;
        default:
          SK_ASSERT(false);
          break;
      }
    }
  }
  
  // The value of "dataWillBeUsed" is generally *MUCH* higher than the *actually* used value.
  // e.g. 40+MB, compared to 4MB. The reason is that the value is from SCHEDULE.xml (see the above logic),
  // where transfermaxbytes specifies the absolute maximum that a test is allowed to use; in practise,
  // the test runs for a capped amount of time (also in the schedule data - transfermaxtime)
  // and processes far less data that the defined maximum number of bytes to use.
  
  if ((dataUsed + dataWillBeUsed) > dataAllowed)
  {
    // Data cap exceeded - but only ask the user if they want to continue, if the app is configured
    // to work like that...
    
    if ([[SKAAppDelegate getAppDelegate] isDataCapEnabled] == YES) {
      
      return YES;
    }
  }
  
  return NO;
}

-(BOOL) checkIfTestsHaveExceededDataCap {
  // If we're currently WiFi, there is nothing to test against!
  if ([SKAAppDelegate getIsUsingWiFi]) {
    return NO;
  }
  
  if ([[SKAAppDelegate getAppDelegate] isDataCapEnabled] == NO) {
    return NO;
  }

  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  int64_t dataUsed = [[prefs objectForKey:Prefs_DataUsage] longLongValue];
  
  int64_t dataAllowed = [[prefs objectForKey:Prefs_DataCapValueBytes] longLongValue];
  
  if (dataUsed > dataAllowed)
  {
    // Data cap already exceeded - but only ask the user if they want to continue, if the app is configured
    // to work like that...
    
    if ([[SKAAppDelegate getAppDelegate] isDataCapEnabled] == YES) {
      
      return YES;
    }
  }
  
  return NO;
}

BOOL sbHaveAlreadyAskedUserAboutDataCapExceededSinceButtonPress = NO;

- (void)handleButtonPress:(BOOL)continuousTesting
{
  sbHaveAlreadyAskedUserAboutDataCapExceededSinceButtonPress = NO;
  self.mbContinuousTesting = continuousTesting;
  
  if (self.mbContinuousTesting == YES) {
    // If continuous testing is set, we check once for the data allowance,
    // and loop continuously until Done is pressed - at which point, we
    // must auto-stop!
    
    SK_ASSERT([[SKAAppDelegate getAppDelegate] supportContinuousTesting] == YES);
  }
  
  if ([self checkIfTestsHaveExceededDataCap]) {
    
    sbHaveAlreadyAskedUserAboutDataCapExceededSinceButtonPress = YES;
    
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:sSKCoreGetLocalisedString(@"Data_Exceeded")
                               message:sSKCoreGetLocalisedString(@"Data_Exceed_Msg")
                              delegate:nil
                     cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")
                     otherButtonTitles:sSKCoreGetLocalisedString(@"MenuAlert_OK"),nil];
    [alert setTag:ACTION_ALREADY_EXCEEDED_PRESS_OK_TO_CONTINUE];
    [alert setDelegate:self];
    [alert show];
    
    return;
  }
  
  [self showTestPicker];
}

- (void)showTestPicker
{
  // Depending on configuration, we either run all tests, or show a picker...
  
  if ([[SKAAppDelegate getAppDelegate] alwaysRunAllTests]) {
    // Run all tests!
    [self runTests:ALL_TESTS];
    return;
  }
  
  if (self.navigationController.topViewController != self) {
    SK_ASSERT(false);
    return;
  }
  
  // Show a picker!
  
  UIActionSheet *action =
  [[UIActionSheet alloc] initWithTitle:nil
                              delegate:self
                     cancelButtonTitle:nil
                destructiveButtonTitle:nil
                     otherButtonTitles:nil];
  
  NSArray *array;
  
  if ([[SKAAppDelegate getAppDelegate] getIsJitterSupported] == NO) {
    array = [[NSArray alloc] initWithObjects:
             sSKCoreGetLocalisedString(@"Test_Run_Download"),
             sSKCoreGetLocalisedString(@"Test_Run_Upload"),
             sSKCoreGetLocalisedString(@"Test_Run_LatencyLoss"),
             sSKCoreGetLocalisedString(@"Test_Run_All"),
             nil];
  } else {
    array = [[NSArray alloc] initWithObjects:
             sSKCoreGetLocalisedString(@"Test_Run_Download"),
             sSKCoreGetLocalisedString(@"Test_Run_Upload"),
             sSKCoreGetLocalisedString(@"Test_Run_LatencyLoss"),
             sSKCoreGetLocalisedString(@"Test_Run_Jitter"),
             sSKCoreGetLocalisedString(@"Test_Run_All"),
             nil];
  }
  
  for (int j=0; j<[array count]; j++)
  {
    [action addButtonWithTitle:[array objectAtIndex:j]];
  }
  
  [action addButtonWithTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")];
  [action setCancelButtonIndex:[array count]];
  [action setTag:ACTION_RUN];
  [action setActionSheetStyle:UIActionSheetStyleDefault];
  [action showInView:self.view];
}

- (void)range
{
  UIActionSheet *action =
  [[UIActionSheet alloc] initWithTitle:nil
                              delegate:self
                     cancelButtonTitle:nil
                destructiveButtonTitle:nil
                     otherButtonTitles:nil];
  
  // One day results view
  if ([[SKAAppDelegate getAppDelegate] supportOneDayResultView]) {
    [action addButtonWithTitle:sSKCoreGetLocalisedString(@"time_period_1day")];
  }
  
  [action addButtonWithTitle:sSKCoreGetLocalisedString(@"time_period_1week")];
  [action addButtonWithTitle:sSKCoreGetLocalisedString(@"time_period_1month")];
  [action addButtonWithTitle:sSKCoreGetLocalisedString(@"time_period_3months")];
  [action addButtonWithTitle:sSKCoreGetLocalisedString(@"time_period_1year")];
  
  int cancelButtonIndex = (int)[action addButtonWithTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")];
  [action setCancelButtonIndex:cancelButtonIndex];
  
  [action setTag:ACTION_RANGE];
  [action setActionSheetStyle:UIActionSheetStyleDefault];
  [action showInView:self.view];
}

#pragma mark - UITableViewDataSource delegate methods

- (CGFloat)tableView:(UITableView *)inTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  int row = (int)indexPath.row;
  int section = (int)indexPath.section;
  
  if (section == 0 || section == 1)
  {
    return 48.0f;
  }
  else if (section == mSectionIndexForFooter) {
    return 60.0F;
  }
  else
  {
    if (row == 0)
    {
      return 48.0f;
    }
    else
    {
      //NSLog(@"HEIGHT : %f", [[dict objectForKey:@"HEIGHT"] floatValue]);
      
      // We need to dynamically calculate the height of the graph cell!
      // That is calculated as being the distance to the top of the table, plus the calculated
      // height of the table (adding-up all the heights for all sections).
      // https://stackoverflow.com/questions/6312821/dynamic-uitableview-height-in-uipopovercontroller-contentsizeforviewinpopover
     
      SKAGraphViewCell *cell = (SKAGraphViewCell*) [self tableView:inTableView cellForRowAtIndexPath:indexPath];
      
      CGFloat currentTotal = cell.tableView.frame.origin.y + 10.0; // 10 is some padding!
      // + cell.tableView.frame.size.height + 10; // Some border!
      
      //Need to total each section
      for (int i = 0; i < [cell.tableView numberOfSections]; i++)
      {
        CGRect sectionRect = [cell.tableView rectForSection:i];
        currentTotal += sectionRect.size.height;
      }
      //return cell.contentView.frame.size.height;
      return currentTotal;
    }
  }
}

- (void)setDateRange:(DATERANGE_1w1m3m1y)range
{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  [prefs setObject:[NSNumber numberWithInt:range] forKey:Prefs_DateRange];
  [prefs synchronize];
}

- (void)refreshGraphTableData
{
  dataForGraphs = [NSMutableArray new];

  // There are 4 graphs; grab the data for each of them.
  DATERANGE_1w1m3m1y dateRange = [self getDateRange];
  NSDate *fromDate = [SKAAppDelegate getStartDateForThisRange:dateRange];
  NSDate *toDate = [SKCore getToday];
 
  //int items = [self getSections];
 
  int resultsRows = [self getResultsRows];
  for (int j=0; j<resultsRows; j++)
  {
    NSMutableArray *array = [SKDatabase getNonAveragedTestData:fromDate ToDate:toDate TestDataType:(TestDataType)j WhereNetworkTypeEquals:[SKAAppDelegate getNetworkTypeString]];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:array forKey:@"DATA"];
    
    [dataForGraphs addObject:dict];
  }
}

- (DATERANGE_1w1m3m1y)getDateRange
{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  return [[prefs objectForKey:Prefs_DateRange] intValue];
}

- (NSString*)getDateRangeText
{
  switch ([self getDateRange]) {
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

- (TestDataType)getTestType:(int)section
{
  switch (section)
  {
    case 2:
      return DOWNLOAD_DATA;
      break;
      
    case 3:
      return UPLOAD_DATA;
      break;
      
    case 4:
      return LATENCY_DATA;
      break;
      
    case 5:
      return LOSS_DATA;
      break;
      
    default:
      return JITTER_DATA;
  }
}

- (NSString*)getTestString:(int)section
{
  switch (section)
  {
    case 2:
      return @"downstream_mt";
      break;
      
    case 3:
      return @"upstream_mt";
      break;
      
    case 4:
      return @"latency";
      break;
      
    case 5:
      return @"packetloss";
      break;
      
    default:
      return @"jitter";
      break;
  }
}

- (NSString*)getTestCellText:(int)section
{
  switch (section)
  {
    case 2:
      return sSKCoreGetLocalisedString(@"Test_Download");
      break;
      
    case 3:
      return sSKCoreGetLocalisedString(@"Test_Upload");
      break;
      
    case 4:
      return sSKCoreGetLocalisedString(@"Test_Latency");
      break;
      
    case 5:
      return sSKCoreGetLocalisedString(@"Test_Packetloss");
      break;
      
    default:
      return sSKCoreGetLocalisedString(@"Test_Jitter");
      break;
  }
}

- (NSString*)getTestDetailText:(int)section
{
  double result = 0;
  NSString *str = nil;
  
  int retCount = 0;
  
  SK_ASSERT(section != mSectionIndexForFooter);
  
  switch (section)
  {
    case 2:
      result = [SKAAppDelegate getAverageTestData:[self getDateRange] testDataType:DOWNLOAD_DATA RetCount:&retCount];
      str = [SKGlobalMethods bitrateMbps1024BasedToString:result];
      break;
      
    case 3:
      result = [SKAAppDelegate getAverageTestData:[self getDateRange] testDataType:UPLOAD_DATA RetCount:&retCount];
      str = [SKGlobalMethods bitrateMbps1024BasedToString:result];
      break;
      
    case 4:
      result = [SKAAppDelegate getAverageTestData:[self getDateRange] testDataType:LATENCY_DATA RetCount:&retCount];
      str = [NSString stringWithFormat:@"%@ ms", [SKGlobalMethods format2DecimalPlaces:result]];
      break;
      
    case 5:
      result = [SKAAppDelegate getAverageTestData:[self getDateRange] testDataType:LOSS_DATA RetCount:&retCount];
      str = [NSString stringWithFormat:@"%d %%", (int)result];
      break;
      
    default:
      result = [SKAAppDelegate getAverageTestData:[self getDateRange] testDataType:JITTER_DATA RetCount:&retCount];
      str = [NSString stringWithFormat:@"%@ ms", [SKGlobalMethods format2DecimalPlaces:result]];
      break;
  }
  
  if (retCount == 0) {
    return @"";
  }
  
  return str;
}

#pragma mark - Graph View Delegate methods

- (void)next:(TestDataType)type
{
  
}

- (void)back:(TestDataType)type
{
  
}

#pragma mark - UITableViewDelegate delegate methods

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//  return 0.01f;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//  return [UIView new];
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  int result = mSections;
  
  if (mSectionIndexForFooter != -1) {
    return result + 1;
  }
  
  return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0) {
    // SKARunTestsButtonCell
    // For some apps, we have a CONTINUOUS TESTING button!
    SKAAppDelegate *appDelegate = [SKAAppDelegate getAppDelegate];
    if ([appDelegate supportContinuousTesting]) {
      return 2;
    }
    
    return 1;
  }
  
  if (section == mSectionIndexForFooter) {
    return 1;
  }
  
  if (mySections[section]) {
    return 2;
  } else {
    return 1;
  }
}

//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//  return [NSString stringWithFormat:@"Section %d", (int)section];
//}

- (UITableViewCell *)tableView:(UITableView *)inTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  int row = (int)indexPath.row;
  int section = (int)indexPath.section;
  
  if (section == 0)
  {
    static NSString *CellIdentifier = @"SKARunTestsButtonCell";
    SKARunTestsButtonCell *cell = (SKARunTestsButtonCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[SKARunTestsButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setDelegate:self];
    //[cell.contentView setBackgroundColor:[UIColor darkGrayColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    BOOL continuousTesting = (indexPath.row == 1);
#ifdef DEBUG
    if (continuousTesting) {
      SKAAppDelegate *appDelegate = [SKAAppDelegate getAppDelegate];
      SK_ASSERT ([appDelegate supportContinuousTesting]);
    }
#endif // DEBUG
    [cell initialize:[self getDateRangeText] ContinuousTesting:continuousTesting];
    
    return cell;
  }
  else if (section == 1)
  {
    static NSString *CellIdentifier = @"SKAMainResultControllerSection1";
    
    SKAMainResultControllerSection1Cell *cell = (SKAMainResultControllerSection1Cell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[SKAMainResultControllerSection1Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.imageView.image = [UIImage imageNamed:@"CALENDAR"];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    cell.textLabel.text = [self getDateRangeText];
    
    return cell;
  } else if (section == mSectionIndexForFooter) {
    static NSString *CellIdentifier = @"SKAFooterCell";
    SKAFooterCell *cell = (SKAFooterCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = (SKAFooterCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
  }
  else
  {
    if (row == 0)
    {
      static NSString *CellIdentifier = @"SKAMainResultTestHeaderCell";
      SKAMainResultTestHeaderCell *cell = (SKAMainResultTestHeaderCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      if (cell == nil) {
        cell = [[SKAMainResultTestHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      }
      
      [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
      
      BOOL isOpen = mySections[indexPath.section];
      
      cell.imageView.image = isOpen ? [UIImage imageNamed:@"DOWN_ARROW"] : [UIImage imageNamed:@"OPEN_ARROW"];
      NSString *labelText = [self getTestCellText:section];
      NSString *detailText = [self getTestDetailText:section];
      [cell setLabelText:labelText DetailText:detailText];
      
      return cell;
    }

    else
    {
      static NSString *CellIdentifier = @"GraphViewCell";
      SKAGraphViewCell *cell = (SKAGraphViewCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      if (cell == nil) {
        cell = [[SKAGraphViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      }
      
      cell.lblDate.text = sSKCoreGetLocalisedString(@"Storyboard_GraphViewCell_DataTimeLabel");
      cell.lblLocation.text = sSKCoreGetLocalisedString(@"Storyboard_GraphViewCell_LocationLabel");
      cell.lblResults.text = sSKCoreGetLocalisedString(@"Storyboard_GraphViewCell_ResultLabel");
      
      [cell setDelegate:self];
      [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
      [cell initialize:[self getTestString:section] type:[self getTestType:section] range:[self getDateRange]];
      
      NSDictionary *dict = [dataForGraphs objectAtIndex:section-2];
      NSArray *data = [dict objectForKey:@"DATA"];
      
      [cell refreshData:data];
      
      return cell;
    }
  }
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [self refreshGraphsAndTableData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  int row = (int)indexPath.row;
  int section = (int)indexPath.section;
  
  if (section == 0)
  {
    return;
  }
  
  if (section == mSectionIndexForFooter) {
    return;
  }
  
  if (section == 1)
  {
    [self range];
    return;
  }
  
  if (row == 0)
  {
		mySections[indexPath.section] = !mySections[indexPath.section];
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:indexPath.section];
  
    // If you just do this on its own on iPad, then the graph simply won't appear at the correct
    // size if the device is in landscape mode!
		//   [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
    // The only thing which seemed to work, was to use a completion block to reload the
    // data post completion of the animation!
    // http://stackoverflow.com/questions/2802146/callback-for-uitableview-animations
   
    [self.tableView beginUpdates];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
    [CATransaction setCompletionBlock:^{
      NSLog(@"Did the update!");
      [self.tableView reloadData];
    }];
    [self.tableView endUpdates];
	}
}

#pragma mark - Configuration

// Each time the app starts, download the latest config.
// The next time the app initializes, it will use the new config

- (void)checkConfig
{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSString *server = [prefs objectForKey:Prefs_TargetServer];
  
  NSLog(@"server=%@", server);
  if (server == nil) {
#ifdef DEBUG
    NSLog(@"DEBUG: server member currently nil - leaving checkConfig - has the app just been installed?");
#endif // DEBUG
    return;
  }
  
  //NSLog(@"Config_Url=%@", Config_Url);
  NSString *strUrl = [NSString stringWithFormat:@"%@%@", server, Config_Url];
  //NSLog(@"strUrl=%@", strUrl);
  
  NSURL *url = [NSURL URLWithString:strUrl];
  
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setURL:url];
  [request setHTTPMethod:@"GET"];
  [request setTimeoutInterval:20];
  
  NSString *enterpriseId = [[SKAAppDelegate getAppDelegate] getEnterpriseId];
  [request setValue:enterpriseId forHTTPHeaderField:@"X-Enterprise-ID"];
  
  NSOperationQueue *idQueue = [[NSOperationQueue alloc] init];
  [idQueue setName:@"com.samknows.schedulequeue"];
  
  [NSURLConnection
   sendAsynchronousRequest:request
   queue:idQueue completionHandler:^(NSURLResponse *response,
                                     NSData *data,
                                     NSError *error)
   {
     if (nil != error)
     {
       NSLog(@"Error fetching XML Config : %@", [error localizedDescription]);
       return;
     }
     
     if (nil == response)
     {
       NSLog(@"Error fetching XML Config : nil response");
     }
     
     NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
     
     if (httpResponse.statusCode == 200)
     {
       if (nil != data)
       {
         NSString *xml = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         if (nil != xml)
         {
           if ([xml length] > 0)
           {
             NSString *filePath = [SKAAppDelegate schedulePath];
             
             //NSLog(@"%@", xml);
             
             NSError *error;
             BOOL res = [xml writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
             
             if (!res)
             {
               NSLog(@"Error Saving Schedule XML");
             }
             else
             {
               //NSLog(@"XML saved");
             }
           }
         }
       }
     }
   }];
}

#pragma mark - dealloc


@end
