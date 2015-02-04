//
//  CAnimatedStatusView.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "CAnimatedStatusView.h"

@interface CAnimatedStatusView()
@property (nonatomic) int activeLabel;
@end

@implementation CAnimatedStatusView

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
  
  self.v1.alpha = 0;
  
  UIFont *theFont = [UIFont fontWithName:@"Roboto-Light" size:0.85 * self.bounds.size.height];
  
  self.l1n.font = theFont;
  self.l1n.textColor = [UIColor lightGrayColor];
  self.l1n.textAlignment = NSTextAlignmentCenter;
  
  self.l1h.font = theFont;
  self.l1h.textColor = [SKAppColourScheme sGetMainColourStatusText];
  self.l1h.textAlignment = NSTextAlignmentCenter;
  
  self.v2.alpha = 0;
  
  self.l2n.font = theFont;
  self.l2n.textColor = self.l1n.textColor;
  self.l2n.textAlignment = NSTextAlignmentCenter;
  
  self.l2h.font = theFont;
  self.l2h.textColor = self.l1h.textColor;
  self.l2h.textAlignment = NSTextAlignmentCenter;
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
