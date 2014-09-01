//
//  SKAArchivedResultsController.h
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SKAAppDelegate.h"

#import "SKATransferTestCell.h"
#import "SKALatencyTestCell.h"
#import "SKAInformationCell.h"

@interface SKAArchivedResultsController : UIViewController <UITableViewDataSource, UITableViewDelegate> // , UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIControl *viewBG;
@property (weak, nonatomic) IBOutlet UILabel *lblMain;
@property (weak, nonatomic) IBOutlet UILabel *lblCount;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblClosest;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;

@property (nonatomic, assign) int testIndex;
@property (nonatomic, strong) NSMutableArray *testMetaData;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *showOlderResultsButton;
- (IBAction)showOlderResultsButton:(id)sender;

- (IBAction)actionButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIToolbar *uiToolbar;

+ (NSString *) platformString:(NSString*)platform;
  
@end
