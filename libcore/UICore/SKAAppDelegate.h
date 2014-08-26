//
//  SKAAppDelegate.h
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "UIColor+Colours.h"
#import "UIView+SKView.h"

// Make this BIG ENOUGH!
#define FILE_SIZE 52430000

FOUNDATION_EXPORT NSString *const Upload_Url;
FOUNDATION_EXPORT NSString *const Schedule_Xml;

FOUNDATION_EXPORT NSString *const Config_Url;

FOUNDATION_EXPORT NSString *const Prefs_DataUsage;
FOUNDATION_EXPORT NSString *const Prefs_ClosestTarget;
FOUNDATION_EXPORT NSString *const Prefs_TargetServer;

FOUNDATION_EXPORT NSString *const Prefs_Activated;
FOUNDATION_EXPORT NSString *const Prefs_DataCapEnabled;
FOUNDATION_EXPORT NSString *const Prefs_DataCapValueBytes;
FOUNDATION_EXPORT NSString *const Prefs_DataDate;
FOUNDATION_EXPORT NSString *const Prefs_DateRange;
FOUNDATION_EXPORT NSString *const Prefs_LastLocation;
FOUNDATION_EXPORT NSString *const Prefs_LastTestSelection;

@class Reachability;

@interface SKAAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, SKAutotestManagerDelegate, UIActionSheetDelegate>
{
    SKScheduler *schedule;
    CLLocationManager* locationManager;
    
    NSString *closestTarget;
    
    NSInteger connectionStatus;
    BOOL dataCapExceeded;
    
    double latitude;
    double longitude;
    
    BOOL hasLocation;
}

@property (nonatomic, strong) NSString *deviceModel;
@property (nonatomic, strong) NSString *devicePlatform;
@property (nonatomic, strong) NSString *carrierName;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *networkCode;
@property (nonatomic, strong) NSString *isoCode;

@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;
@property (assign, nonatomic) BOOL hasLocation;

@property (strong, nonatomic) SKScheduler *schedule;

@property (assign, nonatomic) NSInteger connectionStatus;
@property (assign, nonatomic) BOOL dataCapExceeded;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

// Array of Device Id strings associated with the logged-in user.
// Might be nil, if nothing received for some reason (e.g. if device off-line)
// TODO - this should be saved/retrieved, for that reason!
@property (strong, nonatomic) NSArray *unitDeviceIds;
-(void) didFinishAppLaunching_NotActivatedYet;
- (NSString*)getCurrentlySelectedDeviceId;
- (void)setCurrentlySelectedDeviceId:(NSString*)deviceId;

- (NSString*)getNetworkType:(int)date networkType:(NSString*)networkType;
- (NSString*)getNetworkState:(int)date;
- (NSString*)getLocationInformation:(int)date;
- (NSString*)getPhoneIdentity:(int)date;
- (NSString*)getSimOperator:(int)date;
-(void)   amdSetClosestTarget:(NSString*)inClosestTarget;


- (BOOL)hasAgreed;
- (BOOL)isActivated;
- (BOOL)getIsConnected;

+ (NSString*)getUploadFilePathNeverNil;
+ (NSString*)getUploadFilePath;
+ (NSString*)schedulePath;

+ (void)setHasAgreed:(BOOL)value;
+ (void)setIsActivated:(BOOL)value;
+ (BOOL)getIsActivated;
+ (void)setClosestTarget:(NSString*)value;

+(UIStoryboard*) getStoryboard;
+(void) resetUserInterfaceBackToRunTestsScreenFromViewController;
+(NSDate*)getStartDateForThisRange:(DATERANGE_1w1m3m1y)range;
+ (double)getAverageTestData:(DATERANGE_1w1m3m1y)range testDataType:(TestDataType)testDataType RetCount:(int*)retCount;
+ (double)getAverageTestData:(DATERANGE_1w1m3m1y)range testDataType:(TestDataType)testDataType;

+(SKAAppDelegate*) getAppDelegate;

//
// Network type filter: querying and setting...
//
+(NSString*) getNetworkTypeString;
-(BOOL) isNetworkTypeMobile;
-(BOOL) isNetworkTypeWiFi;
-(BOOL) isNetworkTypeAll;
-(void) switchNetworkTypeToWiFi;
-(void) switchNetworkTypeToMobile;
-(void) switchNetworkTypeToAll;

+ (void)showActionSheetForSocialMediaExport:(NSDictionary*)exportThisText OnViewController:(UIViewController*)onViewController;

+ (NSString*)sBuildSocialMediaMessageForCarrierName:(NSString*)carrierName SocialNetwork:(NSString *)socialNetwork Upload:(NSString *)upload Download:(NSString *)download ThisDataIsAveraged:(BOOL)thisDataIsAveraged;

- (void)updateReachabilityStatus:(Reachability*)curReach;

// Configuration - must be overriden by child class!
-(NSString *) getEnterpriseId;
-(NSString *) getBaseUrlString;
-(BOOL) getIsJitterSupported;
-(BOOL) alwaysRunAllTests;
-(BOOL) supportContinuousTesting;
-(BOOL) supportOneDayResultView;
-(BOOL) supportExportMenuItem;
-(BOOL) canDisableDataCap;
-(BOOL) enableTestsSelection;
// Datacap - enable/disable
-(void) setIsDataCapEnabled:(BOOL) value;
-(BOOL) isDataCapEnabled;


// User interface special behaviours - you can override if you want!
-(UIFont*) getSpecialFontOfSize:(CGFloat)theSize;

// Not all variants need to start with a T&C screen!
-(BOOL) showInitialTermsAndConditions;

// Return the device 'unique id' via the app_id value in the upload data *only* for some app variants;
// the default is NO.
-(BOOL) getShouldUploadDeviceId;

// By default, throttle query is not supported.
-(BOOL) isThrottleQuerySupported;

// Returns YES if using WiFi...
+(BOOL) getIsUsingWiFi;

-(BOOL) isSocialMediaExportSupported;
-(BOOL) isSocialMediaImageExportSupported;

// Zip file archiving!
+ (NSString*)getJSONArchiveZipFilePath;
+(BOOL) exportArchivedJSONFilesToZip:(int*)RpFiles;
+(void) deleteAllArchivedJSONFiles;

@end
