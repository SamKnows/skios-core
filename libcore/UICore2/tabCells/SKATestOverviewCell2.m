//
//  SKATestOverviewCell2.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKATestOverviewCell2.h"
#import "SKHistoryViewMgr.h"
#import "SKTestResults.h"

@implementation SKATestOverviewCell2

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
