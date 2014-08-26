//
//  CActivityBlinking.m
//  SKCore
//
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "CActivityBlinking.h"

#define C_BLINKER_SIZE 10

@implementation CActivityBlinking

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)initialize
{
    if (isInitialised) return;
    
    self.backgroundColor = [UIColor clearColor];
    V_Blinker = [[UIView alloc] init];
    V_Blinker.frame = CGRectMake(self.bounds.origin.x + (self.bounds.size.width - C_BLINKER_SIZE) / 2, self.bounds.origin.y + (self.bounds.size.height - C_BLINKER_SIZE) / 2, C_BLINKER_SIZE, C_BLINKER_SIZE);
    
    V_Blinker.layer.cornerRadius = C_BLINKER_SIZE / 2;
    V_Blinker.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1].CGColor;
    V_Blinker.backgroundColor = [UIColor orangeColor];

    V_Blinker.layer.borderWidth = 1;

    [self addSubview:V_Blinker];
    
    isInitialised = YES;
}

-(void)startAnimating
{
    [self initialize];
     
    self.alpha = 1;

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    
    animation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                          [NSNumber numberWithFloat:0.5],
                          [NSNumber numberWithFloat:1.0], nil];
    
    animation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                        [NSNumber numberWithFloat:0.80],
                        [NSNumber numberWithFloat:0.0], nil];
    
    animation.duration = 1.5;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = HUGE_VALF;
    [V_Blinker.layer addAnimation:animation forKey:@"opacity"];
}

-(void)stopAnimating
{
    [self initialize];

    [V_Blinker.layer removeAllAnimations];
    self.alpha = 0;
}

@end
