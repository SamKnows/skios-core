//
//  SKATransferTestCell.h
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKSpinnerView.h"

@interface SKATransferTestCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTest;
@property (weak, nonatomic) IBOutlet UILabel *lblResult;
@property (weak, nonatomic) IBOutlet STKSpinnerView *progressView;

@end
