//
//  SKAGraphViewCell.m
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKAGraphViewCell.h"


@interface SKAGraphViewCell ()
{
    int limitIndex;
    
    NSMutableArray *allDataForCells;
    NSMutableArray *rangeDataForCells;
}

- (void)refreshCells:(NSArray*)data;
- (void)refreshLocalData;

// Used for CorePlot...
// Used for CorePlot...
@property SKGraphForResults *skGraphForResults;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation SKAGraphViewCell

@synthesize graphView;
@synthesize testString;
@synthesize dateRange;
@synthesize tableView;
@synthesize testType;
@synthesize delegate;
@synthesize lblDate;
@synthesize lblResults;
@synthesize lblLocation;

+(int) getMaxResultsCells {
  // Only ever 4 results max per table...
  return 4;
}

- (NSString*)getSuffix
{
    NSString *suffix = nil;
  
    if (self.testType == DOWNLOAD_DATA || self.testType == UPLOAD_DATA)
    {
        suffix = sSKCoreGetLocalisedString(@"Graph_Suffix_Mbps");
    }
    else if ( (self.testType == LATENCY_DATA) || (self.testType == JITTER_DATA) )
    {
        suffix = sSKCoreGetLocalisedString(@"Graph_Suffix_Ms");
    }
    else
    {
        suffix = sSKCoreGetLocalisedString(@"Graph_Suffix_Percent");
    }
    return suffix;
}

- (void)refreshCells:(NSArray*)data
{
    if (nil == allDataForCells)
    {
        allDataForCells = [[NSMutableArray alloc] init];
    }
    
    if (nil == rangeDataForCells)
    {
        rangeDataForCells = [[NSMutableArray alloc] init];
    }
    
    [allDataForCells removeAllObjects];
    [allDataForCells addObjectsFromArray:data];
    
    [rangeDataForCells removeAllObjects];
    
    if ([allDataForCells count] <= [SKAGraphViewCell getMaxResultsCells])
    {
        [rangeDataForCells addObjectsFromArray:allDataForCells];
    }
    else
    {
        int from = (limitIndex * [SKAGraphViewCell getMaxResultsCells]) - [SKAGraphViewCell getMaxResultsCells];
        int count = (int)[allDataForCells count] - from;
        int length = MIN(count, [SKAGraphViewCell getMaxResultsCells]);
        
        NSRange range = NSMakeRange(from, length);
        
        [rangeDataForCells removeAllObjects];
        NSArray *subArray = [[allDataForCells subarrayWithRange:range] copy];
        [rangeDataForCells addObjectsFromArray:subArray];
    }
    
    BOOL hide = [rangeDataForCells count] == 0;
    
    self.lblDate.hidden = hide;
    self.lblResults.hidden = hide;
    self.lblLocation.hidden = hide;
}

#pragma mark - Result Footer Range Methods

- (void)back
{
    if (limitIndex <= 1)
    {
        return;
    }
    else
    {
        limitIndex -= 1;
        
        int from = (limitIndex * [SKAGraphViewCell getMaxResultsCells]) - [SKAGraphViewCell getMaxResultsCells];
        int count = (int)[allDataForCells count] - from;
        int length = MIN(count, [SKAGraphViewCell getMaxResultsCells]);
        
        NSRange range = NSMakeRange(from, length);
        
        [rangeDataForCells removeAllObjects];
        [rangeDataForCells addObjectsFromArray:[allDataForCells subarrayWithRange:range]];
        
        [self.tableView reloadData];
    }
}

- (void)next
{
    limitIndex += 1;
    
    int from = (limitIndex * [SKAGraphViewCell getMaxResultsCells]) - [SKAGraphViewCell getMaxResultsCells];
    int count = (int)[allDataForCells count] - from;
    
    if (count > 0)
    {
        int length = MIN(count, [SKAGraphViewCell getMaxResultsCells]);
        
        NSRange range = NSMakeRange(from, length);
        
        [rangeDataForCells removeAllObjects];
        [rangeDataForCells addObjectsFromArray:[allDataForCells subarrayWithRange:range]];
        
        [self.tableView reloadData];
    }
    else
    {
        limitIndex -= 1;
    }
}

- (void)initialize:(NSString*)string type:(TestDataType)type range:(DATERANGE_1w1m3m1y)range
{
  SK_ASSERT(self.tableView != nil);
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  SK_ASSERT(self.tableView.delegate == self);
  SK_ASSERT(self.tableView.dataSource == self);
  
  limitIndex = 1;
  
  self.testType = type;
  self.testString = string;
  self.dateRange = range;
}

