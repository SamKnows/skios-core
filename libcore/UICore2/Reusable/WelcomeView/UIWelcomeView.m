//
//  UIWelcomeView.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "UIWelcomeView.h"

@implementation UIWelcomeView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
  }
  return self;
}

#define C_COLOR_OF_WELCOME_TEXT 1

-(void)initializeWelcomeText
{
  if (isInitialised) return;
  
  self.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:159.0/255.0 blue:227.0/255.0 alpha:1];
  
  //NSString *cFontName = @"RobotoBold";
  const CGFloat cFontSizeiPhone = 83;
  const CGFloat cFontSizeiPad = 200;
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
  {
    //UIFont *font = [UIFont fontWithName:cFontName size:cFontSizeiPhone];
    UIFont *font = [UIFont systemFontOfSize:cFontSizeiPhone];
    
    self.l_S1 = [[UILabel alloc] initWithFrame:CGRectMake(17, 199, 100, 100)];
    self.l_S1.font = font;
    self.l_S1.textColor = [UIColor colorWithWhite:1 alpha:1];
    self.l_S1.text = @"S";
    self.l_S1.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_S1];
    
    self.l_A = [[UILabel alloc] initWithFrame:CGRectMake(65, 199, 100, 100)];
    self.l_A.font = font;
    self.l_A.textColor = [UIColor colorWithWhite:1 alpha:1];
    self.l_A.text = @"a";
    self.l_A.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_A];
    
    self.l_M = [[UILabel alloc] initWithFrame:CGRectMake(120, 199, 100, 100)];
    self.l_M.font = font;
    self.l_M.textColor = [UIColor colorWithWhite:1 alpha:1];
    self.l_M.text = @"m";
    self.l_M.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_M];
    
    self.l_K = [[UILabel alloc] initWithFrame:CGRectMake(17, 265, 100, 100)];
    self.l_K.font = font;
    self.l_K.textColor = [UIColor colorWithWhite:1 alpha:1];
    self.l_K.text = @"K";
    self.l_K.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_K];
    
    self.l_N = [[UILabel alloc] initWithFrame:CGRectMake(65, 265, 100, 100)];
    self.l_N.font = font;
    self.l_N.textColor = [UIColor colorWithWhite:1 alpha:1];
    self.l_N.text = @"n";
    self.l_N.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_N];
    
    self.l_O = [[UILabel alloc] initWithFrame:CGRectMake(110, 265, 100, 100)];
    self.l_O.font = font;
    self.l_O.textColor = [UIColor colorWithWhite:1 alpha:1];
    self.l_O.text = @"o";
    self.l_O.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_O];
    
    self.l_W = [[UILabel alloc] initWithFrame:CGRectMake(167, 265, 100, 100)];
    self.l_W.font = font;
    self.l_W.textColor = [UIColor colorWithWhite:1 alpha:1];
    self.l_W.text = @"w";
    self.l_W.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_W];
    
    self.l_S2 = [[UILabel alloc] initWithFrame:CGRectMake(220, 265, 100, 100)];
    self.l_S2.font = font;
    self.l_S2.textColor = [UIColor colorWithWhite:1 alpha:1];
    self.l_S2.text = @"s";
    self.l_S2.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_S2];
  }
  else
  {
    //UIFont *font = [UIFont fontWithName:cFontName size:cFontSizeiPad];
    UIFont *font = [UIFont systemFontOfSize:cFontSizeiPad];
    
    self.l_S1 = [[UILabel alloc] initWithFrame:CGRectMake(48, 302, 200, 200)];
    self.l_S1.font = font;
    self.l_S1.textColor = [UIColor colorWithWhite:C_COLOR_OF_WELCOME_TEXT alpha:1];
    self.l_S1.text = @"S";
    self.l_S1.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_S1];
    
    self.l_A = [[UILabel alloc] initWithFrame:CGRectMake(158, 302, 200, 200)];
    self.l_A.font = font;
    self.l_A.textColor = [UIColor colorWithWhite:C_COLOR_OF_WELCOME_TEXT alpha:1];
    self.l_A.text = @"a";
    self.l_A.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_A];
    
    self.l_M = [[UILabel alloc] initWithFrame:CGRectMake(296, 302, 200, 200)];
    self.l_M.font = font;
    self.l_M.textColor = [UIColor colorWithWhite:C_COLOR_OF_WELCOME_TEXT alpha:1];
    self.l_M.text = @"m";
    self.l_M.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_M];
    
    self.l_K = [[UILabel alloc] initWithFrame:CGRectMake(48, 470, 200, 200)];
    self.l_K.font = font;
    self.l_K.textColor = [UIColor colorWithWhite:C_COLOR_OF_WELCOME_TEXT alpha:1];
    self.l_K.text = @"K";
    self.l_K.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_K];
    
    self.l_N = [[UILabel alloc] initWithFrame:CGRectMake(163, 470, 200, 200)];
    self.l_N.font = font;
    self.l_N.textColor = [UIColor colorWithWhite:C_COLOR_OF_WELCOME_TEXT alpha:1];
    self.l_N.text = @"n";
    self.l_N.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_N];
    
    self.l_O = [[UILabel alloc] initWithFrame:CGRectMake(274, 470, 200, 200)];
    self.l_O.font = font;
    self.l_O.textColor = [UIColor colorWithWhite:C_COLOR_OF_WELCOME_TEXT alpha:1];
    self.l_O.text = @"o";
    self.l_O.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_O];
    
    self.l_W = [[UILabel alloc] initWithFrame:CGRectMake(412, 470, 200, 200)];
    self.l_W.font = font;
    self.l_W.textColor = [UIColor colorWithWhite:C_COLOR_OF_WELCOME_TEXT alpha:1];
    self.l_W.text = @"w";
    self.l_W.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_W];
    
    self.l_S2 = [[UILabel alloc] initWithFrame:CGRectMake(538, 470, 200, 200)];
    self.l_S2.font = font;
    self.l_S2.textColor = [UIColor colorWithWhite:C_COLOR_OF_WELCOME_TEXT alpha:1];
    self.l_S2.text = @"s";
    self.l_S2.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.l_S2];
  }
  
  isInitialised = YES;
}

