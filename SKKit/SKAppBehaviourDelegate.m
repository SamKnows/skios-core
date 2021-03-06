//
//  SKAppBehaviourDelegate.m
//  SKA
//
//  Copyright (c) 2011-2015 SamKnows Limited. All rights reserved.
//

#import "SKAppBehaviourDelegate.h"

#import "SKATermsAndConditionsController.h"
#import "SKAMainResultsController.h"
#import "SKAActivationController.h"

// Make this BIG ENOUGH!
//                  10485760
//#define FILE_SIZE 52430000

//FOUNDATION_EXPORT NSString *const Upload_Url;
//FOUNDATION_EXPORT NSString *const Schedule_Xml;
//
//FOUNDATION_EXPORT NSString *const Config_Url;
//
//FOUNDATION_EXPORT NSString *const [SKAppBehaviourDelegate sGet_Prefs_DataUsage];
//FOUNDATION_EXPORT NSString *const Prefs_ClosestTarget;
//FOUNDATION_EXPORT NSString *const [SKAppBehaviourDelegate sGet_Prefs_TargetServer];
//
//FOUNDATION_EXPORT NSString *const Prefs_Activated;
//FOUNDATION_EXPORT NSString *const Prefs_DataCapEnabled;
//FOUNDATION_EXPORT NSString *const [SKAppBehaviourDelegate sGet_Prefs_DataCapLimitBytes];
//FOUNDATION_EXPORT NSString *const [SKAppBehaviourDelegate sGet_Prefs_DataDate];
//FOUNDATION_EXPORT NSString *const [SKAppBehaviourDelegate sGet_Prefs_DateRange];
//FOUNDATION_EXPORT NSString *const [SKAppBehaviourDelegate sGet_Prefs_LastLocation];

NSString *const Schedule_Xml = @"SCHEDULE.xml";

//NSString *const cPrefs_Agreed = @"PREFS_AGREED_V2";
NSString *const cPrefs_Activated = @"PREFS_ACTIVATED_V2";
NSString *const cPrefs_TargetServer = @"PREFS_TARGET_SERVER";

NSString *const cPrefs_DataDate = @"PREFS_DATA_DATE";
NSString *const cPrefs_DataCapEnabled = @"PREFS_DATA_CAP_ENABLED";
NSString *const cPrefs_DataCapValueBytes = @"PREFS_ALLOWANCE";

NSString *const cPrefs_DataUsage = @"DATA_USAGE";
NSString *const cPrefs_ClosestTarget = @"CLOSEST_TARGET";
NSString *const cPrefs_DateRange = @"DATE_RANGE";
NSString *const cPrefs_LastLocation = @"LAST_LOCATION";
NSString *const cPrefs_LastTestSelection = @"LAST_TESTSELECTION";


@implementation SKKitLocationManager

// Location...
@synthesize locationManager;
@synthesize locationLatitude;
@synthesize locationLongitude;
@synthesize locationDateAsTimeIntervalSince1970;
@synthesize hasLocation;

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
      [locationManager setDelegate:nil];
      [locationManager stopUpdatingLocation];
      locationManager = nil;
    }
  }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  //SK_ASSERT(false);
  
  self.hasLocation = NO;
 
#if DEBUG
  NSLog(@"DEBUG: %s %d %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:@"Location Manager Fail %@", [error localizedDescription]]);
#endif // DEBUG
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
    loc[@"LATITUDE"] = @(self.locationLatitude);
    loc[@"LONGITUDE"] = @(self.locationLongitude);
    loc[@"LOCATIONDATE"] = @(self.locationDateAsTimeIntervalSince1970);
    [prefs setObject:loc forKey:[SKAppBehaviourDelegate sGet_Prefs_LastLocation]];
    [prefs synchronize];
  }
}

//
// Location monitoring (end)
//
@end // SKKitLocationManager

@interface SKAppBehaviourDelegate ()

@property BOOL isConnected;

- (void)initSettings;
- (void)setupReachability;
- (void)populateSchedule;

- (void)setDeviceInformation;
- (void)setCarrierInformation;

- (void)reachabilityChanged:(NSNotification*)note;

@end

@implementation SKAppBehaviourDelegate


@synthesize schedule;
@synthesize connectionStatus;
@synthesize dataCapExceeded;

@synthesize deviceModel;
@synthesize devicePlatform;
@synthesize carrierName;
@synthesize countryCode;
@synthesize networkCode;
@synthesize isoCode;
@synthesize mLocationManager;

static SKAppBehaviourDelegate* spAppBehaviourDelegate = nil;

//@synthesize mpAppBehaviourDelegate;

// This can be called at any time...
+(SKAppBehaviourDelegate*) sGetAppBehaviourDelegate {
  // Can be null if a test!
  //SK_ASSERT(spAppBehaviourDelegate != nil);
  return spAppBehaviourDelegate;
}

// This can be called at any time...
+(SKAppBehaviourDelegate*) sGetAppBehaviourDelegateCanBeNil {
  return spAppBehaviourDelegate;
}

