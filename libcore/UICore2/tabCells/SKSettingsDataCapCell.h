//
//  SKSettingsDataCapCell.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKASettingsController;

@interface SKSettingsDataCapCell : UITableViewCell

@property (weak, nonatomic) SKASettingsController *mpParentSettingsController;
@property (weak, nonatomic) IBOutlet UILabel *lblDataCap;
@property (weak, nonatomic) IBOutlet UITextField *txtDataCap;
//@property (weak, nonatomic) IBOutlet UILabel *lblDataMB;
@property (weak, nonatomic) IBOutlet UISwitch *datacapSwitch;
- (IBAction)datacapSwitch:(id)sender;
- (IBAction)showDataCapEditor:(id)sender;
- (void)setDataAllowance;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dataCapLabelToSwitchSpacingConstraint;

@end
