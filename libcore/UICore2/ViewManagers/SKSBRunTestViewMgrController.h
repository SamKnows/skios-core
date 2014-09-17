//
//  SKSBRunTestViewMgrController.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Reusable/TYMActivityIndicatorView/TYMActivityIndicatorView.h"
#import "../tabCells/SKASimpleResultCell2.h"
#import "../tabCells/SKATestOverviewCell2.h"
#import "cActionSheet.h"
#import "cAnimatedStatusView.h"
#import "SKHistoryViewMgr.h"
#import "SKTestResults.h"

@class SKATestOverviewMetrics;
@class UIWelcomeView;

@interface SKSBRunTestViewMgrController : UIViewController <pTYMAOwner, SKAutotestObserverDelegate, pActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>
{
    bool isRunning;
    int testCells2Show;
    SKHistoryViewMgr* historyViewMgr;
    
    float progressDownload;
    float progressUpload;
    float progressLatencyLoss;
    
    //    id <SKARunTestsDelegate> delegate;
    
    SKAAutotest *autoTest;
    //    NSMutableArray *resultsArray;
    
    UIBackgroundTaskIdentifier btid;
    
    int64_t dataStart;
    int64_t dataEnd;
    
    NSMutableArray* testResultsArray;
    BOOL showPassiveMetrics;
    
    float latencySUM;
    int latencyCNT;
    
    int layoutCurrent;
    
    NSInteger connectionStatus;
    SKATestResults* selectedTest;
}

@property (nonatomic, strong) cActionSheet* casTestTypes;
@property (weak, nonatomic) IBOutlet cAnimatedStatusView *casStatusView;
@property (nonatomic, strong) cActionSheet* casShare;

@property (atomic) double timeOfLastUIUpdate;

@property (weak, nonatomic) IBOutlet UILabel *lClosest;

@property (weak, nonatomic) IBOutlet TYMActivityIndicatorView *tmActivityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tvCurrentResults;
@property (weak, nonatomic) IBOutlet UIView *vProgressView;
@property (weak, nonatomic) IBOutlet UIButton *btSelectTests;
@property (strong, nonatomic) UIButton *btShare;

@property (nonatomic) int testTypes2Execute;
@property (nonatomic) int numberOfTests2Execute;

@property BOOL continuousTesting;

@property SKAAppDelegate *appDelegate;
@property NSString *networkType;

//@property (nonatomic, strong) NSMutableArray *resultsArray;

@property (nonatomic, strong) NSMutableDictionary*resultsDictionary;

@property (nonatomic) double TRES_Download;
@property (nonatomic) double TRES_Upload;
@property (nonatomic) double TRES_Latency;
@property (nonatomic) double TRES_Loss;

@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@property BOOL isConnected;

-(IBAction)B_SelectTests:(id)sender;
-(void)intialiseViewOnMasterView;

//
// Added for storyboard rework...
//
@property (weak, nonatomic) IBOutlet UIWelcomeView *vWelcomeView;
@property (weak, nonatomic) IBOutlet UIViewWithGradient *vC1;
//@property (weak, nonatomic) IBOutlet UIViewWithGradient *vC2;
//@property (weak, nonatomic) IBOutlet UIViewWithGradient *vC3;
//@property (weak, nonatomic) IBOutlet UIViewWithGradient *vC4;
//@property (weak, nonatomic) IBOutlet UIViewWithGradient *vC5;

@end

#import "SKATestOverviewMetrics.h"


