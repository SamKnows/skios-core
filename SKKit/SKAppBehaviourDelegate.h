//
//  SKAppBehaviourDelegate.h
//  SKA
//
//  Copyright (c) 2011-2015 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#ifndef SKAPPBEHAVIOURDELEGATE_H
#define SKAPPBEHAVIOURDELEGATE_H 1

typedef enum C_FILTER_NETWORKTYPE_T {
  C_FILTER_NETWORKTYPE_WIFI = 0,
  C_FILTER_NETWORKTYPE_MOBILE  = 1,
  C_FILTER_NETWORKTYPE_ALL  = 2
} C_FILTER_NETWORKTYPE;

typedef enum C_FILTER_PERIOD_T {
  C_FILTER_PERIOD_1DAY    = 0,
  C_FILTER_PERIOD_1WEEK   = 1,
  C_FILTER_PERIOD_1MONTH  = 2,
  C_FILTER_PERIOD_3MONTHS = 3,
  C_FILTER_PERIOD_1YEAR   = 4
} C_FILTER_PERIOD;

#define C_NETWORKTYPEASSTRING_WIFI   @"network"
#define C_NETWORKTYPEASSTRING_MOBILE @"mobile"
#define C_NETWORKTYPEASSTRING_ALL    @"all"

//@class Reachability;

typedef enum SKBShowMetricsRule
{
  SKBShowMetricsRule_ShowPassiveMetrics_WhenTestStarts = 0,
  SKBShowMetricsRule_ShowPassiveMetrics_Never = 1,
  SKBShowMetricsRule_ShowPassiveMetrics_WhenTestSubmitted = 2
} SKBShowMetricsRule;

// SKA:
typedef enum {
  DATERANGE_1w1m3m1y_ONE_WEEK,
  DATERANGE_1w1m3m1y_ONE_MONTH,
  DATERANGE_1w1m3m1y_THREE_MONTHS,
  DATERANGE_1w1m3m1y_SIX_MONTHS,
  DATERANGE_1w1m3m1y_ONE_YEAR,
  DATERANGE_1w1m3m1y_ONE_DAY
} DATERANGE_1w1m3m1y;

typedef enum { CELLULAR, WIFI, NONE } ConnectionStatus;
typedef enum { DOWNLOAD_DATA, UPLOAD_DATA, LATENCY_DATA, LOSS_DATA, JITTER_DATA } TestDataType;

@class SKScheduler;

@interface SKKitLocationManager : NSObject<CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager* locationManager;
@property double latitude;
@property double longitude;
@property (assign, nonatomic) double locationLatitude;
@property (assign, nonatomic) double locationLongitude;
@property (assign, nonatomic) NSTimeInterval locationDateAsTimeIntervalSince1970;
@property (assign, nonatomic) BOOL hasLocation;

// Start/stop location monitoring!
// Only a test should invoke these methods.
- (void)startLocationMonitoring;
- (void)stopLocationMonitoring;
@end // SKKitLocationManager

#import "SKKitJSONDataCaptureAndUpload.h"
#import "SKKitTest.h"

@interface SKAppBehaviourDelegate : NSObject<UIActionSheetDelegate, SKAutotestManagerDelegate>

// An instance of one of these MUST be called FROM main()... *before* the app fully starts-up.
// This can be called at any time...
+(SKAppBehaviourDelegate*) sGetAppBehaviourDelegate;

// Used for testing!
+(SKAppBehaviourDelegate*) sGetAppBehaviourDelegateCanBeNil;

@property (nonatomic, retain) NSString *closestTarget;

@property (nonatomic, strong) NSString *deviceModel;
@property (nonatomic, strong) NSString *devicePlatform;
@property (nonatomic, strong) NSString *carrierName;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *networkCode;
@property (nonatomic, strong) NSString *isoCode;

@property (retain, atomic) SKKitLocationManager *mLocationManager;

@property (strong, nonatomic) SKScheduler *schedule;

@property (assign, nonatomic) NSInteger connectionStatus;
@property (assign, nonatomic) BOOL dataCapExceeded;

