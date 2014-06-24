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

NSString *const Prefs_Agreed = @"PREFS_AGREED";
NSString *const Prefs_Activated = @"PREFS_ACTIVATED";
NSString *const Prefs_TargetServer = @"PREFS_TARGET_SERVER";

NSString *const Prefs_DataDate = @"PREFS_DATA_DATE";
NSString *const Prefs_DataCapEnabled = @"PREFS_DATA_CAP_ENABLED";
NSString *const Prefs_DataCapValueBytes = @"PREFS_ALLOWANCE";

NSString *const Prefs_DataUsage = @"DATA_USAGE";
NSString *const Prefs_ClosestTarget = @"CLOSEST_TARGET";
NSString *const Prefs_DateRange = @"DATE_RANGE";
NSString *const Prefs_LastLocation = @"LAST_LOCATION";

@interface SKAAppDelegate ()

@property BOOL isConnected;

- (void)initSettings;
- (void)setupReachability;
- (void)setupLocationServices;
- (void)populateSchedule;

- (void)setDeviceInformation;
- (void)setCarrierInformation;

- (void)reachabilityChanged:(NSNotification*)note;

- (void)submitJSON:(NSData*)jsonData filePath:(NSString*)filePath;

@end

@implementation SKAAppDelegate

@synthesize latitude;
@synthesize longitude;
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

#pragma mark - Location Manager delegate methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.hasLocation = NO;
    
    NSLog(@"%s %d %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:@"Location Manager Fail %@", [error localizedDescription]]);
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    self.hasLocation = YES;
    
    //self.locationTimeStamp = newLocation.timestamp;
    self.latitude = newLocation.coordinate.latitude;
    self.longitude = newLocation.coordinate.longitude;
    
    // Update the last known location. If the device restarts, with Location Services turned off,
    // we can use this location for the 'last_location' field in the Submitted JSON.
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *loc = [NSMutableDictionary dictionary];
    [loc setObject:[NSNumber numberWithDouble:self.latitude] forKey:@"LATITUDE"];
    [loc setObject:[NSNumber numberWithDouble:self.longitude] forKey:@"LONGITUDE"];
    [prefs setObject:loc forKey:Prefs_LastLocation];
    [prefs synchronize];
}

- (void)setupLocationServices
{
    self.latitude = 0;
    self.longitude = 0;
    //self.locationTimeStamp = [SKCore getToday];
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [locationManager startUpdatingLocation];
}

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
    if ([self showInitialTermsAndConditions] == NO)
    {
      defaultValue = YES;
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
  
  if (![prefs objectForKey:Prefs_LastLocation])
  {
    NSMutableDictionary *loc = [NSMutableDictionary dictionary];
    [loc setObject:[NSNumber numberWithDouble:0] forKey:@"LATITUDE"];
    [loc setObject:[NSNumber numberWithDouble:0] forKey:@"LONGITUDE"];
    
    [prefs setObject:loc forKey:Prefs_LastLocation];
  }
  
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
- (NSString*)getLocationInformation:(int)date
{
  NSString *str = [NSString stringWithFormat:@"LOCATION;%d;%@;%f;%f;NA;", date, [SKGlobalMethods getNetworkOrGps], self.latitude, self.longitude];
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
    NSLog(@"MPC HERE!");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      NSLog(@"MPC START!");
      NSMutableData *bodyData = [[NSMutableData alloc] initWithLength:FILE_SIZE];
      [bodyData writeToFile:uploadFilePath atomically:NO];
      SK_ASSERT([[[NSFileManager defaultManager] attributesOfItemAtPath:uploadFilePath error:nil][NSFileSize] longLongValue] == FILE_SIZE);
      
      NSLog(@"MPC COMPLETE!");
      
      dispatch_sync(dispatch_get_main_queue(), ^{
        //Call back to the main thread, if we want!
      });
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
        
        if (nil == json) break;
        
        if ([json length] == 0) break;
        
        [self submitJSON:json filePath:pathToFile];
      }
    }
  }
}

- (void)submitJSON:(NSData*)jsonData filePath:(NSString*)filePath {
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSString *server = [prefs objectForKey:Prefs_TargetServer];
  
  NSString *strUrl = [NSString stringWithFormat:@"%@%@", server, Upload_Url];
  NSURL *url = [NSURL URLWithString:strUrl];
  
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setURL:url];
  [request setHTTPMethod:@"POST"];
  [request setTimeoutInterval:60];
  [request setValue:@"false" forHTTPHeaderField:@"X-Encrypted"];
  
  NSString *enterpriseId = [[SKAAppDelegate getAppDelegate] getEnterpriseId];
  [request setValue:enterpriseId forHTTPHeaderField:@"X-Enterprise-ID"];
  [request setHTTPBody:jsonData];
  
