//
//  SKATestOverviewCell2.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKATestOverviewCell2.h"
#import "SKATestOverviewMetrics.h"
#import "SKHistoryViewMgr.h"
#import "SKTestResults.h"

@implementation SKATestOverviewCell2

-(void)setResultDownload:(SKATestOverviewMetrics*)down_ upload:(SKATestOverviewMetrics*)up_ latency:(SKATestOverviewMetrics*)lat_ loss:(SKATestOverviewMetrics*)loss_ jitter:(SKATestOverviewMetrics*)jitter_
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
  if (self.vBackground != nil) return;
  
  float GUI_MULTIPLIER = [cTabController sGet_GUI_MULTIPLIER];
  
  UIFont* labelFontLight = [UIFont fontWithName:@"Roboto-Light" size:GUI_MULTIPLIER * 12];
  UIFont* labelFontThin = [UIFont fontWithName:@"Roboto-Thin" size:GUI_MULTIPLIER * 12];
  UIFont* resultFont1 = [UIFont fontWithName:@"DINCondensed-Bold" size:GUI_MULTIPLIER * 53];
  UIFont* resultFont2 = [UIFont fontWithName:@"DINCondensed-Bold" size:GUI_MULTIPLIER * 17];
  
  self.vBackground = [[UIView alloc] initWithFrame:CGRectMake(GUI_MULTIPLIER * 5,GUI_MULTIPLIER * 3, GUI_MULTIPLIER * 310, GUI_MULTIPLIER * 90)];
  self.vBackground.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
  self.vBackground.layer.cornerRadius = GUI_MULTIPLIER * 3;
  self.vBackground.layer.borderWidth = 0.5;
  self.vBackground.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
  [self.contentView addSubview:self.vBackground];
  
  self.lDownloadLabel = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 29, GUI_MULTIPLIER * 9, GUI_MULTIPLIER * 103, GUI_MULTIPLIER * 21)];
  self.lDownloadLabel.text = @"Download";
  self.lDownloadLabel.textColor = [UIColor whiteColor];
  self.lDownloadLabel.font = labelFontLight;
  
  [self.contentView addSubview:self.lDownloadLabel];
  
  self.lUploadLabel = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 121, GUI_MULTIPLIER * 9, GUI_MULTIPLIER * 82, GUI_MULTIPLIER * 21)];
  self.lUploadLabel.text = @"Upload";
  self.lUploadLabel.textColor = [UIColor whiteColor];
  self.lUploadLabel.font = labelFontLight;
  [self.contentView addSubview:self.lUploadLabel];
  
  self.lMbpsLabel4Download = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 15, GUI_MULTIPLIER * 69, GUI_MULTIPLIER * 59, GUI_MULTIPLIER * 21)];
  self.lMbpsLabel4Download.text = @"Mbps";
  self.lMbpsLabel4Download.textColor = [UIColor whiteColor];
  self.lMbpsLabel4Download.font = labelFontThin;
  [self.contentView addSubview:self.lMbpsLabel4Download];
  
  self.lMbpsLabel4Upload = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 105, GUI_MULTIPLIER * 69, GUI_MULTIPLIER * 46, GUI_MULTIPLIER * 21)];
  self.lMbpsLabel4Upload.text = @"Mbps";
  self.lMbpsLabel4Upload.textColor = [UIColor whiteColor];
  self.lMbpsLabel4Upload.font = labelFontThin;
  [self.contentView addSubview:self.lMbpsLabel4Upload];
  
  self.lLatencyLabel = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 191, GUI_MULTIPLIER * 9, GUI_MULTIPLIER * 65, GUI_MULTIPLIER * 21)];
  self.lLatencyLabel.text = @"Latency";
  self.lLatencyLabel.textColor = [UIColor whiteColor];
  self.lLatencyLabel.font = labelFontLight;
  self.lLatencyLabel.textAlignment = UITextAlignmentCenter;
  [self.contentView addSubview:self.lLatencyLabel];
  
  self.lLossLabel = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 247, GUI_MULTIPLIER * 9, GUI_MULTIPLIER * 65, GUI_MULTIPLIER * 21)];
  self.lLossLabel.text = @"Loss";
  self.lLossLabel.textColor = [UIColor whiteColor];
  self.lLossLabel.font = labelFontLight;
  self.lLossLabel.textAlignment = UITextAlignmentCenter;
  [self.contentView addSubview:self.lLossLabel];
  
  if ([[SKAAppDelegate getAppDelegate] getIsJitterSupported])
  {
    self.lJitterLabel = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 297, GUI_MULTIPLIER * 9, GUI_MULTIPLIER * 65, GUI_MULTIPLIER * 21)];
    self.lJitterLabel.text = @"Jitter";
    self.lJitterLabel.textColor = [UIColor whiteColor];
    self.lJitterLabel.font = labelFontLight;
    self.lJitterLabel.textAlignment = UITextAlignmentCenter;
    [self.contentView addSubview:self.lJitterLabel];
  }
  
  self.lDateOfTest = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 180, GUI_MULTIPLIER * 55, GUI_MULTIPLIER * 121, GUI_MULTIPLIER * 21)];
  self.lDateOfTest.text = @"-";
  self.lDateOfTest.textColor = [UIColor whiteColor];
  self.lDateOfTest.font = labelFontLight;
  self.lDateOfTest.textAlignment = UITextAlignmentCenter;
  [self.contentView addSubview:self.lDateOfTest];
  
  self.lTimeOfTest = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 180, GUI_MULTIPLIER * 68, GUI_MULTIPLIER * 121, GUI_MULTIPLIER * 21)];
  self.lTimeOfTest.text = @"-";
  self.lTimeOfTest.textColor = [UIColor whiteColor];
  self.lTimeOfTest.font = labelFontLight;
  self.lTimeOfTest.textAlignment = UITextAlignmentCenter;
  [self.contentView addSubview:self.lTimeOfTest];
  
  self.lResultDownload = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 11, GUI_MULTIPLIER * 31, GUI_MULTIPLIER * 80, GUI_MULTIPLIER * 55)];
  self.lResultDownload.text = @"-";
  self.lResultDownload.textColor = [UIColor colorWithWhite:0.85 alpha:1];
  self.lResultDownload.font = resultFont1;
  [self.contentView addSubview:self.lResultDownload];
  
  self.lResultUpload = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 105, GUI_MULTIPLIER * 31, GUI_MULTIPLIER * 82, GUI_MULTIPLIER * 55)];
  self.lResultUpload.text = @"-";
  self.lResultUpload.textColor = [UIColor colorWithWhite:0.85 alpha:1];
  self.lResultUpload.font = resultFont1;
  [self.contentView addSubview:self.lResultUpload];
  
  self.lResultLatency = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 191, GUI_MULTIPLIER * 27, GUI_MULTIPLIER * 65, GUI_MULTIPLIER * 17)];
  self.lResultLatency.text = @"-";
  self.lResultLatency.textColor = [UIColor colorWithWhite:0.85 alpha:1];
  self.lResultLatency.textAlignment = UITextAlignmentCenter;
  self.lResultLatency.font = resultFont2;
  [self.contentView addSubview:self.lResultLatency];
  
  self.lResultLoss = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 247, GUI_MULTIPLIER * 27, GUI_MULTIPLIER * 65, GUI_MULTIPLIER * 17)];
  self.lResultLoss.text = @"-";
  self.lResultLoss.textColor = [UIColor colorWithWhite:0.85 alpha:1];
  self.lResultLoss.textAlignment = UITextAlignmentCenter;
  self.lResultLoss.font = resultFont2;
  [self.contentView addSubview:self.lResultLoss];
  
  if ([[SKAAppDelegate getAppDelegate] getIsJitterSupported])
  {
    self.lResultJitter = [[UILabel alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 297, GUI_MULTIPLIER * 27, GUI_MULTIPLIER * 65, GUI_MULTIPLIER * 17)];
    self.lResultJitter.text = @"-";
    self.lResultJitter.textColor = [UIColor colorWithWhite:0.85 alpha:1];
    self.lResultJitter.textAlignment = UITextAlignmentCenter;
    self.lResultJitter.font = resultFont2;
    [self.contentView addSubview:self.lResultJitter];
  }
  
  self.ivNetworkType = [[UIImageView alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 280, GUI_MULTIPLIER * 60, GUI_MULTIPLIER * 25, GUI_MULTIPLIER * 25)];
  self.ivNetworkType.contentMode = UIViewContentModeScaleAspectFit;
  [self.contentView addSubview:self.ivNetworkType];
  
  self.ivArrowDownload = [[UIImageView alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 9, GUI_MULTIPLIER * 12, GUI_MULTIPLIER * 17, GUI_MULTIPLIER * 17)];
  self.ivArrowDownload.image = [UIImage imageNamed:@"ga"];
  [self.contentView addSubview:self.ivArrowDownload];
  
  self.ivArrowUpload = [[UIImageView alloc] initWithFrame: CGRectMake(GUI_MULTIPLIER * 103, GUI_MULTIPLIER * 11, GUI_MULTIPLIER * 17, GUI_MULTIPLIER * 17)];
  self.ivArrowUpload.image = [UIImage imageNamed:@"ra"];
  [self.contentView addSubview:self.ivArrowUpload];
  
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
  
  self.aiDownload = [[CActivityBlinking alloc] initWithFrame:CGRectMake(self.lResultDownload.frame.origin.x, self.lDownloadLabel.frame.origin.y + self.lDownloadLabel.frame.size.height, self.lResultDownload.frame.size.width, self.lMbpsLabel4Download.frame.origin.y - self.lDownloadLabel.frame.origin.y - self.lDownloadLabel.frame.size.height)];
  [self.contentView addSubview:self.aiDownload];
  
  self.aiUpload = [[CActivityBlinking alloc] initWithFrame:CGRectMake(self.lResultUpload.frame.origin.x, self.lUploadLabel.frame.origin.y + self.lUploadLabel.frame.size.height, self.lResultUpload.frame.size.width, self.lMbpsLabel4Upload.frame.origin.y - self.lUploadLabel.frame.origin.y - self.lUploadLabel.frame.size.height)];
  [self.contentView addSubview:self.aiUpload];
  
  self.aiLatency = [[CActivityBlinking alloc] initWithFrame:self.lResultLatency.frame];
  [self.contentView addSubview:self.aiLatency];
  
  self.aiLoss = [[CActivityBlinking alloc] initWithFrame:self.lResultLoss.frame];
  [self.contentView addSubview:self.aiLoss];
  
  self.aiJitter = [[CActivityBlinking alloc] initWithFrame:self.lResultJitter.frame];
  [self.contentView addSubview:self.aiJitter];
}

