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

@interface SKBTestOverviewCell()
@property (weak, nonatomic) IBOutlet  UIView* vBackground;

@property (weak, nonatomic) IBOutlet  UILabel *lDownloadLabel;
@property (weak, nonatomic) IBOutlet  UILabel *lUploadLabel;

@property (weak, nonatomic) IBOutlet  UILabel *lMbpsLabel4Download;
@property (weak, nonatomic) IBOutlet  UILabel *lMbpsLabel4Upload;
@property (weak, nonatomic) IBOutlet  UILabel *lLatencyLabel;
@property (weak, nonatomic) IBOutlet  UILabel *lLossLabel;
@property (weak, nonatomic) IBOutlet  UILabel *lJitterLabel;

@property (weak, nonatomic) IBOutlet  UILabel *lDateOfTest;
@property (weak, nonatomic) IBOutlet  UILabel *lTimeOfTest;

@property (weak, nonatomic) IBOutlet  UILabel *lResultDownload;
@property (weak, nonatomic) IBOutlet  UILabel *lResultUpload;
@property (weak, nonatomic) IBOutlet  UILabel *lResultLatency;
@property (weak, nonatomic) IBOutlet  UILabel *lResultLoss;
@property (weak, nonatomic) IBOutlet  UILabel *lResultJitter;

@property (weak, nonatomic) IBOutlet  UIImageView *ivArrowDownload;
@property (weak, nonatomic) IBOutlet  UIImageView *ivArrowUpload;

@property (weak, nonatomic) IBOutlet  CActivityBlinking* aiDownload;
@property (weak, nonatomic) IBOutlet  CActivityBlinking* aiUpload;
@property (weak, nonatomic) IBOutlet  CActivityBlinking* aiLatency;
@property (weak, nonatomic) IBOutlet  CActivityBlinking* aiLoss;
@property (weak, nonatomic) IBOutlet  CActivityBlinking* aiJitter;
@end

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
    self.lResultUpload.text = self.cellResultUpload.value;
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

