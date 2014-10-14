//
//  SKBInfoViewController.m
//  SKCore
//
//  Created by Pete Cole on 29/09/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBInfoViewController.h"

#import "SKInfoViewMgr.h"
#import "SKSettingsMgr.h"

@interface SKBInfoViewController ()

@end

@implementation SKBInfoViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self.infoManagerView setColoursAndShowHideElements];
  
  ((UIViewWithGradient*)self.view).innerColor = [SKAppColourScheme sGetInnerColor];
  ((UIViewWithGradient*)self.view).outerColor = [SKAppColourScheme sGetOuterColor];
  
  self.title = sSKCoreGetLocalisedString(@"Menu_TermsOfUse");
}

-(void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self.navigationController setNavigationBarHidden:YES animated:NO];
}

@end