#ifdef DEBUG
  NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  NSLog(@"DEBUG: upload - jsonStr=...\n%@", jsonStr);
#endif // DEBUG
  
  NSOperationQueue *idQueue = [[NSOperationQueue alloc] init];
  [idQueue setName:@"com.samknows.uploadqueue"];
  
  [NSURLConnection sendAsynchronousRequest:request queue:idQueue completionHandler:^(NSURLResponse *response,
                                                                                     NSData *data,
                                                                                     NSError *error)
   {
     SK_ASSERT_NONSERROR(error);
     
     if (nil != error)
     {
       NSLog(@"Error uploading JSON file : %@", error);
     }
     else
     {
       if (nil == response)
       {
         return;
       }
       
       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
       
       if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]])
       {
         if (httpResponse.statusCode == 200)
         {
           // file upload successful.. blast out the file
           if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL])
           {
             NSLog(@"Unable to remove JSON file");
           }
           else
           {
             NSLog(@"Uploaded JSON File");
           }
         }
         else
         {
           if (nil != data)
           {
             NSString* newStr = [[NSString alloc] initWithData:data
                                                      encoding:NSUTF8StringEncoding];
             
             NSLog(@"submitJSON Error Response : %@", newStr);
           }
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
  [self setupLocationServices];
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
    UIStoryboard *storyboard = [self.class getStoryboard];
    self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ActivationNavigationController"];
    
  }
    
  
  [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
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

+(void) resetUserInterfaceBackToRunTestsScreenFromViewController { // :(UIViewController*)fromViewController {
  UIStoryboard *storyboard = [SKAAppDelegate getStoryboard];
  UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"theRootNavigationController"];
  
  SKAAppDelegate *instance;
  UIApplication *application = [UIApplication sharedApplication];
  instance = (SKAAppDelegate*)application.delegate;
  instance.window.rootViewController = nc;
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
  return self.latitude;
}
-(double)       amdGetLongitude {
  return self.longitude;
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
          UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Posted",nil) message:NSLocalizedString(@"Post successful",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles: nil];
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
                        NSLocalizedString(@"SocialMedia_TwitterIfUsingImage_ChangeFromThis1",nil)
                        withString:
                        NSLocalizedString(@"SocialMedia_TwitterIfUsingImage_ChangeToThis1",nil)
                        ];
        
        exportString = [exportString
                        stringByReplacingOccurrencesOfString:
                        NSLocalizedString(@"SocialMedia_TwitterIfUsingImage_ChangeFromThis2",nil)
                        withString:
                        NSLocalizedString(@"SocialMedia_TwitterIfUsingImage_ChangeToThis2",nil)
                        ];
        
        exportString = [exportString
                        stringByReplacingOccurrencesOfString:
                        NSLocalizedString(@"SocialMedia_TwitterIfUsingImage_ChangeRegex4From",nil)
                        withString:
                        NSLocalizedString(@"SocialMedia_TwitterIfUsingImage_ChangeRegex4To",nil)
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
                        initWithTitle:NSLocalizedString(@"Include screenshot?",nil)
                        message:NSLocalizedString(@"Would you like to include a screenshot with your social media post?",nil)
                        delegate:nil
                        cancelButtonTitle:NSLocalizedString(@"MenuAlert_No",nil)
                        otherButtonTitles:NSLocalizedString(@"MenuAlert_Yes",nil), nil];
  
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)range
{
  if (range == actionSheet.cancelButtonIndex) {
    return;
  }
  
  if (actionSheet.tag == ACTION_MENU) {
    NSString *buttonText = [actionSheet buttonTitleAtIndex:range];
    
    if ([buttonText isEqualToString:NSLocalizedString(@"SocialMediaOption_Twitter",nil)]) {
      
      NSString *bodyString = GShowThisTextForSocialMediaExport[SLServiceTypeTwitter];
      [SKAAppDelegate Controller_DoShowFacebookOrTwitterEtc:GpShowSocialExportOnViewController SocialNetwork:(NSString*)SLServiceTypeTwitter ExportThisString:bodyString];
    } else if ([buttonText isEqualToString:NSLocalizedString(@"SocialMediaOption_SinaWeibo",nil)]) {
      
      NSString *bodyString = GShowThisTextForSocialMediaExport[SLServiceTypeSinaWeibo];
      [SKAAppDelegate Controller_DoShowFacebookOrTwitterEtc:GpShowSocialExportOnViewController SocialNetwork:(NSString*)SLServiceTypeSinaWeibo ExportThisString:bodyString];
      
    } else if ([buttonText isEqualToString:NSLocalizedString(@"SocialMediaOption_Facebook",nil)]) {
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
  
  
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Title_ShareUsingSocialMedia",nil)
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
    [array addObject:NSLocalizedString(@"SocialMediaOption_Twitter",nil)];
  }
  if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
  {
    [array addObject:NSLocalizedString(@"SocialMediaOption_Facebook",nil)];
  }
  if([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo])
  {
    [array addObject:NSLocalizedString(@"SocialMediaOption_SinaWeibo",nil)];
  }
  //[array addObject:@"Email"];
  
  if (array.count == 0) {
    UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:NSLocalizedString(@"Title_ShareUsingSocialMediaInfo",nil)
     message:NSLocalizedString(@"Message_ShareUsingSocialMediaInfo",nil)
     delegate:nil
     cancelButtonTitle:NSLocalizedString(@"MenuAlert_OK",nil)
     otherButtonTitles:nil];
    [alert show];
    return;
  }
  
  [array addObject:NSLocalizedString(@"MenuAlert_Cancel",nil)];
  
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
        [bodyString setString:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"SocialMedia_Header_Twitter_Carrier_Average",nil), carrierNameReformatted]];
      } else {
        [bodyString setString:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"SocialMedia_Header_Twitter_Carrier",nil), carrierNameReformatted]];
      }
    } else {
      if (thisDataIsAveraged) {
        [bodyString setString:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SocialMedia_Header_Twitter_NoCarrier_Average",nil)]];
      } else {
        [bodyString setString:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SocialMedia_Header_Twitter_NoCarrier",nil)]];
        
      }
    }
  } else if ([socialNetwork isEqualToString:SLServiceTypeFacebook]) {
    bShortMessages = NO;
    if ((carrierName != nil) && (carrierName.length > 0)) {
      if (thisDataIsAveraged) {
        [bodyString setString:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"SocialMedia_Header_Facebook_Carrier_Average",nil), carrierNameReformatted]];
      } else {
        [bodyString setString:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"SocialMedia_Header_Facebook_Carrier",nil), carrierNameReformatted]];
      }
    } else {
      if (thisDataIsAveraged) {
        [bodyString setString:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SocialMedia_Header_Facebook_NoCarrier_Average",nil)]];
      } else {
        [bodyString setString:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SocialMedia_Header_Facebook_NoCarrier",nil)]];
      }
    }
  } else if ([socialNetwork isEqualToString:SLServiceTypeSinaWeibo]) {
    if ((carrierName != nil) && (carrierName.length > 0)) {
      if (thisDataIsAveraged) {
        [bodyString setString:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"SocialMedia_Header_SinaWeibo_Carrier_Average",nil), carrierNameReformatted]];
      } else {
        [bodyString setString:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"SocialMedia_Header_SinaWeibo_Carrier",nil), carrierNameReformatted]];
      }
    } else {
      [bodyString setString:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SocialMedia_Header_SinaWeibo_NoCarrier",nil)]];
    }
  } else {
    SK_ASSERT(false);
    return nil;
  }

  
  BOOL bGotData = NO;
  
  if (download != nil) {
    [bodyString appendString:@" "];
    [bodyString appendString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"SocialMedia_Download_Short",nil), download]];
    
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
    
    [bodyString appendString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"SocialMedia_Upload_Short",nil),upload]];
  }
  
  // TODO - what should we do if bGotData is NO...?
  SK_ASSERT(bGotData);
  
  [bodyString appendString:@" "];
  
  if (bShortMessages) {
    [bodyString appendString:NSLocalizedString(@"SocialMedia_Footer_Short",nil)];
    // SK_ASSERT(bodyString.length < 140);
  } else {
    [bodyString appendString:NSLocalizedString(@"SocialMedia_Footer_Long",nil)];
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

-(BOOL) getIsJitterSupported {
  SK_ASSERT(false);
  return NO;
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

// User interface special behaviours - you can override if you want!
-(UIFont*) getSpecialFontOfSize:(CGFloat)theSize {
  return [UIFont systemFontOfSize:theSize];
}

// Not all variants need to start with a T&C screen!
-(BOOL) showInitialTermsAndConditions {
  return YES;
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

@end
