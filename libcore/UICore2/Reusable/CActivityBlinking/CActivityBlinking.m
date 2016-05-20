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
  
  // Put on the LEFT-X, CENTER-Y (not CENTER-X), as our text is now left-aligned.
  //V_Blinker.frame = CGRectMake(self.bounds.origin.x + (self.bounds.size.width - C_BLINKER_SIZE) / 2, self.bounds.origin.y + (self.bounds.size.height - C_BLINKER_SIZE) / 2, C_BLINKER_SIZE, C_BLINKER_SIZE);
  V_Blinker.frame = CGRectMake
  (
   (self.frame.size.width - C_BLINKER_SIZE) / 2,
   (self.frame.size.height - C_BLINKER_SIZE) / 2,
   C_BLINKER_SIZE,
   C_BLINKER_SIZE);
  
  V_Blinker.layer.cornerRadius = C_BLINKER_SIZE / 2;
  V_Blinker.layer.borderColor = [SKAppColourScheme sGetBlinkerBorderColour].CGColor;
  V_Blinker.backgroundColor = [SKAppColourScheme sGetBlinkerBackgroundColour];
  
  V_Blinker.layer.borderWidth = 1;
  
  [self addSubview:V_Blinker];
  
  isInitialised = YES;
}

-(void)startAnimating
{
  [self initialize];
  
  self.alpha = 1;
  
  CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
  
  animation.keyTimes = @[@0.0F,
          @0.5F,
          @1.0F];
  
  animation.values = @[@0.0F,
          @0.80F,
          @0.0F];
  
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
