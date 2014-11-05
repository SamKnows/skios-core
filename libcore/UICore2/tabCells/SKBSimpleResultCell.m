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
 
  // Match the behaviour of SKBHistoryViewMgr!
  self.measureNameWidthConstraint.constant = [SKAppColourScheme sGet_GUI_MULTIPLIER] * 85;
  
  // Use font sizes that match those in the HistoryViewMgr screen...
  // overriding those in the storyboard.
  // This allows iPad to have larger text, for example.
  self.lMeasureName.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 13];
  self.lResult.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 13];
  
  self.lMeasureName.textColor = [SKAppColourScheme sGetMetricsTextColour];
  self.lResult.textColor      = [SKAppColourScheme sGetMetricsTextColour];
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
