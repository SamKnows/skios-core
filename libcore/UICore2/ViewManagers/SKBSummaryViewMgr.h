//
//  SKBSummaryViewMgr.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Reusable/CActionSheet/cActionSheet.h"
#import "SKHistoryViewMgr.h"
#import "../tabCells/SKATestOverviewCell2.h"
#import "../Reusable/Graphing/Graphing.h"
#import "SKTestResults.h"

@interface SKBSummaryViewMgr : UIView <UITableViewDataSource, UITableViewDelegate, pActionSheetDelegate>
{
    NSMutableArray *arrTestsList;
    NSDate* previousDate;
    NSDate* dateTo;
    
    int currentFilterNetworkType;
    int currentFilterPeriod;
    
    int currentChartType;
    
    float downloadSUM;
    int downloadCNT;
    float downloadBEST;
    float uploadSUM;
    int uploadCNT;
    float uploadBEST;
    float latencySUM;
    int latencyCNT;
    float latencyBEST;
    float lossSUM;
    int lossCNT;
    float lossBEST;
    float jitterSUM;
    int jitterCNT;
    float jitterBEST;
}

@property (nonatomic, weak) UIView* masterView;

@property (weak, nonatomic) IBOutlet UIButton *btNetworkType;
@property (weak, nonatomic) IBOutlet UIButton *btPeriod;

@property (nonatomic, strong) cActionSheet* casNetworkType;
@property (nonatomic, strong) cActionSheet* casPeriod;
@property (nonatomic, strong) cActionSheet* casShare;

@property NSString *lDownloadName;
@property NSString *lDownloadAvgUnit;
@property NSString *lDownloadBstUnit;
@property NSString *lDownloadAvg;
@property NSString *lDownloadBst;

@property NSString *lUploadName;
@property NSString *lUploadAvgUnit;
@property NSString *lUploadBstUnit;
@property NSString *lUploadAvg;
@property NSString *lUploadBst;

@property NSString *lLatencyAvgUnit;
@property NSString *lLatencyBstUnit;
@property NSString *lLatencyName;
@property NSString *lLatencyAvg;
@property NSString *lLatencyBst;

@property NSString *lLossAvgUnit;
@property NSString *lLossBstUnit;
@property NSString *lLossName;
@property NSString *lLossAvg;
@property NSString *lLossBst;

@property NSString *lJitterAvgUnit;
@property NSString *lJitterBstUnit;
@property NSString *lJitterName;
@property NSString *lJitterAvg;
@property NSString *lJitterBst;

@property (weak, nonatomic) IBOutlet UILabel *lNumberOfRecords;

@property (weak, nonatomic) IBOutlet UIImageView *ivDownloadSymbol;
@property (weak, nonatomic) IBOutlet UIImageView *ivUploadSymbol;

@property (weak, nonatomic) IBOutlet UIView *vHeader;
@property (weak, nonatomic) IBOutlet UIView *vDownload;
@property (weak, nonatomic) IBOutlet UIView *vUpload;
@property (weak, nonatomic) IBOutlet UIView *vLatency;
@property (weak, nonatomic) IBOutlet UIView *vLoss;
@property (weak, nonatomic) IBOutlet UIView *vJitter;

@property (weak, nonatomic) IBOutlet UIImageView *ivDownloadChart;
@property (weak, nonatomic) IBOutlet UIImageView *ivUploadChart;
@property (weak, nonatomic) IBOutlet UIImageView *ivLatencyChart;
@property (weak, nonatomic) IBOutlet UIImageView *ivLossChart;
@property (weak, nonatomic) IBOutlet UIImageView *ivJitterChart;

@property (strong, nonatomic) UIButton *btDownloadSelect;
@property (strong, nonatomic) UIButton *btUploadSelect;
@property (strong, nonatomic) UIButton *btLatencySelect;
@property (strong, nonatomic) UIButton *btLossSelect;

@property (strong, nonatomic) IBOutlet UIView *vChart;

// New stuff!
@property (weak, nonatomic) IBOutlet UITableView *tvTests;
@property (weak, nonatomic) IBOutlet UIButton *btBack;
- (IBAction)B_Back:(id)sender;

- (IBAction)B_NetworkType:(id)sender;
- (IBAction)B_Period:(id)sender;

-(void)intialiseViewOnMasterView:(UIView*)masterView_;
-(void)setColoursAndShowHideElements;
//-(void)performLayout;

//@property (retain, nonatomic) IBOutlet NSLayoutConstraint* backButtonHeightConstraint;
//@property (retain, nonatomic) IBOutlet NSLayoutConstraint* backButtonTopOffsetConstraint;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint* chartHeightConstraint;

@end
