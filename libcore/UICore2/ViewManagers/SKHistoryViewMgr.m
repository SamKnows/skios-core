//
//  SKHistoryViewMgr.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKHistoryViewMgr.h"
#import "SKTestResults.h"
#import "SKTestResultsSharer.h"

#define C_SHARE_BUTTON_HEIGHT   ([cTabController sGet_GUI_MULTIPLIER] * 40)
#define C_SHARE_BUTTON_WIDTH   ([cTabController sGet_GUI_MULTIPLIER] * 40)

@interface SKHistoryViewMgr()

@property (nonatomic, strong) SKTestResultsSharer* mpSharer;

@end

@implementation SKHistoryViewMgr

- (void)intialiseViewOnMasterViewController:(UIViewController*)masterViewController_
{
  self.mpSharer = [[SKTestResultsSharer alloc] initWithViewController:masterViewController_];
  
  self.masterViewController = masterViewController_;
  self.masterView = masterViewController_.view;
  self.backgroundColor = [UIColor clearColor];
  
  self.tvTests.delegate = self;
  self.tvTests.dataSource = self;
  
  //    [cActionSheet formatButton:self.btNetworkType];
  //    [cActionSheet formatButton:self.btPeriod];
  //    [cActionSheet formatButton:self.btGraph];
  
  testHeight = 100;
  expandedRow = -1;
  self.btShare.alpha = 0;
  
  currentFilterNetworkType = C_FILTER_NETWORKTYPE_ALL;
  currentFilterPeriod = C_FILTER_PERIOD_3MONTHS;

  // Ensure that the back button is properly sized!
  self.backButtonHeightConstraint.constant = [cTabController sGet_GUI_MULTIPLIER] * 100;
  
  // Remove constraints to allow dynamic positioning, if we required.
//  [self.btBack setTranslatesAutoresizingMaskIntoConstraints:YES];
//  [self.btBack removeConstraints:self.btShare.constraints];
//  [self.btShare setTranslatesAutoresizingMaskIntoConstraints:YES];
//  [self.btShare removeConstraints:self.btShare.constraints];
  
  [self selectedOption:C_FILTER_NETWORKTYPE_ALL from:self.casNetworkType WithState:1];
  
  [self loadData];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateTestList:)
                                               name:@"TestListNeedsUpdate"
                                             object:nil];
}

-(void)updateTestList:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"TestListNeedsUpdate"])
    {
      [self loadData];
      
      if (self.btBack.userInteractionEnabled) {
        [self B_Back:self.btBack];
      }
    }
}

-(void)setColoursAndShowHideElements {
  self.backgroundColor = [UIColor clearColor];
  self.btShare.hidden = YES;
}

-(void)performLayout
{
  //self.tvTests.frame = CGRectMake(0, 20, self.bounds.size.width, self.bounds.size.height - 20);
  
  [self setColoursAndShowHideElements];
}

-(BOOL) canViewArchivedResults {
    NSMutableArray * GArrayForResultsController = [SKDatabase getTestMetaDataWhereNetworkTypeEquals:[SKAAppDelegate getNetworkTypeString]];
    
    if (GArrayForResultsController != nil)
    {
        if ([GArrayForResultsController count] > 0)
        {
            return YES;
        }
        GArrayForResultsController = nil;
    }
    return NO;
}

