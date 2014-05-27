//
//  SKAGraphResultFooterCell.m
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKAGraphResultFooterCell.h"

@implementation SKAGraphResultFooterCell

@synthesize delegate;


- (IBAction)back:(id)sender
{
    [[self delegate] back];
}

- (IBAction)next:(id)sender
{
    [[self delegate] next];
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

    // Configure the view for the selected state
}

@end
