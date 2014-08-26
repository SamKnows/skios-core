//
//  SKAActivationController2.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKAActivationController2.h"
#import "Reusable/CTabController/cTabController.h"

@interface SKAActivationController2 ()
{
    BOOL isRunning;
    SKAAppDelegate *appDelegate;
    SKAClosestTargetTest *targetTest;
    UIBackgroundTaskIdentifier btid;
}

- (void)setTitleLabel;

- (void)tryToActivate;
- (void)getConfig;
- (BOOL)saveScheduleXml:(NSString*)xml;
- (void)populateNewSchedule;

- (void)checkInitTests;

- (void)activationError:(NSString*)error;
@end

@implementation SKAActivationController2

-(void)showActivated
{
//    self.lActivating.backgroundColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:1.0];
}

-(void)showaDownloaded
{
//    self.lDownloading.backgroundColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:1.0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int y = 30;
    
    self.lTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, y, self.view.bounds.size.width - 40, 60)];
    self.lTitle.textColor = [UIColor orangeColor];
    self.lTitle.textAlignment = UITextAlignmentCenter;
    self.lTitle.font = [UIFont fontWithName:@"Roboto-Regular" size:22];
    self.lTitle.text = NSLocalizedString(@"Storyboard_Activation_Title",nil);
    self.lTitle.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    self.lTitle.layer.cornerRadius = 3;
    self.lTitle.layer.borderWidth = 0.5;
    self.lTitle.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
    self.lTitle.clipsToBounds = YES;
    [self.view addSubview:self.lTitle];
    y += 80;
    
    self.lActivating = [[UILabel alloc] initWithFrame:CGRectMake(20, y, self.view.bounds.size.width - 40, 40)];
    self.lActivating.textColor = [UIColor whiteColor];
    self.lActivating.textAlignment = UITextAlignmentCenter;
    self.lActivating.font = [UIFont fontWithName:@"Roboto-Light" size:15];
    self.lActivating.text = NSLocalizedString(@"ACTV_Label_Activating", nil);
    self.lActivating.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    self.lActivating.layer.cornerRadius = 3;
    self.lActivating.layer.borderWidth = 0.5;
    self.lActivating.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
    self.lActivating.clipsToBounds = YES;
    [self.view addSubview:self.lActivating];
    y += 50;

    self.lDownloading = [[UILabel alloc] initWithFrame:CGRectMake(20, y, self.view.bounds.size.width - 40, 40)];
    self.lDownloading.textColor = [UIColor whiteColor];
    self.lDownloading.textAlignment = UITextAlignmentCenter;
    self.lDownloading.font = [UIFont fontWithName:@"Roboto-Light" size:15];
    self.lDownloading.text = NSLocalizedString(@"ACTV_Label_Downloading", nil);
    self.lDownloading.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    self.lDownloading.layer.cornerRadius = 3;
    self.lDownloading.layer.borderWidth = 0.5;
    self.lDownloading.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
    self.lDownloading.clipsToBounds = YES;
    [self.view addSubview:self.lDownloading];
    y += 80;

#define C_SPINNER_LEFT_INSET    40
    
    self.spinnerMain = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.lTitle.frame.origin.x + self.lTitle.frame.size.width - C_SPINNER_LEFT_INSET, self.lTitle.frame.origin.y, C_SPINNER_LEFT_INSET, self.lTitle.frame.size.height)];
    self.spinnerMain.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.spinnerMain.hidesWhenStopped = YES;
    self.spinnerMain.hidden = YES;
    [self.view addSubview:self.spinnerMain];

    self.spinnerActivating = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.lActivating.frame.origin.x + self.lActivating.frame.size.width - C_SPINNER_LEFT_INSET, self.lActivating.frame.origin.y, C_SPINNER_LEFT_INSET, self.lActivating.frame.size.height)];
    self.spinnerActivating.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.spinnerActivating.hidesWhenStopped = YES;
    self.spinnerActivating.hidden = YES;
    [self.view addSubview:self.spinnerActivating];

    self.spinnerDownloading = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.lDownloading.frame.origin.x + self.lDownloading.frame.size.width - C_SPINNER_LEFT_INSET, self.lDownloading.frame.origin.y, C_SPINNER_LEFT_INSET, self.lDownloading.frame.size.height)];
    self.spinnerDownloading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.spinnerDownloading.hidesWhenStopped = YES;
    self.spinnerDownloading.hidden = YES;
    [self.view addSubview:self.spinnerDownloading];
    
    isRunning = YES;
    
    appDelegate = (SKAAppDelegate*)[UIApplication sharedApplication].delegate;

