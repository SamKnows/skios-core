//
//  SKAAppDelegate.m
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKAAppDelegate.h"

#import "SKATermsAndConditionsController.h"
#import "SKAMainResultsController.h"
#import "SKAActivationController.h"

NSString *const Upload_Url = @"/mobile/submitjson";
NSString *const Config_Url = @"/mobile/getconfig";

//NSString *const Upload_Url = @"http://dcs-mobile-SKA.samknows.com/mobile/submit";
//NSString *const Config_Url = @"http://dcs-mobile-SKA.samknows.com/mobile/getconfig";

NSString *const Schedule_Xml = @"SCHEDULE.xml";

NSString *const Prefs_Agreed = @"PREFS_AGREED_V2";
NSString *const Prefs_Activated = @"PREFS_ACTIVATED_V2";
NSString *const Prefs_TargetServer = @"PREFS_TARGET_SERVER";

NSString *const Prefs_DataDate = @"PREFS_DATA_DATE";
NSString *const Prefs_DataCapEnabled = @"PREFS_DATA_CAP_ENABLED";
NSString *const Prefs_DataCapValueBytes = @"PREFS_ALLOWANCE";

NSString *const Prefs_DataUsage = @"DATA_USAGE";
NSString *const Prefs_ClosestTarget = @"CLOSEST_TARGET";
NSString *const Prefs_DateRange = @"DATE_RANGE";
NSString *const Prefs_LastLocation = @"LAST_LOCATION";
NSString *const Prefs_LastTestSelection = @"LAST_TESTSELECTION";

@interface SKAAppDelegate ()

@property BOOL isConnected;

- (void)initSettings;
- (void)setupReachability;
- (void)populateSchedule;

- (void)setDeviceInformation;
- (void)setCarrierInformation;

- (void)reachabilityChanged:(NSNotification*)note;

@end

@implementation SKAAppDelegate

// Location...
@synthesize locationLatitude;
@synthesize locationLongitude;
@synthesize locationDateAsTimeIntervalSince1970;
@synthesize hasLocation;

@synthesize schedule;
@synthesize connectionStatus;
@synthesize dataCapExceeded;

@synthesize deviceModel;
@synthesize devicePlatform;
@synthesize carrierName;
@synthesize countryCode;
@synthesize networkCode;
@synthesize isoCode;


+ (NSString*)logFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [paths objectAtIndex:0];
    return [libraryPath stringByAppendingPathComponent:@"LOG.txt"];
}

+ (NSString*)jsonDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [paths objectAtIndex:0];
    NSString *docPath = [libraryPath stringByAppendingPathComponent:@"JSON"];
    
    return docPath;
}

+ (NSString*)jsonArchiveDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [paths objectAtIndex:0];
    NSString *docPath = [libraryPath stringByAppendingPathComponent:@"JSONArchive"];
    
    return docPath;
}

+ (NSString*)getNewJSONFilePath
{
    NSString *docPath = [SKAAppDelegate jsonDirectory];
    
    NSTimeInterval ti = [[SKCore getToday] timeIntervalSince1970];
    NSString *strDate = [NSString stringWithFormat:@"%d", (int)ti];
    
    return [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", strDate]];
}

+ (NSString*)getNewJSONArchiveFilePath
{
    NSString *docPath = [SKAAppDelegate jsonArchiveDirectory];
    
    NSTimeInterval ti = [[SKCore getToday] timeIntervalSince1970];
    NSString *strDate = [NSString stringWithFormat:@"%d", (int)ti];
    
    return [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", strDate]];
}

+ (NSString*)getJSONArchiveZipFilePath
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *libraryPath = [paths objectAtIndex:0];
  NSString *docPath = [libraryPath stringByAppendingPathComponent:@"export.zip"];
  return docPath;
}

//
// Location monitoring!
//

#pragma mark - Location Manager delegate methods

- (void)startLocationMonitoring
{
  @synchronized (self.class) {
    SK_ASSERT([CLLocationManager locationServicesEnabled]);
    
    locationManager = [[CLLocationManager alloc] init];
    SK_ASSERT(locationManager != nil);
    
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLHeadingFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //[locationManager setPausesLocationUpdatesAutomatically:NO];
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    // http://stackoverflow.com/questions/24062509/ios-8-location-services-not-working
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
      [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
    [locationManager stopUpdatingLocation];
    [locationManager startUpdatingLocation];
  }
}

-(void)stopLocationMonitoring {
  @synchronized (self.class) {
    if (locationManager != nil) {
      [locationManager stopUpdatingLocation];
      locationManager = nil;
    }
  }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  SK_ASSERT(false);
  
  self.hasLocation = NO;
  
  NSLog(@"%s %d %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:@"Location Manager Fail %@", [error localizedDescription]]);
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
  
  SK_ASSERT(locationManager != nil);
  
  for (CLLocation * newLocation in locations) {
    
    self.hasLocation = YES;
    //self.locationTimeStamp = newLocation.timestamp;
    
    if (self.locationLatitude == newLocation.coordinate.latitude) {
      if (self.locationLongitude == newLocation.coordinate.longitude) {
        continue;
      }
    }
    self.locationLatitude = newLocation.coordinate.latitude;
    self.locationLongitude = newLocation.coordinate.longitude;
    self.locationDateAsTimeIntervalSince1970 = [SKGlobalMethods getTimeNowAsTimeIntervalSince1970];
    
    // Update the last known location. If the device restarts, with Location Services turned off,
    // we can use this location for the 'last_location' field in the Submitted JSON.
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *loc = [NSMutableDictionary dictionary];
    [loc setObject:[NSNumber numberWithDouble:self.locationLatitude] forKey:@"LATITUDE"];
    [loc setObject:[NSNumber numberWithDouble:self.locationLongitude] forKey:@"LONGITUDE"];
    [loc setObject:[NSNumber numberWithDouble:self.locationDateAsTimeIntervalSince1970] forKey:@"LOCATIONDATE"];
    [prefs setObject:loc forKey:Prefs_LastLocation];
    [prefs synchronize];
  }
}

//
// Location monitoring (end)
//

- (void)addReachabilityStatus:(NSString*)route {
  // TODO - not required in SKA
}

#pragma mark - App Activation

- (void)initSettings
{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

  // Start with Mobile network type configured!
  [self switchNetworkTypeToMobile];
  
  if (![prefs objectForKey:Prefs_DataCapEnabled])
  {
    [prefs setObject:[NSNumber numberWithBool:YES] forKey:Prefs_DataCapEnabled];
  }
  
  if (![prefs objectForKey:Prefs_DataCapValueBytes])
  {
    int64_t theValue = 100L;
    theValue *= CBytesInAMegabyte;
    [prefs setObject:[NSNumber numberWithLongLong:theValue] forKey:Prefs_DataCapValueBytes];
  }
  
  if (![prefs objectForKey:Prefs_Agreed])
  {
    BOOL defaultValue = NO;
    SKAAppDelegate *appDelegate = [SKAAppDelegate getAppDelegate];
    if ([appDelegate getIsThisTheNewApp] == YES) {
      if ([appDelegate getNewAppShowInitialTermsAndConditions] == NO)
      {
        defaultValue = YES;
      }
    } else {
      if ([self showInitialTermsAndConditions] == NO)
      {
        defaultValue = YES;
      }
    }
    [prefs setObject:[NSNumber numberWithBool:defaultValue] forKey:Prefs_Agreed];
  }
  
  if (![prefs objectForKey:Prefs_Activated])
  {
    [prefs setObject:[NSNumber numberWithBool:NO] forKey:Prefs_Activated];
  }
  
  if (![prefs objectForKey:Prefs_DateRange])
  {
    [prefs setObject:[NSNumber numberWithInt:DATERANGE_1w1m3m1y_ONE_WEEK] forKey:Prefs_DateRange];
  }
  
//  if (![prefs objectForKey:Prefs_LastLocation])
//  {
//    NSMutableDictionary *loc = [NSMutableDictionary dictionary];
//    [loc setObject:[NSNumber numberWithDouble:0] forKey:@"LATITUDE"];
//    [loc setObject:[NSNumber numberWithDouble:0] forKey:@"LONGITUDE"];
//
//    [prefs setObject:loc forKey:Prefs_LastLocation];
//  }


  [prefs synchronize];
}

#pragma mark - Data Usage Method

- (void)amdDoUpdateDataUsage:(int)bytes
{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  if (nil == [prefs stringForKey:Prefs_DataUsage])
  {
    [prefs setObject:[NSNumber numberWithLongLong:bytes] forKey:Prefs_DataUsage];
    [prefs synchronize];
  }
  else
  {
    if ([SKAAppDelegate getIsUsingWiFi]) {
      // Don't add if on WiFi!
      return;
    }
    
    NSNumber *num = [prefs objectForKey:Prefs_DataUsage];
    
    long currentBytes = [num longLongValue];
    
    long totalBytes = currentBytes + bytes;
    //NSLog(@"totalBytes : %d", totalBytes);
    
    [prefs setObject:[NSNumber numberWithLongLong:totalBytes] forKey:Prefs_DataUsage];
    [prefs synchronize];
    
    if (self.schedule.dataCapMB > 0)
    {
      int64_t mbUsed = (int64_t)(totalBytes / CBytesInAMegabyte);
      
      // if we have exceeded the data cap, turn off auto-scheduling
      if (mbUsed > self.schedule.dataCapMB)
      {
        dataCapExceeded = YES;
      }
    }
  }
}

#pragma mark - Log File Methods
- (NSString*)getNetworkType:(int)date networkType:(NSString*)inNetworkType {
  return [self.class getNetworkType:date networkType:inNetworkType ForConnectionStatus:(ConnectionStatus)self.connectionStatus];
}
- (NSString*)getLocationInformationForDate:(int)date
{
  NSString *str = [NSString stringWithFormat:@"LOCATION;%f;%@;%f;%f;NA;", self.locationDateAsTimeIntervalSince1970, [SKGlobalMethods getNetworkOrGps], self.locationLatitude, self.locationLongitude];
#ifdef DEBUG
  NSLog(@"getLocationInformation=%@", str);
#endif // DEBUG
  return str;
}

- (NSString*)getNetworkState:(int)date {
  return [SKGlobalMethods getNetworkState:date ForConnectionStatus:(ConnectionStatus)self.connectionStatus];
}

- (int64_t)amdGetDataUsageBytes {
  return [self.class amdGetDataUsageBytes];
}

- (NSString*)getPhoneIdentity:(int)date {
  return [SKGlobalMethods getPhoneIdentity:date];
}

- (NSString*)getSimOperator:(int)date {
  return [SKGlobalMethods getSimOperator:date];
}

// not in use anymore..
- (NSString*)getCarrierInformation:(int)date {
  return [SKGlobalMethods getCarrierInformation:date];
}

+ (int64_t)amdGetDataUsageBytes
{
  SK_ASSERT(sizeof(int64_t) == 8);
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  if (nil == [prefs stringForKey:Prefs_DataUsage])
  {
    return 0;
  }
  else
  {
    NSNumber *num = [prefs objectForKey:Prefs_DataUsage];
    
    int64_t currentBytes = [num longLongValue];
    
    return currentBytes;
  }
}

- (void)amdDoAppendOutputResultsArrayToLogFile:(NSMutableArray*)results networkType:(NSString*)networkType
{
  SK_ASSERT(false);
}

-(void) createFolderAtPathIfNotExists:(NSString*)thePath {
  if (![[NSFileManager defaultManager] fileExistsAtPath:thePath])
  {
    if ([[NSFileManager defaultManager] createDirectoryAtPath:thePath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:NULL])
    {
#ifdef DEBUG
      NSLog(@"Created Directory at %@", thePath);
#endif // DEBUG
    }
    else
    {
      SK_ASSERT(false);
    }
  }
}

- (void)createJSONDirectories {
  NSString *jsonFolderPath = [self.class jsonDirectory];
  [self createFolderAtPathIfNotExists:jsonFolderPath];
  
  NSString *jsonArchiveFolderPath = [self.class jsonArchiveDirectory];
  [self createFolderAtPathIfNotExists:jsonArchiveFolderPath];
}

- (void)populateSchedule
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[SKAAppDelegate schedulePath]])
    {
        NSData *data = [NSData dataWithContentsOfFile:[SKAAppDelegate schedulePath]];
        
        if (nil != data)
        {
            SKScheduler *sch = [[SKAScheduler alloc] initWithXmlData:data];
            
            if (nil != sch)
            {
                self.schedule = sch;
            }
        }
    }
}