#pragma mark TabelView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrTestsList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == expandedRow)
        return testHeight;
    
    return [cTabController sGet_GUI_MULTIPLIER] * 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKATestOverviewCell2 *cell;
    static NSString *CellIdentifier = @"SKATestOverviewCell2";
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[SKATestOverviewCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell initCell];
    [cell setTest:[arrTestsList objectAtIndex:indexPath.row]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  selectedTest = arrTestsList[indexPath.row];
  cell2putBack = (SKATestOverviewCell2*)[tableView cellForRowAtIndexPath:indexPath];
  view2putBack = [cell2putBack getView];
  originalCellFrame = cell2putBack.frame;
  
  [view2putBack removeFromSuperview];
  view2putBack.frame = CGRectMake(cell2putBack.frame.origin.x, self.tvTests.frame.origin.y, cell2putBack.frame.size.width, cell2putBack.frame.size.height);
  [self addSubview:view2putBack];
  [self bringSubviewToFront:self.btBack];
  
  // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
  [self layoutIfNeeded];
  self.shareButtonTopOffsetConstraint.constant = self.masterView.frame.size.height + 1;
  //self.btBack.frame = CGRectMake(0, 0, 0, 0);
  //self.btShare.frame = CGRectMake(10, self.masterView.bounds.size.height + 1, C_SHARE_BUTTON_WIDTH, C_SHARE_BUTTON_HEIGHT);
  // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
  [self layoutIfNeeded];
  
  self.btShare.alpha = 0;
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [UIView animateWithDuration:0.3 animations:^{
      self.tvTests.alpha = 0;
      self.tvTests.frame = CGRectMake(- self.tvTests.frame.size.width, self.tvTests.frame.origin.y, self.tvTests.frame.size.width, self.tvTests.frame.size.height);
    } completion:^(BOOL finished) {
      [self printPassiveMetrics:(arrTestsList[indexPath.row])];
     
      // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
      [self layoutIfNeeded];
      
      [UIView animateWithDuration:1.0
                            delay:0.0
           usingSpringWithDamping:1
            initialSpringVelocity:13
                          options:UIViewAnimationOptionCurveEaseIn
       
                       animations:^{
                         view2putBack.frame = CGRectMake(0, 20, view2putBack.frame.size.width, view2putBack.frame.size.height);
                         self.shareButtonTopOffsetConstraint.constant = y + [cTabController sGet_GUI_MULTIPLIER] * 10;
                         //self.btShare.frame = CGRectMake([cTabController sGet_GUI_MULTIPLIER] * 10, y + [cTabController sGet_GUI_MULTIPLIER] * 10, C_SHARE_BUTTON_WIDTH, C_SHARE_BUTTON_HEIGHT);
                         
                         self.btShare.alpha = 1;
                         [self showMetrics];
                         
                         // http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
                         [self layoutIfNeeded];
                         
                       } completion:^(BOOL finished) {
                       }];
    }];
  });
  
  return;
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
        [self.casPeriod addOption:@"1 week" withImage:nil andTag:C_FILTER_PERIOD_1WEEK];
        [self.casPeriod addOption:@"1 month" withImage:nil andTag:C_FILTER_PERIOD_1MONTH];
        [self.casPeriod addOption:@"3 months" withImage:nil andTag:C_FILTER_PERIOD_3MONTHS];
        [self.casPeriod addOption:@"1 year" withImage:nil andTag:C_FILTER_PERIOD_1YEAR];
    }
    
    [self.casPeriod expand];
}

-(void)selectedOption:(int)optionTag from:(cActionSheet*)sender WithState:(int)state {
  
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
      case C_FILTER_PERIOD_1WEEK:
        [self.btPeriod setTitle:@"1 week" forState:UIControlStateNormal];
        break;
      case C_FILTER_PERIOD_1MONTH:
        [self.btPeriod setTitle:@"1 month" forState:UIControlStateNormal];
        break;
      case C_FILTER_PERIOD_3MONTHS:
        [self.btPeriod setTitle:@"3 months" forState:UIControlStateNormal];
        break;
      case C_FILTER_PERIOD_1YEAR:
        [self.btPeriod setTitle:@"1 year" forState:UIControlStateNormal];
        break;
      default:
        break;
    }
    [self loadData];
  }
}

-(void)selectedMainButtonFrom:(cActionSheet *)sender
{
    
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

-(void)loadData
{
    //    arrTestsList = [SKDatabase getTestDataForNetworkType:[SKAAppDelegate getNetworkTypeString]];
    arrTestsList = [SKDatabase getTestDataForNetworkType:[self getSelectedNetworkWord] afterDate:nil];
    [self.tvTests reloadData];

    return;
}

static SKATestResults* testToShareExternal = nil;
+(SKATestResults *) sCreateNewTstToShareExternal {
  testToShareExternal = [[SKATestResults alloc] init];
  return testToShareExternal;
}

+(SKATestResults *) sGetTstToShareExternal {
  SK_ASSERT(testToShareExternal != nil);
//  if (testToShareExternal == nil) {
//      testToShareExternal = [[SKATestResults alloc] init];
//  }
  return testToShareExternal;
}

-(void)shareTest:(SKATestResults*)testResult
{
    selectedTest = testResult;
  
  [self.mpSharer shareTest:selectedTest];
}

- (IBAction)B_Back:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.3 animations:^{
            
            view2putBack.frame = CGRectMake(cell2putBack.frame.origin.x, cell2putBack.frame.origin.y - self.tvTests.contentOffset.y + self.tvTests.frame.origin.y, cell2putBack.frame.size.width, cell2putBack.frame.size.height);
            
            [self hideMetrics];
            self.btShare.frame = CGRectMake([cTabController sGet_GUI_MULTIPLIER] * 10, self.masterView.bounds.size.height + 1, C_SHARE_BUTTON_WIDTH, C_SHARE_BUTTON_HEIGHT);
            self.btShare.alpha = 0;
          
            
        } completion:^(BOOL finished) {
            
            self.tvTests.frame = CGRectMake(- self.tvTests.frame.size.width, self.tvTests.frame.origin.y, self.tvTests.frame.size.width, self.tvTests.frame.size.height);
            
            float tableAnimationTime = 0.3;
          
            [UIView animateWithDuration:tableAnimationTime animations:^{
                self.tvTests.alpha = 1;
                self.tvTests.frame = CGRectMake(0, self.tvTests.frame.origin.y, self.tvTests.frame.size.width, self.tvTests.frame.size.height);
            } completion:^(BOOL finished) {
                
                [view2putBack removeFromSuperview];
                [cell2putBack addSubview:view2putBack];
                
                view2putBack.frame = cell2putBack.bounds;
                self.btShare.hidden = NO;
                
                [self destroyMetrics];
            }];
        }];
    });
}