//    [self.spinnerMain startAnimating];
//    [self.spinnerActivating startAnimating];
//    [self.spinnerDownloading startAnimating];
    
//    self.lblMain.text = NSLocalizedString(@"ACTV_Label", nil);
}

-(void)viewWillAppear:(BOOL)animated
{
    ((UIViewWithGradient*)self.view).innerColor = [[cTabController globalInstance] getInnerColor];
    ((UIViewWithGradient*)self.view).outerColor = [[cTabController globalInstance] getOuterColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startBackgroundTask];
    
    [self tryToActivate];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [self finishBackgroundTask];
}

- (void)setTitleLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,45,45)];
    label.font = [[SKAAppDelegate getAppDelegate] getSpecialFontOfSize:17];
    
    label.textColor = [UIColor blackColor];
    
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"ACTV_Title", nil);
    [label sizeToFit];
    self.navigationItem.titleView = label;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
//    if ( (isRunning) ||
//        ([self.spinnerActivating isAnimating] == YES) ||
//        ([self.spinnerDownloading isAnimating] == YES) ||
//        ([self.spinnerMain isAnimating] == YES)
//        )
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//                                                        message:NSLocalizedString(@"ACTV_Running", nil)
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"MenuAlert_OK",nil)
//                                              otherButtonTitles: nil];
//        [alert show];
//        return;
//    }
//    
//    [SKAAppDelegate resetUserInterfaceBackToRunTestsScreenFromViewController];
}

#pragma mark - Background Task management

- (void)startBackgroundTask
{
    btid = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        if (btid != UIBackgroundTaskInvalid)
        {
            [[UIApplication sharedApplication] endBackgroundTask:btid];
            btid = UIBackgroundTaskInvalid;
        }
    }];
}

- (void)finishBackgroundTask
{
    if (btid != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:btid];
        btid = UIBackgroundTaskInvalid;
    }
}

#pragma mark - Activation Lifecycle

- (void)tryToActivate
{
    isRunning = YES;
    
    [self.spinnerActivating stopAnimating];
    [self.spinnerDownloading stopAnimating];
    [self.spinnerMain stopAnimating];
//    [self.imgviewActivate setHidden:YES];
//    [self.imgviewDownload setHidden:YES];
    
    [self.spinnerMain startAnimating];
    
    [self getBaseServer];
    
    //[self getConfig];
}

// What happens:
// 1. call to [self getBaseServer] ... which is an async HTTP request to query the server to use.
// 2. Once that completes, call to [self getConfig] ... which is an async HTTP request
// 3. Once that completes, call to [self populateNewSchedule] and complete.

- (void)getBaseServer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.spinnerActivating startAnimating];
    });
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *baseUrlString = [[SKAAppDelegate getAppDelegate] getBaseUrlString];
    NSURL *url = [NSURL URLWithString:baseUrlString];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:20];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *enterpriseId = [[SKAAppDelegate getAppDelegate] getEnterpriseId];
    [request setValue:enterpriseId forHTTPHeaderField:@"X-Enterprise-ID"];
    
    NSOperationQueue *idQueue = [[NSOperationQueue alloc] init];
    [idQueue setName:@"com.samknows.basequeue"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:idQueue completionHandler:^(NSURLResponse *response,
                                                                                       NSData *data,
                                                                                       NSError *error)
     {
         SK_ASSERT_NONSERROR(error);
         
         if (nil == error)
         {
             if (nil != data)
             {
                 NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 
                 if (nil != strData)
                 {
                     NSString *server = [strData stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                     
                     NSString *final = [NSString stringWithFormat:@"%@%@", @"http://", server];
                     
                     if (nil != final)
                     {
                         // To get here, we succeeeded!
                         NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                         [prefs setObject:final forKey:Prefs_TargetServer];
                         [prefs synchronize];
                         [self getConfig];
                         return;
                     }
                 }
             }
         }
         
         // TO get here, there is an ERROR!
         [self activationError:@"getBaseServer"];
     }];
}

