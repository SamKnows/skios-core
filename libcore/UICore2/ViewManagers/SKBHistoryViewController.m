//
//  SKBHistoryViewController.m
//  SKCore
//
//  Created by Pete Cole on 29/09/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBHistoryViewController.h"

#import "SKHistoryViewMgr.h"

@interface SKBHistoryViewController ()

@end

@implementation SKBHistoryViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  [self.historyManagerView intialiseViewOnMasterView:self.view];
  [self.historyManagerView setColoursAndShowHideElements];
  
  ((UIViewWithGradient*)self.view).innerColor = [cTabController sGetInnerColor];
  ((UIViewWithGradient*)self.view).outerColor = [cTabController sGetOuterColor];
}

-(void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  //[self.historyManagerView.tDataCapValue becomeFirstResponder];
}

@end