-(void)animateLetter:(UILabel*)l_ withDelay:(float)delay_ onCompletion: (void (^)())completionBlock_
{
  [UIView animateWithDuration:0.30
                        delay:delay_
                      options:UIViewAnimationOptionCurveEaseIn
                   animations:^{
                     l_.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
                   } completion:^(BOOL finished) {
                     [UIView animateWithDuration:0.3
                                      animations:
                      ^{
                        l_.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
                      }
                                      completion:^(BOOL finished) {
                                        
                                        [UIView animateWithDuration:0.3
                                                         animations:
                                         ^{
                                           l_.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                                         }
                                                         completion:^(BOOL finished) {
                                                           
                                                           if (finished && completionBlock_ != nil)
                                                             completionBlock_();
                                                         }];
                                      }];
                   }];
}

-(void)startAnimationOnCompletion:(void (^)())completionBlock_
{
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
  {
    self.l_S1.frame = CGRectMake(17, 199, 100, 100);
    self.l_A.frame = CGRectMake(65, 199, 100, 100);
    self.l_M.frame = CGRectMake(120, 199, 100, 100);
    self.l_K.frame = CGRectMake(17, 265, 100, 100);
    self.l_N.frame = CGRectMake(65, 265, 100, 100);
    self.l_O.frame = CGRectMake(110, 265, 100, 100);
    self.l_W.frame = CGRectMake(167, 265, 100, 100);
    self.l_S2.frame = CGRectMake(220, 265, 100, 100);
  }
  else
  {
    self.l_S1.frame = CGRectMake(48, 302, 200, 200);
    self.l_A.frame = CGRectMake(158, 302, 200, 200);
    self.l_M.frame = CGRectMake(296, 302, 200, 200);
    self.l_K.frame = CGRectMake(48, 470, 200, 200);
    self.l_N.frame = CGRectMake(163, 470, 200, 200);
    self.l_O.frame = CGRectMake(274, 470, 200, 200);
    self.l_W.frame = CGRectMake(412, 470, 200, 200);
    self.l_S2.frame = CGRectMake(538, 470, 200, 200);
  }
  
#define C_DELAY_LETTER_BY   0.06
  
  [self animateLetter:self.l_S1 withDelay:0 onCompletion:nil];
  [self animateLetter:self.l_A withDelay:1 * C_DELAY_LETTER_BY onCompletion:nil];
  [self animateLetter:self.l_M withDelay:2 * C_DELAY_LETTER_BY onCompletion:nil];
  [self animateLetter:self.l_K withDelay:3 * C_DELAY_LETTER_BY onCompletion:nil];
  [self animateLetter:self.l_N withDelay:4 * C_DELAY_LETTER_BY onCompletion:nil];
  [self animateLetter:self.l_O withDelay:5 * C_DELAY_LETTER_BY onCompletion:nil];
  [self animateLetter:self.l_W withDelay:6 * C_DELAY_LETTER_BY onCompletion:nil];
  [self animateLetter:self.l_S2 withDelay:7 * C_DELAY_LETTER_BY onCompletion:^{
    
    [self animation2OnCompletion:completionBlock_];
    
  }];
}

