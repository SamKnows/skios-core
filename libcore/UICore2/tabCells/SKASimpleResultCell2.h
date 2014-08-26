//
//  SKASimpleResultCell2.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKATestResultSuperCell.h"

@class SKATestOverviewMetrics;

@interface SKASimpleResultCell2 : SKATestResultSuperCell

-(void)initCell;
-(void)setMetrics:(SKATestOverviewMetrics*)metricsObject;
-(void)updateDisplay;
-(void)setResultDownload:(SKATestOverviewMetrics*)down_ upload:(SKATestOverviewMetrics*)up_ latency:(SKATestOverviewMetrics*)lat_ loss:(SKATestOverviewMetrics*)loss_ jitter:(SKATestOverviewMetrics*)jitter_;

@end
