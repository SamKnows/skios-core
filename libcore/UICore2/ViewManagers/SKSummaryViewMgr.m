//
//  SKSummaryViewMgr.m
//  SKCore
//
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKSummaryViewMgr.h"
#import "SKBSummaryTableViewCell.h"

@implementation SKSummaryViewMgr
{
  UIView* cellContentView2putBack;
  SKBSummaryTableViewCell* cell2putBack;
  //CGRect originalCellContentFrame;
  CGFloat mRestoreToY;
}

#define C_BUTTON_BASE_ALPHA 0.1
#define C_VIEWS_Y_FIRST 110

- (void)intialiseViewOnMasterView:(UIView*)masterView_
{
  currentChartType= -1;
  
  self.backgroundColor = [UIColor clearColor];
  
  self.masterView = masterView_;
  
  [cActionSheet formatView:self.btNetworkType];
  [cActionSheet formatView:self.btPeriod];
  
  currentFilterNetworkType = C_FILTER_NETWORKTYPE_ALL;
  currentFilterPeriod = C_FILTER_PERIOD_1MONTH;
  
  // Set table to clear background colour!
  // http://stackoverflow.com/questions/18878258/uitableviewcell-show-white-background-and-cannot-be-modified-on-ios7
  [self.tvTests setBackgroundView:nil];
  [self.tvTests setBackgroundColor:[UIColor clearColor]];
  
  //TODO: Adjust button texts to these default values
  [self loadData];
  [self.tvTests reloadData];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateTestList:)
                                               name:@"TestListNeedsUpdate"
                                             object:nil];
}

static BOOL sbReloadTableAfterBack = NO;

-(void)updateTestList:(NSNotification *) notification
{
  if ([[notification name] isEqualToString:@"TestListNeedsUpdate"]) {
    
    if (self.btBack.userInteractionEnabled == YES) {
      dispatch_async(dispatch_get_main_queue(), ^{
        sbReloadTableAfterBack = YES;
        [self B_Back:nil];
      });
    } else {
      [self loadData];
    }
  }
}

-(void)setColoursAndShowHideElements {
  self.backgroundColor = [UIColor clearColor];
  
  self.vHeader.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
  self.vHeader.layer.cornerRadius = [cTabController sGet_GUI_MULTIPLIER] * 3;
  self.vHeader.layer.borderWidth = 0.5;
  self.vHeader.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
  
  self.vChart.alpha = 0;
  self.vChart.backgroundColor = [UIColor clearColor];
  // DEBUG!
  //self.vChart.backgroundColor = [UIColor greenColor];
}

- (IBAction)B_NetworkType:(id)sender {
    
    if (!self.casNetworkType)
    {
        self.casNetworkType = [[cActionSheet alloc] initOnView:self.masterView withDelegate:self mainTitle:@"Cancel"];
        [self.casNetworkType addOption:@"Wi-Fi" withImage:[UIImage imageNamed:@"swifi.png"] andTag:C_FILTER_NETWORKTYPE_WIFI];
        [self.casNetworkType addOption:@"Mobile" withImage:[UIImage imageNamed:@"sgsm.png"] andTag:C_FILTER_NETWORKTYPE_GSM];
        [self.casNetworkType addOption:@"All" withImage:nil andTag:C_FILTER_NETWORKTYPE_ALL];
    }
    
    [self.casNetworkType expand];
    
}

- (IBAction)B_Period:(id)sender {
    
    if (!self.casPeriod)
    {
        self.casPeriod = [[cActionSheet alloc] initOnView:self.masterView withDelegate:self mainTitle:@"Cancel"];
        [self.casPeriod addOption:@"1 day" withImage:nil andTag:C_FILTER_PERIOD_1DAY];
        [self.casPeriod addOption:@"1 week" withImage:nil andTag:C_FILTER_PERIOD_1WEEK];
        [self.casPeriod addOption:@"1 month" withImage:nil andTag:C_FILTER_PERIOD_1MONTH];
        [self.casPeriod addOption:@"3 months" withImage:nil andTag:C_FILTER_PERIOD_3MONTHS];
        [self.casPeriod addOption:@"1 year" withImage:nil andTag:C_FILTER_PERIOD_1YEAR];
    }
    
    [self.casPeriod expand];
}