- (void)refreshLocalData
{
  NSDate *previousDate = nil;
  
  DATERANGE_1w1m3m1y curDateFilter;
  
  curDateFilter = self.dateRange;
  switch (self.dateRange)
  {
    case DATERANGE_1w1m3m1y_ONE_WEEK:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-7*24*60*60];
      break;
      
    case DATERANGE_1w1m3m1y_ONE_MONTH:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-30*24*60*60];
      break;
      
    case DATERANGE_1w1m3m1y_THREE_MONTHS:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-3*30*24*60*60];
      break;
      
    case DATERANGE_1w1m3m1y_SIX_MONTHS:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-6*30*24*60*60];
      break;
      
    case DATERANGE_1w1m3m1y_ONE_YEAR:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-12*30*24*60*60];
      break;
      
    case DATERANGE_1w1m3m1y_ONE_DAY:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-1*24*60*60];
      break;
      
    default:
      SK_ASSERT(false);
      return;
  }
  
  NSDate *dateNow = [SKCore getToday];
  
  NSString *rootPath = NSTemporaryDirectory();
  NSString *dataFilename = [NSString stringWithFormat:@"data_%d_%@.json", self.dateRange, self.testString];
  NSString *dataPath = [rootPath stringByAppendingPathComponent:dataFilename];
  NSString *infoPath = [rootPath stringByAppendingPathComponent:@"info.json"];
  NSString *info = [NSString stringWithFormat:@"{\"file\":\"%@\",\"test\":\"%@\"}", dataFilename, self.testString];
  
  NSFileManager *filemgr = [NSFileManager defaultManager];
  if (![filemgr createFileAtPath:infoPath contents:[info dataUsingEncoding:NSASCIIStringEncoding] attributes:nil])
  {
    NSLog(@"Failed");
  }
  
  NSDictionary *graphDataForDateRange = [SKAGraphViewCell sFetchGraphDataTestType:self.testString
                                                                        ForDateRange:self.dateRange
                                                                            FromDate:previousDate
                                                                              ToDate:dateNow
                                                                            DataPath:dataPath];
  
  if (graphDataForDateRange != nil)
  {
    if ([graphDataForDateRange count] == 2)
    {
      NSError *err = nil;
      NSData *json = [NSJSONSerialization dataWithJSONObject:graphDataForDateRange
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&err];
      
      //[SKGlobalMethods printNSData:json];
      
      if (nil == err)
      {
        SK_ASSERT([NSThread isMainThread]);
        
        // Update the CORE PLOT!
        if (self.skGraphForResults == nil) {
          self.skGraphForResults = [[SKGraphForResults alloc] init];
        }
        
        [self.skGraphForResults updateGraphWithTheseResults:json OnParentView:self InFrame:self.graphView.frame StartHidden:NO WithDateFilter:curDateFilter];
        
        return;
      }
      else
      {
        NSLog(@"Error : %@", [err localizedDescription]);
      }
    }
  }
}

- (void)refreshData:(NSArray*)data
{
  [self refreshCells:data];
  [self refreshLocalData];
  
  SK_ASSERT(self.tableView != nil);
  SK_ASSERT(self.tableView.delegate == self);
  SK_ASSERT(self.tableView.dataSource == self);
  [self.tableView reloadData];
}

