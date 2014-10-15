//
//  SKBSplashVC.m
//  SKCore
//
//  Created by Pete Cole on 09/10/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBSplashVC.h"

#import "UIWelcomeView.h"
#import "UIViewWithGradient.h"
#import "SKAppColourScheme.h"

@interface SKBSplashVC ()

@property (weak, nonatomic) IBOutlet UIWelcomeView *vWelcomeView;

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
