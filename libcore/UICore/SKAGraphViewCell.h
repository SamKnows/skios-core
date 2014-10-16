//
//  SKAGraphViewCell.h
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKAAppDelegate.h"
#import "SKAGraphResultCell.h"

#import "SKAGraphResultFooterCell.h"

@protocol SKAGraphViewDelegate;

@interface SKAGraphViewCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate, SKARangeDelegate>
{
  NSString  *testString;
  TestDataType testType;
  DATERANGE_1w1m3m1y dateRange;
  
  id <SKAGraphViewDelegate> delegate;
}

@property (atomic, strong) id <SKAGraphViewDelegate> delegate;

@property (nonatomic, copy) NSString  *testString;
@property (nonatomic, assign) TestDataType testType;
@property (nonatomic, assign) DATERANGE_1w1m3m1y dateRange;

@property (nonatomic, weak) IBOutlet UIView *graphView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UILabel *lblDate;
@property (nonatomic, weak) IBOutlet UILabel *lblLocation;
@property (nonatomic, weak) IBOutlet UILabel *lblResults;

- (void)initialize:(NSString*)string type:(TestDataType)type range:(DATERANGE_1w1m3m1y)range;

- (void)refreshData:(NSArray*)data;

+(int) getMaxResultsCells;
+ (NSDictionary*)sFetchGraphDataTestType:(NSString*)inTestType
                                ForDateRange:(DATERANGE_1w1m3m1y)inDateRange
                                    FromDate:(NSDate*)fromDate
                                      ToDate:(NSDate*)toDate
                                    DataPath:(NSString*)dataPath;

@end

@protocol SKAGraphViewDelegate

- (void)next:(TestDataType)type;
- (void)back:(TestDataType)type;

@end
