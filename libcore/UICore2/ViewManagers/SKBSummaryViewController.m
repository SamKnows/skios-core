//
//  SKBSummaryViewController.m
//  SKCore
//
//  Created by Pete Cole on 29/09/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBSummaryViewController.h"

#import "SKBSummaryViewMgr.h"

@interface SKBSummaryViewController ()
@property (weak, nonatomic) IBOutlet UILabel *averageLabel;
@property (weak, nonatomic) IBOutlet UILabel *bestLabel;

@end

@implementation SKBSummaryViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  [self.summaryManagerView initialiseViewOnMasterView:self.view];
  [self.summaryManagerView setColoursAndShowHideElements];
  
  ((UIViewWithGradient*)self.view).innerColor = [SKAppColourScheme sGetInnerColor];
  ((UIViewWithGradient*)self.view).outerColor = [SKAppColourScheme sGetOuterColor];
  
  // http://stackoverflow.com/questions/18775874/ios-7-status-bar-overlaps-the-view
  self.edgesForExtendedLayout = UIRectEdgeNone;
  self.extendedLayoutIncludesOpaqueBars = NO;
  self.automaticallyAdjustsScrollViewInsets = NO;
  
  SK_ASSERT(self.averageLabel != nil);
  SK_ASSERT(self.bestLabel != nil);
  self.averageLabel.text = sSKCoreGetLocalisedString(@"Average");
  self.bestLabel.text = sSKCoreGetLocalisedString(@"Best");
  self.averageLabel.textColor = [UIColor whiteColor]; // [SKAppColourScheme sGetTableCellColourText];
  self.averageLabel.alpha = 1.0;
  self.bestLabel.textColor =[SKAppColourScheme sGetTableCellColourText];
  self.bestLabel.alpha = 1.0;
}

-(void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // Update any results...
  [[NSNotificationCenter defaultCenter]
   postNotificationName:@"TestListNeedsUpdate"
   object:self];
}

@end
