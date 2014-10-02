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
  
  ((UIViewWithGradient*)self.view).innerColor = [cTabController sGetInnerColor];
  ((UIViewWithGradient*)self.view).outerColor = [cTabController sGetOuterColor];
}

@end