- (instancetype)init
{
  self = [super init];
  
  if (self) {
    SK_ASSERT(spAppBehaviourDelegate == nil);
    spAppBehaviourDelegate = self;
    
    mLocationManager = [[SKKitLocationManager alloc] init];
    
    // Initialise SKCore!
#ifdef DEBUG
    SKCore *libCore =
#endif // DEBUG
    [SKCore getInstance];
#ifdef DEBUG
    SK_ASSERT(libCore != nil);
#endif // DEBUG
    
    [SKGlobalMethods setLongDateFormat:@"dd-MM-yyyy HH:mm"];
    [SKGlobalMethods setShortDateFormat:@"dd/MM/yy"];
    [SKGlobalMethods setGraphDateFormat:@"d/MM"];
    
    // Start by DISABLING all internet NSURLRequest caching!
    // http://twobitlabs.com/2012/01/ios-ipad-iphone-nsurlcache-uiwebview-memory-utilization/
    // otherwise, we can run out of file handles due to too many cached responses!
    //  [NSURLCache setSharedURLCache:[[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:@"nsurlcache"]];
    
    // FIRST - remove an old file in Library/UPLOAD.dat, that we don't want backed-up to the Cloud!
    // It is large; and if it remains there, it might lead to the application getting rejected by
    // Apple's reviewers.
    // http://stackoverflow.com/questions/15446457/which-technique-will-be-better-to-store-ios-app-data-and-run-app-in-offline-mode
    NSString *oldUploadFilePath = [SKAppBehaviourDelegate getUploadFilePathDeprecated];
    if ([[NSFileManager defaultManager] fileExistsAtPath:oldUploadFilePath])
    {
      NSError *theError;
#ifdef DEBUG
      BOOL bRes =
#endif // DEBUG
      [[NSFileManager defaultManager] removeItemAtPath:oldUploadFilePath error:&theError];
#ifdef DEBUG
      SK_ASSERT(bRes);
      if (bRes == NO) {
        [SKDebugSupport SK_ASSERT_NONSERROR_INTERNAL:theError File:__FILE__ Line:__LINE__];
      }
#endif // DEBUG
    }
    
    [self initSettings];
    [self setupReachability];
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
    
   
    // Upload any accumulated JSON Files, that have not yet been pushed for some reason.
    [SKKitJSONDataCaptureAndUpload sDoUploadAllJSONFiles];
    
    if (![self hasAgreed]) {
    } else if (![self isActivated]) {
    } else {
      SK_ASSERT([self hasAgreed] && [self isActivated]);
    }
   
    if ([self isActivationSupported] == NO) {
      [self populateSchedule];
    } else if ([self hasAgreed] && [self isActivated])
    {
      [self populateSchedule];
    }
  }
  return self;
}

+(NSString*)sGet_Prefs_DataCapLimitBytes {
  return cPrefs_DataCapValueBytes;
}

+(NSString*)sGet_Prefs_LastTestSelection {
  return cPrefs_LastTestSelection;
}
+(NSString*)sGet_Prefs_DateRange {
  return cPrefs_DateRange;
}
+(NSString*)sGet_Prefs_DataUsage {
  return cPrefs_DataUsage;
}
+(NSString*)sGet_Prefs_DataDate {
  return cPrefs_DataDate;
}
+(NSString*)sGet_Prefs_LastLocation {
  return cPrefs_LastLocation;
}
+(NSString*)sGet_Prefs_TargetServer {
  return cPrefs_TargetServer;
}
+(NSString*)sGetUpload_Url {
  return @"/mobile/submitjson";
}
+(NSString*)sGetConfig_Url {
  return @"/mobile/getconfig";
}

-(NSString*)getBaseUrlForUpload {
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  if (![prefs stringForKey:cPrefs_TargetServer]){
    SK_ASSERT(false);
    return @"";
  }
  
  // Prepare the URL
  NSString *baseServer = [prefs stringForKey:cPrefs_TargetServer];
  return baseServer;
}

+ (NSString*)logFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = paths[0];
    return [libraryPath stringByAppendingPathComponent:@"LOG.txt"];
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
  
  if (![prefs objectForKey:cPrefs_DataCapEnabled])
  {
    [prefs setObject:@YES forKey:cPrefs_DataCapEnabled];
  }
  
  [SKAppBehaviourDelegate sRegisterDataCapDefaultBytes:[NSNumber numberWithLong:(100L * CBytesInAMegabyte)]];
 
  NSString *cPrefs_Agreed = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getPrefsAgreedPropertyName];
  if (![prefs objectForKey:cPrefs_Agreed])
  {
    BOOL defaultValue = NO;
    SKAppBehaviourDelegate *appDelegate = [SKAppBehaviourDelegate sGetAppBehaviourDelegate];
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
    [prefs setObject:@(defaultValue) forKey:cPrefs_Agreed];
  }
  
  if (![prefs objectForKey:cPrefs_Activated])
  {
    [prefs setObject:@NO forKey:cPrefs_Activated];
  }
  
  if (![prefs objectForKey:cPrefs_DateRange])
  {
    [prefs setObject:@(DATERANGE_1w1m3m1y_ONE_WEEK) forKey:cPrefs_DateRange];
  }
  
//  if (![prefs objectForKey:[SKAppBehaviourDelegate sGet_Prefs_LastLocation]])
//  {
//    NSMutableDictionary *loc = [NSMutableDictionary dictionary];
//    [loc setObject:[NSNumber numberWithDouble:0] forKey:@"LATITUDE"];
//    [loc setObject:[NSNumber numberWithDouble:0] forKey:@"LONGITUDE"];
//
//    [prefs setObject:loc forKey:[SKAppBehaviourDelegate sGet_Prefs_LastLocation]];
//  }


  [prefs synchronize];
}

#pragma mark - Data Usage Method