-(void)selectedMainButtonFrom:(cActionSheet *)sender
{
    
}

-(void)selectedOption:(int)optionTag from:(cActionSheet *)sender WithState:(int)state
{
  if (sender == self.casNetworkType)
  {
    currentFilterNetworkType = optionTag;
    
    switch (optionTag) {
      case C_FILTER_NETWORKTYPE_WIFI:
        [self.btNetworkType setTitle:@"Wi-Fi" forState:UIControlStateNormal];
        break;
      case C_FILTER_NETWORKTYPE_GSM:
        [self.btNetworkType setTitle:@"Mobile" forState:UIControlStateNormal];
        break;
      case C_FILTER_NETWORKTYPE_ALL:
        [self.btNetworkType setTitle:@"All" forState:UIControlStateNormal];
        break;
      default:
        break;
    }
    [self loadData];
  }
  else if (sender == self.casPeriod)
  {
    currentFilterPeriod = optionTag;
    
    switch (optionTag) {
      case C_FILTER_PERIOD_1DAY:
        [self.btPeriod setTitle:@"1 day" forState:UIControlStateNormal];
        currentFilterPeriod = C_FILTER_PERIOD_1DAY;
        break;
      case C_FILTER_PERIOD_1WEEK:
        [self.btPeriod setTitle:@"1 week" forState:UIControlStateNormal];
        currentFilterPeriod = C_FILTER_PERIOD_1WEEK;
        break;
      case C_FILTER_PERIOD_1MONTH:
        [self.btPeriod setTitle:@"1 month" forState:UIControlStateNormal];
        currentFilterPeriod = C_FILTER_PERIOD_1MONTH;
        break;
      case C_FILTER_PERIOD_3MONTHS:
        [self.btPeriod setTitle:@"3 months" forState:UIControlStateNormal];
        currentFilterPeriod = C_FILTER_PERIOD_3MONTHS;
        break;
      case C_FILTER_PERIOD_1YEAR:
        [self.btPeriod setTitle:@"1 year" forState:UIControlStateNormal];
        currentFilterPeriod = C_FILTER_PERIOD_1YEAR;
        break;
      default:
        break;
    }
    [self loadData];
  }
}