-(void)printPassiveMetrics:(SKATestResults*)testResult_
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        y = [cTabController sGet_GUI_MULTIPLIER] * 110;
    else
        y = [cTabController sGet_GUI_MULTIPLIER] * 120;
    
    arrPassiveLabelsAndValues = [[NSMutableArray alloc] initWithCapacity:[testResult_ numberOfOptionalMetrics]];
    
    [self placeMetrics:testResult_.device withLabelTextID:@"Phone"];
    [self placeMetrics:testResult_.os withLabelTextID:@"OS"];
    [self placeMetrics:testResult_.carrier_name withLabelTextID:@"Carrier_Name"];
    [self placeMetrics:testResult_.country_code withLabelTextID:@"Carrier_Country"];
    [self placeMetrics:testResult_.iso_country_code withLabelTextID:@"Carrier_ISO"];
    [self placeMetrics:testResult_.network_code withLabelTextID:@"Carrier_Network"];
    
    if (testResult_.radio_type.length > 0)
    {
        NSString* networkType;
        networkType = NSLocalizedString(@"Unknown",nil);
        if ([testResult_.network_type isEqualToString:@"network"]) {
            networkType = NSLocalizedString(@"NetworkTypeMenu_WiFi",nil);
        } else if ([testResult_.network_type isEqualToString:@"mobile"]) {
            
            NSString *mobileString = NSLocalizedString(@"NetworkTypeMenu_Mobile",nil);
            
            NSString *theRadio = [SKGlobalMethods getNetworkTypeLocalized:testResult_.radio_type];
            if ([theRadio isEqualToString:NSLocalizedString(@"CTRadioAccessTechnologyUnknown",nil)]) {
                networkType = mobileString;
            } else {
                networkType = [NSString stringWithFormat:@"%@ (%@)", mobileString, theRadio];
            }
        }
        
        [self placeMetrics:networkType withLabelTextID:@"Network_Type"];
    }
    [self placeMetrics:testResult_.target withLabelTextID:@"Target"];
}

-(void)placeMetrics:(NSString*)text_ withLabelTextID:(NSString*)labelTextID_
{
    UILabel* label;
    if (text_.length > 0)
    {
        label = [[UILabel alloc] initWithFrame:CGRectMake([cTabController sGet_GUI_MULTIPLIER] * 10, y + self.bounds.size.height, [cTabController sGet_GUI_MULTIPLIER] * 155, [cTabController sGet_GUI_MULTIPLIER] * 18)];
        label.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:[cTabController sGet_GUI_MULTIPLIER] * 14];
        label.textColor = [UIColor colorWithRed:255.0/255.0 green:166.0/255.0 blue:26.0/255.0 alpha:1];
        label.text = NSLocalizedString(labelTextID_, nil);
        [self addSubview:label];
        [arrPassiveLabelsAndValues addObject:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake([cTabController sGet_GUI_MULTIPLIER] * 155, y + self.bounds.size.height, [cTabController sGet_GUI_MULTIPLIER] * 210, [cTabController sGet_GUI_MULTIPLIER] * 18)];
        label.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:[cTabController sGet_GUI_MULTIPLIER] * 14];
        label.textColor = [UIColor colorWithRed:255.0/255.0 green:166.0/255.0 blue:26.0/255.0 alpha:1];
        label.text = text_;
        [self addSubview:label];
        [arrPassiveLabelsAndValues addObject:label];
        y += [cTabController sGet_GUI_MULTIPLIER] * 15;
    }
}

-(void)destroyMetrics
{
    for (UILabel* l in arrPassiveLabelsAndValues) {
        [l removeFromSuperview];
    }
    [arrPassiveLabelsAndValues removeAllObjects];
}

-(void)hideMetrics
{
    for (UILabel* l in arrPassiveLabelsAndValues) {
        l.frame = CGRectMake(l.frame.origin.x, self.bounds.size.height + l.frame.origin.y, l.frame.size.width, l.frame.size.height);
    }
    self.btBack.userInteractionEnabled = NO;
}

-(void)showMetrics
{
    for (UILabel* l in arrPassiveLabelsAndValues) {
        l.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y - self.bounds.size.height, l.frame.size.width, l.frame.size.height);
    }
    self.btBack.userInteractionEnabled = YES;
}

- (IBAction)B_Share:(id)sender
{
    //if ([cTabController globalInstance].selectedTab != C_TABINDX_HISTORY) //Call from another tab
    //[self shareTest:self.testToShareExternal];
    //else
    [self shareTest:selectedTest];
}

-(void)activate
{
}

-(void)deactivate
{
}

@end