-(NSDate*) generateDataCapPeriodStartDate:(NSDate*)baseOnOptionalLastDate {
  
  if (baseOnOptionalLastDate == nil) {
    NSDate *date = [NSDate date];
    return date;
  }
  
  NSDate *dateNow = [SKCore getToday];
  return dateNow;
}

- (void)resetDataCapStartDate:(NSDate*)baseOnStartDate {
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSDate *newDatcapStartDate = [self generateDataCapPeriodStartDate:baseOnStartDate];
  [prefs setValue:newDatcapStartDate forKey:[SKAppBehaviourDelegate sGet_Prefs_DataDate]];
  [prefs setValue:@0 forKey:[SKAppBehaviourDelegate sGet_Prefs_DataUsage]];
  [prefs synchronize];
}

-(void) resetDataUsageToZero {
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  [prefs setObject:@(0) forKey:[SKAppBehaviourDelegate sGet_Prefs_DataUsage]];
  [prefs synchronize];
}

- (void)checkDataUsageReset
{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSDate *date = [prefs objectForKey:[SKAppBehaviourDelegate sGet_Prefs_DataDate]];
  if (date == nil) {
    date = [self generateDataCapPeriodStartDate:nil];
    [prefs setValue:date forKey:[SKAppBehaviourDelegate sGet_Prefs_DataDate]];
    [prefs synchronize];
  }
  
  NSDate *dateNow = [SKCore getToday];
  NSTimeInterval interval = [dateNow timeIntervalSinceDate:date];
  NSTimeInterval oneMonth = 30 * 24 * 60 * 60; // 2592000 seconds in 30 days
  if (interval > oneMonth)
  {
    // reset the data usage
    [self resetDataCapStartDate:dateNow];
  }
}

- (void)amdDoUpdateDataUsage:(int)bytes
{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  if (nil == [prefs stringForKey:[SKAppBehaviourDelegate sGet_Prefs_DataUsage]])
  {
    [prefs setObject:@(bytes) forKey:[SKAppBehaviourDelegate sGet_Prefs_DataUsage]];
    [prefs synchronize];
  }
  else
  {
    if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getShouldRecordUsageEvenIfOnWiFi]) {
      // Some custom apps require us to record usage, even if on WiFi!
    } else {
      if ([SKAppBehaviourDelegate getIsUsingWiFi]) {
        // Don't add if on WiFi!
        return;
      }
    }
    
    NSNumber *num = [prefs objectForKey:[SKAppBehaviourDelegate sGet_Prefs_DataUsage]];
    
    long currentBytes = [num longValue];
    
    long totalBytes = currentBytes + bytes;
    //NSLog(@"totalBytes : %d", totalBytes);

    [prefs setObject:@(totalBytes) forKey:[SKAppBehaviourDelegate sGet_Prefs_DataUsage]];
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

-(NSDate*) getDataCapDate {
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSDate *date = [prefs objectForKey:[SKAppBehaviourDelegate sGet_Prefs_DataDate]];
  // This might be nil!
  return date;
}

+(void) sRegisterDataCapDefaultBytes:(NSNumber*)bytes {
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  [prefs registerDefaults:@{
    [SKAppBehaviourDelegate sGet_Prefs_DataUsage]:@0,
    [SKAppBehaviourDelegate sGet_Prefs_DataCapLimitBytes]:bytes}
   ];
  
  [prefs synchronize];
}

+(NSNumber*) sGetDataCapDefaultBytes {
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  if (prefs == nil) {
    SK_ASSERT(false);
    return [NSNumber numberWithInteger:0];
  }
  
  int64_t dataAllowed = [[prefs objectForKey:[SKAppBehaviourDelegate sGet_Prefs_DataCapLimitBytes]] longLongValue];
  return [NSNumber numberWithLong:(long)dataAllowed];
}

- (NSNumber*)getDataLimitBytes {
  return [SKAppBehaviourDelegate sGetDataCapDefaultBytes];
}

-(void)setDataLimitBytes:(NSNumber*)valueBytes {
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  if (prefs == nil) {
    SK_ASSERT(false);
    return;
  }
  
  [prefs setValue:valueBytes forKey:[SKAppBehaviourDelegate sGet_Prefs_DataCapLimitBytes]];
  [prefs synchronize];
}

#pragma mark - Log File Methods
- (NSString*)getNetworkType:(int)date networkType:(NSString*)inNetworkType {
  return [self.class getNetworkType:date networkType:inNetworkType ForConnectionStatus:(ConnectionStatus)self.connectionStatus];
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
  
  if (nil == [prefs stringForKey:[SKAppBehaviourDelegate sGet_Prefs_DataUsage]])
  {
    return 0;
  }
  else
  {
    NSNumber *num = [prefs objectForKey:[SKAppBehaviourDelegate sGet_Prefs_DataUsage]];
    
    int64_t currentBytes = [num longLongValue];
    
    return currentBytes;
  }
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

- (void)populateSchedule
{
  if ([[NSFileManager defaultManager] fileExistsAtPath:[self schedulePath]])
  {
    NSData *data = [NSData dataWithContentsOfFile:[self schedulePath]];
    
    if (data != nil)
    {
      SKScheduler *sch = [[SKScheduler alloc] initWithXmlData:data];
      
      if (nil != sch)
      {
        self.schedule = sch;
      }
    } else {
      // If activation is NOT required, then this is NOT valid!
      SK_ASSERT([self isActivationSupported] == NO);
    }
  } else {
    // If activation is NOT required, then this is NOT valid!
    SK_ASSERT([self isActivationSupported] == NO);
  }
}

+ (void)setHasAgreed:(BOOL)value
{
  NSString *cPrefs_Agreed = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getPrefsAgreedPropertyName];
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  [prefs setObject:[SKCore getToday] forKey:[SKAppBehaviourDelegate sGet_Prefs_DataDate]];
  [prefs setObject:@(value) forKey:cPrefs_Agreed];
  [prefs synchronize];
}

