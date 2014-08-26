//
//  SKSummaryViewMgr.h
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

@interface SKSummaryViewMgr : UIView <pActionSheetDelegate>
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

@property (weak, nonatomic) IBOutlet UILabel *lDownloadName;
@property (weak, nonatomic) IBOutlet UILabel *lDownloadAvgUnit;
@property (weak, nonatomic) IBOutlet UILabel *lDownloadBstUnit;
@property (weak, nonatomic) IBOutlet UILabel *lDownloadAvg;
@property (weak, nonatomic) IBOutlet UILabel *lDownloadBst;

@property (weak, nonatomic) IBOutlet UILabel *lUploadName;
@property (weak, nonatomic) IBOutlet UILabel *lUploadAvgUnit;
@property (weak, nonatomic) IBOutlet UILabel *lUploadBstUnit;
@property (weak, nonatomic) IBOutlet UILabel *lUploadAvg;
@property (weak, nonatomic) IBOutlet UILabel *lUploadBst;

@property (weak, nonatomic) IBOutlet UILabel *lLatencyAvgUnit;
@property (weak, nonatomic) IBOutlet UILabel *lLatencyBstUnit;
@property (weak, nonatomic) IBOutlet UILabel *lLatencyName;
@property (weak, nonatomic) IBOutlet UILabel *lLatencyAvg;
@property (weak, nonatomic) IBOutlet UILabel *lLatencyBst;

@property (weak, nonatomic) IBOutlet UILabel *lLossAvgUnit;
@property (weak, nonatomic) IBOutlet UILabel *lLossBstUnit;
@property (weak, nonatomic) IBOutlet UILabel *lLossName;
@property (weak, nonatomic) IBOutlet UILabel *lLossAvg;
@property (weak, nonatomic) IBOutlet UILabel *lLossBst;

@property (weak, nonatomic) IBOutlet UILabel *lJitterAvgUnit;
@property (weak, nonatomic) IBOutlet UILabel *lJitterBstUnit;
@property (weak, nonatomic) IBOutlet UILabel *lJitterName;
@property (weak, nonatomic) IBOutlet UILabel *lJitterAvg;
@property (weak, nonatomic) IBOutlet UILabel *lJitterBst;

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

@property (strong, nonatomic) IBOutlet Graphing *vChart;


- (IBAction)B_NetworkType:(id)sender;
- (IBAction)B_Period:(id)sender;

-(void)intialiseViewOnMasterView:(UIView*)masterView_;
-(void)performLayout;

@end
