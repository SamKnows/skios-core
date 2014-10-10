//
//  SKSBMainViewTabBarController.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKSBMainViewTabBarController.h"

@interface SKSBMainViewTabBarController ()

@end

@implementation SKSBMainViewTabBarController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  //[self.infoManagerView setColoursAndShowHideElements];
  
//  ((UIViewWithGradient*)self.view).innerColor = [cTabController sGetInnerColor];
//  ((UIViewWithGradient*)self.view).outerColor = [cTabController sGetOuterColor];
 
  for (UITabBarItem *item in self.tabBar.items) {
    if ([item.title isEqualToString:@"Run"]) {
      [item setTitle:NSLocalizedString(@"Run", nil)];
    } else if ([item.title isEqualToString:@"Results"]) {
      [item setTitle:NSLocalizedString(@"Results", nil)];
    } else if ([item.title isEqualToString:@"Summary"]) {
      [item setTitle:NSLocalizedString(@"Summary", nil)];
    } else if ([item.title isEqualToString:@"Settings"]) {
      [item setTitle:NSLocalizedString(@"Settings", nil)];
    } else {
      SK_ASSERT(false);
    }
  }
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