+ (void)setHasAgreed:(BOOL)value
{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  [prefs setObject:[SKCore getToday] forKey:Prefs_DataDate];
  [prefs setObject:[NSNumber numberWithBool:value] forKey:Prefs_Agreed];
  [prefs synchronize];
}

- (BOOL)hasAgreed
{
  if ([self showInitialTermsAndConditions] == NO) {
    // For such apps, always act as though the user has agreed to T&C...
    return YES;
  }
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  if ([prefs objectForKey:Prefs_Agreed])
  {
    NSNumber *num = [prefs objectForKey:Prefs_Agreed];
    if (nil != num)
    {
      return [num boolValue];
    }
  }
  
  return NO;
}


- (BOOL)hasNewAppAgreed
{
  if ([self getNewAppShowInitialTermsAndConditions] == NO) {
    // For such apps, always act as though the user has agreed to T&C...
    return YES;
  }
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  if ([prefs objectForKey:Prefs_Agreed])
  {
    NSNumber *num = [prefs objectForKey:Prefs_Agreed];
    if (nil != num)
    {
      return [num boolValue];
    }
  }
  
  return NO;
}

+ (void)setIsActivated:(BOOL)value
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithBool:value] forKey:Prefs_Activated];
    [prefs synchronize];
}

+ (BOOL)getIsActivated
{
  SKAAppDelegate *appDelegate = (SKAAppDelegate*)[UIApplication sharedApplication].delegate;
  return [appDelegate isActivated];
}

- (BOOL)isActivated
{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

  if ([prefs objectForKey:Prefs_Activated])
  {
    NSNumber *num = [prefs objectForKey:Prefs_Activated];
    if (nil != num)
    {
      return [num boolValue];
    }
  }

  return NO;
}

-(BOOL) getIsConnected {
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  
  [self updateReachabilityStatus:reachability];
  
  return self.isConnected;
}


