//
//  SKASimpleResultCell2.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKASimpleResultCell2.h"
#import "../ViewManagers/SKRunTestViewMgr.h"

@implementation SKASimpleResultCell2

-(void)initCell
{
    self.backgroundColor = [UIColor clearColor];
}

-(void)setResultDownload:(SKATestOverviewMetrics*)down_ upload:(SKATestOverviewMetrics*)up_ latency:(SKATestOverviewMetrics*)lat_ loss:(SKATestOverviewMetrics*)loss_ jitter:(SKATestOverviewMetrics*)jitter_
{
    self.lMeasureName.hidden = YES;
    self.lResult.hidden = YES;
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


-(void)setMetrics:(SKATestOverviewMetrics*)metricsObject
{
    self.cellMetrics = metricsObject;
    self.cellResultDownload = nil;
    self.cellResultUpload = nil;
    self.cellResultLatency = nil;
    self.cellResultLoss = nil;
    self.cellResultJitter = nil;

    if (self.lMeasureName == nil)
    {
        [self layoutCellPassive];
    }
    
    self.lMeasureName.hidden = NO;
    self.lResult.hidden = NO;
    
    if (self.lDownloadLabel != nil)
    {
        self.lDownloadLabel.hidden = YES;
        self.lUploadLabel.hidden = YES;
        self.lMbpsLabel4Download.hidden = YES;
        self.lMbpsLabel4Upload.hidden = YES;
        self.lLatencyLabel.hidden = YES;
        self.lLossLabel.hidden = YES;
        self.lDateOfTest.hidden = YES;
        self.lTimeOfTest.hidden = YES;
        self.lResultDownload.hidden = YES;
        self.lResultUpload.hidden = YES;
        self.lResultLatency.hidden = YES;
        self.lResultLoss.hidden = YES;
        self.lResultJitter.hidden = YES;
        self.ivNetworkType.hidden = YES;
        self.ivArrowDownload.hidden = YES;
        self.ivArrowUpload.hidden = YES;
    }
    
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
    else
    {
        self.lMeasureName.text = self.cellMetrics.name;
        self.lResult.text = self.cellMetrics.value;
    }
}

@end
