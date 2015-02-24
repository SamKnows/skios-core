//
//  SKBHistoryViewController.h
//  SKCore
//
//  Created by Pete Cole on 29/09/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKBHistoryViewMgr;

@interface SKBHistoryViewController : UIViewController

@property (weak, nonatomic) IBOutlet SKBHistoryViewMgr *historyManagerView;
// The following is populated with "no_archived_results_yet"
@property (weak, nonatomic) IBOutlet UILabel *tv_warning_no_results_yet;

// This should be called only from the historyManagerView...
-(void) childTableViewRowsUpdated:(NSInteger)rowCount;

@end
