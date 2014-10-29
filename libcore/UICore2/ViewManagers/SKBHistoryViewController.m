//
//  SKBHistoryViewController.m
//  SKCore
//
//  Created by Pete Cole on 29/09/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBHistoryViewController.h"

#import "SKBHistoryViewMgr.h"

@interface SKBHistoryViewController ()

@end

@implementation SKBHistoryViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  [self.historyManagerView intialiseViewOnMasterViewController:self];
  [self.historyManagerView setColoursAndShowHideElements];
  
  ((UIViewWithGradient*)self.view).innerColor = [SKAppColourScheme sGetInnerColor];
  ((UIViewWithGradient*)self.view).outerColor = [SKAppColourScheme sGetOuterColor];
 
  // http://stackoverflow.com/questions/18775874/ios-7-status-bar-overlaps-the-view
  self.edgesForExtendedLayout = UIRectEdgeNone;
  self.extendedLayoutIncludesOpaqueBars = NO;
  self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // Update any results...
  [[NSNotificationCenter defaultCenter]
   postNotificationName:@"TestListNeedsUpdate"
   object:self];
}

@end