- (void)amdDoUploadLogFile
{
  NSString *logFile = [SKAAppDelegate logFile];
  
  if (![[NSFileManager defaultManager] fileExistsAtPath:logFile])
  {
    SK_ASSERT(false);
    return;
  }
  
  NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:logFile];
  if (fileUrl == nil)
  {
    SK_ASSERT(false);
    return;
  }
  
  NSData *bodyData = [[NSData alloc] initWithContentsOfURL:fileUrl options:NSUTF8StringEncoding error:NULL];
  
  if (bodyData == nil)
  {
    SK_ASSERT(false);
    return;
  }
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  if (![prefs stringForKey:Prefs_TargetServer]){
    SK_ASSERT(false);
    return;
  }
  
  // Prepare the URL
  NSString *baseServer = [prefs stringForKey:Prefs_TargetServer];
  NSString *urlString = [NSString stringWithFormat:@"%@%@", baseServer, Upload_Url];
  
  NSURL *url = [NSURL URLWithString:urlString];
  
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setURL:url];
  [request setHTTPMethod:@"POST"];
  [request setTimeoutInterval:60];
  [request setValue:@"false" forHTTPHeaderField:@"X-Encrypted"];
  
  NSString *enterpriseId = [[SKAAppDelegate getAppDelegate] getEnterpriseId];
  [request setValue:enterpriseId forHTTPHeaderField:@"X-Enterprise-ID"];
  [request setHTTPBody:bodyData];
  
  NSOperationQueue *idQueue = [[NSOperationQueue alloc] init];
  [idQueue setName:@"com.samknows.uploadqueue"];
  
  // Send an asynchronous request

  [NSURLConnection sendAsynchronousRequest:request queue:idQueue completionHandler:^(NSURLResponse *response, 
                                                                                     NSData *data, 
                                                                                     NSError *error) 
  {
    SK_ASSERT_NONSERROR(error);

    if (error != nil)
    {
      NSLog(@"Error uploading log file : %@", error);
      SK_ASSERT(false);
    }
    else
    {
      if (response == nil)
      {
        SK_ASSERT(false);
      }
      else
      {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;

        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]])
        {
          if (httpResponse.statusCode == 200)
          {
            // file upload successful.. blast out the file
            if (![[NSFileManager defaultManager] removeItemAtPath:logFile error:NULL])
            {
              NSLog(@"Unable to remove log file");
            }
            else
            {
              NSLog(@"Uploaded Log File");
            }
          }
          else
          {
            if (nil != data)
            {
              NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"UploadLogFile Response : %@", newStr);
            }
          }
        }
      }
    }
  }];
}

#pragma mark - Upload File Creation

//The file is deleted only when the size is different than requested
- (void)amdDoCreateUploadFile
{
  NSString *uploadFilePath = [SKAAppDelegate getUploadFilePathNeverNil];
  
  if ([[NSFileManager defaultManager] fileExistsAtPath:uploadFilePath]) {
    NSError *error = nil;
    
    // To save time, do not delete the file at every application launch.
    // Do this only when the existing one is different to that needed.
    if ([[[NSFileManager defaultManager] attributesOfItemAtPath:uploadFilePath error:nil][NSFileSize] longLongValue] != FILE_SIZE)
    {
      BOOL bRes = [[NSFileManager defaultManager] removeItemAtPath:uploadFilePath error:&error];
      SK_ASSERT(bRes);
    }
  }
  
  if (![[NSFileManager defaultManager] fileExistsAtPath:uploadFilePath])
  {
    // Perform in background, to prevent hang at app start!
    //NSLog(@"PREPARE!");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      //NSLog(@"START!");
      NSMutableData *bodyData = [[NSMutableData alloc] initWithLength:FILE_SIZE];
      [bodyData writeToFile:uploadFilePath atomically:NO];
      SK_ASSERT([[[NSFileManager defaultManager] attributesOfItemAtPath:uploadFilePath error:nil][NSFileSize] longLongValue] == FILE_SIZE);
      
      //NSLog(@"COMPLETE!");
      
        // Could back to the main thread, if we wanted...
//      dispatch_sync(dispatch_get_main_queue(), ^{
//      });
    });
  }
}

#pragma mark - Reachability

- (void)updateReachabilityStatus:(Reachability*)curReach
{
  NetworkStatus netStatus = [curReach currentReachabilityStatus];
  
  switch (netStatus)
  {
    case NotReachable:
    {
      connectionStatus = NONE;
      self.isConnected = NO;
      break;
    }
    
    case ReachableViaWiFi:
    {
      if ([curReach isInterventionRequired])
      {
        self.isConnected = NO;
        connectionStatus = NONE;
      }
      else
      {
        self.isConnected = ![curReach isConnectionRequired];
        connectionStatus = self.isConnected ? WIFI : NONE;
      }
      
      break;
    }
    
    case ReachableViaWWAN:
    {
      self.isConnected = ![curReach isConnectionRequired];
      connectionStatus = self.isConnected ? CELLULAR : NONE;
      break;
    }
  }
}

//Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification*)note
{
	Reachability *curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateReachabilityStatus:curReach];
}

- (void)setupReachability
{
    self.isConnected = NO;
    connectionStatus = NONE;
}


- (void) amdDoSaveJSON:(NSString*)jsonString {
 
  // 1. Write to JSON file for upload
  {
    NSString *path = [SKAAppDelegate getNewJSONFilePath];
    NSError *error = nil;
    if ([jsonString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
      //NSLog(@"Wrote JSON Successfully");
    }
    else
    {
#ifdef DEBUG
      NSLog(@"Error writing JSON : %@", error.localizedDescription);
      SK_ASSERT(false);
#endif // DEBUG
    }
  }
  
  // 2. Write to JSON file for archive (for subsequent export!)
  {
    NSString *path = [SKAAppDelegate getNewJSONArchiveFilePath];
    NSError *error = nil;
    if ([jsonString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
      NSLog(@"Wrote Archive JSON Successfully");
    }
    else
    {
#ifdef DEBUG
      NSLog(@"Error writing archive JSON : %@", error.localizedDescription);
      SK_ASSERT(false);
#endif // DEBUG
    }
  }
}

+(BOOL) exportArchivedJSONFilesToZip:(int*)RpFiles {
  
  // Write to zip of JSON files!
  
  NSString *zipFilePath = [self getJSONArchiveZipFilePath];
  
  NSError *error = nil;
  NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self jsonArchiveDirectory] error:&error];
  if (dirFiles == nil) {
    SK_ASSERT(false);
    return NO;
  }
  
  if (error != nil) {
    SK_ASSERT(false);
    return NO;
  }
  
  ZipArchive *zipArchive = [[ZipArchive alloc] init];
  BOOL bRes = [zipArchive CreateZipFile2:zipFilePath];
  if (bRes == NO) {
    SK_ASSERT(false);
    return NO;
  }
  
  int itemCount = 0;
  for (NSString *theFile in dirFiles) {
    NSURL *url = [NSURL URLWithString:theFile];
    if ([[url pathExtension] isEqualToString:@"json"]) {
      NSString *fullFilePath = [[self jsonArchiveDirectory] stringByAppendingPathComponent:theFile];
      SK_ASSERT([[NSFileManager defaultManager] fileExistsAtPath:fullFilePath]);
      
      NSString *writeAsFile = [[url pathComponents] lastObject];
      bRes = [zipArchive addFileToZip:fullFilePath newname:writeAsFile];
      SK_ASSERT(bRes);
      
      itemCount++;
    }
  }
  
  [zipArchive CloseZipFile2];

  // Note that the zip file seems to be invalid, if there are zero items!
  *RpFiles = itemCount;
  
#ifdef DEBUG
    NSLog(@"DEBUG: Wrote zip file to %@, with %d items", zipFilePath, itemCount);
#endif // DEBUG
  
  zipArchive = nil;
  
  return YES;
}

+(void) deleteAllArchivedJSONFiles {
  
  // Write to zip of JSON files!
  
  NSError *error = nil;
  NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self jsonArchiveDirectory] error:&error];
  if (dirFiles == nil) {
    SK_ASSERT(false);
    return;
  }
  
  if (error != nil) {
    SK_ASSERT(false);
    return;
  }
  
  int itemCount = 0;
  for (NSString *theFile in dirFiles) {
    NSURL *url = [NSURL URLWithString:theFile];
    if ([[url pathExtension] isEqualToString:@"json"]) {
      NSString *fullFilePath = [[self jsonArchiveDirectory] stringByAppendingPathComponent:theFile];
      SK_ASSERT([[NSFileManager defaultManager] fileExistsAtPath:fullFilePath]);
     
      error = nil;
      BOOL bRes = [[NSFileManager defaultManager] removeItemAtPath:fullFilePath error:&error];
      SK_ASSERT(bRes == YES);
      SK_ASSERT(error == nil);
      
      itemCount++;
    }
  }
}

