//
//  SKMainViewController.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewWithGradient.h"
#import "cTabController.h"
#import "SKRunTestViewMgr.h"
#import "SKHistoryViewMgr.h"
#import "SKSummaryViewMgr.h"
#import "SKSettingsMgr.h"
#import "SKInfoViewMgr.h"
#import "../UICore2/Reusable/WelcomeView/UIWelcomeView.h"

@interface SKMainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWelcomeView *vWelcomeView;

@property (nonatomic, weak) cTabController* tabController;

@property (weak, nonatomic) IBOutlet UIView *vTab;
@property (weak, nonatomic) IBOutlet UIScrollView *svContent;

@property (weak, nonatomic) IBOutlet SKRunTestViewMgr *vRun;
@property (weak, nonatomic) IBOutlet SKHistoryViewMgr *vHistory;
@property (weak, nonatomic) IBOutlet SKSummaryViewMgr *vSummary;
@property (weak, nonatomic) IBOutlet SKSettingsMgr *vSettings;
@property (weak, nonatomic) IBOutlet SKInfoViewMgr *vInfo;

@property (weak, nonatomic) IBOutlet UIViewWithGradient *vC1;
@property (weak, nonatomic) IBOutlet UIViewWithGradient *vC2;
@property (weak, nonatomic) IBOutlet UIViewWithGradient *vC3;
@property (weak, nonatomic) IBOutlet UIViewWithGradient *vC4;
@property (weak, nonatomic) IBOutlet UIViewWithGradient *vC5;

@end
