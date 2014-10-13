//
//  SKARunTestsButtonCell.m
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKARunTestsButtonCell.h"

@interface SKARunTestsButtonCell ()
@property BOOL mbContinuousTesting;
@end

@implementation SKARunTestsButtonCell

@synthesize btnRun;
@synthesize delegate;

// Handler for our being pressed.
- (IBAction)run:(id)sender
{
  [[self delegate] handleButtonPress:self.mbContinuousTesting];
}

- (void)initialize:(NSString*)rangeText ContinuousTesting:(BOOL)continuousTesting
{
  if (continuousTesting == true) {
    self.mbContinuousTesting = YES;
    [self.btnRun setTitle:sSKCoreGetLocalisedString(@"RESULTS_Label_Continuous_Start") forState:UIControlStateNormal];
  } else {
    self.mbContinuousTesting = NO;
    [self.btnRun setTitle:sSKCoreGetLocalisedString(@"RESULTS_Label_Run") forState:UIControlStateNormal];
  }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