+ (NSDictionary*)sFetchGraphDataTestType:(NSString*)inTestType
                                ForDateRange:(DATERANGE_1w1m3m1y)inDateRange
                                    FromDate:(NSDate*)fromDate
                                      ToDate:(NSDate*)toDate
                                    DataPath:(NSString*)dataPath
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd"];
  
  NSString *fromDateStr = [dateFormatter stringFromDate:fromDate];
  NSString *toDateStr = [dateFormatter stringFromDate:toDate];
  
  TestDataType testDataType = DOWNLOAD_DATA;
  
  if ([inTestType isEqualToString:@"downstream_mt"])
  {
    testDataType = DOWNLOAD_DATA;
  }
  else if([inTestType isEqualToString:@"upstream_mt"])
  {
    testDataType = UPLOAD_DATA;
  }
  else if([inTestType isEqualToString:@"latency"])
  {
    testDataType = LATENCY_DATA;
  }
  else if([inTestType isEqualToString:@"packetloss"])
  {
    testDataType = LOSS_DATA;
  }
  else if (([inTestType isEqualToString:@"jitter"]) || ([inTestType isEqualToString:@"voip_jitter"]))
  {
    testDataType = JITTER_DATA;
  }
  else
  {
    SK_ASSERT(false);
  }
  
  NSMutableDictionary *valuesDict = [SKDatabase getDailyAveragedTestDataAsDictionaryKeyByDay:fromDate ToDate:toDate TestDataType:testDataType WhereNetworkTypeAsStringEquals:[SKAppBehaviourDelegate getNetworkTypeString]];
  if (valuesDict == nil)
  {
    SK_ASSERT(false);
    return nil;
  }

  // Now, store and return the results in a dictionary.
  // @"results" = the results dictionary (mutable):
  //    <testtype, e.g. @"jitter">, value=valuesDict (mutable):
  //      @"<theday>", value=<float_value>
  //       ... and if this is a 1-day query...!...:
  ///   @"24hours", value=:
  //       array of items, where each item is 1 day, and is a mutable dictionary with these
  //       critical values:
  //         [dict setObject:nsNumberDate forKey:@"DATE"];
  //         [dict setObject:[SKGlobalMethods format2DecimalPlaces:val] forKey:@"RESULT"];

  // @"request" = the request dictionary (mutable)
  //    @"start_date", value = the start date
  //    @"end_date",   value = the end data date
  //    @"test_type",  value = the test type (e.g. @"jitter")
  NSMutableDictionary *localDataDictForTestType = [NSMutableDictionary dictionary];
  
  NSMutableDictionary *resultsDict = [[NSMutableDictionary alloc] init];
  resultsDict[inTestType] = valuesDict;
  if (inDateRange == DATERANGE_1w1m3m1y_ONE_DAY) {
    
    SK_ASSERT([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] supportOneDayResultView]);
    
    NSMutableArray *valuesArray24 = [SKDatabase getNonAveragedTestData:fromDate ToDate:toDate TestDataType:testDataType WhereNetworkTypeAsStringEquals:[SKAppBehaviourDelegate getNetworkTypeString]];
    if (valuesArray24 == nil)
    {
      SK_ASSERT(false);
      return nil;
    }
    
    resultsDict[@"24hours"] = valuesArray24;
  }
  localDataDictForTestType[@"results"] = resultsDict;

  NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
  requestDict[@"start_date"] = fromDateStr;
  requestDict[@"end_date"] = toDateStr;
  requestDict[@"test_type"] = inTestType;
  localDataDictForTestType[@"request"] = requestDict;
  
  return localDataDictForTestType;
}

#pragma mark - UITableViewDelegate delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 20.0f;
    }
    else
    {
        return 36.0f;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([allDataForCells count] > [SKAGraphViewCell getMaxResultsCells])
    {
        return 2;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return ([rangeDataForCells count] > [SKAGraphViewCell getMaxResultsCells]) ? [SKAGraphViewCell getMaxResultsCells] : [rangeDataForCells count];
    }
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  int row = (int)indexPath.row;
  int section = (int)indexPath.section;
  
  if (section == 0)
  {
    static NSString *CellIdentifier = @"SKAGraphResultCell";
    SKAGraphResultCell *cell = (SKAGraphResultCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[SKAGraphResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSDictionary *dict = rangeDataForCells[row];
    
    if (nil != dict)
    {
      NSTimeInterval interval = (NSTimeInterval)[dict[@"DATE"] doubleValue];
    
      NSString *textToShow;
      if (self.testType == DOWNLOAD_DATA || self.testType == UPLOAD_DATA) {
        // If this is BITRATE, we need to do something special...
        NSString *bitrateMbps1024BasedAsLocalString = dict[@"RESULT"];
        textToShow = [SKGlobalMethods bitrateMbps1024BasedLocalNumberStringBasedToString:bitrateMbps1024BasedAsLocalString];
      } else {
        // Not bitrate - it is simply value then suffix.
        NSString *result1 = (NSString*) dict[@"RESULT"];
        textToShow = [NSString stringWithFormat:@"%@ %@", result1, [self getSuffix]];
      }
      
      NSString *target = (NSString*) dict[@"TARGET"];
      
      NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
      
      cell.lblDate.text = [SKGlobalMethods formatShorterDate:date];
      cell.lblResult.text = textToShow;
      cell.lblLocation.text = target;
      
      NSString *networkType = (NSString*) dict[@"NETWORK_TYPE"];
      if ([networkType isEqualToString:C_NETWORKTYPEASSTRING_WIFI]) {
        cell.lblIcon.image = [UIImage imageNamed:@"Wifiservice"];
        cell.lblIcon.hidden = NO;
      } else if ([networkType isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
        cell.lblIcon.image = [UIImage imageNamed:@"Cell_phone_icon"];
        cell.lblIcon.hidden = NO;
      } else {
        SK_ASSERT(false);
        cell.lblIcon.hidden = YES;
      }
    }
    
    return cell;
  }
  else
  {
    static NSString *CellIdentifier = @"SKAGraphResultFooterCell";
    SKAGraphResultFooterCell *cell = (SKAGraphResultFooterCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[SKAGraphResultFooterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setDelegate:self];
    cell.backgroundColor = [UIColor sSKCGetColor_samKnowsGrayColor];
    cell.centerLabel.text = sSKCoreGetLocalisedString(@"Storyboard_GraphViewFooterCell_CenterLabel");
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
  }
}

#pragma mark - Various methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


@end