-(void)loadData
{
  [self clearFields];
  
  dateTo = [NSDate date];
  
  switch (currentFilterPeriod) {
    case C_FILTER_PERIOD_1DAY:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-1*24*3600];
      break;
    case C_FILTER_PERIOD_1WEEK:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-7*24*3600];
      break;
    case C_FILTER_PERIOD_1MONTH:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-31*24*3600];
      break;
    case C_FILTER_PERIOD_3MONTHS:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-31*3*24*3600];
      break;
    case C_FILTER_PERIOD_1YEAR:
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-364*24*3600];
      break;
    default:
      break;
  }
  
  arrTestsList = [SKDatabase getTestDataForNetworkType:[self getSelectedNetworkWord] afterDate:previousDate];
  
  downloadSUM = 0;
  downloadCNT = 0;
  downloadBEST = -1;
  uploadSUM = 0;
  uploadCNT = 0;
  uploadBEST = -1;
  latencySUM = 0;
  latencyCNT = 0;
  latencyBEST = -1;
  lossSUM = 0;
  lossCNT = 0;
  lossBEST = -1;
  jitterSUM = 0;
  jitterCNT = 0;
  jitterBEST = -1;
  
  for (SKATestResults* tr in arrTestsList) {
    
    if (tr.downloadSpeed >= 0) //If the test was executed
    {
      downloadCNT++;
      downloadSUM += tr.downloadSpeed;
      if (downloadBEST < 0 || downloadBEST < tr.downloadSpeed) downloadBEST = tr.downloadSpeed;
    }
    
    if (tr.uploadSpeed >= 0) //If the test was executed
    {
      uploadCNT++;
      uploadSUM += tr.uploadSpeed;
      if (uploadBEST < 0 || uploadBEST < tr.uploadSpeed) uploadBEST = tr.uploadSpeed;
    }
    
    if (tr.latency >= 0) //If the test was executed
    {
      latencyCNT++;
      latencySUM += tr.latency;
      if (latencyBEST < 0 || latencyBEST > tr.latency) latencyBEST = tr.latency;
    }
    
    if (tr.loss >= 0) //If the test was executed
    {
      lossCNT++;
      lossSUM += tr.loss;
      if (lossBEST < 0 || lossBEST > tr.loss) lossBEST = tr.loss;
    }
    
    if (tr.jitter >= 0) //If the test was executed
    {
      jitterCNT++;
      jitterSUM += tr.jitter;
      if (jitterBEST < 0 || jitterBEST > tr.jitter) jitterBEST = tr.jitter;
    }
  }
  
  if (downloadCNT > 0)
  {
    self.lDownloadAvg = [SKATestOverviewCell2 get3digitsNumber:downloadSUM / downloadCNT];
    self.lDownloadBst = [SKATestOverviewCell2 get3digitsNumber:downloadBEST];
  }
  else
  {
    self.lDownloadAvg = @"-";
    self.lDownloadBst = @"-";
  }
  
  if (uploadCNT > 0)
  {
    self.lUploadAvg = [SKATestOverviewCell2 get3digitsNumber:uploadSUM / uploadCNT];
    self.lUploadBst = [SKATestOverviewCell2 get3digitsNumber:uploadBEST];
  }
  else
  {
    self.lUploadAvg = @"-";
    self.lUploadBst = @"-";
  }
  
  if (latencyCNT > 0)
  {
    self.lLatencyAvg = [NSString stringWithFormat:@"%.0f", latencySUM / latencyCNT];
    self.lLatencyBst = [NSString stringWithFormat:@"%.0f", latencyBEST];
  }
  else
  {
    self.lLatencyAvg = @"-";
    self.lLatencyBst = @"-";
  }
  
  if (lossCNT > 0)
  {
    self.lLossAvg = [NSString stringWithFormat:@"%.0f", lossSUM / lossCNT];
    self.lLossBst = [NSString stringWithFormat:@"%.0f", lossBEST];
  }
  else
  {
    self.lLossAvg = @"-";
    self.lLossBst = @"-";
  }
  
  if (jitterCNT > 0)
  {
    self.lJitterAvg = [NSString stringWithFormat:@"%.0f", jitterSUM / jitterCNT];
    self.lJitterBst = [NSString stringWithFormat:@"%.0f", jitterBEST];
  }
  else
  {
    self.lJitterAvg = @"-";
    self.lJitterBst = @"-";
  }
  
  self.lNumberOfRecords.text = [NSString stringWithFormat:@"%lu", (unsigned long)arrTestsList.count];
 
  // Do NOT reload the table view, as that might screw-up the current post-animation state!
  //[self.tvTests reloadData];
  NSInteger rows = [self.tvTests numberOfRowsInSection:0];
  for (NSInteger i = 0; i < rows; i++) {
    [self refreshCellAtIndex:i];
  }
  
  [self prepareDataForChart];
  [self.vChart setNeedsDisplay];
  self.lNumberOfRecords.alpha = 1;
}

-(void)clearFields
{
  self.lNumberOfRecords.text = nil;
  self.lDownloadAvg = nil;
  self.lDownloadAvgUnit = @"Mbps";
  self.lDownloadBst = nil;
  self.lDownloadBstUnit = @"Mbps";
  self.lUploadAvg = nil;
  self.lUploadAvgUnit = @"Mbps";
  self.lUploadBst = nil;
  self.lUploadBstUnit = @"Mbps";
  self.lLatencyAvg = nil;
  self.lLatencyAvgUnit = @"ms";
  self.lLatencyBst = nil;
  self.lLatencyBstUnit = @"ms";
  self.lLossAvg = nil;
  self.lLossAvgUnit = @"%";
  self.lLossBst = nil;
  self.lLossBstUnit = @"%";
  self.lJitterAvg = nil;
  self.lJitterAvgUnit = @"ms";
  self.lJitterBst = nil;
  self.lJitterBstUnit = @"ms";
  
//  [UIView animateWithDuration:0.5 animations:^{
//    self.lNumberOfRecords.alpha = 0;
//
//    if (currentChartType >= 0) {
//      self.vChart.alpha = 0;
//    }
//  }];
}