-(void) amdDoUploadJSON {
  
  NSString *jsonDirectory = [SKAAppDelegate jsonDirectory];
  
  NSError *error = nil;
  NSArray *jsonFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:jsonDirectory error:&error];
  
  if (nil == error)
  {
    //NSLog(@"JSON Files to Upload : %d", [jsonFiles count]);
    
    for (int j=0; j<[jsonFiles count]; j++)
    {
      NSString *fileName = [jsonFiles objectAtIndex:j];
      
      NSString *pathToFile = [jsonDirectory stringByAppendingPathComponent:fileName];
      
      if ([[NSFileManager defaultManager] fileExistsAtPath:pathToFile]) // ultra paranoid
      {
        NSURL *fileUrl = [NSURL fileURLWithPath:pathToFile];
        
        NSData *json = [NSData dataWithContentsOfURL:fileUrl options:NSUTF8StringEncoding error:NULL];
        
        if (nil == json) {
          break;
        }
        
        if ([json length] == 0) {
          break;
        }
        
        [self postResultsJsonToServer:json filePath:pathToFile];
      }
    }
  }
}

- (void)postResultsJsonToServer:(NSData*)jsonData filePath:(NSString*)filePath {

  NSError *error = nil;
  NSDictionary *theDictionaryToSend = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:NSJSONReadingMutableLeaves
                                                                       error:&error];
  NSArray *metricsArray = theDictionaryToSend[@"metrics"];
  
  NSString *test_id = nil;
  NSNumber *testId = nil;
  
  for (NSObject *jsonObject in metricsArray) {
    //NSLog(@"DEBUG: description = %@", jsonObject.description);
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
      NSDictionary *theDict = (NSDictionary*)jsonObject;
      if ([theDict objectForKey:@"test_id"]) {
        test_id = theDict[@"test_id"];
        break;
      }
    }
  }
  
  if (test_id == nil) {
#ifdef DEBUG
    NSLog(@"DEBUG: This is an OLD TEST - with no test_id!");
#endif // DEBUG
  } else {
    testId = [NSNumber numberWithLongLong:test_id.longLongValue];
    NSLog(@"DEBUG: test_id = %@", testId);
  }
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSString *server = [prefs objectForKey:Prefs_TargetServer];
  
  NSString *strUrl = [NSString stringWithFormat:@"%@%@", server, Upload_Url];
  NSURL *url = [NSURL URLWithString:strUrl];
  
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setURL:url];
  [request setHTTPMethod:@"POST"];
  //[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  //[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setTimeoutInterval:60];
  [request setValue:@"false" forHTTPHeaderField:@"X-Encrypted"];
  
  NSString *enterpriseId = [[SKAAppDelegate getAppDelegate] getEnterpriseId];
  [request setValue:enterpriseId forHTTPHeaderField:@"X-Enterprise-ID"];
  [request setHTTPBody:jsonData];
  
#ifdef DEBUG
  NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  NSLog(@"DEBUG: postResultsJsonToServer - jsonStr=...\n%@", jsonStr);
#endif // DEBUG
  
  NSOperationQueue *idQueue = [[NSOperationQueue alloc] init];
  [idQueue setName:@"com.samknows.uploadqueue"];
  
  [NSURLConnection sendAsynchronousRequest:request queue:idQueue completionHandler:^(NSURLResponse *response,
                                                                                     NSData *data,
                                                                                     NSError *error)
   {
     SK_ASSERT_NONSERROR(error);
     
     if (error != nil)
     {
       NSLog(@"Error uploading JSON file : %@", error.description);
       SK_ASSERT(false);
     }
     else
     {
       if (response == nil)
       {
         SK_ASSERT(false);
         return;
       }
       
       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
       
       if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]])
       {
         if (httpResponse.statusCode == 200)
         {
           //
           // File upload successfully!
           //
#ifdef DEBUG
           NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
           NSLog(@"DEBUG: postResultsJsonToServer - jsonStr=...\n%@", jsonStr);
#endif // DEBUG
           
           NSError *error = nil;
           NSDictionary *theObject = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingMutableLeaves
                                                                       error:&error];
#ifdef DEBUG
           NSLog(@"DEBUG: postResultsJsonToServer - resultDictionaryFromJson=%@", theObject);
#endif // DEBUG
           if (testId != nil) {
             // Write the data to the database, along with the
             // other passive metrics associated with the test!
             // Notify the app, in case it is interested in showing it.
             NSString *thePublicIp = theObject[@"public_ip"];
             SK_ASSERT(thePublicIp != nil);
             NSString *theSubmissionId = theObject[@"submission_id"];
             SK_ASSERT(theSubmissionId != nil);
             
             [SKDatabase updateMetricForTestId:testId
                                  MetricColumn:@"Public_IP"
                                   MetricValue:thePublicIp];
             
             [SKDatabase updateMetricForTestId:testId
                                  MetricColumn:@"Submission_ID"
                                   MetricValue:theSubmissionId];
             
             // Send the notification - it is used ONLY if it matches THE CURRENT TEST ID!
             dispatch_async(dispatch_get_main_queue(), ^{
               [[NSNotificationCenter defaultCenter] postNotificationName:@"SKB_public_ip_and_Submission_ID" object:testId userInfo:@{@"test_id":testId, @"Public_IP": thePublicIp, @"Submission_ID":theSubmissionId}];
             });
           }
           
           // file upload successfully.. remove the uploaded file
           if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL])
           {
#ifdef DEBUG
             NSLog(@"DEBUG: Unable to remove JSON file");
#endif // DEBUG
           }
           else
           {
#ifdef DEBUG
             NSLog(@"DEBUG: Uploaded JSON File");
#endif // DEBUG
           }
         }
         else
         {
#ifdef DEBUG
           if (nil != data)
           {
             NSString* newStr = [[NSString alloc] initWithData:data
                                                      encoding:NSUTF8StringEncoding];
             
             NSLog(@"DEBUG: postResultsJsonToServer Error Response : %@", newStr);
           }
#endif // DEBUG
         }
       }
     }
   }];
}




- (void)setDeviceInformation
{
  self.deviceModel = [SKGlobalMethods getDeviceModel];
  self.devicePlatform = [SKGlobalMethods getDevicePlatform];
}

