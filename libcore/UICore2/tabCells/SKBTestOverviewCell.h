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

@property (strong, nonatomic) UIActivityIndicatorView *aiActivity;

@property (nonatomic) int networkType;
@property (strong, nonatomic) SKBTestResultValue* cellResultDownload;
@property (strong, nonatomic) SKBTestResultValue* cellResultUpload;
@property (strong, nonatomic) SKBTestResultValue* cellResultLatency;
@property (strong, nonatomic) SKBTestResultValue* cellResultLoss;
@property (strong, nonatomic) SKBTestResultValue* cellResultJitter;
@property (strong, nonatomic) NSDate* testDateTime;

@property (weak, nonatomic) IBOutlet  UIImageView *ivNetworkType;

-(void)initCell;
-(void)setResultDownload:(SKBTestResultValue*)down_ upload:(SKBTestResultValue*)up_ latency:(SKBTestResultValue*)lat_ loss:(SKBTestResultValue*)loss_ jitter:(SKBTestResultValue*)jitter_;
-(void)setTest:(SKATestResults*)testResult;

-(UIView*)getView;
+(NSString*)get3digitsNumber:(float)number_;

-(void)layoutCellActive;

@end
