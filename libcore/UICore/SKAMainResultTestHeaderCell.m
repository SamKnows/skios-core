//
//  SKAMainResultTestHeaderCell.m
//  SKCore
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKAMainResultTestHeaderCell.h"

@implementation SKAMainResultTestHeaderCell

@synthesize imageView;
@synthesize textLabel;
@synthesize detailTextLabel;

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

-(void) setLabelText:(NSString*)inLabelText DetailText:(NSString*)inDetailText {
  textLabel.text = inLabelText;
  detailTextLabel.text = inDetailText;
}

@end