- (void)setCarrierInformation
{
  self.carrierName = [SKGlobalMethods getCarrierName];
  self.countryCode = [SKGlobalMethods getCarrierMobileCountryCode];
  self.networkCode = [SKGlobalMethods getCarrierNetworkCode];
  self.isoCode =     [SKGlobalMethods getCarrierIsoCountryCode];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//  // Start by DISABLING all internet NSURLRequest caching!
//  // http://twobitlabs.com/2012/01/ios-ipad-iphone-nsurlcache-uiwebview-memory-utilization/
//  // otherwise, we can run out of file handles due to too many cached responses!
//  [NSURLCache setSharedURLCache:[[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:@"nsurlcache"]];
  
  // FIRST - remove an old file in Library/UPLOAD.dat, that we don't want backed-up to the Cloud!
  // It is large; and if it remains there, it might lead to the application getting rejected by
  // Apple's reviewers.
  // http://stackoverflow.com/questions/15446457/which-technique-will-be-better-to-store-ios-app-data-and-run-app-in-offline-mode
  NSString *oldUploadFilePath = [SKAAppDelegate getUploadFilePathDeprecated];
  if ([[NSFileManager defaultManager] fileExistsAtPath:oldUploadFilePath])
  {
    NSError *theError;
    BOOL bRes = [[NSFileManager defaultManager] removeItemAtPath:oldUploadFilePath error:&theError];
    SK_ASSERT(bRes);
#ifdef DEBUG
    if (bRes == NO) {
      [SKDebugSupport SK_ASSERT_NONSERROR_INTERNAL:theError File:__FILE__ Line:__LINE__];
    }
#endif // DEBUG
  }

  
  [SKGlobalMethods setLongDateFormat:@"MM-dd-yyyy HH:mm"];
  [SKGlobalMethods setShortDateFormat:@"MM/dd/yy"];
  [SKGlobalMethods setGraphDateFormat:@"MM/d"];
  
  [self initSettings];
  [self createJSONDirectories];
  [self amdDoCreateUploadFile];
  [self setupReachability];
  //[self startLocationMonitoring];
  [self setDeviceInformation];
  [self setCarrierInformation];
  
  [SKDatabase createDatabase];
 
#ifdef DEBUG
//  // DEBUG build - grab a copy of the database, for investigation via iTunes file sharing!
//  if ([[NSFileManager defaultManager] fileExistsAtPath:[SKDatabase dbPath]]) {
//    // Database exists!
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSError *error = nil;
//    NSString *targetPath = [NSString stringWithFormat:@"%@/sk.db", documentsDirectory];
//    BOOL bRes = [[NSFileManager defaultManager] copyItemAtPath:[SKDatabase dbPath] toPath:targetPath error:&error];
//    SK_ASSERT(bRes);
//  }
#endif // DEBUG

  
  [self amdDoUploadJSON];
  
  if (![self hasAgreed]) {
  } else if (![self isActivated]) {
  } else {
    SK_ASSERT([self hasAgreed] && [self isActivated]);
  }
  
  if ([self hasAgreed] && [self isActivated])
  {
    [self populateSchedule];
  }
  
  if (![self hasAgreed]) {
    // Not yet agreed to T&C - start (modally) with the T&C navigation controller, instead!
    UIStoryboard *storyboard = [self.class getStoryboard];
    self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditionsNavigationController"];
  } else if (![self isActivated]) {
    [self didFinishAppLaunching_NotActivatedYet];
  }
    
  
  [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // STOP monitoring location data, as we background!
  [[SKAAppDelegate getAppDelegate] stopLocationMonitoring];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // STOP monitoring location data, as we background!
  if ([SKAutotest sGetIsTestRunning] == YES) {
    // Resume monitoring!
    [[SKAAppDelegate getAppDelegate] startLocationMonitoring];
  }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

+(UIStoryboard*) getStoryboard {
  // http://stackoverflow.com/questions/8025248/uistoryboard-get-first-view-controller-from-applicationdelegate
  NSString *storyBoardName = [[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"];
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:[NSBundle mainBundle]];
  return storyboard;
}


+(NSDate*)getStartDateForThisRange:(DATERANGE_1w1m3m1y)range {
  NSDate *previousDate = nil;
  
  switch (range)
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
      previousDate = [NSDate dateWithTimeIntervalSinceNow:-7*24*60*60];
      break;
  }
  
  return previousDate;
}


+ (double)getAverageTestData:(DATERANGE_1w1m3m1y)range testDataType:(TestDataType)testDataType {
  return [SKAAppDelegate getAverageTestData:range testDataType:testDataType RetCount:NULL];
}

+ (double)getAverageTestData:(DATERANGE_1w1m3m1y)range testDataType:(TestDataType)testDataType RetCount:(int*)retCount {
  NSDate *previousDate = [SKAAppDelegate getStartDateForThisRange:range];
  NSDate *dateNow = [SKCore getToday];
  
  return [SKDatabase getAverageTestDataJoinToMetrics:previousDate toDate:dateNow testDataType:testDataType WhereNetworkTypeEquals:[SKAAppDelegate getNetworkTypeString] RetCount:retCount];
}

+ (void)setClosestTarget:(NSString*)value
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:value forKey:Prefs_ClosestTarget];
    [prefs synchronize];
}

+ (NSString *)schedulePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    return [cacheDirectory stringByAppendingPathComponent:Schedule_Xml];
}

+ (NSString *)getUploadFilePathDeprecated
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
  NSString *docDirectory = [paths objectAtIndex:0];
  return [docDirectory stringByAppendingPathComponent:@"UPLOAD.dat"];
}

+ (NSString *)getUploadFilePathNeverNil {
  NSString *uploadFilePath = NSTemporaryDirectory();
  uploadFilePath = [uploadFilePath stringByAppendingPathComponent:@"UPLOAD.dat"];
  return uploadFilePath;
}

+ (NSString *)getUploadFilePath
{
  NSString *uploadFilePath = [self getUploadFilePathNeverNil];
 
  if (![[NSFileManager defaultManager] fileExistsAtPath:uploadFilePath]) {
    SK_ASSERT(false);
    return nil;
  }
  
  if([[[NSFileManager defaultManager] attributesOfItemAtPath:uploadFilePath error:nil][NSFileSize] longLongValue] != FILE_SIZE) {
    SK_ASSERT(false);
    return nil;
  }
  
  return uploadFilePath;
  
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *docDirectory = [paths objectAtIndex:0];
//    return [docDirectory stringByAppendingPathComponent:@"UPLOAD.dat"];
}

#pragma mark SKAutotestManagerDelegate

-(double)       amdGetLatitude {
  return self.locationLatitude;
}
-(double)       amdGetLongitude {
  return self.locationLongitude;
}
-(NSTimeInterval)       amdGetDateAsTimeIntervalSince1970{
  return self.locationDateAsTimeIntervalSince1970;
}

-(SKScheduler *)amdGetSchedule {
  return self.schedule;
}
-(NSString *)   amdGetClosestTarget {
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  return (NSString*)[prefs objectForKey:Prefs_ClosestTarget];
}
-(void)   amdSetClosestTarget:(NSString*)inClosestTarget {
  [self.class setClosestTarget:inClosestTarget];
}
-(BOOL)         amdGetIsConnected {
  return self.isConnected;
}
-(NSInteger)    amdGetConnectionStatus {
  return self.connectionStatus;
}

-(NSString*)     amdGetFileUploadPath {
  return [self.class getUploadFilePath];
}

+(BOOL) getIsUsingWiFi {
#if TARGET_IPHONE_SIMULATOR
#ifdef DEBUG
  NSLog(@"DEBUG: warning - on simulator, in DEBUG mode - pretending to be on 3G... (i.e. pretending we are NOT using WiFi!)");
  return NO;
#endif  // DEBUG
#else // TARGET_IPHONE_SIMULATOR
  
//#ifdef DEBUG
//  NSLog(@"DEBUG: warning - on device, in DEBUG mode - pretending to be on 3G... (i.e. pretending we are NOT using WiFi!)");
//  return NO;
//#endif  // DEBUG
#endif // TARGET_IPHONE_SIMULATOR
  
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  NetworkStatus netStatus = [reachability currentReachabilityStatus];
  return (netStatus == kReachableViaWiFi);
  // Do NOT use this variant, as it is CACHED - and won't work (say) on first use.
  //return ([[SKAAppDelegate getAppDelegate] amdGetConnectionStatus] == WIFI);
}

+(SKAAppDelegate*) getAppDelegate {
  SKAAppDelegate *appDelegate = (SKAAppDelegate*)[UIApplication sharedApplication].delegate;
  return appDelegate;
}

//
// Network type filter - querying and setting
//

static NSString *networkTypeSwitchValue = nil;

+(NSString*) getNetworkTypeString {
  return networkTypeSwitchValue;
}

-(BOOL) isNetworkTypeMobile {
  if ([networkTypeSwitchValue isEqualToString:@"mobile"]) {
    return YES;
  }
  return NO;
}

-(BOOL) isNetworkTypeWiFi {
  if ([networkTypeSwitchValue isEqualToString:@"network"]) {
    return YES;
  }
  return NO;
}

-(BOOL) isNetworkTypeAll {
  if ([networkTypeSwitchValue isEqualToString:@"all"]) {
    return YES;
  }
  return NO;
}

