//
//  SKSplashVC.m
//  SKCore
//
//  Created by Pete Cole on 09/10/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKSplashVC.h"

#import "UIWelcomeView.h"
#import "UIViewWithGradient.h"
#import "cTabController.h"

@interface SKSplashVC ()

@property (weak, nonatomic) IBOutlet UIWelcomeView *vWelcomeView;

@end

@implementation SKSplashVC

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //[[UITabBar appearance] setBarTintColor:[UIColor yellowColor]];
  
  // The main background view...
  //self.view.backgroundColor = [UIColor clearColor];
  ((UIViewWithGradient*)self.view).innerColor = [cTabController sGetInnerColor];
  ((UIViewWithGradient*)self.view).outerColor = [cTabController sGetOuterColor];
}

-(void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self.vWelcomeView initializeWelcomeText];
}

-(void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self.vWelcomeView startAnimationOnCompletion:^{
    
    [self SKSafePerformSegueWithIdentifier:@"segueFromSplashVC" sender:self];
//    
//    [UIView animateWithDuration:0.3 animations:^{
//      
//      self.vWelcomeView.alpha = 0;
//      
//    } completion:^(BOOL finished) {
//      
//      [self SKSafePerformSegueWithIdentifier:@"segueFromSplashVC" sender:self];
//      
//    }];
  }];
}

@end
