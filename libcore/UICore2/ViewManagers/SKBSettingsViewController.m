//
//  SKBSettingsViewController.m
//  SKCore
//
//  Created by Pete Cole on 29/09/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBSettingsViewController.h"

#import "SKSettingsMgr.h"

@interface SKBSettingsViewController ()

@end

@implementation SKBSettingsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  [self.settingsManagerView setColoursAndShowHideElements];
  
  ((UIViewWithGradient*)self.view).innerColor = [[cTabController globalInstance] getInnerColor];
  ((UIViewWithGradient*)self.view).outerColor = [[cTabController globalInstance] getOuterColor];
}

-(void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  //[self.settingsManagerView.tDataCapValue becomeFirstResponder];
}

@end