-(void) switchNetworkTypeToWiFi {
  networkTypeSwitchValue = @"network";
  
  SK_ASSERT(![self isNetworkTypeMobile]);
  SK_ASSERT(![self isNetworkTypeAll]);
  SK_ASSERT([self isNetworkTypeWiFi]);
  
  //   [[NSNotificationCenter defaultCenter] postNotificationName:@"SKANetworkResultChange" object:self];
}

-(void) switchNetworkTypeToMobile {
  networkTypeSwitchValue = @"mobile";
  
  SK_ASSERT(![self isNetworkTypeWiFi]);
  SK_ASSERT(![self isNetworkTypeAll]);
  SK_ASSERT([self isNetworkTypeMobile]);
  
  //[[NSNotificationCenter defaultCenter] postNotificationName:@"SKANetworkResultChange" object:self];
}

-(void) switchNetworkTypeToAll {
  networkTypeSwitchValue = @"all";
  
  SK_ASSERT(![self isNetworkTypeWiFi]);
  SK_ASSERT(![self isNetworkTypeMobile]);
  SK_ASSERT([self isNetworkTypeAll]);
  
  //[[NSNotificationCenter defaultCenter] postNotificationName:@"SKANetworkResultChange" object:self];
}

+(void) Controller_DoShowFacebookOrTwitterEtc_PostAlertToShowImageOrNot:(UIViewController*)fromViewController SocialNetwork:(NSString*)socialNetwork ExportThisString:(NSString*)exportString ShowImage:(BOOL)showImage
{
  SK_ASSERT([[SKAAppDelegate getAppDelegate] isSocialMediaExportSupported]);
  
  if([SLComposeViewController isAvailableForServiceType:socialNetwork])
  {
    UIImage *exportImage = nil;
    if([[SKAAppDelegate getAppDelegate] isSocialMediaImageExportSupported]) {
      // TODO - move this decision to a menu item from which the user selects...
      exportImage = [fromViewController.view skTakeScreenshot];
    }
    
    SLComposeViewController *theSocialMediaController = [SLComposeViewController composeViewControllerForServiceType:socialNetwork];
    
    SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
      
      [theSocialMediaController dismissViewControllerAnimated:YES completion:nil];
      
      switch(result) {
        case SLComposeViewControllerResultCancelled:
        default:
          //NSLog(@"Cancelled.....");
          break;
        case SLComposeViewControllerResultDone:
        {
          UIAlertView * alert = [[UIAlertView alloc]
                                 initWithTitle:sSKCoreGetLocalisedString(@"Posted")
                                 message:sSKCoreGetLocalisedString(@"Post successful")
                                 delegate:nil
                                 cancelButtonTitle:sSKCoreGetLocalisedString(@"Dismiss")
                                 otherButtonTitles:nil];
          [alert show];
        }
          break;
      }};
    
    //NSLog(@"message=%@", message);
    
    
    if (showImage) {
      SK_ASSERT((exportImage != nil) == [[SKAAppDelegate getAppDelegate] isSocialMediaImageExportSupported]);
      if (exportImage != nil) {
        // Use the attached screenshot...
        SK_ASSERT([[SKAAppDelegate getAppDelegate] isSocialMediaImageExportSupported]);
        [theSocialMediaController addImage:exportImage];
      } else if ([socialNetwork isEqualToString:SLServiceTypeFacebook]) {
        // Otherwise, add image ONLY for Facebook; otherwise, there is not enough room for the text!
        [theSocialMediaController addImage:[UIImage imageNamed:@"Icon.png"]];
      }
    } else {
      if ([socialNetwork isEqualToString:SLServiceTypeFacebook]) {
        // Otherwise, add image ONLY for Facebook; otherwise, there is not enough room for the text!
        [theSocialMediaController addImage:[UIImage imageNamed:@"Icon.png"]];
      }
    }
    
    if (showImage) {
      if ([socialNetwork isEqualToString:SLServiceTypeTwitter]) {
       
#ifdef DEBUG
        NSLog(@"DEBUG: exportString was: %@", exportString);
#endif // DEBUG
        exportString = [exportString
                        stringByReplacingOccurrencesOfString:
                        sSKCoreGetLocalisedString(@"SocialMedia_TwitterIfUsingImage_ChangeFromThis1")
                        withString:
                        sSKCoreGetLocalisedString(@"SocialMedia_TwitterIfUsingImage_ChangeToThis1")
                        ];
        
        exportString = [exportString
                        stringByReplacingOccurrencesOfString:
                        sSKCoreGetLocalisedString(@"SocialMedia_TwitterIfUsingImage_ChangeFromThis2")
                        withString:
                        sSKCoreGetLocalisedString(@"SocialMedia_TwitterIfUsingImage_ChangeToThis2")
                        ];
        
        exportString = [exportString
                        stringByReplacingOccurrencesOfString:
                        sSKCoreGetLocalisedString(@"SocialMedia_TwitterIfUsingImage_ChangeRegex4From")
                        withString:
                        sSKCoreGetLocalisedString(@"SocialMedia_TwitterIfUsingImage_ChangeRegex4To")
                        options:NSRegularExpressionSearch
                        range:NSMakeRange(0, exportString.length)
                        ];
#ifdef DEBUG
        NSLog(@"DEBUG: exportString now: %@", exportString);
#endif // DEBUG
      }
    }
    
    [theSocialMediaController setInitialText:exportString];
    [theSocialMediaController setCompletionHandler:completionHandler];
    [fromViewController presentViewController:theSocialMediaController animated:YES completion:nil];
  }
  else
  {
    SK_ASSERT(false);
  }
}

+(void) Controller_DoShowFacebookOrTwitterEtc:(UIViewController*)fromViewController SocialNetwork:(NSString*)socialNetwork ExportThisString:(NSString*)exportString
{
  if ([[SKAAppDelegate getAppDelegate] isSocialMediaImageExportSupported] == NO) {
    // This app configuration doesn't allow for image data to be attached to the social
    // media post.
    [self Controller_DoShowFacebookOrTwitterEtc_PostAlertToShowImageOrNot:fromViewController SocialNetwork:socialNetwork ExportThisString:exportString ShowImage:NO];
    return;
  }
  
  // This app configuration allows for image data to be attached to the social
  // media post. Prompt the user to see if they want to attache a screen grab.
  SK_ASSERT([[SKAAppDelegate getAppDelegate] isSocialMediaExportSupported]);
  UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle:sSKCoreGetLocalisedString(@"Include screenshot?")
                        message:sSKCoreGetLocalisedString(@"Would you like to include a screenshot with your social media post?")
                        delegate:nil
                        cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_No")
                        otherButtonTitles:sSKCoreGetLocalisedString(@"MenuAlert_Yes"),
                        nil];
  
  [alert showWithBlock:^(UIAlertView *inView, NSInteger buttonIndex) {
    
    [self Controller_DoShowFacebookOrTwitterEtc_PostAlertToShowImageOrNot:fromViewController SocialNetwork:socialNetwork ExportThisString:exportString ShowImage:YES];
    
  } cancelBlock:^(UIAlertView *inView) {
    [self Controller_DoShowFacebookOrTwitterEtc_PostAlertToShowImageOrNot:fromViewController SocialNetwork:socialNetwork ExportThisString:exportString ShowImage:NO];
  }];
}

#define ACTION_MENU   5

#pragma mark - Action Sheet Delegate