-(void)viewTouched:(UIButton*)button_
{
    switch (button_.tag) {
        case 0:
            self.vDownload.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            break;
        case 1:
            self.vUpload.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            break;
        case 2:
            self.vLatency.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            break;
        case 3:
            self.vLoss.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            break;
        case 4:
            self.vJitter.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            break;
    }
}

-(void)viewUntouched:(UIButton*)button_
{
    switch (button_.tag) {
        case 0:
            self.vDownload.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
            break;
        case 1:
            self.vUpload.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
            break;
        case 2:
            self.vLatency.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
            break;
        case 3:
            self.vLoss.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
            break;
        case 4:
            self.vJitter.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
            break;
    }
}

-(NSString*)getSelectedNetworkWord
{
    switch (currentFilterNetworkType) {
        case C_FILTER_NETWORKTYPE_WIFI:
            return @"network";
            break;
        case C_FILTER_NETWORKTYPE_GSM:
            return @"mobile";
            break;
        case C_FILTER_NETWORKTYPE_ALL:
            return @"all";
            break;
        default:
            break;
    }
    return nil;
}

-(void)activate
{
    self.vDownload.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vUpload.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vLatency.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vLoss.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vJitter.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
}

-(void)deactivate
{
    self.vDownload.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vUpload.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vLatency.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vLoss.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
    self.vJitter.backgroundColor = [UIColor colorWithWhite:0 alpha:C_BUTTON_BASE_ALPHA];
}

