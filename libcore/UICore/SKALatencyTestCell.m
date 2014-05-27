//
//  SKALatencyTestCell.m
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKALatencyTestCell.h"

@implementation SKALatencyTestCell

@synthesize lblLatency;
@synthesize lblLatencyResult;
@synthesize lblLoss;
@synthesize lblLossResult;
@synthesize lblJitter;
@synthesize lblJitterResult;
@synthesize latencyProgressView;
@synthesize lossProgressView;
@synthesize jitterProgressView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
