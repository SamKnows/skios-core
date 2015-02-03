//
//  SKBRunTestViewMgrController.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Reusable/CGaugeView/CGaugeView.h"
#import "../tabCells/SKBSimpleResultCell.h"
#import "../tabCells/SKBTestOverviewCell.h"
#import "CActionSheet.h"
#import "CAnimatedStatusView.h"
#import "SKBHistoryViewMgr.h"
#import "SKTestResults.h"

@class SKBTestResultValue;
@class SKSplashView;

@interface SKBRunTestViewMgrController : UIViewController <CGaugeViewOwnerProtocol, SKAutotestObserverDelegate, pActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>
{
    bool isRunning;
    int testCells2Show;
    //SKBHistoryViewMgr* historyViewMgr;
    
    float progressDownload;
    float progressUpload;
    float progressLatencyLoss;
    
    //    id <SKARunTestsDelegate> delegate;
    
    SKAutotest *autoTest;
    //    NSMutableArray *resultsArray;
    
    UIBackgroundTaskIdentifier btid;
    
    int64_t dataStart;
    int64_t dataEnd;
    
    BOOL showPassiveMetrics;
    
    float latencySUM;
    int latencyCNT;
    
    int layoutCurrent;
    
    NSInteger connectionStatus;
}

@property NSMutableArray* mTestResultsArray;
@property (nonatomic, strong) CActionSheet* casTestTypes;
@property (weak, nonatomic) IBOutlet CAnimatedStatusView *casStatusView;
@property (nonatomic, strong) CActionSheet* casShare;

@property (atomic) double timeOfLastUIUpdate;

@property (weak, nonatomic) IBOutlet UILabel *mPressTheStartButtonLabel;

@property (weak, nonatomic) IBOutlet CGaugeView *tmActivityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tvCurrentResults;
@property (weak, nonatomic) IBOutlet UILabel *warningLabelBeforeTableFirstShown;
@property (weak, nonatomic) IBOutlet UIView *vProgressView;
@property (weak, nonatomic) IBOutlet UIButton *btSelectTests;
@property (weak, nonatomic) IBOutlet UIButton *btShare;

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

-(BOOL) getIsConnected;

-(IBAction)B_SelectTests:(id)sender;
-(void)initialiseViewOnMasterView;

//
// Added for storyboard rework...
//
//@property (weak, nonatomic) IBOutlet UIViewWithGradient *vC1;
//@property (weak, nonatomic) IBOutlet UIViewWithGradient *vC2;
//@property (weak, nonatomic) IBOutlet UIViewWithGradient *vC3;
//@property (weak, nonatomic) IBOutlet UIViewWithGradient *vC4;
//@property (weak, nonatomic) IBOutlet UIViewWithGradient *vC5;
@property (weak, nonatomic) IBOutlet UIImageView *optionalTopLeftLogoView;

@end

#import "SKBTestResultValue.h"


