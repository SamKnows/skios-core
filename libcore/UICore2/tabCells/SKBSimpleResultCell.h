//
//  SKBSimpleResultCell.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKBTestResultValue;

@interface SKBSimpleResultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lMeasureName;
@property (weak, nonatomic) IBOutlet UILabel *lResult;

@property (strong, nonatomic) SKBTestResultValue* cellMetrics;

-(void)initCell;
-(void)setMetrics:(SKBTestResultValue*)metricsObject;
-(void)updateDisplay;

@end