// Array of Device Id strings associated with the logged-in user.
// Might be nil, if nothing received for some reason (e.g. if device off-line)
// TODO - this should be saved/retrieved, for that reason!
@property (strong, nonatomic) NSArray *unitDeviceIds;
- (NSString*)getCurrentlySelectedDeviceId;
- (void)setCurrentlySelectedDeviceId:(NSString*)deviceId;

- (NSString*)getNetworkType:(int)date networkType:(NSString*)networkType;
- (NSString*)getNetworkState:(int)date;
//- (NSString*)getLocationInformation:(int)date;
- (NSString*)getPhoneIdentity:(int)date;
- (NSString*)getSimOperator:(int)date;
-(void)   amdSetClosestTarget:(NSString*)inClosestTarget;

- (BOOL)hasAgreed;
- (BOOL)hasNewAppAgreed;
- (BOOL)isActivated;
- (BOOL)isActivationSupported;
- (BOOL)getIsConnected;
-(NSString*)getBaseUrlForUpload;

- (NSString*)schedulePath;

+ (void)setHasAgreed:(BOOL)value;
+ (void)setIsActivated:(BOOL)value;
+ (BOOL)getIsActivated;
+ (void)setClosestTarget:(NSString*)value;

+(NSDate*)getStartDateForThisRange:(DATERANGE_1w1m3m1y)range;
+ (double)getAverageTestData:(DATERANGE_1w1m3m1y)range testDataType:(TestDataType)testDataType RetCount:(int*)retCount;
+ (double)getAverageTestData:(DATERANGE_1w1m3m1y)range testDataType:(TestDataType)testDataType;

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

- (void)updateReachabilityStatus:(NSObject*)curReach;

// Configuration - must be overriden by child class!
-(NSString *) getEnterpriseId;
-(NSString *) getUrlForServerQuery;
-(BOOL)       getDoesAppSupportServerBasedUploadSpeedTesting;

-(BOOL) getIsFooterSupported;
-(BOOL) getIsJitterSupported;
-(BOOL) getIsLossSupported;
-(BOOL) alwaysRunAllTests;
-(BOOL) supportContinuousTesting;
-(BOOL) supportOneDayResultView;
-(BOOL) supportExportMenuItem;
-(BOOL) canDisableDataCap;
-(BOOL) canViewLocationInSettings;
-(BOOL) canViewPhoneInfoInSettings;
-(BOOL) canViewNetworkInfoInSettings;
-(BOOL) getRevealGraphFromSummary;
-(BOOL) enableTestsSelection;
// Datacap - enable/disable
-(BOOL) isDataCapSupported;
-(void) setIsDataCapEnabled:(BOOL) value;
-(BOOL) isDataCapEnabled;
-(void) resetDataUsageToZero;
+(NSNumber*) sGetDataCapDefaultBytes;
+(void) sRegisterDataCapDefaultBytes:(NSNumber*)bytes;
-(NSDate*) getDataCapDate;
-(NSNumber*) getDataLimitBytes;
-(void)setDataLimitBytes:(NSNumber*)valueBytes;
-(void) checkDataUsageReset;
-(void)resetDataCapStartDate:(NSDate*)baseOnStartDate;
-(NSDate*) generateDataCapPeriodStartDate:(NSDate*)baseOnOptionalLastDate;


// User interface special behaviours - you can override if you want!
-(UIFont*) getSpecialFontOfSize:(CGFloat)theSize;

// Not all variants need to start with a T&C screen!
-(BOOL) showInitialTermsAndConditions;

// The New app might show T&C at start, but this is handled differently to the way the old app does it.
// Note that for the NewApp, the showInitialTermsAndConditions *must* return NO.
-(BOOL) getIsThisTheNewApp;
-(BOOL) getCanUserZoomTheTAndCView;
-(BOOL) getNewAppShowInitialTermsAndConditions;

// Return the device 'unique id' via the app_id value in the upload data *only* for some app variants;
// the default is NO.
-(BOOL) getShouldUploadDeviceId;

// By default, throttle query is not supported.
-(BOOL) isThrottleQuerySupported;
  
// Returns YES if using WiFi...
+(BOOL) getIsUsingWiFi;

// Used for special debugging behaviours
+(void) sSetSimulatorThinksItIsOnMobile:(BOOL)value;