-(void)initCell
{
  self.backgroundColor = [UIColor clearColor];
  
  if (self.lDownloadLabel == nil)
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
    self.lResultDownload.text = [SKATestOverviewCell2 get3digitsNumber:testResult_.downloadSpeed];
  
  if (testResult.uploadSpeed < 0)
    self.lResultUpload.text = @"-";
  else
    self.lResultUpload.text = [SKATestOverviewCell2 get3digitsNumber:testResult.uploadSpeed];
  
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
  
  if ([testResult_.network_type isEqualToString:@"mobile"])
    self.ivNetworkType.image  = [UIImage imageNamed:@"sgsm.png"];
  else
    self.ivNetworkType.image = [UIImage imageNamed:@"swifi.png"];
  
  y = 100;
  
  return;
}

-(UIView*)getView
{
  //    [self printLayoutDefinition];
  return self.contentView;
}

+(NSString*)get3digitsNumber:(float)number_
{
  if (number_ < 10) return [NSString stringWithFormat:@"%.02f", number_];
  else if (number_ < 100) return [NSString stringWithFormat:@"%.01f", number_];
  else return [NSString stringWithFormat:@"%.00f", number_];
}

#pragma mark Reverse Engineering

-(void)printLayoutDefinition
{
  [SKATestOverviewCell2 printFrameForView:self.lDownloadLabel withName:@"lDownloadLabel"];
  [SKATestOverviewCell2 printFrameForView:self.lUploadLabel withName:@"lUploadLabel"];
  
  [SKATestOverviewCell2 printFrameForView:self.lMbpsLabel4Download withName:@"lMbpsLabel4Download"];
  [SKATestOverviewCell2 printFrameForView:self.lMbpsLabel4Upload withName:@"lMbpsLabel4Upload"];
  [SKATestOverviewCell2 printFrameForView:self.lLatencyLabel withName:@"lLatencyLabel"];
  [SKATestOverviewCell2 printFrameForView:self.lLossLabel withName:@"lLossLabel"];
  
  [SKATestOverviewCell2 printFrameForView:self.lDateOfTest withName:@"lDateOfTest"];
  [SKATestOverviewCell2 printFrameForView:self.lTimeOfTest withName:@"lTimeOfTest"];
  
  [SKATestOverviewCell2 printFrameForView:self.lResultDownload withName:@"lResultDownload"];
  [SKATestOverviewCell2 printFrameForView:self.lResultUpload withName:@"lResultUpload"];
  [SKATestOverviewCell2 printFrameForView:self.lResultLatency withName:@"lResultLatency"];
  [SKATestOverviewCell2 printFrameForView:self.lResultLoss withName:@"lResultLoss"];
  
  [SKATestOverviewCell2 printFrameForView:self.ivNetworkType withName:@"ivNetworkType"];
  [SKATestOverviewCell2 printFrameForView:self.ivArrowDownload withName:@"ivArrowDownload"];
  [SKATestOverviewCell2 printFrameForView:self.ivArrowUpload withName:@"ivArrowUpload"];
  
  [SKATestOverviewCell2 printFrameForView:self.ivNetworkType withName:@"ivNetworkType"];
}

+(void)printFrameForView:(UIView*)view_ withName:(NSString*)name_
{
  if ([view_ isKindOfClass:[UILabel class]])
  {
    NSLog(@"self.%@ = [[UILabel alloc] initWithFrame: CGRectMake(%.0f, %.0f, %.0f, %.0f)];", name_, view_.frame.origin.x, view_.frame.origin.y, view_.frame.size.width, view_.frame.size.height);
    NSLog(@"self.%@.text = @\"%@\";", name_, ((UILabel*)view_).text);
    NSLog(@"self.%@.textColor =[UIColor whiteColor];", name_);
    
  }
  else if ([view_ isKindOfClass:[UIImageView class]])
    NSLog(@"self.%@ = [[UIImageView alloc] initWithFrame: CGRectMake(%.0f, %.0f, %.0f, %.0f)];", name_, view_.frame.origin.x, view_.frame.origin.y, view_.frame.size.width, view_.frame.size.height);
  
  //    NSLog(@"self.%@.frame = CGRectMake(%.0f, %.0f, %.0f, %.0f);", name_, view_.frame.origin.x, view_.frame.origin.y, view_.frame.size.width, view_.frame.size.height);
}

@end