static NSDictionary *GShowThisTextForSocialMediaExport = nil;
static UIViewController *GpShowSocialExportOnViewController = nil;

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)range {
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)range {
  
  if (range == actionSheet.cancelButtonIndex) {
    return;
  }
  
  if (actionSheet.tag == ACTION_MENU) {
    NSString *buttonText = [actionSheet buttonTitleAtIndex:range];
    
    if ([buttonText isEqualToString:sSKCoreGetLocalisedString(@"SocialMediaOption_Twitter")]) {
      
      NSString *bodyString = GShowThisTextForSocialMediaExport[SLServiceTypeTwitter];
      [SKAAppDelegate Controller_DoShowFacebookOrTwitterEtc:GpShowSocialExportOnViewController SocialNetwork:(NSString*)SLServiceTypeTwitter ExportThisString:bodyString];
    } else if ([buttonText isEqualToString:sSKCoreGetLocalisedString(@"SocialMediaOption_SinaWeibo")]) {
      
      NSString *bodyString = GShowThisTextForSocialMediaExport[SLServiceTypeSinaWeibo];
      [SKAAppDelegate Controller_DoShowFacebookOrTwitterEtc:GpShowSocialExportOnViewController SocialNetwork:(NSString*)SLServiceTypeSinaWeibo ExportThisString:bodyString];
      
    } else if ([buttonText isEqualToString:sSKCoreGetLocalisedString(@"SocialMediaOption_Facebook")]) {
      NSString *bodyString = GShowThisTextForSocialMediaExport[SLServiceTypeFacebook];
      [SKAAppDelegate Controller_DoShowFacebookOrTwitterEtc:GpShowSocialExportOnViewController SocialNetwork:(NSString*)SLServiceTypeFacebook ExportThisString:bodyString];
      
    } else {
      SK_ASSERT(false);
    }
  }
  else
  {
    SK_ASSERT(false);
  }
  
}

+ (void)showActionSheetForSocialMediaExport:(NSDictionary*)exportThisText OnViewController:(UIViewController*)onViewController {
 
  GShowThisTextForSocialMediaExport = exportThisText;
  GpShowSocialExportOnViewController = onViewController;
  
  /*
   // Using UIActivityViewController doesn't really work for us, as we want a restricted list,
   // and (primarily!) we want different text to be submitted according to the media type.
   UIImage *postImage = [UIImage imageNamed:@"Icon.png"];
   NSString *postText =  [self getTextForSocialMedia:SLServiceTypeSinaWeibo];
   NSArray *activityItems = @[postText, postImage];
   
   UIActivityViewController *activityController =
   [[UIActivityViewController alloc]
   initWithActivityItems:activityItems
   applicationActivities:nil];
   
   [self presentViewController:activityController
   animated:YES completion:nil];
  
   
   118617350
   */
  
  
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:sSKCoreGetLocalisedString(@"Title_ShareUsingSocialMedia")
                                                           delegate:[SKAAppDelegate getAppDelegate]
                                                  cancelButtonTitle:nil
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:nil];
  
  
  NSMutableArray *array = [NSMutableArray new];
  
//#if TARGET_IPHONE_SIMULATOR
//#else // TARGET_IPHONE_SIMULATOR
  if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
//#endif // TARGET_IPHONE_SIMULATOR
  {
    [array addObject:sSKCoreGetLocalisedString(@"SocialMediaOption_Twitter")];
  }
  if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
  {
    [array addObject:sSKCoreGetLocalisedString(@"SocialMediaOption_Facebook")];
  }
  if([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo])
  {
    [array addObject:sSKCoreGetLocalisedString(@"SocialMediaOption_SinaWeibo")];
  }
  //[array addObject:@"Email"];
  
  if (array.count == 0) {
    UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:sSKCoreGetLocalisedString(@"Title_ShareUsingSocialMediaInfo")
     message:sSKCoreGetLocalisedString(@"Message_ShareUsingSocialMediaInfo")
     delegate:nil
     cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_OK")
     otherButtonTitles:nil];
    [alert show];
    return;
  }
  
  [array addObject:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")];
  
  int i;
  for (i = 0; i < array.count; i++)
  {
    [actionSheet addButtonWithTitle:array[i]];
  }
  
  actionSheet.cancelButtonIndex = [array count] - 1;
  actionSheet.tag = ACTION_MENU; //  Magic identifiying tag, on the base UIView
  actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
  
  [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
  
  // Calling with showFromToolbar seems to make no difference!
  //[actionSheet showFromToolbar:self.uiToolbar];
  // http://stackoverflow.com/questions/3568773/very-weird-error-of-uiactionsheet-clicks-not-working-on-the-bottom-of-the-action
  [actionSheet showInView:[UIApplication sharedApplication].delegate.window];
  //[actionSheet showInView:GpShowSocialExportOnViewController.view];
}

+ (NSString*)sBuildSocialMediaMessageForCarrierName:(NSString*)carrierName SocialNetwork:(NSString *)socialNetwork Upload:(NSString *)upload Download:(NSString *)download ThisDataIsAveraged:(BOOL)thisDataIsAveraged {
  //
  // Build-up the message!
  //
  
  NSMutableString *bodyString = [NSMutableString new];
  
  NSString *separator = @", ";
  
  BOOL bShortMessages = YES;
  
  NSString *carrierNameReformatted = @"";
  if (carrierName != nil) {
    // Social media posting: Change e.g. "My-Network-Operator" to "MyNetworkOperator"
    // Social media posting: Change e.g. "Network&Operator" to "NetworkOperator"
    // Social media posting: Change e.g. "Network - Operator" to "Network Operator"
    carrierNameReformatted = [carrierName stringByReplacingOccurrencesOfString:@"-" withString:@""];
    carrierNameReformatted = [carrierNameReformatted stringByReplacingOccurrencesOfString:@"&" withString:@""];
    carrierNameReformatted = [carrierNameReformatted stringByReplacingOccurrencesOfString:@"  " withString:@" "];
  }
  
  if ([socialNetwork isEqualToString:SLServiceTypeTwitter]) {
    if ((carrierName != nil) && (carrierName.length > 0)) {
      if (thisDataIsAveraged) {
        [bodyString setString:[NSString stringWithFormat:@"%@%@", sSKCoreGetLocalisedString(@"SocialMedia_Header_Twitter_Carrier_Average"), carrierNameReformatted]];
      } else {
        [bodyString setString:[NSString stringWithFormat:@"%@%@", sSKCoreGetLocalisedString(@"SocialMedia_Header_Twitter_Carrier"), carrierNameReformatted]];
      }
    } else {
      if (thisDataIsAveraged) {
        [bodyString setString:[NSString stringWithFormat:@"%@", sSKCoreGetLocalisedString(@"SocialMedia_Header_Twitter_NoCarrier_Average")]];
      } else {
        [bodyString setString:[NSString stringWithFormat:@"%@", sSKCoreGetLocalisedString(@"SocialMedia_Header_Twitter_NoCarrier")]];
        
      }
    }
  } else if ([socialNetwork isEqualToString:SLServiceTypeFacebook]) {
    bShortMessages = NO;
    if ((carrierName != nil) && (carrierName.length > 0)) {
      if (thisDataIsAveraged) {
        [bodyString setString:[NSString stringWithFormat:@"%@%@", sSKCoreGetLocalisedString(@"SocialMedia_Header_Facebook_Carrier_Average"), carrierNameReformatted]];
      } else {
        [bodyString setString:[NSString stringWithFormat:@"%@%@", sSKCoreGetLocalisedString(@"SocialMedia_Header_Facebook_Carrier"), carrierNameReformatted]];
      }
    } else {
      if (thisDataIsAveraged) {
        [bodyString setString:[NSString stringWithFormat:@"%@", sSKCoreGetLocalisedString(@"SocialMedia_Header_Facebook_NoCarrier_Average")]];
      } else {
        [bodyString setString:[NSString stringWithFormat:@"%@", sSKCoreGetLocalisedString(@"SocialMedia_Header_Facebook_NoCarrier")]];
      }
    }
  } else if ([socialNetwork isEqualToString:SLServiceTypeSinaWeibo]) {
    if ((carrierName != nil) && (carrierName.length > 0)) {
      if (thisDataIsAveraged) {
        [bodyString setString:[NSString stringWithFormat:@"%@%@", sSKCoreGetLocalisedString(@"SocialMedia_Header_SinaWeibo_Carrier_Average"), carrierNameReformatted]];
      } else {
        [bodyString setString:[NSString stringWithFormat:@"%@%@", sSKCoreGetLocalisedString(@"SocialMedia_Header_SinaWeibo_Carrier"), carrierNameReformatted]];
      }
    } else {
      [bodyString setString:[NSString stringWithFormat:@"%@", sSKCoreGetLocalisedString(@"SocialMedia_Header_SinaWeibo_NoCarrier")]];
    }
  } else {
    SK_ASSERT(false);
    return nil;
  }

  
  BOOL bGotData = NO;
  
  if (download != nil) {
    [bodyString appendString:@" "];
    [bodyString appendString:[NSString stringWithFormat:@"%@: %@", sSKCoreGetLocalisedString(@"SocialMedia_Download_Short"), download]];
    
    bGotData = YES;
  }
  
  if (upload != nil) {
    if (bGotData == YES)
    {
      [bodyString appendString:separator];
    }
    else
    {
      [bodyString appendString:@" "];
    }
    
    bGotData = YES;
    
    [bodyString appendString:[NSString stringWithFormat:@"%@: %@", sSKCoreGetLocalisedString(@"SocialMedia_Upload_Short"),upload]];
  }
  
  // TODO - what should we do if bGotData is NO...?
  SK_ASSERT(bGotData);
  
  [bodyString appendString:@" "];
  
  if (bShortMessages) {
    [bodyString appendString:sSKCoreGetLocalisedString(@"SocialMedia_Footer_Short")];
    // SK_ASSERT(bodyString.length < 140);
  } else {
    [bodyString appendString:sSKCoreGetLocalisedString(@"SocialMedia_Footer_Long")];
  }
  
  return bodyString;
}

// Configuration - must be overriden by child class!
-(NSString *) getEnterpriseId {
  SK_ASSERT(false);
  return nil;
}

-(NSString *) getBaseUrlString {
  SK_ASSERT(false);
  return nil;
}

// For now, only this app variant supports server-based upload speed measurement testing.
-(BOOL)       getDoesAppSupportServerBasedUploadSpeedTesting {
  return NO;
}

-(BOOL) getIsFooterSupported {
  return NO;
}

-(BOOL) getIsJitterSupported {
  SK_ASSERT(false);
  return NO;
}

-(BOOL) getIsLossSupported {
  return YES;
}

-(BOOL) alwaysRunAllTests {
  SK_ASSERT(false);
  return NO;
}

-(BOOL) supportContinuousTesting {
  SK_ASSERT(false);
  return NO;
}

-(BOOL) supportOneDayResultView {
  SK_ASSERT(false);
  return NO;
}

-(BOOL) supportExportMenuItem {
  return NO;
}

-(BOOL)enableTestsSelection
{
    return YES;
}

// User interface special behaviours - you can override if you want!
-(UIFont*) getSpecialFontOfSize:(CGFloat)theSize {
  return [UIFont systemFontOfSize:theSize];
}

// Not all variants need to start with a T&C screen!
-(BOOL) showInitialTermsAndConditions {
  return YES;
}

-(BOOL) getIsThisTheNewApp {
  return NO;
}

// The New app might show T&C at start, but this is handled differently to the way the old app does it.
-(BOOL) getNewAppShowInitialTermsAndConditions {
  return NO;
}

// Some versions of the app can disable the datacap
-(BOOL) canDisableDataCap {
  return NO;
}

-(void) setIsDataCapEnabled:(BOOL) value {
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  [prefs setObject:[NSNumber numberWithBool:value] forKey:Prefs_DataCapEnabled];
  [prefs synchronize];
}

-(BOOL) isDataCapEnabled {
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  if ([prefs objectForKey:Prefs_DataCapEnabled])
  {
    NSNumber *num = [prefs objectForKey:Prefs_DataCapEnabled];
    if (nil != num)
    {
      return [num boolValue];
    }
  }
  
  return YES;
}

// Return the device 'unique id' via the app_id value in the upload data *only* for some app variants;
// the default is NO.
-(BOOL) getShouldUploadDeviceId {
  return NO;
}

// By default, throttle query is not supported.
-(BOOL) isThrottleQuerySupported {
  return NO;
}

-(BOOL) isSocialMediaExportSupported {
  return NO;
}

-(BOOL) isSocialMediaImageExportSupported {
  return NO;
}

-(BOOL) isTwitterExportSupported {
  return [self isSocialMediaExportSupported];
}

-(BOOL) isFacebookExportSupported {
  return [self isSocialMediaExportSupported];
}

-(void) didFinishAppLaunching_NotActivatedYet {
  UIStoryboard *storyboard = [self.class getStoryboard];
  self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ActivationNavigationController"];
}

// Device ID querying
- (NSString*)getCurrentlySelectedDeviceId {
  NSString *deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:@"unitID"];
  return deviceId;
}

