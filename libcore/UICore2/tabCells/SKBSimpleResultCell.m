//
//  SKBSimpleResultCell.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBSimpleResultCell.h"
#import "SKBTestResultValue.h"
//#import "../ViewManagers/SKRunTestViewMgr.h"

@implementation SKBSimpleResultCell

-(void)initCell
{
  self.backgroundColor = [UIColor clearColor];
  self.lMeasureName.textColor = [UIColor colorWithRed:255.0/255.0 green:166.0/255.0 blue:26.0/255.0 alpha:1];
  self.lResult.textColor = [UIColor colorWithRed:255.0/255.0 green:166.0/255.0 blue:26.0/255.0 alpha:1];
}

-(void)setMetrics:(SKBTestResultValue*)metricsObject
{
  self.cellMetrics = metricsObject;
  [self updateDisplay];
}

-(void)updateDisplay
{
  self.lMeasureName.text = self.cellMetrics.mLocalizedIdentifier;
  self.lResult.text = self.cellMetrics.value;
}

@end
