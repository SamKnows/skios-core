//
//  cAnimatedStatusView.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "cAnimatedStatusView.h"

@implementation cAnimatedStatusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)initialize;
{
    self.backgroundColor = [UIColor clearColor];
    
    self.activeLabel = 1;

    self.v1 = [[UIView alloc] initWithFrame:self.bounds];
    self.v1.alpha = 0;
    [self addSubview:self.v1];
    self.l1h = [[UILabel alloc] initWithFrame:self.bounds];
    self.l1n = [[UILabel alloc] initWithFrame:self.bounds];
    [self.v1 addSubview:self.l1n];
    [self.v1 addSubview:self.l1h];
    self.l1n.font = [UIFont fontWithName:@"Roboto-Light" size:0.85 * self.bounds.size.height];
    self.l1h.font = self.l1n.font;
    self.l1n.textColor = [UIColor lightGrayColor];
    self.l1h.textColor = [UIColor whiteColor];
    self.l1n.textAlignment = UITextAlignmentCenter;
    self.l1h.textAlignment = UITextAlignmentCenter;

    self.v2 = [[UIView alloc] initWithFrame:self.bounds];
    self.v2.alpha = 0;
    [self addSubview:self.v2];
    self.l2h = [[UILabel alloc] initWithFrame:self.bounds];
    self.l2n = [[UILabel alloc] initWithFrame:self.bounds];
    [self.v2 addSubview:self.l2n];
    [self.v2 addSubview:self.l2h];
    self.l2n.font = self.l1n.font;
    self.l2h.font = self.l1n.font;
    self.l2n.textColor = self.l1n.textColor;
    self.l2h.textColor = self.l1h.textColor;
    self.l2n.textAlignment = UITextAlignmentCenter;
    self.l2h.textAlignment = UITextAlignmentCenter;
}

-(void)startAnimating:(UILabel*)l_ forever:(BOOL)forever_
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    
    animation.keyTimes = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.0],
                          [NSNumber numberWithFloat:0.5],
                          [NSNumber numberWithFloat:1.0],
                          nil];
    
    if (forever_)
    {
        animation.values = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:1.0],
                            [NSNumber numberWithFloat:0.0],
                            [NSNumber numberWithFloat:1.0],
                            nil];
    }
    else
    {
        animation.values = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:1.0],
                            [NSNumber numberWithFloat:0.5],
                            [NSNumber numberWithFloat:0.0],
                            nil];
    }
    
    animation.duration = 5.0;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    if (forever_)
        animation.repeatCount = HUGE_VALF;
    else
        animation.repeatCount = 1;
    
    [l_.layer addAnimation:animation forKey:@"opacity"];
}

-(void)animate:(BOOL)forever_
{
    [self.l1h.layer removeAllAnimations];
    [self.l2h.layer removeAllAnimations];

    if (self.activeLabel == 1) [self startAnimating:self.l1h forever:forever_];
    else [self startAnimating:self.l2h forever:forever_];
}

-(void)setText:(NSString*)text_ forever:(bool)forever_
{
    if (self.activeLabel == 1)
    {
        self.activeLabel = 2;
        
        self.l2n.text = text_;
        self.l2h.text = text_;
        self.l2h.alpha = 1;
        
        [UIView animateWithDuration:0.5 animations:^{
           
            self.v2.alpha = 1;
            self.v1.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [self animate:forever_];
            
        }];
    }
    else
    {
        self.activeLabel = 1;
        
        self.l1n.text = text_;
        self.l1h.text = text_;
        self.l1h.alpha = 1;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.v1.alpha = 1;
            self.v2.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [self animate:forever_];
            
        }];
    }
}

@end
