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
    [item setTitle:NSLocalizedString(item.title, @"")];
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