- (void)prepareDataForChart
{
  if (currentChartType == -1)
  {
    currentChartType = 0;
  }
  
  int numberOfPoints;
  float pixelLength;
  int intervals;
  
  [self.vChart setDefaultValues];
  
  switch (currentFilterPeriod) {
    case C_FILTER_PERIOD_1DAY:
      numberOfPoints = 600;
      pixelLength = 3600*24 / numberOfPoints;
      break;
    case C_FILTER_PERIOD_1WEEK:
      numberOfPoints = 600;
      pixelLength = 3600*24*7 / numberOfPoints;
      break;
    case C_FILTER_PERIOD_1MONTH:
      numberOfPoints = 600;
      pixelLength = 3600*24*31 / numberOfPoints;
      break;
    case C_FILTER_PERIOD_3MONTHS:
      numberOfPoints = 600;
      pixelLength = 3600*24*31*3 / numberOfPoints;
      break;
    case C_FILTER_PERIOD_1YEAR:
      numberOfPoints = 600;
      pixelLength = 3600*24*364 / numberOfPoints;
      break;
    default:
      SK_ASSERT(false);
      numberOfPoints = 0;
      pixelLength = 1;
      break;
  }
  
  [self.vChart createAndInitialiseArrayOfValues:numberOfPoints];
  
  cGraphValue* graphValue;
  
  switch (currentChartType) {
    case 0: {
      for (SKATestResults* tr in arrTestsList) {
        intervals = [tr.testDateTime timeIntervalSinceDate:previousDate];
        if (tr.downloadSpeed >= 0) //If the test was executed
        {
          graphValue = ((cGraphValue*)self.vChart.arrValues[(int)floorf(intervals / pixelLength)]);
          graphValue.sum += tr.downloadSpeed;
          graphValue.numberOfElements++;
          graphValue.active = YES;
        }
      }
    }
      break;
      
    case 1: {
      for (SKATestResults* tr in arrTestsList) {
        intervals = [tr.testDateTime timeIntervalSinceDate:previousDate];
        if (tr.uploadSpeed >= 0) //If the test was executed
        {
          graphValue = ((cGraphValue*)self.vChart.arrValues[(int)floorf(intervals / pixelLength)]);
          graphValue.sum += tr.uploadSpeed;
          graphValue.numberOfElements++;
          graphValue.active = YES;
        }
      }
    }
      break;
      
    case 2: {
      for (SKATestResults* tr in arrTestsList) {
        intervals = [tr.testDateTime timeIntervalSinceDate:previousDate];
        if (tr.latency >= 0) //If the test was executed
        {
          graphValue = ((cGraphValue*)self.vChart.arrValues[(int)floorf(intervals / pixelLength)]);
          graphValue.sum += tr.latency;
          graphValue.numberOfElements++;
          graphValue.active = YES;
        }
      }
    }
      break;
      
    case 3: {
      for (SKATestResults* tr in arrTestsList) {
        intervals = [tr.testDateTime timeIntervalSinceDate:previousDate];
        if (tr.loss >= 0) //If the test was executed
        {
          graphValue = ((cGraphValue*)self.vChart.arrValues[(int)floorf(intervals / pixelLength)]);
          graphValue.sum += tr.loss;
          graphValue.numberOfElements++;
          graphValue.active = YES;
        }
      }
    }
      break;
      
    case 4: {
      for (SKATestResults* tr in arrTestsList) {
        intervals = [tr.testDateTime timeIntervalSinceDate:previousDate];
        if (tr.jitter >= 0) //If the test was executed
        {
          graphValue = ((cGraphValue*)self.vChart.arrValues[(int)floorf(intervals / pixelLength)]);
          graphValue.sum += tr.jitter;
          graphValue.numberOfElements++;
          graphValue.active = YES;
        }
      }
    }
      break;
      
    default:
      SK_ASSERT(false);
  }
  
  self.vChart.yMax = 0;
  for (cGraphValue* gv in self.vChart.arrValues) {
    if ((gv.sum / gv.numberOfElements) > self.vChart.yMax) //Recalculating the Y MAX
      self.vChart.yMax = gv.sum / gv.numberOfElements;
  }
  
//  if (((cGraphValue*)[self.vChart.arrValues firstObject]).active == NO)
//  {
//    ((cGraphValue*)[self.vChart.arrValues firstObject]).sum = 0;
//    ((cGraphValue*)[self.vChart.arrValues firstObject]).numberOfElements = 1;
//    ((cGraphValue*)[self.vChart.arrValues firstObject]).active = YES;
//  }
//  if (((cGraphValue*)[self.vChart.arrValues lastObject]).active == NO)
//  {
//    ((cGraphValue*)[self.vChart.arrValues lastObject]).sum = 0;
//    ((cGraphValue*)[self.vChart.arrValues lastObject]).numberOfElements = 1;
//    ((cGraphValue*)[self.vChart.arrValues lastObject]).active = YES;
//  }
  
  [self.vChart setupYAxis];
  [self.vChart setupXAxis:currentFilterPeriod withStartDate:previousDate];
  
  switch (currentChartType) {
    case 0:
      self.vChart.chartTitle = @"Download speed for ";
      self.vChart.axisYTitle = @"Mb/s";
      break;
    case 1:
      self.vChart.chartTitle = @"Upload speed for ";
      self.vChart.axisYTitle = @"Mb/s";
      break;
    case 2:
      self.vChart.chartTitle = @"Latency for ";
      self.vChart.axisYTitle = @"ms";
      break;
    case 3:
      self.vChart.chartTitle = @"Loss for ";
      self.vChart.axisYTitle = @"%";
      break;
    case 4:
      self.vChart.chartTitle = @"Jitter for ";
      self.vChart.axisYTitle = @"ms";
      break;
  }
  
  switch (currentFilterPeriod) {
    case C_FILTER_PERIOD_1DAY:
      self.vChart.chartTitle = [NSString stringWithFormat:@"%@%@", self.vChart.chartTitle, @"1 day"];
      break;
    case C_FILTER_PERIOD_1WEEK:
      self.vChart.chartTitle = [NSString stringWithFormat:@"%@%@", self.vChart.chartTitle, @"1 week"];
      break;
    case C_FILTER_PERIOD_1MONTH:
      self.vChart.chartTitle = [NSString stringWithFormat:@"%@%@", self.vChart.chartTitle, @"1 month"];
      break;
    case C_FILTER_PERIOD_3MONTHS:
      self.vChart.chartTitle = [NSString stringWithFormat:@"%@%@", self.vChart.chartTitle, @"3 months"];
      break;
    case C_FILTER_PERIOD_1YEAR:
      self.vChart.chartTitle = [NSString stringWithFormat:@"%@%@", self.vChart.chartTitle, @"1 year"];
      break;
  }
}

