//
//  SKSplashView.m
//  SKCore
//
//  Copyright (c) 2014-2015 SamKnows. All rights reserved.
//
// Note: this file was created as a direct translation of SKSplashView.swift
//

#import "SKSplashView.h"

@interface SKSplashView()
@property NSMutableArray* mLetterLabels;
@end

@implementation SKSplashView

@synthesize mLetterLabels;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
  }
  return self;
}

-(void)initializeWelcomeText
{
  self.backgroundColor = [SKAppColourScheme sGetWelcomeSplashBackgroundColor];
}

-(void) prepareForAnimation {
  self.mLetterLabels = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getSplashLabelArray:self];
}
  
-(void) animatePhase3:(UIView*)l_ delay:(CGFloat)delay_ completionBlock_:(void (^)())completionBlock_ {
  
  [UIView animateWithDuration:0.3
                   animations:^{
                     l_.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                   }
                   completion:^ (BOOL inFinished) {
                     if (inFinished) {
                       completionBlock_();
                     }
                   }];
}

-(void) animatePhase2:(UIView*)l_ delay:(CGFloat)delay_ completionBlock_:(void (^)())completionBlock_ {
  
  [UIView animateWithDuration:0.3
                   animations:^{
                     l_.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
                   }
                   completion:^ (BOOL finished) {
                     [self animatePhase3:l_ delay:delay_ completionBlock_:completionBlock_];
                   }];
}

-(void) animatePhase1:(UIView*)inLabel delay:(CGFloat)delay_ completionBlock_:(void (^)())completionBlock_ {
  [UIView animateWithDuration:0.30
                        delay: delay_
                      options: UIViewAnimationOptionCurveEaseIn
                   animations: ^{
                     inLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
                   }
                   completion:^(BOOL inState) {
                     [self animatePhase2:inLabel  delay:delay_ completionBlock_:completionBlock_];
                   }];
}

-(void) animatePhase0:(void (^)())completionBlock_ {
  // Now, start to animate them all...
  double C_DELAY_LETTER_BY = 0.06;
  
  double delay = 0.0;
  
  __block int letterCompletionCountdown = (int)mLetterLabels.count;
  
  for (UILabel *theLabel in mLetterLabels) {
    [self animatePhase1:theLabel
                  delay: delay
       completionBlock_:^ {
         letterCompletionCountdown--;
         if (letterCompletionCountdown == 0) {
           // Got the last letter!
           completionBlock_();
         }
       }];
    delay += C_DELAY_LETTER_BY;
  }
}
  
  // Scale out, and fade-out, all words!
-(void) scaleOutAnimation:(void (^)())completionBlock_ {
  
  CGFloat C_ANIMATION_SCALE = 10.0;
  [UIView animateWithDuration:0.75
                   animations:^{
                     for (UILabel *theWord in self.mLetterLabels) {
                       theWord.transform = CGAffineTransformScale(CGAffineTransformIdentity, C_ANIMATION_SCALE, C_ANIMATION_SCALE);
                       theWord.alpha = 0.0;
                     }
                   }
                   completion:^(BOOL finished) {
                     completionBlock_();
                   }];
}
  
-(void) strategyAnimationOfWordsWithFadeInThenScaleOut:(void (^)())completionBlock_ {
  
  [UIView animateWithDuration:1.0
                   animations: ^{
                     // Start by fading-in all the letters...
                     for (UILabel *theLabel in self.mLetterLabels) {
                       theLabel.alpha = 1.0;
                     }
                   }
                   completion:^(BOOL finished) {
                     // Now, pulse the letters in/out
                     [self animatePhase0:^{
                       // Now, apply the final animation - where we scale-out all words!
                       [self scaleOutAnimation:^() {
                         // To reach here, all the animations are done!
                         completionBlock_();
                       }];
                     }];
                   }
   ];
}

-(void) callWhenViewControllerResized:(void (^)())completionBlock_ {
  [self prepareForAnimation];
  
  // Start with all words hidden...
  for (UILabel *theLabel in self.mLetterLabels) {
    theLabel.alpha = 0.0;
  }
 
  [self strategyAnimationOfWordsWithFadeInThenScaleOut:^() {
    // All animations are complete - we can now leave this splash view, if we want!
    completionBlock_();
  }];
}
@end