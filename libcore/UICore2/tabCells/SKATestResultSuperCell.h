//
//  SKATestResultSuperCell.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Reusable/CActivityBlinking/CActivityBlinking.h"

//#import "../ViewManagers/SKRunTestViewMgr.h"

@class SKATestOverviewMetrics;

@interface SKATestResultSuperCell : UITableViewCell

@property (strong, nonatomic) SKATestOverviewMetrics* cellMetrics;

@property (strong, nonatomic) UIView* vBackground;

@property (strong, nonatomic) UILabel *lMeasureName;
@property (strong, nonatomic) UILabel *lResult;
@property (strong, nonatomic) UIActivityIndicatorView *aiActivity;

@property (nonatomic) int networkType;
@property (strong, nonatomic) SKATestOverviewMetrics* cellResultDownload;
@property (strong, nonatomic) SKATestOverviewMetrics* cellResultUpload;
@property (strong, nonatomic) SKATestOverviewMetrics* cellResultLatency;
@property (strong, nonatomic) SKATestOverviewMetrics* cellResultLoss;
@property (strong, nonatomic) SKATestOverviewMetrics* cellResultJitter;
@property (strong, nonatomic) NSDate* testDateTime;

@property (strong, nonatomic) UILabel *lDownloadLabel;
@property (strong, nonatomic) UILabel *lUploadLabel;

@property (strong, nonatomic) UILabel *lMbpsLabel4Download;
@property (strong, nonatomic) UILabel *lMbpsLabel4Upload;
@property (strong, nonatomic) UILabel *lLatencyLabel;
@property (strong, nonatomic) UILabel *lLossLabel;
@property (strong, nonatomic) UILabel *lJitterLabel;

@property (strong, nonatomic) UILabel *lDateOfTest;
@property (strong, nonatomic) UILabel *lTimeOfTest;

@property (strong, nonatomic) UILabel *lResultDownload;
@property (strong, nonatomic) UILabel *lResultUpload;
@property (strong, nonatomic) UILabel *lResultLatency;
@property (strong, nonatomic) UILabel *lResultLoss;
@property (strong, nonatomic) UILabel *lResultJitter;

@property (strong, nonatomic) UIImageView *ivNetworkType;
@property (strong, nonatomic) UIImageView *ivArrowDownload;
@property (strong, nonatomic) UIImageView *ivArrowUpload;

@property (strong, nonatomic) CActivityBlinking* aiDownload;
@property (strong, nonatomic) CActivityBlinking* aiUpload;
@property (strong, nonatomic) CActivityBlinking* aiLatency;
@property (strong, nonatomic) CActivityBlinking* aiLoss;
@property (strong, nonatomic) CActivityBlinking* aiJitter;

-(void)layoutCellActive;
-(void)layoutCellPassive;

@end
