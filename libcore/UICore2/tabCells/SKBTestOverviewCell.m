//
//  SKBTestOverviewCell.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBTestOverviewCell.h"
#import "SKBTestResultValue.h"
#import "SKBHistoryViewMgr.h"
#import "SKTestResults.h"

@implementation SKBTestOverviewCell

-(void)setResultDownload:(SKBTestResultValue*)down_ upload:(SKBTestResultValue*)up_ latency:(SKBTestResultValue*)lat_ loss:(SKBTestResultValue*)loss_ jitter:(SKBTestResultValue*)jitter_
{
  self.aiActivity.hidden = YES;
  
  if (self.lDownloadLabel != nil)
  {
    self.lDownloadLabel.hidden = NO;
    self.lUploadLabel.hidden = NO;
    self.lMbpsLabel4Download.hidden = NO;
    self.lMbpsLabel4Upload.hidden = NO;
    self.lLatencyLabel.hidden = NO;
    self.lLossLabel.hidden = NO;
    self.lDateOfTest.hidden = NO;
    self.lTimeOfTest.hidden = NO;
    self.lResultDownload.hidden = NO;
    self.lResultUpload.hidden = NO;
    self.lResultLatency.hidden = NO;
    self.lResultLoss.hidden = NO;
    self.lResultJitter.hidden = NO;
    self.ivNetworkType.hidden = NO;
    self.ivArrowDownload.hidden = NO;
    self.ivArrowUpload.hidden = NO;
  }
  else
  {
    [self layoutCellActive];
  }
  
  self.cellResultDownload = down_;
  self.cellResultUpload = up_;
  self.cellResultLatency = lat_;
  self.cellResultLoss = loss_;
  self.cellResultJitter = jitter_;
  
  [self updateDisplay];
}

