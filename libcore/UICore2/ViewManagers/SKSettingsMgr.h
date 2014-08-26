//
//  SKSettingsMgr.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "../Reusable/CTabController/cTabController.h"
#import "../Reusable/CActionSheet/cActionSheet.h"

enum {
    ALERT_DATACAP = 1,
    ALERT_WIPEDATA = 2,
};

@interface SKSettingsMgr : UIView <UIAlertViewDelegate, UITextFieldDelegate, pViewManager, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) UIView* masterView;
@property (nonatomic, weak) UIViewController* masterViewController;

@property (weak, nonatomic) IBOutlet UIView *vSmallBackground;
@property (weak, nonatomic) IBOutlet UIButton *btClearDB;
@property (weak, nonatomic) IBOutlet UIButton *btOK1;
@property (weak, nonatomic) IBOutlet UIButton *btExport;

// Simple labels
@property (weak, nonatomic) IBOutlet UILabel *lMonthlyDataCap;
@property (weak, nonatomic) IBOutlet UILabel *lCapUsed;

// Data values
@property (weak, nonatomic) IBOutlet UILabel *lDataUsageValue;
@property (weak, nonatomic) IBOutlet UITextField *tDataCapValue;

// Optional - not in all storyboards
@property (weak, nonatomic) IBOutlet UILabel *lClearAllData;
@property (weak, nonatomic) IBOutlet UISwitch *swDataCapOnOff;

- (IBAction)B_OK1:(id)sender;
- (IBAction)B_ClearDatabase:(id)sender;
- (IBAction)B_ExportResults:(id)sender;

-(void)intialiseViewOnMasterView:(UIView*)masterView_;
-(void)performLayout;

@end