- (BOOL)hasAgreed
{
  if ([self showInitialTermsAndConditions] == NO) {
    // For such apps, always act as though the user has agreed to T&C...
    return YES;
  }
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  NSString *cPrefs_Agreed = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getPrefsAgreedPropertyName];
  
  if ([prefs objectForKey:cPrefs_Agreed])
  {
    NSNumber *num = [prefs objectForKey:cPrefs_Agreed];
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
  
  NSString *cPrefs_Agreed = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getPrefsAgreedPropertyName];
  if ([prefs objectForKey:cPrefs_Agreed])
  {
    NSNumber *num = [prefs objectForKey:cPrefs_Agreed];
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
  [prefs setObject:@(value) forKey:cPrefs_Activated];
    [prefs synchronize];
}

+ (BOOL)getIsActivated
{
  SKAppBehaviourDelegate *appDelegate = [SKAppBehaviourDelegate sGetAppBehaviourDelegate];
  return [appDelegate isActivated];
}

// By default, all app variants support activation.
// Newer apps don't require this...
- (BOOL)isActivationSupported {
  return YES;
}

- (BOOL)isActivated
{
  return YES;
}

-(BOOL) getIsConnected {
  Reachability *reachability = [Reachability newReachabilityForInternetConnection];
  
  [self updateReachabilityStatus:reachability];
  
  return self.isConnected;
}

#pragma mark - Upload File Creation

//The file is deleted only when the size is different than requested
-(void)         amdDoCreateUploadFile:(int)fileSizeBytes  {
  
  @synchronized(self.class) {
    NSString *uploadFilePath = [SKAppBehaviourDelegate getUploadFilePathNeverNil];
    
    int FILE_SIZE = fileSizeBytes;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:uploadFilePath]) {
      NSError *error = nil;
      
      // To save time, do not delete the file at every application launch.
      // Do this only when the existing one is different to that needed.
      if ([[[NSFileManager defaultManager] attributesOfItemAtPath:uploadFilePath error:nil][NSFileSize] longLongValue] != FILE_SIZE)
      {
#ifdef DEBUG
        BOOL bRes =
#endif // DEBUG
        [[NSFileManager defaultManager] removeItemAtPath:uploadFilePath error:&error];
#ifdef DEBUG
        SK_ASSERT(bRes);
#endif // DEBUG
      }
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:uploadFilePath])
    {
      // Perform in background, to prevent hang at app start!
      //NSLog(@"PREPARE!");
      //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      //NSLog(@"START!");
      NSMutableData *bodyData = [[NSMutableData alloc] initWithLength:FILE_SIZE];
      [bodyData writeToFile:uploadFilePath atomically:NO];
      SK_ASSERT([[[NSFileManager defaultManager] attributesOfItemAtPath:uploadFilePath error:nil][NSFileSize] longLongValue] == FILE_SIZE);
      
      //NSLog(@"COMPLETE!");
      
      // Could back to the main thread, if we wanted...
      //      dispatch_sync(dispatch_get_main_queue(), ^{
      //      });
      //    });
    }
  }
}

#pragma mark - Reachability

- (void)updateReachabilityStatus:(NSObject*)inReach
{
  Reachability *curReach = (Reachability*)inReach;
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
  return [SKAppBehaviourDelegate getAverageTestData:range testDataType:testDataType RetCount:NULL];
}

+ (double)getAverageTestData:(DATERANGE_1w1m3m1y)range testDataType:(TestDataType)testDataType RetCount:(int*)retCount {
  NSDate *previousDate = [SKAppBehaviourDelegate getStartDateForThisRange:range];
  NSDate *dateNow = [SKCore getToday];
  
  return [SKDatabase getAverageTestDataJoinToMetrics:previousDate toDate:dateNow testDataType:testDataType WhereNetworkTypeAsStringEquals:[SKAppBehaviourDelegate getNetworkTypeString] RetCount:retCount];
}

+ (void)setClosestTarget:(NSString*)value
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:value forKey:cPrefs_ClosestTarget];
    [prefs synchronize];
}

- (NSString *)schedulePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = paths[0];
    return [cacheDirectory stringByAppendingPathComponent:Schedule_Xml];
}

+ (NSString *)getUploadFilePathDeprecated
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
  NSString *docDirectory = paths[0];
  return [docDirectory stringByAppendingPathComponent:@"UPLOAD.dat"];
}

+ (NSString *)getUploadFilePathNeverNil {
  NSString *uploadFilePath = NSTemporaryDirectory();
  uploadFilePath = [uploadFilePath stringByAppendingPathComponent:@"UPLOAD.dat"];
  return uploadFilePath;
}