-(void)updateDisplay
{
  self.testDateTime = [NSDate date];
  
  [self.aiActivity stopAnimating];
  
  if (self.cellResultDownload != nil)
  {
    self.lResultDownload.text = self.cellResultDownload.value;
//#ifdef DEBUG
//    self.lResultDownload.text = @"19999";
//#endif // DEBUG
    self.lResultUpload.text = self.cellResultUpload.value;
//#ifdef DEBUG
//    self.lResultUpload.text = @"19999";
//#endif // DEBUG
    self.lResultLatency.text = self.cellResultLatency.value;
    self.lResultLoss.text = self.cellResultLoss.value;
    self.lResultJitter.text = self.cellResultJitter.value;
    
    if ([self.cellResultDownload.value isEqualToString:@"r"])
    {
      [self.aiDownload startAnimating];
      self.lResultDownload.alpha = 0;
    }
    else
    {
      [self.aiDownload stopAnimating];
      self.lResultDownload.alpha = 1;
    }
    
    if ([self.cellResultUpload.value isEqualToString:@"r"])
    {
      [self.aiUpload startAnimating];
      self.lResultUpload.alpha = 0;
    }
    else
    {
      [self.aiUpload stopAnimating];
      self.lResultUpload.alpha = 1;
    }
    
    if ([self.cellResultLatency.value isEqualToString:@"r"])
    {
      [self.aiLatency startAnimating];
      self.lResultLatency.alpha = 0;
      [self.aiLoss startAnimating];
      self.lResultLoss.alpha = 0;
      [self.aiJitter startAnimating];
      self.lResultJitter.alpha = 0;
    }
    else
    {
      [self.aiLatency stopAnimating];
      self.lResultLatency.alpha = 1;
      [self.aiLoss stopAnimating];
      self.lResultLoss.alpha = 1;
      [self.aiJitter stopAnimating];
      self.lResultJitter.alpha = 1;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    self.lDateOfTest.text = [dateFormatter stringFromDate:self.testDateTime];
    
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    self.lTimeOfTest.text = [dateFormatter stringFromDate:self.testDateTime];
  }
}

CGRect MakeScaledRect(float GUI_MULTIPLIER, CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
  CGRect rect;
  rect.origin.x = x * GUI_MULTIPLIER;
  rect.origin.y = y * GUI_MULTIPLIER;
  rect.size.width = width * GUI_MULTIPLIER;
  rect.size.height = height * GUI_MULTIPLIER;
  return rect;
}

-(void)layoutCellActive
{
  if (self.vBackground != nil) return;
  
  float GUI_MULTIPLIER = [SKAppColourScheme sGet_GUI_MULTIPLIER];
  
  UIFont* labelFontLight = [SKAppColourScheme sGetFontWithName:@"Roboto-Regular" size:GUI_MULTIPLIER * 12];
  UIFont* labelFontThin = [SKAppColourScheme sGetFontWithName:@"Roboto-Regular" size:GUI_MULTIPLIER * 12];
  UIFont* resultFont1 = [SKAppColourScheme sGetFontWithName:@"DINCondensed-Bold" size:GUI_MULTIPLIER * 53];
  UIFont* resultFont2 = [SKAppColourScheme sGetFontWithName:@"DINCondensed-Bold" size:GUI_MULTIPLIER * 17];
  UIFont* dateTimeFont = labelFontLight;
 
  BOOL newLayout = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsAlternativeResultsPanelLayoutRequired];
  if (newLayout) {
    resultFont2 = labelFontLight;
    dateTimeFont = [SKAppColourScheme sGetFontWithName:@"Roboto-Regular" size:GUI_MULTIPLIER * 10];
  }
  
  self.backgroundColor = [UIColor clearColor];
  self.vBackground = [[UIView alloc] initWithFrame:MakeScaledRect(GUI_MULTIPLIER, 5,3, 310, 90)];
  self.vBackground.backgroundColor = [SKAppColourScheme sGetPanelColourBackground];
  self.vBackground.layer.cornerRadius = GUI_MULTIPLIER * 3;
  self.vBackground.layer.borderWidth = 0.5;
  self.vBackground.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
  [self.contentView addSubview:self.vBackground];
  
  //
  // Determine the item positions.
  // Depending on the app configuration, the positions might be different from app to app.
  // TODO: for some clients, the strings are of lengths such that we require very different layouts!
  //
  
  CGRect ivArrowDownloadFrame = MakeScaledRect(GUI_MULTIPLIER,      9,  12,  17,  17);
  CGRect lDownloadLabelFrame = MakeScaledRect( GUI_MULTIPLIER,     29,   9, 103,  21);
  CGRect lResultDownloadFrame = MakeScaledRect(GUI_MULTIPLIER,     11,  31,  80,  55);
  CGRect lMbpsLabel4DownloadFrame = MakeScaledRect(GUI_MULTIPLIER, 11,  69,  59,  21);
  
  CGRect ivArrowUploadFrame = MakeScaledRect(GUI_MULTIPLIER,      103,  11,  17,  17);
  CGRect lUploadLabelFrame = MakeScaledRect(GUI_MULTIPLIER,       121,   9,  82,  21);
  CGRect lResultUploadFrame = MakeScaledRect(GUI_MULTIPLIER,      105,  31,  82,  55);
  CGRect lMbpsLabel4UploadFrame = MakeScaledRect(GUI_MULTIPLIER,  105,  69,  46,  21);
  
  CGRect lLatencyLabelFrame = MakeScaledRect(GUI_MULTIPLIER,       191,  9,  130,  21);
    CGRect lLossLabelFrame = MakeScaledRect(GUI_MULTIPLIER,  247,  9,  65,  21);
    CGRect lJitterLabelFrame = MakeScaledRect(GUI_MULTIPLIER,  297,  9,  65,  21);
  CGRect lDateOfTestFrame = MakeScaledRect(GUI_MULTIPLIER,  191,  55,  121,  21);
  CGRect lTimeOfTestFrame = MakeScaledRect(GUI_MULTIPLIER,  191,  68,  121,  21);
  CGRect lResultLatencyFrame = MakeScaledRect(GUI_MULTIPLIER,  191,  27,  65,  17);
    CGRect lResultLossFrame = MakeScaledRect(GUI_MULTIPLIER,  247,  27,  65,  17);
    CGRect lResultJitterFrame = MakeScaledRect(GUI_MULTIPLIER,  297,  27,  65,  17);
  CGRect ivNetworkTypeFrame = MakeScaledRect(GUI_MULTIPLIER,  280,  60,  25,  25);
  
  // Activity indicator frames... (left)
  CGRect laiDownloadFrame = lResultDownloadFrame; // CGRectMake(self.lResultDownload.frame.origin.x, self.lDownloadLabel.frame.origin.y + self.lDownloadLabel.frame.size.height, self.lResultDownload.frame.size.width, self.lMbpsLabel4Download.frame.origin.y - self.lDownloadLabel.frame.origin.y - self.lDownloadLabel.frame.size.height);
  CGRect laiUploadFrame = lResultUploadFrame; // CGRectMake(self.lResultUpload.frame.origin.x, self.lUploadLabel.frame.origin.y + self.lUploadLabel.frame.size.height, self.lResultUpload.frame.size.width, self.lMbpsLabel4Upload.frame.origin.y - self.lUploadLabel.frame.origin.y - self.lUploadLabel.frame.size.height);
  
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsJitterSupported]) {
    //Change the layout of the right side, to make space for the Jitter Labels!
    lLatencyLabelFrame = MakeScaledRect(GUI_MULTIPLIER,  180,  9,  45,  21);
    lDateOfTestFrame = MakeScaledRect(GUI_MULTIPLIER,  180,  55,  121,  21);
    lTimeOfTestFrame = MakeScaledRect(GUI_MULTIPLIER,  180,  68,  121,  21);
    lLossLabelFrame = MakeScaledRect(GUI_MULTIPLIER,  230,  9,  35,  21);
    lJitterLabelFrame = MakeScaledRect(GUI_MULTIPLIER,  270,  9,  45,  21);
    lResultLatencyFrame = MakeScaledRect(GUI_MULTIPLIER,  180,  27,  45,  21);
    lResultLossFrame = MakeScaledRect(GUI_MULTIPLIER,  230,  27,  45,  21);
    lResultJitterFrame = MakeScaledRect(GUI_MULTIPLIER,  270,  27,  45,  21);
  }
  
  if (newLayout)
  {
    lLatencyLabelFrame = MakeScaledRect(GUI_MULTIPLIER,  180,  10,  80,  21);
    lLossLabelFrame = MakeScaledRect(GUI_MULTIPLIER,     180,  30,  80,  21);
    lJitterLabelFrame = MakeScaledRect(GUI_MULTIPLIER,   180,  50,  80,  21);
    lDateOfTestFrame = MakeScaledRect(GUI_MULTIPLIER,    180,  70,  50,  21);
    
    lResultLatencyFrame = MakeScaledRect(GUI_MULTIPLIER, 265,  10,  40,  21);
    lResultLossFrame = MakeScaledRect(GUI_MULTIPLIER,    265,  30,  40,  21);
    lResultJitterFrame = MakeScaledRect(GUI_MULTIPLIER,  265,  50,  40,  21);
    lTimeOfTestFrame = MakeScaledRect(GUI_MULTIPLIER,    235,  70,  50,  21);
    
    ivNetworkTypeFrame = MakeScaledRect(GUI_MULTIPLIER,  293,  73,  17,  17);
  }
 
  // Activity indicator frames... (right)
  CGRect laiLatencyFrame = lResultLatencyFrame;
  CGRect laiLossFrame = lResultLossFrame;
  CGRect laiJitterFrame = lResultJitterFrame;
  
  //
  // Construct the items at the required positions...
  //
  
  self.lDownloadLabel = [[UILabel alloc] initWithFrame:lDownloadLabelFrame];
  self.lDownloadLabel.text = sSKCoreGetLocalisedString(@"Test_Download");
  self.lDownloadLabel.textColor = [UIColor whiteColor];
  self.lDownloadLabel.font = labelFontLight;
  self.lDownloadLabel.adjustsFontSizeToFitWidth = YES;
  self.lDownloadLabel.minimumScaleFactor = 0.1; // minimumFontSize = 6.0 is deprecated from iOS 6
  
  [self.contentView addSubview:self.lDownloadLabel];
  
  self.lUploadLabel = [[UILabel alloc] initWithFrame:lUploadLabelFrame];
  self.lUploadLabel.text = sSKCoreGetLocalisedString(@"Test_Upload");
  self.lUploadLabel.textColor = [UIColor whiteColor];
  self.lUploadLabel.font = labelFontLight;
  self.lUploadLabel.adjustsFontSizeToFitWidth = YES;
  self.lUploadLabel.minimumScaleFactor = 0.1; // minimumFontSize = 6.0 is deprecated from iOS 6
  [self.contentView addSubview:self.lUploadLabel];
  
  self.lMbpsLabel4Download = [[UILabel alloc] initWithFrame:lMbpsLabel4DownloadFrame];
  self.lMbpsLabel4Download.text = sSKCoreGetLocalisedString(@"Graph_Suffix_Mbps");
  self.lMbpsLabel4Download.textColor = [UIColor whiteColor];
  self.lMbpsLabel4Download.font = labelFontThin;
  self.lMbpsLabel4Download.adjustsFontSizeToFitWidth = YES;
  self.lMbpsLabel4Download.minimumScaleFactor = 0.1; // minimumFontSize = 6.0 is deprecated from iOS 6
  [self.contentView addSubview:self.lMbpsLabel4Download];
  
  self.lMbpsLabel4Upload = [[UILabel alloc] initWithFrame:lMbpsLabel4UploadFrame];
  self.lMbpsLabel4Upload.text = sSKCoreGetLocalisedString(@"Graph_Suffix_Mbps");
  self.lMbpsLabel4Upload.textColor = [UIColor whiteColor];
  self.lMbpsLabel4Upload.font = labelFontThin;
  self.lMbpsLabel4Upload.adjustsFontSizeToFitWidth = YES;
  self.lMbpsLabel4Upload.minimumScaleFactor = 0.1; // minimumFontSize = 6.0 is deprecated from iOS 6
  [self.contentView addSubview:self.lMbpsLabel4Upload];
 
  // This must be wide enough to display "Network Latency" ...!
  self.lLatencyLabel = [[UILabel alloc] initWithFrame:lLatencyLabelFrame];
  self.lLatencyLabel.text = sSKCoreGetLocalisedString(@"Test_Latency");
  self.lLatencyLabel.textColor = [UIColor whiteColor];
  self.lLatencyLabel.font = labelFontLight;
  self.lLatencyLabel.adjustsFontSizeToFitWidth = YES;
  self.lLatencyLabel.minimumScaleFactor = 0.1; // minimumFontSize = 6.0 is deprecated from iOS 6
  self.lLatencyLabel.textAlignment = NSTextAlignmentLeft;
  [self.contentView addSubview:self.lLatencyLabel];
  
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsLossSupported])
  {
    self.lLossLabel = [[UILabel alloc] initWithFrame:lLossLabelFrame];
    self.lLossLabel.text = sSKCoreGetLocalisedString(@"Test_Loss");
    self.lLossLabel.textColor = [UIColor whiteColor];
    self.lLossLabel.font = labelFontLight;
    self.lLossLabel.adjustsFontSizeToFitWidth = YES;
    self.lLossLabel.minimumScaleFactor = 0.1; // minimumFontSize = 6.0 is deprecated from iOS 6
    self.lLossLabel.textAlignment = NSTextAlignmentLeft;
    // Comment this out, if you want to allow the number of lines to be > 1!
    // self.lLossLabel.numberOfLines = 0;
    [self.contentView addSubview:self.lLossLabel];
  }
  
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsJitterSupported])
  {
    self.lJitterLabel = [[UILabel alloc] initWithFrame:lJitterLabelFrame];
    self.lJitterLabel.text = sSKCoreGetLocalisedString(@"Test_Jitter");
    self.lJitterLabel.textColor = [UIColor whiteColor];
    self.lJitterLabel.font = labelFontLight;
    self.lJitterLabel.adjustsFontSizeToFitWidth = YES;
    self.lJitterLabel.minimumScaleFactor = 0.1; // minimumFontSize = 6.0 is deprecated from iOS 6
    self.lJitterLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.lJitterLabel];
  }
  
  self.lDateOfTest = [[UILabel alloc] initWithFrame:lDateOfTestFrame];
  self.lDateOfTest.text = @"-";
  self.lDateOfTest.textColor = [UIColor whiteColor];
  self.lDateOfTest.font = dateTimeFont;
  self.lDateOfTest.textAlignment = NSTextAlignmentLeft;
  self.lDateOfTest.adjustsFontSizeToFitWidth = YES;
  self.lDateOfTest.minimumScaleFactor = 0.1; // minimumFontSize = 6.0 is deprecated from iOS 6
  [self.contentView addSubview:self.lDateOfTest];
  
  self.lTimeOfTest = [[UILabel alloc] initWithFrame:lTimeOfTestFrame];
  self.lTimeOfTest.text = @"-";
  self.lTimeOfTest.textColor = [UIColor whiteColor];
  self.lTimeOfTest.font = dateTimeFont;
  self.lTimeOfTest.adjustsFontSizeToFitWidth = YES;
  self.lTimeOfTest.minimumScaleFactor = 0.1; // minimumFontSize = 6.0 is deprecated from iOS 6
  self.lTimeOfTest.textAlignment = NSTextAlignmentLeft;
  [self.contentView addSubview:self.lTimeOfTest];
  
  self.lResultDownload = [[UILabel alloc] initWithFrame:lResultDownloadFrame];
  self.lResultDownload.text = @"-";
  self.lResultDownload.textColor = [SKAppColourScheme sGetResultColourText];
  self.lResultDownload.font = resultFont1;
  self.lResultDownload.adjustsFontSizeToFitWidth = YES;
  self.lResultDownload.minimumScaleFactor = 0.1; // minimumFontSize = 6.0 is deprecated from iOS 6
  [self.contentView addSubview:self.lResultDownload];
  
  self.lResultUpload = [[UILabel alloc] initWithFrame:lResultUploadFrame];
  self.lResultUpload.text = @"-";
  self.lResultUpload.textColor = [SKAppColourScheme sGetResultColourText];
  self.lResultUpload.font = resultFont1;
  self.lResultUpload.adjustsFontSizeToFitWidth = YES;
  self.lResultUpload.minimumScaleFactor = 0.1; // minimumFontSize = 6.0 is deprecated from iOS 6
  [self.contentView addSubview:self.lResultUpload];
  
  self.lResultLatency = [[UILabel alloc] initWithFrame:lResultLatencyFrame];
  self.lResultLatency.text = @"-";
  self.lResultLatency.textColor = [SKAppColourScheme sGetResultColourText];
  self.lResultLatency.textAlignment = NSTextAlignmentLeft;
  self.lResultLatency.font = resultFont2;
  self.lResultLatency.adjustsFontSizeToFitWidth = YES;
  self.lResultLatency.minimumScaleFactor = 0.1; // minimumFontSize = 6.0 is deprecated from iOS 6
  [self.contentView addSubview:self.lResultLatency];
  
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsLossSupported]) {
    self.lResultLoss = [[UILabel alloc] initWithFrame:lResultLossFrame];
    self.lResultLoss.text = @"-";
    self.lResultLoss.textColor = [SKAppColourScheme sGetResultColourText];
    self.lResultLoss.textAlignment = NSTextAlignmentLeft;
    self.lResultLoss.font = resultFont2;
    self.lResultLoss.adjustsFontSizeToFitWidth = YES;
    self.lResultLoss.minimumScaleFactor = 0.1; // minimumFontSize = 6.0 is deprecated from iOS 6
    [self.contentView addSubview:self.lResultLoss];
  }
  
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsJitterSupported])
  {
    self.lResultJitter = [[UILabel alloc] initWithFrame:lResultJitterFrame];
    self.lResultJitter.text = @"-";
    self.lResultJitter.textColor = [SKAppColourScheme sGetResultColourText];
    self.lResultJitter.textAlignment = NSTextAlignmentLeft;
    self.lResultJitter.font = resultFont2;
    self.lResultJitter.adjustsFontSizeToFitWidth = YES;
    self.lResultJitter.minimumScaleFactor = 0.1; // minimumFontSize = 6.0 is deprecated from iOS 6
    [self.contentView addSubview:self.lResultJitter];
  }
  
  self.ivNetworkType = [[UIImageView alloc] initWithFrame:ivNetworkTypeFrame];
  self.ivNetworkType.contentMode = UIViewContentModeScaleAspectFit;
  [self.contentView addSubview:self.ivNetworkType];
  
  self.ivArrowDownload = [[UIImageView alloc] initWithFrame:ivArrowDownloadFrame];
  self.ivArrowDownload.image = [UIImage imageNamed:@"ga"];
  [self.contentView addSubview:self.ivArrowDownload];
  
  self.ivArrowUpload = [[UIImageView alloc] initWithFrame:ivArrowUploadFrame];
  self.ivArrowUpload.image = [UIImage imageNamed:@"ra"];
  [self.contentView addSubview:self.ivArrowUpload];

  //
  // Finally, construct the activity indicators...
  //
  self.aiDownload = [[CActivityBlinking alloc] initWithFrame:laiDownloadFrame];
  [self.contentView addSubview:self.aiDownload];
  
  self.aiUpload = [[CActivityBlinking alloc] initWithFrame:laiUploadFrame];
  [self.contentView addSubview:self.aiUpload];
  
  self.aiLatency = [[CActivityBlinking alloc] initWithFrame:laiLatencyFrame];
  [self.contentView addSubview:self.aiLatency];
  
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsLossSupported]) {
    self.aiLoss = [[CActivityBlinking alloc] initWithFrame:laiLossFrame];
    [self.contentView addSubview:self.aiLoss];
  }
  
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsJitterSupported]) {
    self.aiJitter = [[CActivityBlinking alloc] initWithFrame:laiJitterFrame];
    [self.contentView addSubview:self.aiJitter];
  }
  