- (void)setCurrentlySelectedDeviceId:(NSString*)deviceId {
  [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:@"unitID"];
}

-(void) setLogoImage:(UIImageView*)uiImage {
  return;
}

-(SKBShowMetricsRule) getShowMetricsOnMainScreen {
  return SKBShowMetricsRule_ShowPassiveMetrics_WhenTestStarts;
}

-(NSArray*)getPassiveMetricsToDisplay
{
  return @[SKB_TESTVALUERESULT_C_PM_CARRIER_NAME,
           SKB_TESTVALUERESULT_C_PM_CARRIER_COUNTRY,
           SKB_TESTVALUERESULT_C_PM_CARRIER_NETWORK,
           SKB_TESTVALUERESULT_C_PM_CARRIER_ISO,
           SKB_TESTVALUERESULT_C_PM_DEVICE,
           SKB_TESTVALUERESULT_C_PM_OS,
           SKB_TESTVALUERESULT_C_PM_TARGET,
           SKB_TESTVALUERESULT_C_PM_PUBLIC_IP,
           SKB_TESTVALUERESULT_C_PM_SUBMISSION_ID];
}

-(BOOL)showNetworkTypeAndTargetAtEndOfHistoryPassiveMetrics {
  return YES;
}

-(void) overrideTabBarColoursOnStart:(UITabBarController*)inTabBarController {
}

-(BOOL) getIsBestTargetDisplaySupported {
  return YES;
}

-(NSArray*)getDownloadSixSegmentMaxValues {
  return @[@1.0, @2.0, @5.0, @10.0, @30.0, @100.0];
}

-(NSArray*)getUploadSixSegmentMaxValues {
  return @[@0.5, @1.0, @1.5, @2.0, @5.0, @10.0];
}


+(void) sResetUserInterfaceBackToMainScreen  {
  UIStoryboard *storyboard = [SKAAppDelegate getStoryboard];
  UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"theRootNavigationControllerTAndCAgreed"];
  
  SKAAppDelegate *instance;
  UIApplication *application = [UIApplication sharedApplication];
  instance = (SKAAppDelegate*)application.delegate;
  instance.window.rootViewController = nc;
}

+(void) resetUserInterfaceBackToRunTestsScreenFromViewController { // :(UIViewController*)fromViewController {
  UIStoryboard *storyboard = [SKAAppDelegate getStoryboard];
  UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"theRootNavigationController"];
  
  SKAAppDelegate *instance;
  UIApplication *application = [UIApplication sharedApplication];
  instance = (SKAAppDelegate*)application.delegate;
  instance.window.rootViewController = nc;
}

// The width of the top left icon, can be customized for different app variants!
-(CGFloat) getNewAppTopLeftIconWidth {
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    return 120.0;
  }
  
  return 60.0;
}

-(NSString*) getNewAppUrlForHelpAbout {
  return nil;
}
@end
