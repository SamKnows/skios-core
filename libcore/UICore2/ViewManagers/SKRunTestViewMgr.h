//
//  SKRunTestViewMgr.h
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

#define ACTION_RUN      1
#define ACTION_RANGE    2
#define ACTION_ALREADY_EXCEEDED_PRESS_OK_TO_CONTINUE   3
#define ACTION_NETWORKTYPE   4
#define ACTION_MENU   5
#define ACTION_WILL_BE_EXCEEDED_PRESS_OK_TO_CONTINUE   6
#define ACTION_CANCEL_CONFIRMATION  7

#define C_NUMBER_OF_PASSIVE_METRICS 7
#define C_NUMBER_OF_METRICS (C_NUMBER_OF_TESTS + C_NUMBER_OF_PASSIVE_METRICS)
#define C_NUMBER_OF_TESTS    5
#define C_DOWNLOAD_TEST 0
#define C_UPLOAD_TEST   1
#define C_LATENCY_TEST  2
#define C_LOSS_TEST 3
#define C_JITTER_TEST 4

#define C_PM_CARRIER_NAME   0
#define C_PM_CARRIER_COUNTRY    1
#define C_PM_CARRIER_NETWORK    2
#define C_PM_CARRIER_ISO    3
#define C_PM_PHONE  4
#define C_PM_OS 5
#define C_PM_TARGET 6

//#define C_METRICS_STATUS_EMPTY  0
//#define C_METRICS_STATUS_OK 1
//#define C_METRICS_STATUS_CANCELLED  2
//#define C_METRICS_STATUS_ERROR  3
#define C_GUI_UPDATE_INTERVAL   0.2

#define C_SHARE_FACEBOOK    1
#define C_SHARE_TWITTER    2
#define C_SHARE_MAIL    3
#define C_SHARE_SAVE    4

@class SKATestOverviewMetrics;

@interface SKRunTestViewMgr : UIView <pTYMAOwner, SKAutotestObserverDelegate, pActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>
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

@property (nonatomic, weak) UIView* masterView;

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
-(void)intialiseViewOnMasterView:(UIView*)masterView_;
-(void)performLayout;

@end

@interface SKATestOverviewMetrics : NSObject

@property (nonatomic) int number;
//@property (nonatomic) int status;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* value;

-(id)initWithMetricsNumber:(int)metricsNumber;

@end