+ (NSString *)getUploadFilePath:(int)fileSizeBytes
{
  NSString *uploadFilePath = [self getUploadFilePathNeverNil];
 
  if (![[NSFileManager defaultManager] fileExistsAtPath:uploadFilePath]) {
    SK_ASSERT(false);
    return nil;
  }
 
  if (fileSizeBytes != -1) {
    if([[[NSFileManager defaultManager] attributesOfItemAtPath:uploadFilePath error:nil][NSFileSize] longLongValue] != fileSizeBytes) {
      SK_ASSERT(false);
      return nil;
    }
  }
  
  return uploadFilePath;
  
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *docDirectory = [paths objectAtIndex:0];
//    return [docDirectory stringByAppendingPathComponent:@"UPLOAD.dat"];
}

#pragma mark SKAutotestManagerDelegate

-(double)       amdLocationGetLatitude {
  return self.mLocationManager.locationLatitude;
}
-(double)       amdLocationGetLongitude {
  return self.mLocationManager.locationLongitude;
}
-(NSTimeInterval)       amdLocationGetDateAsTimeIntervalSince1970{
  return self.mLocationManager.locationDateAsTimeIntervalSince1970;
}

-(SKScheduler *)amdGetSchedule {
  return self.schedule;
}
-(NSString *)   amdGetClosestTarget {
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  return (NSString*)[prefs objectForKey:cPrefs_ClosestTarget];
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

-(NSString*)     amdGetFileUploadPath:(int)fileSizeBytes {
  return [self.class getUploadFilePath:fileSizeBytes];
}

#if (defined(TARGET_IPHONE_SIMULATOR) && TARGET_IPHONE_SIMULATOR == 1) &&defined(DEBUG)
static BOOL sbDebugWarningMessageShownYet = NO;
static BOOL sbSimulatorThinksItIsOnMobile = NO;
#endif // (defined(TARGET_IPHONE_SIMULATOR) && TARGET_IPHONE_SIMULATOR == 1) &&defined(DEBUG)

// Used for special debugging behaviours
+(void) sSetSimulatorThinksItIsOnMobile:(BOOL)value {
#if (defined(TARGET_IPHONE_SIMULATOR) && TARGET_IPHONE_SIMULATOR == 1) &&defined(DEBUG)
  NSLog(@"DEBUG: WARNING: sSetSimulatorThinksItIsOnMobile:%d", value);
  sbSimulatorThinksItIsOnMobile = value;
#endif // (defined(TARGET_IPHONE_SIMULATOR) && TARGET_IPHONE_SIMULATOR == 1) &&defined(DEBUG)
}

+(BOOL) getIsUsingWiFi {
#if (defined(TARGET_IPHONE_SIMULATOR) && TARGET_IPHONE_SIMULATOR == 1) && defined(DEBUG)
  if (sbSimulatorThinksItIsOnMobile == YES) {
    if (sbDebugWarningMessageShownYet == NO) {
      sbDebugWarningMessageShownYet = YES;
      NSLog(@"DEBUG: warning - on simulator, in DEBUG mode - pretending to be on 3G... (i.e. pretending we are NOT using WiFi!)");
    }
    return NO;
  }
#endif // (defined(TARGET_IPHONE_SIMULATOR) && TARGET_IPHONE_SIMULATOR == 1) && defined(DEBUG)

  Reachability *reachability = [Reachability newReachabilityForInternetConnection];
  //BOOL bReachableViaWWan =[reachability isReachableViaWWAN];
#ifdef DEBUG
  BOOL bReachableViaWiFi =[reachability isReachableViaWiFi];
#endif // DEBUG
  
  NetworkStatus netStatus = [reachability currentReachabilityStatus];
  BOOL result = (netStatus == kReachableViaWiFi);
  // Do NOT use this variant, as it is CACHED - and won't work (say) on first use.
  //return ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] amdGetConnectionStatus] == WIFI);
#ifdef DEBUG
  SK_ASSERT(result == bReachableViaWiFi);
#endif // DEBUG
  
  return result;
}


//
// Network type filter - querying and setting
//

static NSString *networkTypeSwitchValue = nil;

+(NSString*) getNetworkTypeString {
  return networkTypeSwitchValue;
}

-(BOOL) isNetworkTypeMobile {
  if ([networkTypeSwitchValue isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
    return YES;
  }
  return NO;
}

-(BOOL) isNetworkTypeWiFi {
  if ([networkTypeSwitchValue isEqualToString:C_NETWORKTYPEASSTRING_WIFI]) {
    return YES;
  }
  return NO;
}

-(BOOL) isNetworkTypeAll {
  if ([networkTypeSwitchValue isEqualToString:C_NETWORKTYPEASSTRING_ALL]) {
    return YES;
  }
  return NO;
}

-(void) switchNetworkTypeToWiFi {
  networkTypeSwitchValue = C_NETWORKTYPEASSTRING_WIFI;
  
  SK_ASSERT(![self isNetworkTypeMobile]);
  SK_ASSERT(![self isNetworkTypeAll]);
  SK_ASSERT([self isNetworkTypeWiFi]);
  
  //   [[NSNotificationCenter defaultCenter] postNotificationName:@"SKANetworkResultChange" object:self];
}

-(void) switchNetworkTypeToMobile {
  networkTypeSwitchValue = C_NETWORKTYPEASSTRING_MOBILE;
  
  SK_ASSERT(![self isNetworkTypeWiFi]);
  SK_ASSERT(![self isNetworkTypeAll]);
  SK_ASSERT([self isNetworkTypeMobile]);
  
  //[[NSNotificationCenter defaultCenter] postNotificationName:@"SKANetworkResultChange" object:self];
}

-(void) switchNetworkTypeToAll {
  networkTypeSwitchValue = C_NETWORKTYPEASSTRING_ALL;
  
  SK_ASSERT(![self isNetworkTypeWiFi]);
  SK_ASSERT(![self isNetworkTypeMobile]);
  SK_ASSERT([self isNetworkTypeAll]);
  
  //[[NSNotificationCenter defaultCenter] postNotificationName:@"SKANetworkResultChange" object:self];
}

+(void) Controller_DoShowFacebookOrTwitterEtc_PostAlertToShowImageOrNot:(UIViewController*)fromViewController SocialNetwork:(NSString*)socialNetwork ExportThisString:(NSString*)exportString ShowImage:(BOOL)showImage
{
  SK_ASSERT([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isSocialMediaExportSupported]);
  
  if([SLComposeViewController isAvailableForServiceType:socialNetwork])
  {
    UIImage *exportImage = nil;
    if([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isSocialMediaImageExportSupported]) {
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
      SK_ASSERT((exportImage != nil) == [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isSocialMediaImageExportSupported]);
      if (exportImage != nil) {
        // Use the attached screenshot...
        SK_ASSERT([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isSocialMediaImageExportSupported]);
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
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isSocialMediaImageExportSupported] == NO) {
    // This app configuration doesn't allow for image data to be attached to the social
    // media post.
    [self Controller_DoShowFacebookOrTwitterEtc_PostAlertToShowImageOrNot:fromViewController SocialNetwork:socialNetwork ExportThisString:exportString ShowImage:NO];
    return;
  }
  
  // This app configuration allows for image data to be attached to the social
  // media post. Prompt the user to see if they want to attache a screen grab.
  SK_ASSERT([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isSocialMediaExportSupported]);
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
      [SKAppBehaviourDelegate Controller_DoShowFacebookOrTwitterEtc:GpShowSocialExportOnViewController SocialNetwork:(NSString*)SLServiceTypeTwitter ExportThisString:bodyString];
    } else if ([buttonText isEqualToString:sSKCoreGetLocalisedString(@"SocialMediaOption_SinaWeibo")]) {
      
      NSString *bodyString = GShowThisTextForSocialMediaExport[SLServiceTypeSinaWeibo];
      [SKAppBehaviourDelegate Controller_DoShowFacebookOrTwitterEtc:GpShowSocialExportOnViewController SocialNetwork:(NSString*)SLServiceTypeSinaWeibo ExportThisString:bodyString];
      
    } else if ([buttonText isEqualToString:sSKCoreGetLocalisedString(@"SocialMediaOption_Facebook")]) {
      NSString *bodyString = GShowThisTextForSocialMediaExport[SLServiceTypeFacebook];
      [SKAppBehaviourDelegate Controller_DoShowFacebookOrTwitterEtc:GpShowSocialExportOnViewController SocialNetwork:(NSString*)SLServiceTypeFacebook ExportThisString:bodyString];
      
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
                                                           delegate:[SKAppBehaviourDelegate sGetAppBehaviourDelegate]
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

-(NSString *) getUrlForServerQuery {
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
  // We use AmericanTypewriter in some cases in the OLD app only!
  SK_ASSERT(false);
  return [UIFont systemFontOfSize:theSize];
}

// Not all variants need to start with a T&C screen!
-(BOOL) showInitialTermsAndConditions {
  return YES;
}

-(BOOL) getIsThisTheNewApp {
  return NO;
}

-(BOOL) getCanUserZoomTheTAndCView {
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
  [prefs setObject:@(value) forKey:cPrefs_DataCapEnabled];
  [prefs synchronize];
}

-(BOOL) isDataCapSupported {
  return YES;
}

-(BOOL) getShouldClosestTargetTestBeRunFirst {
  return NO;
}

// Some custom apps require us to record usage, even if on WiFi - the default for this is NO.
// If you want data cap usage to be updated even if on WiFi, then overrride to return YES.
-(BOOL) getShouldRecordUsageEvenIfOnWiFi {
  return NO;
}

-(BOOL) isDataCapEnabled {
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  if ([prefs objectForKey:cPrefs_DataCapEnabled])
  {
    NSNumber *num = [prefs objectForKey:cPrefs_DataCapEnabled];
    if (nil != num)
    {
      return [num boolValue];
    }
  }
  
  return YES;
}

-(BOOL) canViewLocationInSettings {
  return YES;
}

-(BOOL) canViewPhoneInfoInSettings {
  return NO;
}

-(BOOL) canViewNetworkInfoInSettings {
  return NO;
}

-(BOOL) getRevealGraphFromSummary {
  return YES;
}

-(BOOL) getRevealPassiveMetricsOnArchiveResultsPanel {
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
// Device ID querying
- (NSString*)getCurrentlySelectedDeviceId {
  NSString *deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:@"unitID"];
  return deviceId;
}

- (void)setCurrentlySelectedDeviceId:(NSString*)deviceId {
  [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:@"unitID"];
}

-(void) setTopLeftLogoImage:(UIImageView*)uiImage TopRightLogoImage:(UIImageView*)topRightImage {
  return;
}

-(SKBShowMetricsRule) getRevealMetricsOnMainScreen {
  return SKBShowMetricsRule_ShowPassiveMetrics_WhenTestStarts;
}

-(NSArray*)getPassiveMetricsToDisplayWiFiFlag:(BOOL)bIsWiFi
{
  if (bIsWiFi) {
    return @[SKB_TESTVALUERESULT_C_PM_CARRIER_NAME,
             SKB_TESTVALUERESULT_C_PM_CARRIER_COUNTRY,
             SKB_TESTVALUERESULT_C_PM_CARRIER_NETWORK,
             SKB_TESTVALUERESULT_C_PM_ISO_COUNTRY_CODE,
             SKB_TESTVALUERESULT_C_PM_DEVICE,
             SKB_TESTVALUERESULT_C_PM_OS,
             SKB_TESTVALUERESULT_C_PM_TARGET,
             SKB_TESTVALUERESULT_C_PM_PUBLIC_IP,
             SKB_TESTVALUERESULT_C_PM_SUBMISSION_ID];
  } else {
    return @[SKB_TESTVALUERESULT_C_PM_DEVICE,
             SKB_TESTVALUERESULT_C_PM_OS,
             SKB_TESTVALUERESULT_C_PM_TARGET,
             SKB_TESTVALUERESULT_C_PM_PUBLIC_IP,
             SKB_TESTVALUERESULT_C_PM_SUBMISSION_ID];
  }
}

-(BOOL)showNetworkTypeAndTargetAtEndOfHistoryPassiveMetrics {
  return YES;
}

-(void) overrideTabBarColoursOnStart:(UITabBarController*)inTabBarController {
}

-(BOOL) getIsBestTargetDisplaySupported {
  return YES;
}

-(BOOL) getShouldTestResultsBeUploadedToTestSpecificServer {
  return NO;
}

-(BOOL) getShouldDisplayWlanCarrierNameInRunTestScreen {
  return NO;
}

-(NSArray*)getDownloadSixSegmentMaxValues {
  return @[@1.0, @2.0, @5.0, @10.0, @30.0, @100.0];
}

-(NSArray*)getUploadSixSegmentMaxValues {
  return @[@0.5, @1.0, @1.5, @2.0, @5.0, @10.0];
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

-(BOOL) getShowAboutVersionInSettingsLinksToAboutScreen {
  return YES;
}


//
// Splash screen (begin)
//
-(UILabel*) prepareLetterForAnimation:(UIView*)onView inArray:(NSMutableArray*)inArray inText:(NSString*)inText  wordFrame:(CGRect)wordFrame {
  UILabel *theLabel = [[UILabel alloc] initWithFrame:wordFrame];
  theLabel.text = inText;
  theLabel.textColor = [UIColor whiteColor];
  theLabel.textAlignment = NSTextAlignmentCenter;
  theLabel.font = [UIFont systemFontOfSize:scaleWidthHeightTo(83.0)];
  //theLabel.adjustsFontSizeToFitWidth = true
  [onView addSubview:theLabel];
  
  [inArray addObject:theLabel];
  return theLabel;
}

CGFloat getGuiMultiplier() {
  CGFloat width = [UIScreen mainScreen].bounds.size.width;
  CGFloat guiMultiplier = (width / 320.0);
  return guiMultiplier;
}

CGFloat scaleWidthHeightTo(CGFloat value) {
  //return value * Singleton.guiMultiplier
  return value * getGuiMultiplier();
}

-(NSMutableArray *) getSplashLabelArray:(UIView*)onView {
  NSMutableArray *mLetterLabels = [NSMutableArray new];
  
  CGPoint center = CGPointMake(onView.frame.size.width/2, onView.frame.size.height/2);
  
  // Initial positioning and sizing is Critical... to work well on iPhone, iPad variants...
  [self prepareLetterForAnimation:onView inArray:mLetterLabels inText:@"S" wordFrame:CGRectMake(center.x-scaleWidthHeightTo(140),center.y-scaleWidthHeightTo(100),scaleWidthHeightTo(80),scaleWidthHeightTo(80))];
  [self prepareLetterForAnimation:onView inArray:mLetterLabels inText:@"a" wordFrame:CGRectMake(center.x-scaleWidthHeightTo(90),center.y-scaleWidthHeightTo(100),scaleWidthHeightTo(80),scaleWidthHeightTo(80))];
  [self prepareLetterForAnimation:onView inArray:mLetterLabels inText:@"m" wordFrame:CGRectMake(center.x-scaleWidthHeightTo(30),center.y-scaleWidthHeightTo(100),scaleWidthHeightTo(80),scaleWidthHeightTo(80))];
  [self prepareLetterForAnimation:onView inArray:mLetterLabels inText:@"K" wordFrame:CGRectMake(center.x-scaleWidthHeightTo(140),center.y-scaleWidthHeightTo(20),scaleWidthHeightTo(80),scaleWidthHeightTo(80))];
  [self prepareLetterForAnimation:onView inArray:mLetterLabels inText:@"n" wordFrame:CGRectMake(center.x-scaleWidthHeightTo(90),center.y-scaleWidthHeightTo(20),scaleWidthHeightTo(80),scaleWidthHeightTo(80))];
  [self prepareLetterForAnimation:onView inArray:mLetterLabels inText:@"o" wordFrame:CGRectMake(center.x-scaleWidthHeightTo(45),center.y-scaleWidthHeightTo(20),scaleWidthHeightTo(80),scaleWidthHeightTo(80))];
  [self prepareLetterForAnimation:onView inArray:mLetterLabels inText:@"w" wordFrame:CGRectMake(center.x+scaleWidthHeightTo(10),center.y-scaleWidthHeightTo(20),scaleWidthHeightTo(80),scaleWidthHeightTo(80))];
  [self prepareLetterForAnimation:onView inArray:mLetterLabels inText:@"s" wordFrame:CGRectMake(center.x+scaleWidthHeightTo(65),center.y-scaleWidthHeightTo(20),scaleWidthHeightTo(80),scaleWidthHeightTo(80))];
  
  return mLetterLabels;
}

//
// Splash screen (end)
//

-(BOOL) getIsAlternativeResultsPanelLayoutRequired {
  return NO;
}

-(NSString*)getPrefsAgreedPropertyName {
  return @"PREFS_AGREED_V2";
}

// Location!
- (void)startLocationMonitoring {
  [mLocationManager startLocationMonitoring];
}

- (void)stopLocationMonitoring {
  [mLocationManager stopLocationMonitoring];
}

-(SKKitLocationManager*) amdGetSKKitLocationManager {
  return mLocationManager;
}


//
// SKKit test creation...
//
// Return an array of NSString*
//
-(NSArray*) getTestClosestTargetArray {
  SK_ASSERT(false);
  return nil;
}

// Translate IP returned form above method, into the most descriptive name available.
// Will default to returning the supplied string!
-(NSString*) getTargetIPAsDescriptiveName:(NSString*)targetIP {
  return targetIP;
}

-(NSInteger)      getTestDownloadNumberOfThreads {
  SK_ASSERT(false);
  return 4;
}
-(NSTimeInterval) getTestDownloadWarmupSeconds {
  SK_ASSERT(false);
  return 2.0;
}
-(NSTimeInterval) getTestDownloadTransferSeconds {
  SK_ASSERT(false);
  return 8.0;
}
-(NSInteger)      getTestUploadNumberOfThreads {
  SK_ASSERT(false);
  return 4;
}
-(NSTimeInterval) getTestUploadWarmupSeconds {
  SK_ASSERT(false);
  return 2.0;
}
-(NSTimeInterval) getTestUploadTransferSeconds {
  SK_ASSERT(false);
  return 8.0;
}
-(NSTimeInterval) getTestLatencyMaxDurationSeconds {
  SK_ASSERT(false);
  return 5.0;
}
-(NSTimeInterval) getTestLatencyTimeoutSeconds {
  return 2.0;
}

-(BOOL) getShouldCoreJSONFilesBeSavedAndUploaded {
  return YES;
}

// This is overriden in apps using Swift!
-(NSString*) exportDictionaryAsString:(NSDictionary*)dictionary {
  NSError *error = nil;
  NSData *jsonData;
  
  @try {
    jsonData = [NSJSONSerialization
                dataWithJSONObject:dictionary
                options:NSJSONWritingPrettyPrinted
                error:&error
                ];
  } @catch (NSException *e) {
    SK_ASSERT(false);
    //@throw e;
    return @"";
  }
  
  if (error != nil) {
    SK_ASSERT(false);
    return @"";
  }
  
  NSString *jsonStr = @"";
  @try {
    jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  } @catch (NSException *e) {
    SK_ASSERT(false);
    //@throw e;
    return @"";
  }
  return jsonStr;
}

@end

NSString *skGetResourcePathFromBundleUsingClass(Class theClass, NSString *componentPath) {
  NSBundle *bundle = [NSBundle bundleForClass:theClass];
  SK_ASSERT(bundle != nil);
  NSString *resourcePath = [[bundle resourcePath] stringByAppendingPathComponent:componentPath];
  return resourcePath;
}

NSData *skGetFileDataFromBundleWithComponentPath(Class theClass, NSString *componentPath) {
  NSString *foundAtResourcePath = nil;
  NSString *resourcePath1 = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:componentPath];
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:resourcePath1]) {
#if DEBUG
    NSLog(@"DEBUG: bundle data file found in mainBundle");
#endif // DEBUG
    foundAtResourcePath = resourcePath1;
  } else {
    NSString * resourcePath2 = skGetResourcePathFromBundleUsingClass(theClass, componentPath);
      
    if ([fm fileExistsAtPath:resourcePath2] == false) {
#if DEBUG
      //NSLog(@"DEBUG: bundle data file does not exist in either mainBundle or class bundle \(componentPath) - try SKKit");
#endif // DEBUG
      NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.samknows.SKKit"];
      if (bundle != nil) {
        resourcePath2 = [[bundle resourcePath] stringByAppendingPathComponent:componentPath];
        if ([fm fileExistsAtPath:resourcePath2] == false) {
#if DEBUG
          NSLog(@"DEBUG: bundle data file does not exist in either mainBundle or class bundle or SKKit\(componentPath)");
          SK_ASSERT(false);
#endif // DEBUG
        } else {
#if DEBUG
          NSLog(@"DEBUG: bundle data file found in SKKit");
#endif // DEBUG
        }
      } else {
#if DEBUG
        NSLog(@"DEBUG: bundle data file does not exist in SKKit \(componentPath)");
        SK_ASSERT(false);
#endif // DEBUG
        return nil;
      }
    } else {
#if DEBUG
      NSLog(@"DEBUG: bundle data file found in class bundle");
#endif // DEBUG
    }
    foundAtResourcePath = resourcePath2;
  }
    
  NSData *theData = [NSData dataWithContentsOfFile:foundAtResourcePath];
  if (theData == nil) {
#if DEBUG
    NSLog(@"DEBUG: bundle data file failed to load at \(componentPath)");
    SK_ASSERT(false);
#endif // DEBUG
  }
    
  return theData;
}

