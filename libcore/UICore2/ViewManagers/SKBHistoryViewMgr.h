//
//  SKBHistoryViewMgr.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
//#import <MessageUI/MFMailComposeViewController.h>
#import "cActionSheet.h"
#import "../tabCells/SKBTestOverviewCell.h"

@class SKATestResults;

#define C_FILTER_NETWORKTYPE_WIFI   1
#define C_FILTER_NETWORKTYPE_GSM   2
#define C_FILTER_NETWORKTYPE_ALL   3

#define C_FILTER_PERIOD_1DAY   1
#define C_FILTER_PERIOD_1WEEK   2
#define C_FILTER_PERIOD_1MONTH  3
#define C_FILTER_PERIOD_3MONTHS  4
#define C_FILTER_PERIOD_1YEAR  5

@interface SKBHistoryViewMgr : UIView <UITableViewDataSource, UITableViewDelegate, pActionSheetDelegate, MFMailComposeViewControllerDelegate>
{
    NSMutableArray *arrTestsList;
    
    SKATestResults* selectedTest;
    
    int currentFilterNetworkType;
    int currentFilterPeriod;
    
    int testHeight;
    int expandedRow;
    
    SKBTestOverviewCell* cell2putBack;
    UIView* view2putBack;
    CGRect originalCellFrame;
    
    NSMutableArray* arrPassiveLabelsAndValues;
    float y;
}

@property (nonatomic, weak) UIView* masterView;
@property (nonatomic, weak) UIViewController* masterViewController;

@property (weak, nonatomic) IBOutlet UITableView *tvTests;
@property (weak, nonatomic) IBOutlet UIButton *btBack;

@property (nonatomic, strong) cActionSheet* casNetworkType;
@property (nonatomic, strong) cActionSheet* casPeriod;

+(SKATestResults *) sCreateNewTstToShareExternal;
+(SKATestResults *) sGetTstToShareExternal;

-(void)shareTest:(SKATestResults*)testResult;
- (IBAction)B_Back:(id)sender;
- (IBAction)B_Share:(id)sender;

-(void)intialiseViewOnMasterViewController:(UIViewController*)masterViewController_;
-(void)setColoursAndShowHideElements;
-(void)performLayout;

@property (weak, nonatomic) IBOutlet UIButton *btNetworkType;
@property (weak, nonatomic) IBOutlet UIButton *btPeriod;
@property (weak, nonatomic) IBOutlet UIButton *btGraph;
@property (weak, nonatomic) IBOutlet UIButton *btShare;

//@property (retain, nonatomic) IBOutlet NSLayoutConstraint* backButtonHeightConstraint;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint* shareButtonTopOffsetConstraint;

@end
