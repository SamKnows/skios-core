//
//  SKATestResultSuperCell.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKATestResultSuperCell.h"
#import "cTabController.h"

@implementation SKATestResultSuperCell

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

-(void)layoutCellPassive
{
    if (self.lMeasureName != nil) return;
    
    self.lMeasureName = [[UILabel alloc] initWithFrame:CGRectMake([cTabController sGet_GUI_MULTIPLIER] * 10, 0, [cTabController globalInstance].GUI_WIDTH, [cTabController sGet_GUI_MULTIPLIER] * 18)];
    self.lMeasureName.font= [UIFont fontWithName:@"RobotoCondensed-Regular" size:[cTabController sGet_GUI_MULTIPLIER] * 14];
    self.lMeasureName.textColor = [UIColor colorWithRed:255.0/255.0 green:166.0/255.0 blue:26.0/255.0 alpha:1];
    [self.contentView addSubview:self.lMeasureName];

    self.lResult = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [cTabController globalInstance].GUI_WIDTH - [cTabController sGet_GUI_MULTIPLIER] * 10, [cTabController sGet_GUI_MULTIPLIER] * 18)];
    self.lResult.font= [UIFont fontWithName:@"RobotoCondensed-Regular" size:[cTabController sGet_GUI_MULTIPLIER] * 14];
    self.lResult.textColor = [UIColor colorWithRed:255.0/255.0 green:166.0/255.0 blue:26.0/255.0 alpha:1];
    self.lResult.textAlignment = UITextAlignmentRight;
    [self.contentView addSubview:self.lResult];
}

@end