-(void)layoutCellActive
{
  float GUI_MULTIPLIER = [SKAppColourScheme sGet_GUI_MULTIPLIER];
  
  UIFont* labelFontLight = [UIFont fontWithName:@"Roboto-Light" size:GUI_MULTIPLIER * 12];
  UIFont* labelFontThin = [UIFont fontWithName:@"Roboto-Thin" size:GUI_MULTIPLIER * 12];
  UIFont* resultFont1 = [UIFont fontWithName:@"DINCondensed-Bold" size:GUI_MULTIPLIER * 53];
  UIFont* resultFont2 = [UIFont fontWithName:@"DINCondensed-Bold" size:GUI_MULTIPLIER * 17];
  
  self.vBackground.backgroundColor = [SKAppColourScheme sGetPanelColourBackground];
  self.vBackground.layer.cornerRadius = GUI_MULTIPLIER * 3;
  self.vBackground.layer.borderWidth = 0.5;
  self.vBackground.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
  
  self.lDownloadLabel.text = sSKCoreGetLocalisedString(@"Test_Download");
  self.lDownloadLabel.textColor = [UIColor whiteColor];
  self.lDownloadLabel.font = labelFontLight;
  
  self.lUploadLabel.text = sSKCoreGetLocalisedString(@"Test_Upload");
  self.lUploadLabel.textColor = [UIColor whiteColor];
  self.lUploadLabel.font = labelFontLight;
  
  //self.lMbpsLabel4Download = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 15, GUI_MULTIPLIER * 69, GUI_MULTIPLIER * 59, GUI_MULTIPLIER * 21)];
  self.lMbpsLabel4Download.text = sSKCoreGetLocalisedString(@"Graph_Suffix_Mbps");
  self.lMbpsLabel4Download.textColor = [UIColor whiteColor];
  self.lMbpsLabel4Download.font = labelFontThin;
  
  //self.lMbpsLabel4Upload = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 105, GUI_MULTIPLIER * 69, GUI_MULTIPLIER * 46, GUI_MULTIPLIER * 21)];
  self.lMbpsLabel4Upload.text = sSKCoreGetLocalisedString(@"Graph_Suffix_Mbps");
  self.lMbpsLabel4Upload.textColor = [UIColor whiteColor];
  self.lMbpsLabel4Upload.font = labelFontThin;
  
  //self.lLatencyLabel = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 191, GUI_MULTIPLIER * 9, GUI_MULTIPLIER * 65, GUI_MULTIPLIER * 21)];
  self.lLatencyLabel.text = sSKCoreGetLocalisedString(@"Test_Latency");
  self.lLatencyLabel.textColor = [UIColor whiteColor];
  self.lLatencyLabel.font = labelFontLight;
  self.lLatencyLabel.textAlignment = UITextAlignmentCenter;
  
  if ([[SKAAppDelegate getAppDelegate] getIsLossSupported])
  {
    //self.lLossLabel = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 247, GUI_MULTIPLIER * 9, GUI_MULTIPLIER * 65, GUI_MULTIPLIER * 21)];
    self.lLossLabel.text = sSKCoreGetLocalisedString(@"Test_Loss");
    self.lLossLabel.textColor = [UIColor whiteColor];
    self.lLossLabel.font = labelFontLight;
    self.lLossLabel.textAlignment = UITextAlignmentCenter;
  } else {
    self.lLossLabel.hidden = YES;
  }
  
  if ([[SKAAppDelegate getAppDelegate] getIsJitterSupported])
  {
    //self.lJitterLabel = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 297, GUI_MULTIPLIER * 9, GUI_MULTIPLIER * 65, GUI_MULTIPLIER * 21)];
    self.lJitterLabel.text = sSKCoreGetLocalisedString(@"Test_Jitter");
    self.lJitterLabel.textColor = [UIColor whiteColor];
    self.lJitterLabel.font = labelFontLight;
    self.lJitterLabel.textAlignment = UITextAlignmentCenter;
  } else {
    self.lJitterLabel.hidden = YES;
  }
  
  //self.lDateOfTest = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 180, GUI_MULTIPLIER * 55, GUI_MULTIPLIER * 121, GUI_MULTIPLIER * 21)];
  self.lDateOfTest.text = @"-";
  self.lDateOfTest.textColor = [UIColor whiteColor];
  self.lDateOfTest.font = labelFontLight;
  self.lDateOfTest.textAlignment = UITextAlignmentCenter;
  
  //self.lTimeOfTest = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 180, GUI_MULTIPLIER * 68, GUI_MULTIPLIER * 121, GUI_MULTIPLIER * 21)];
  self.lTimeOfTest.text = @"-";
  self.lTimeOfTest.textColor = [UIColor whiteColor];
  self.lTimeOfTest.font = labelFontLight;
  self.lTimeOfTest.textAlignment = UITextAlignmentCenter;
  
  //self.lResultDownload = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 11, GUI_MULTIPLIER * 31, GUI_MULTIPLIER * 80, GUI_MULTIPLIER * 55)];
  self.lResultDownload.text = @"-";
  self.lResultDownload.textColor = [SKAppColourScheme sGetResultColourText];
  self.lResultDownload.font = resultFont1;
  
  //self.lResultUpload = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 105, GUI_MULTIPLIER * 31, GUI_MULTIPLIER * 82, GUI_MULTIPLIER * 55)];
  self.lResultUpload.text = @"-";
  self.lResultUpload.textColor = [SKAppColourScheme sGetResultColourText];
  self.lResultUpload.font = resultFont1;
  
  //self.lResultLatency = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 191, GUI_MULTIPLIER * 27, GUI_MULTIPLIER * 65, GUI_MULTIPLIER * 17)];
  self.lResultLatency.text = @"-";
  self.lResultLatency.textColor = [SKAppColourScheme sGetResultColourText];
  self.lResultLatency.textAlignment = UITextAlignmentCenter;
  self.lResultLatency.font = resultFont2;
  
  if ([[SKAAppDelegate getAppDelegate] getIsLossSupported]) {
    //self.lResultLoss = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 247, GUI_MULTIPLIER * 27, GUI_MULTIPLIER * 65, GUI_MULTIPLIER * 17)];
    self.lResultLoss.text = @"-";
    self.lResultLoss.textColor = [SKAppColourScheme sGetResultColourText];
    self.lResultLoss.textAlignment = UITextAlignmentCenter;
    self.lResultLoss.font = resultFont2;
  }
  
  if ([[SKAAppDelegate getAppDelegate] getIsJitterSupported])
  {
    //self.lResultJitter = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 297, GUI_MULTIPLIER * 27, GUI_MULTIPLIER * 65, GUI_MULTIPLIER * 17)];
    self.lResultJitter.text = @"-";
    self.lResultJitter.textColor = [SKAppColourScheme sGetResultColourText];
    self.lResultJitter.textAlignment = UITextAlignmentCenter;
    self.lResultJitter.font = resultFont2;
  }
  
  //self.ivNetworkType = [[UIImageView alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 280, GUI_MULTIPLIER * 60, GUI_MULTIPLIER * 25, GUI_MULTIPLIER * 25)];
  self.ivNetworkType.contentMode = UIViewContentModeScaleAspectFit;
  
  //self.ivArrowDownload = [[UIImageView alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 9, GUI_MULTIPLIER * 12, GUI_MULTIPLIER * 17, GUI_MULTIPLIER * 17)];
  self.ivArrowDownload.image = [UIImage imageNamed:@"ga"];
  
  //self.ivArrowUpload = [[UIImageView alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 103, GUI_MULTIPLIER * 11, GUI_MULTIPLIER * 17, GUI_MULTIPLIER * 17)];
  self.ivArrowUpload.image = [UIImage imageNamed:@"ra"];
  
  if ([[SKAAppDelegate getAppDelegate] getIsJitterSupported])
    //Change the layout to make space for the Jitter Labels
  {
    self.lLatencyLabel.frame = CGRectMake(GUI_MULTIPLIER * 180, GUI_MULTIPLIER * 9, GUI_MULTIPLIER * 45, GUI_MULTIPLIER * 21);
    self.lLossLabel.frame = CGRectMake(GUI_MULTIPLIER * 225, GUI_MULTIPLIER * 9, GUI_MULTIPLIER * 45, GUI_MULTIPLIER * 21);
    self.lJitterLabel.frame = CGRectMake(GUI_MULTIPLIER * 270, GUI_MULTIPLIER * 9, GUI_MULTIPLIER * 45, GUI_MULTIPLIER * 21);
    
    self.lResultLatency.frame = CGRectMake(GUI_MULTIPLIER * 180, GUI_MULTIPLIER * 27, GUI_MULTIPLIER * 45, GUI_MULTIPLIER * 21);
    self.lResultLoss.frame = CGRectMake(GUI_MULTIPLIER * 225, GUI_MULTIPLIER * 27, GUI_MULTIPLIER * 45, GUI_MULTIPLIER * 21);
    self.lResultJitter.frame = CGRectMake(GUI_MULTIPLIER * 270, GUI_MULTIPLIER * 27, GUI_MULTIPLIER * 45, GUI_MULTIPLIER * 21);
  }
  
  //self.aiDownload = [[CActivityBlinking alloc] initWithFrame:CGRectMake(self.lResultDownload.frame.origin.x, self.lDownloadLabel.frame.origin.y + self.lDownloadLabel.frame.size.height, self.lResultDownload.frame.size.width, self.lMbpsLabel4Download.frame.origin.y - self.lDownloadLabel.frame.origin.y - self.lDownloadLabel.frame.size.height)];
  [self.aiDownload initialize];
  
  //self.aiUpload = [[CActivityBlinking alloc] initWithFrame:CGRectMake(self.lResultUpload.frame.origin.x, self.lUploadLabel.frame.origin.y + self.lUploadLabel.frame.size.height, self.lResultUpload.frame.size.width, self.lMbpsLabel4Upload.frame.origin.y - self.lUploadLabel.frame.origin.y - self.lUploadLabel.frame.size.height)];
  [self.aiUpload initialize];
  
  //self.aiLatency = [[CActivityBlinking alloc] initWithFrame:self.lResultLatency.frame];
  [self.aiLatency initialize];
  
  [self.aiLoss initialize];
  if ([[SKAAppDelegate getAppDelegate] getIsLossSupported]) {
    //self.aiLoss = [[CActivityBlinking alloc] initWithFrame:self.lResultLoss.frame];
  } else {
    self.aiLoss.hidden = YES;
  }
  
  [self.aiJitter initialize];
  if ([[SKAAppDelegate getAppDelegate] getIsJitterSupported]) {
    //self.aiJitter = [[CActivityBlinking alloc] initWithFrame:self.lResultJitter.frame];
    [self.aiJitter initialize];
  } else {
    self.aiLoss.hidden = YES;
  }
  
#ifdef DEBUG
//  [self printLayoutDefinition];
#endif // DEBUG
}

