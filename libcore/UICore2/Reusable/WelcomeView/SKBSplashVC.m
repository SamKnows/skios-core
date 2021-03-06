//
//  SKBSplashVC.m
//  SKCore
//
//  Created by Pete Cole on 09/10/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBSplashVC.h"

#import "SKSplashView.h"
#import "UIViewWithGradient.h"
#import "SKAppColourScheme.h"

@interface SKBSplashVC ()

@property (weak, nonatomic) IBOutlet SKSplashView *vWelcomeView;

@end

@implementation SKBSplashVC

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // The main background view...
  ((UIViewWithGradient*)self.view).innerColor = [SKAppColourScheme sGetInnerColor];
  ((UIViewWithGradient*)self.view).outerColor = [SKAppColourScheme sGetOuterColor];
}

-(void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self.vWelcomeView initializeWelcomeText];
}

// This can be overridden!
-(void) segueFromSplashToMainVC {
  SKAppBehaviourDelegate *appDelegate = [SKAppBehaviourDelegate sGetAppBehaviourDelegate];
  if ( ([appDelegate getNewAppShowInitialTermsAndConditions] == YES) &&
      ([appDelegate hasNewAppAgreed] == NO)
      )
  {
    [self performSegueWithIdentifier:@"segueFromSplashVCToTerms" sender:self];
  } else {
    [self SKSafePerformSegueWithIdentifier:@"segueFromSplashVCToMain" sender:self];
  }
}

-(void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self.vWelcomeView callWhenViewControllerResized:^{
    [self segueFromSplashToMainVC];
//
//    [UIView animateWithDuration:0.3 animations:^{
//      
//      self.vWelcomeView.alpha = 0;
//      
//    } completion:^(BOOL finished) {
//      
//      [self SKSafePerformSegueWithIdentifier:@"segueFromSplashVCToMain" sender:self];
//      
//    }];
  }];
}

@end