-(BOOL) isTwitterExportSupported;
-(BOOL) isFacebookExportSupported;
-(BOOL) isSocialMediaExportSupported;
-(BOOL) isSocialMediaImageExportSupported;


//
// Introduced for New app
//
// Optional method!
-(void) setTopLeftLogoImage:(UIImageView*)uiImage TopRightLogoImage:(UIImageView*)topRightImage;
-(SKBShowMetricsRule) getRevealMetricsOnMainScreen;
-(BOOL) getRevealPassiveMetricsOnArchiveResultsPanel;
-(NSArray*)getPassiveMetricsToDisplayWiFiFlag:(BOOL)bIsWiFi;
-(BOOL)showNetworkTypeAndTargetAtEndOfHistoryPassiveMetrics;
-(void) overrideTabBarColoursOnStart:(UITabBarController*)inTabBarController;
-(BOOL) getIsBestTargetDisplaySupported;

-(NSArray*)getDownloadSixSegmentMaxValues;
-(NSArray*)getUploadSixSegmentMaxValues;

// The width of the top left icon, can be customized for different app variants!
-(CGFloat) getNewAppTopLeftIconWidth;

// Use this to override the "new app" behaviour which otherwise would show the about screen.
// Returns nil if the about screen should be shown instead.
-(NSString*) getNewAppUrlForHelpAbout;

-(BOOL) getShowAboutVersionInSettingsLinksToAboutScreen;

// Splash screen (begin)
//-(UIColor*) getSplashBackgroundColour;
-(UILabel*) prepareLetterForAnimation:(UIView*)onView inArray:(NSMutableArray*)inArray inText:(NSString*)inText  wordFrame:(CGRect)wordFrame;
-(NSMutableArray *) getSplashLabelArray:(UIView*)onView;
// Splash screen (end)

+(NSString*)sGet_Prefs_LastTestSelection;
+(NSString*)sGet_Prefs_DateRange;
+(NSString*)sGet_Prefs_DataUsage;
+(NSString*)sGet_Prefs_DataDate;
+(NSString*)sGet_Prefs_DataCapLimitBytes;
+(NSString*)sGet_Prefs_LastLocation;
+(NSString*)sGet_Prefs_TargetServer;
+(NSString*)sGetUpload_Url;
+(NSString*)sGetConfig_Url;
-(BOOL)getShouldTestResultsBeUploadedToTestSpecificServer;

-(BOOL) getIsAlternativeResultsPanelLayoutRequired;
-(NSString*)getPrefsAgreedPropertyName;

-(BOOL) getShouldDisplayWlanCarrierNameInRunTestScreen;

// Location!
- (void)startLocationMonitoring;
- (void)stopLocationMonitoring;

-(BOOL) getShouldClosestTargetTestBeRunFirst;

// Some custom apps require us to record usage, even if on WiFi - the default for this is NO.
// If you want data cap usage to be updated even if on WiFi, then overrride to return YES.
-(BOOL) getShouldRecordUsageEvenIfOnWiFi;

//
// SKKit test creation...
//

// Return an array of NSString*
-(NSArray*) getTestClosestTargetArray;

// Translate IP returned form above method, into the most descriptive name available.
// Will default to returning the supplied string!
-(NSString*) getTargetIPAsDescriptiveName:(NSString*)targetIP;

-(NSInteger)      getTestDownloadNumberOfThreads;
-(NSTimeInterval) getTestDownloadWarmupSeconds;
-(NSTimeInterval) getTestDownloadTransferSeconds;
-(NSInteger)      getTestUploadNumberOfThreads;
-(NSTimeInterval) getTestUploadWarmupSeconds;
-(NSTimeInterval) getTestUploadTransferSeconds;
-(NSTimeInterval) getTestLatencyMaxDurationSeconds;
-(NSTimeInterval) getTestLatencyTimeoutSeconds;

// We require special handling for this to work with Swift objects!
-(NSString*) exportDictionaryAsString:(NSDictionary*)dictionary;

-(BOOL) getShouldCoreJSONFilesBeSavedAndUploaded;
@end


NSString *skGetResourcePathFromBundleUsingClass(Class theClass, NSString *componentPath);
NSData *skGetFileDataFromBundleWithComponentPath(Class theClass, NSString *componentPath);

#endif // SKAPPBEHAVIOURDELEGATE_H
