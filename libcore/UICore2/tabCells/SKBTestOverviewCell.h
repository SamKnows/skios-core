//
//  SKBTestOverviewCell.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "../Reusable/CActivityBlinking/CActivityBlinking.h"
#import "SKTestResults.h"

//#import "../ViewManagers/SKRunTestViewMgr.h"

@class SKBTestResultValue;

@interface SKBTestOverviewCell : UITableViewCell

{
  bool initialised;
  SKATestResults* testResult;
  //SKATestsListController2* testListController;
  
  float y;
}

@property (strong, nonatomic) SKBTestResultValue* cellMetrics;

@property (strong, nonatomic) UIView* vBackground;


@property (strong, nonatomic) UIActivityIndicatorView *aiActivity;

@property (nonatomic) int networkType;
@property (strong, nonatomic) SKBTestResultValue* cellResultDownload;
@property (strong, nonatomic) SKBTestResultValue* cellResultUpload;
@property (strong, nonatomic) SKBTestResultValue* cellResultLatency;
@property (strong, nonatomic) SKBTestResultValue* cellResultLoss;
@property (strong, nonatomic) SKBTestResultValue* cellResultJitter;
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

-(void)initCell;
-(void)setResultDownload:(SKBTestResultValue*)down_ upload:(SKBTestResultValue*)up_ latency:(SKBTestResultValue*)lat_ loss:(SKBTestResultValue*)loss_ jitter:(SKBTestResultValue*)jitter_;
-(void)setTest:(SKATestResults*)testResult;

-(UIView*)getView;
+(NSString*)sGet3DigitsNumber:(float)number_;

-(void)layoutCellActive;

@end