-(void)animation2OnCompletion:(void (^)())completionBlock_
{
  //#define C_ANIMATION_LEFT_SHIFT  0
  //#define C_ANIMATION_RIGHT_SHIFT  0
#define C_ANIMATION_LEFT_SHIFT  210
#define C_ANIMATION_RIGHT_SHIFT  280
  
#define C_ANIMATION_LEFT_UP  0
#define C_ANIMATION_RIGHT_DOWN  0
  //#define C_ANIMATION_LEFT_UP  200
  //#define C_ANIMATION_RIGHT_DOWN  200
  
#define C_ANIMATION_SCALE   10
  
  [UIView animateWithDuration:0.75 animations:^{
    
    self.l_S1.transform = CGAffineTransformScale(CGAffineTransformIdentity, C_ANIMATION_SCALE, C_ANIMATION_SCALE);
    self.l_A.transform = CGAffineTransformScale(CGAffineTransformIdentity, C_ANIMATION_SCALE, C_ANIMATION_SCALE);
    self.l_M.transform = CGAffineTransformScale(CGAffineTransformIdentity, C_ANIMATION_SCALE, C_ANIMATION_SCALE);
    
    self.l_K.transform = CGAffineTransformScale(CGAffineTransformIdentity, C_ANIMATION_SCALE, C_ANIMATION_SCALE);
    self.l_N.transform = CGAffineTransformScale(CGAffineTransformIdentity, C_ANIMATION_SCALE, C_ANIMATION_SCALE);
    self.l_O.transform = CGAffineTransformScale(CGAffineTransformIdentity, C_ANIMATION_SCALE, C_ANIMATION_SCALE);
    self.l_W.transform = CGAffineTransformScale(CGAffineTransformIdentity, C_ANIMATION_SCALE, C_ANIMATION_SCALE);
    self.l_S2.transform = CGAffineTransformScale(CGAffineTransformIdentity, C_ANIMATION_SCALE, C_ANIMATION_SCALE);
    
    self.l_S1.alpha = 0;
    self.l_A.alpha = 0;
    self.l_M.alpha = 0;
    
    self.l_K.alpha = 0;
    self.l_N.alpha = 0;
    self.l_O.alpha = 0;
    self.l_W.alpha = 0;
    self.l_S2.alpha = 0;
    
    self.alpha = 0;
    
  } completion:^(BOOL finished) {
    
    if (completionBlock_ != nil) completionBlock_();
    
  }];
}

@end