//  if (newLayout) {
//    self.lTimeOfTest.adjustsFontSizeToFitWidth = NO;
//    self.lDateOfTest.adjustsFontSizeToFitWidth = NO;
//  }
}

-(void)initCell
{
  self.backgroundColor = [UIColor clearColor];
  
  if (self.lDownloadLabel == nil) {
    [self layoutCellActive];
  }

}

-(void)setTest:(SKATestResults *)testResult_
{
  testResult = testResult_;
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  
  [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
  [dateFormatter setDateStyle:NSDateFormatterShortStyle];
  self.lDateOfTest.text = [dateFormatter stringFromDate:testResult.testDateTime];
  
  [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
  [dateFormatter setDateStyle:NSDateFormatterNoStyle];
  self.lTimeOfTest.text = [dateFormatter stringFromDate:testResult.testDateTime];
  
  if (testResult_.downloadSpeed1000Based < 0)
    self.lResultDownload.text = @"-";
  else {
    NSString *displayValue = [SKBTestOverviewCell sGet3DigitsNumber:testResult_.downloadSpeed1000Based];
    self.lResultDownload.text = displayValue;
  }
  
  if (testResult.uploadSpeed1000Based < 0)
    self.lResultUpload.text = @"-";
  else {
    NSString *displayValue = [SKBTestOverviewCell sGet3DigitsNumber:testResult_.uploadSpeed1000Based];
    self.lResultUpload.text = displayValue;
  }
  
  if (testResult.latency < 0)
    self.lResultLatency.text = @"-";
  else
    self.lResultLatency.text = [NSString stringWithFormat:@"%.0f ms", testResult.latency];
  
  if (testResult.loss < 0)
    self.lResultLoss.text = @"-";
  else
    self.lResultLoss.text = [NSString stringWithFormat:@"%.0f %%", testResult.loss];
  
  if (testResult.jitter < 0)
    self.lResultJitter.text = @"-";
  else
    self.lResultJitter.text = [NSString stringWithFormat:@"%.0f ms", testResult.jitter];
  
  if ([testResult_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_NETWORK_TYPE] isEqualToString:@"mobile"]) {
    self.ivNetworkType.image  = [UIImage imageNamed:@"sgsm.png"];
  } else {
    self.ivNetworkType.image = [UIImage imageNamed:@"swifi.png"];
  }
  
  y = 100;
  
  return;
}

-(UIView*)getView
{
  return self.contentView;
}

+(NSString*)sGet3DigitsNumber:(float)number_
{
  return [SKGlobalMethods sGet3DigitsNumber:number_];
}

@end