#pragma mark TabelView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 70;
}

// http://stackoverflow.com/questions/14460772/how-to-hide-remove-separator-line-if-cells-are-empty
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
  // To "clear" the footer view
  return [UIView new];
}

-(void) refreshCellAtIndex:(NSInteger)row {
  
  SKBSummaryTableViewCell *cell = (SKBSummaryTableViewCell*)[self.tvTests cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
  
  switch (row) {
    case 0:
      [cell prepareWithTopLeftImage:[UIImage imageNamed:@"ga.png"]
                       TopLeftTitle:@"Download"
                   LeftAverageValue:self.lDownloadAvg
                   LeftAverageUnits:self.lDownloadAvgUnit
                     RightBestValue:self.lDownloadBst
                     RightBestUnits:self.lDownloadBstUnit
       ];
      break;
    case 1:
      [cell prepareWithTopLeftImage:[UIImage imageNamed:@"ra.png"]
                       TopLeftTitle:@"Upload"
                   LeftAverageValue:self.lUploadAvg
                   LeftAverageUnits:self.lUploadAvgUnit
                     RightBestValue:self.lUploadBst
                     RightBestUnits:self.lUploadBstUnit
       ];
      break;
    case 2:
      [cell prepareWithTopLeftImage:nil
                       TopLeftTitle:@"Latency"
                   LeftAverageValue:self.lLatencyAvg
                   LeftAverageUnits:self.lLatencyAvgUnit
                     RightBestValue:self.lLatencyBst
                     RightBestUnits:self.lLatencyBstUnit
       ];
      break;
    case 3:
      [cell prepareWithTopLeftImage:nil
                       TopLeftTitle:@"Loss"
                   LeftAverageValue:self.lLossAvg
                   LeftAverageUnits:self.lLossAvgUnit
                     RightBestValue:self.lLossBst
                     RightBestUnits:self.lLossBstUnit
       ];
      break;
    case 4:
    default:
      [cell prepareWithTopLeftImage:nil
                       TopLeftTitle:@"Jitter"
                   LeftAverageValue:self.lJitterAvg
                   LeftAverageUnits:self.lJitterAvgUnit
                     RightBestValue:self.lJitterBst
                     RightBestUnits:self.lJitterBstUnit
       ];
      break;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  SKBSummaryTableViewCell *cell;
  static NSString *CellIdentifier = @"SKBSummaryTableViewCell";
  
  cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    
    cell = [[SKBSummaryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  [self refreshCellAtIndex:indexPath.row];

  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.row) {
    case 0:
      currentChartType = 0;
      break;
    case 1:
      currentChartType = 1;
      break;
    case 2:
      currentChartType = 2;
      break;
    case 3:
      currentChartType = 3;
      break;
    case 4:
      currentChartType = 4;
      break;
    default:
      SK_ASSERT(false);
      break;
  }
  [self prepareDataForChart];
  [self.vChart setNeedsDisplay];
  
  cell2putBack = (SKBSummaryTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
  
  CGRect cellFrame = cell2putBack.frame;
  
  cellContentView2putBack = cell2putBack.contentView;
  mRestoreToY = self.tvTests.frame.origin.y;
  
  CGFloat chartMoveUpToY = self.tvTests.frame.origin.y + cellFrame.size.height;
  SK_ASSERT(chartMoveUpToY >= 20.0);
  // Account for TOOLBAR!
  const CGFloat cUITabBarHeight = 20.0; // 56.0;
  CGFloat chartHeight = (self.frame.size.height - cUITabBarHeight) - chartMoveUpToY;
  [cellContentView2putBack removeFromSuperview];
  
  // Immediately position at the top of the table.
  cellContentView2putBack.frame = CGRectMake(cell2putBack.frame.origin.x, mRestoreToY, cell2putBack.frame.size.width, cell2putBack.frame.size.height);
  [self addSubview:cellContentView2putBack];
  
  // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
  [self layoutIfNeeded];
  
  // Move chart to off bottom of screen...
  self.vChart.alpha = 0.0;
  self.chartHeightConstraint.constant = 0.0F;
  [self.vChart setNeedsDisplay];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [UIView animateWithDuration:0.3 animations:^{
      // Animation, to slide the table view LEFT!
      self.tvTests.alpha = 0;
      self.tvTests.frame = CGRectMake(-self.tvTests.frame.size.width, self.tvTests.frame.origin.y, self.tvTests.frame.size.width, self.tvTests.frame.size.height);
    } completion:^(BOOL finished) {
      
      [UIView animateWithDuration:1.0
                            delay:0.0
           usingSpringWithDamping:1
            initialSpringVelocity:13
                          options:UIViewAnimationOptionCurveEaseIn
       
                       animations:^{
                         // Animation, to move the detached cell content view UP!
                         cellContentView2putBack.frame = CGRectMake(0, mRestoreToY, cellFrame.size.width, cellFrame.size.height);
                         //self.vChart.frame = CGRectMake(0, chartMoveUpToY, chartWidth, chartHeight);
                         self.chartHeightConstraint.constant = chartHeight;
                         self.vChart.alpha = 1.0;
                         [self.vChart setNeedsDisplay];
                         
                       } completion:^(BOOL finished) {
                         // Animation, to put the button in the same place.
                         //self.btBack.frame = cellContentView2putBack.frame;
                         //self.backButtonTopOffsetConstraint.constant = 0; // Align to the top of the table view!
                         // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
                         [self layoutIfNeeded];
                         
                         //[self.vChart setNeedsDisplay];
                         self.btBack.userInteractionEnabled = YES;
                         [self bringSubviewToFront:self.btBack];
                         
                         //self.vChart.frame = CGRectMake(200, 200, 200, 200);
                         //[self.vChart setNeedsDisplay];
                       }];
    }];
  });
  
  return;
}

- (IBAction)B_Back:(id)sender {
  
  // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
  [self layoutIfNeeded];
  
  self.btBack.userInteractionEnabled = NO;
  [self sendSubviewToBack:self.btBack];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    
    [UIView animateWithDuration:0.3 animations:^{
      
      cellContentView2putBack.frame = CGRectMake(cell2putBack.frame.origin.x, cell2putBack.frame.origin.y - self.tvTests.contentOffset.y + self.tvTests.frame.origin.y, cell2putBack.frame.size.width, cell2putBack.frame.size.height);
      
      //self.vChart.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 0);
      self.chartHeightConstraint.constant = 0.0;
      self.vChart.alpha = 0;
      
    } completion:^(BOOL finished) {
      // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
      [self layoutIfNeeded];
      
      self.tvTests.frame = CGRectMake(- self.tvTests.frame.size.width, self.tvTests.frame.origin.y, self.tvTests.frame.size.width, self.tvTests.frame.size.height);
      
      float tableAnimationTime = 0.3;
      
      [UIView animateWithDuration:tableAnimationTime animations:^{
        self.tvTests.alpha = 1;
        self.tvTests.frame = CGRectMake(0, self.tvTests.frame.origin.y, self.tvTests.frame.size.width, self.tvTests.frame.size.height);
      } completion:^(BOOL finished) {
        
        [cellContentView2putBack removeFromSuperview];
        [cell2putBack addSubview:cellContentView2putBack];
        
        cellContentView2putBack.frame = cell2putBack.bounds;
        
        if (sbReloadTableAfterBack == YES) {
          sbReloadTableAfterBack = NO;
          [self loadData];
        }
      }];
    }];
  });
}
@end
