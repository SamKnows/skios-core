//
//  SKALatencyTestCell.h
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKSpinnerView.h"

@interface SKALatencyTestCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblLatency;
@property (weak, nonatomic) IBOutlet UILabel *lblLatencyResult;
@property (weak, nonatomic) IBOutlet STKSpinnerView *latencyProgressView;

@property (weak, nonatomic) IBOutlet UILabel *lblLoss;
@property (weak, nonatomic) IBOutlet UILabel *lblLossResult;
@property (weak, nonatomic) IBOutlet STKSpinnerView *lossProgressView;

@property (weak, nonatomic) IBOutlet UIView *jitterViewSeparator;
@property (weak, nonatomic) IBOutlet UILabel *lblJitter;
@property (weak, nonatomic) IBOutlet UILabel *lblJitterResult;
@property (weak, nonatomic) IBOutlet STKSpinnerView *jitterProgressView;

@end
