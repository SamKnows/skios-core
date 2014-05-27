//
//  SKARunTestsButtonCell.h
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SKARunTestsButtonCellProtocol;

@interface SKARunTestsButtonCell : UITableViewCell
{
    id <SKARunTestsButtonCellProtocol> delegate;
}

@property (weak, nonatomic) IBOutlet UIButton *btnRun;

@property (atomic, strong) id <SKARunTestsButtonCellProtocol> delegate;

- (IBAction)run:(id)sender;

- (void)initialize:(NSString*)rangeText ContinuousTesting:(BOOL)continuousTesting;

@end

@protocol SKARunTestsButtonCellProtocol

- (void)handleButtonPress:(BOOL)continuousTesting;

@end
