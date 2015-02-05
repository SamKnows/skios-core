//
//  SKBMainViewTabBarController.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBMainViewTabBarController.h"

@interface SKBMainViewTabBarController ()

@end

@implementation SKBMainViewTabBarController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
//  ((UIViewWithGradient*)self.view).innerColor = [SKAppColourScheme sGetInnerColor];
//  ((UIViewWithGradient*)self.view).outerColor = [SKAppColourScheme sGetOuterColor];
 
  for (UITabBarItem *item in self.tabBar.items) {
    if ([item.title isEqualToString:@"Run"]) {
      [item setTitle:sSKCoreGetLocalisedString(@"Run")];
    } else if ([item.title isEqualToString:@"Results"]) {
      [item setTitle:sSKCoreGetLocalisedString(@"Results")];
    } else if ([item.title isEqualToString:@"Summary"]) {
      [item setTitle:sSKCoreGetLocalisedString(@"Summary")];
    } else if ([item.title isEqualToString:@"Settings"]) {
      [item setTitle:sSKCoreGetLocalisedString(@"Settings")];
    } else {
      SK_ASSERT(false);
    }
  }
 
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] overrideTabBarColoursOnStart:self];
}


-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
}

@end