-(void)initCell
{
  self.backgroundColor = [UIColor clearColor];
  
  [self layoutCellActive];
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
  
  if (testResult_.downloadSpeed < 0)
    self.lResultDownload.text = @"-";
  else
    self.lResultDownload.text = [SKBTestOverviewCell get3digitsNumber:testResult_.downloadSpeed];
  
  if (testResult.uploadSpeed < 0)
    self.lResultUpload.text = @"-";
  else
    self.lResultUpload.text = [SKBTestOverviewCell get3digitsNumber:testResult.uploadSpeed];
  
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

+(NSString*)get3digitsNumber:(float)number_
{
  if (number_ < 10) return [NSString stringWithFormat:@"%.02f", number_];
  else if (number_ < 100) return [NSString stringWithFormat:@"%.01f", number_];
  else return [NSString stringWithFormat:@"%.00f", number_];
}

#pragma mark Reverse Engineering

#ifdef DEBUG
-(void)printLayoutDefinition
{
  [SKBTestOverviewCell printFrameForView:self.lDownloadLabel withName:@"lDownloadLabel"];
  [SKBTestOverviewCell printFrameForView:self.lUploadLabel withName:@"lUploadLabel"];
  
  [SKBTestOverviewCell printFrameForView:self.lMbpsLabel4Download withName:@"lMbpsLabel4Download"];
  [SKBTestOverviewCell printFrameForView:self.lMbpsLabel4Upload withName:@"lMbpsLabel4Upload"];
  [SKBTestOverviewCell printFrameForView:self.lLatencyLabel withName:@"lLatencyLabel"];
  [SKBTestOverviewCell printFrameForView:self.lLossLabel withName:@"lLossLabel"];
  [SKBTestOverviewCell printFrameForView:self.lJitterLabel withName:@"lJitterLabel"];
  
  [SKBTestOverviewCell printFrameForView:self.lDateOfTest withName:@"lDateOfTest"];
  [SKBTestOverviewCell printFrameForView:self.lTimeOfTest withName:@"lTimeOfTest"];
  
  [SKBTestOverviewCell printFrameForView:self.lResultDownload withName:@"lResultDownload"];
  [SKBTestOverviewCell printFrameForView:self.lResultUpload withName:@"lResultUpload"];
  [SKBTestOverviewCell printFrameForView:self.lResultLatency withName:@"lResultLatency"];
  [SKBTestOverviewCell printFrameForView:self.lResultLoss withName:@"lResultLoss"];
  [SKBTestOverviewCell printFrameForView:self.lResultJitter withName:@"lResult§Jitter"];
  
  [SKBTestOverviewCell printFrameForView:self.ivNetworkType withName:@"ivNetworkType"];
  [SKBTestOverviewCell printFrameForView:self.ivArrowDownload withName:@"ivArrowDownload"];
  [SKBTestOverviewCell printFrameForView:self.ivArrowUpload withName:@"ivArrowUpload"];
  
  [SKBTestOverviewCell printFrameForView:self.ivNetworkType withName:@"ivNetworkType"];
  
  [SKBTestOverviewCell printFrameForView:self.aiActivity withName:@"aiActivity"];
  [SKBTestOverviewCell printFrameForView:self.aiDownload withName:@"aiDownload"];
  [SKBTestOverviewCell printFrameForView:self.aiJitter withName:@"aiJitter"];
  [SKBTestOverviewCell printFrameForView:self.aiLatency withName:@"aiLatency"];
  [SKBTestOverviewCell printFrameForView:self.aiLoss withName:@"aiLoss"];
  [SKBTestOverviewCell printFrameForView:self.aiUpload withName:@"aiUpload"];
}
#endif // DEBUG

+(void)printFrameForView:(UIView*)view_ withName:(NSString*)name_
{
  if ([view_ isKindOfClass:[UILabel class]])
  {
    NSLog(@"self.%@ = frame: CGRectMake(%.0f, %.0f, %.0f, %.0f)];", name_, view_.frame.origin.x, view_.frame.origin.y, view_.frame.size.width, view_.frame.size.height);
    NSLog(@"self.%@.text = @\"%@\";", name_, ((UILabel*)view_).text);
    NSLog(@"self.%@.textColor =[UIColor whiteColor];", name_);
    
  }
  else if ([view_ isKindOfClass:[UIView class]])
    NSLog(@"self.%@ = frame: (%.0f, %.0f, %.0f, %.0f)];", name_, view_.frame.origin.x, view_.frame.origin.y, view_.frame.size.width, view_.frame.size.height);
  
  //    NSLog(@"self.%@.frame = CGRectMake(%.0f, %.0f, %.0f, %.0f);", name_, view_.frame.origin.x, view_.frame.origin.y, view_.frame.size.width, view_.frame.size.height);
}

@end
