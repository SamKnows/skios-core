//
//  SKARunTestsController.h
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "SKAAppDelegate.h"

#import "SKATransferTestCell.h"
#import "SKALatencyTestCell.h"
#import "SKAInformationCell.h"
#import "SKATransferTestCell.h"

@protocol SKARunTestsDelegate;

@interface SKARunTestsController : UIViewController
<UITableViewDataSource,
UITableViewDelegate,
SKAutotestObserverDelegate,
UIAlertViewDelegate>
{
    id <SKARunTestsDelegate> delegate;
}

@property (nonatomic, assign) TestType testType;
@property BOOL continuousTesting;

@property (weak, nonatomic) IBOutlet UIView *viewBG;
@property (weak, nonatomic) IBOutlet UILabel *lblMain;
@property (weak, nonatomic) IBOutlet UILabel *lblClosest;

//@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerMain;

@property (atomic, strong) id <SKARunTestsDelegate> delegate;

- (IBAction)done:(id)sender;
- (IBAction)actionButton:(id)sender;

@end

@protocol SKARunTestsDelegate

- (void)refreshGraphsAndTableData;

@end