- (void)getConfig
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.spinnerDownloading startAnimating];
    });
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *server = [prefs objectForKey:Prefs_TargetServer];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", server, Config_Url];
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:20];
    
    NSString *enterpriseId = [[SKAAppDelegate getAppDelegate] getEnterpriseId];
    [request setValue:enterpriseId forHTTPHeaderField:@"X-Enterprise-ID"];
    
    NSString *appVersionName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
#ifdef DEBUG
    NSLog(@"DEBUG: app_version_name=%@", appVersionName);
#endif // DEBUG
    
    NSString *appVersionCode = [appVersionName stringByReplacingOccurrencesOfString:@"." withString:@""];
#ifdef DEBUG
    NSLog(@"DEBUG: app_version_code=%@", appVersionCode);
#endif // DEBUG
    [request setValue:appVersionCode forHTTPHeaderField:@"X-App-Version"];
    
    NSOperationQueue *idQueue = [[NSOperationQueue alloc] init];
    [idQueue setName:@"com.samknows.schedulequeue"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:idQueue completionHandler:^(NSURLResponse *response,
                                                                                       NSData *data,
                                                                                       NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             SK_ASSERT_NONSERROR(error);
             
             if (nil != error)
             {
                 [self activationError:[NSString stringWithFormat:@"getConfig : %@", [error localizedDescription]]];
                 return;
             }
             
             if (nil == response)
             {
                 [self activationError:@"getConfig : nil response"];
                 return;
             }
             
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
             
             if (httpResponse.statusCode == 200)
             {
                 if (nil != data)
                 {
                     NSString *xml = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                     
                     //NSLog(@"xml : ");
                     NSLog(@"%s %d %@", __FUNCTION__, __LINE__, xml);
                     
                     if (nil != xml)
                     {
                         if ([self saveScheduleXml:xml])
                         {
                             [self populateNewSchedule];
                             return;
                         }
                     }
                 }
             }
             
             [self activationError:@"getConfig"];
         });
     }];
}

- (BOOL)saveScheduleXml:(NSString*)xml
{
    BOOL result = false;
    
    if (nil != xml)
    {
        if ([xml length] > 0)
        {
            NSString *filePath = [SKAAppDelegate schedulePath];
            
            NSError *error;
            result = [xml writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
            
            if (!result)
            {
                [self activationError:[NSString stringWithFormat:@"saveScheduleXml : %@", [error localizedDescription]]];
            }
        }
    }
    return result;
}

- (void)populateNewSchedule
{
    NSString *file = [SKAAppDelegate schedulePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:file])
    {
        NSData *data = [NSData dataWithContentsOfFile:file];
        
        if (nil != data)
        {
            SKScheduler *schedule = [[SKAScheduler alloc] initWithXmlData:data];
            
            if (nil != schedule)
            {
                appDelegate.schedule = schedule;
                
                [SKAAppDelegate setIsActivated:YES];
                
                [self.spinnerMain stopAnimating];
                [self.spinnerActivating stopAnimating];
                [self.spinnerDownloading stopAnimating];
                
                [self showActivated];
                [self showaDownloaded];
                
                
                isRunning = NO;
                
                [[self delegate] hasCompleted];
                
                [self dismissModalViewControllerAnimated:YES];
            }
        }
    }
}

- (void)checkInitTests
{
    /*
     if (![appDelegate.schedule hasValidInitTests]) {
     SK_ASSERT(false);
     } else {
     int closestTargetTestCount = 0;
     
     int testCount = [appDelegate.schedule getInitTestCount];
     for (int j=0; j<testCount; j++)
     {
     NSString *testName = [appDelegate.schedule getInitTestName:j];
     
     if (nil != testName)
     {
     if ([testName length] > 0)
     {
     if ([testName isEqualToString:@"closestTarget"])
     {
     // There might be more than one of these, I suppose - but I think we should know at debug time if that
     // ever happens; as the decision to mark activation is completed (isRunning = NO) is dependent on
     // the (only?!) clostestTarget test completing...
     closestTargetTestCount++;
     SK_ASSERT(closestTargetTestCount == 1);
     [self runClosestTargetTest];
     }
     }
     }
     }
     }
     */
}

- (void)activationError:(NSString*)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"Activation Error : %@", error);
        
        [self.spinnerActivating stopAnimating];
        [self.spinnerDownloading stopAnimating];
        [self.spinnerMain stopAnimating];

//        [self.imgviewActivate setHidden:YES];
//        [self.imgviewDownload setHidden:YES];
        
        isRunning = NO;
    });
}

@end
