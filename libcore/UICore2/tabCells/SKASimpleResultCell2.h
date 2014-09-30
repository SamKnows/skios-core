//
//  SKASimpleResultCell2.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKATestOverviewMetrics;

@interface SKASimpleResultCell2 : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lMeasureName;
@property (weak, nonatomic) IBOutlet UILabel *lResult;

@property (strong, nonatomic) SKATestOverviewMetrics* cellMetrics;

-(void)initCell;
-(void)setMetrics:(SKATestOverviewMetrics*)metricsObject;
-(void)updateDisplay;

@end
