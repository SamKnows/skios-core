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
  
  [self.historyManagerView intialiseViewOnMasterViewController:self];
  [self.historyManagerView setColoursAndShowHideElements];
  
  ((UIViewWithGradient*)self.view).innerColor = [cTabController sGetInnerColor];
  ((UIViewWithGradient*)self.view).outerColor = [cTabController sGetOuterColor];
 
  // http://stackoverflow.com/questions/18775874/ios-7-status-bar-overlaps-the-view
  self.edgesForExtendedLayout = UIRectEdgeNone;
  self.extendedLayoutIncludesOpaqueBars = NO;
  self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  //[self.historyManagerView.tDataCapValue becomeFirstResponder];
}

@end
