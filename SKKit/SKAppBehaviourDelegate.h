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

@class Reachability;

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

@protocol SKAutotestManagerDelegate

-(double)       amdGetLatitude;
-(double)       amdGetLongitude;
-(NSTimeInterval)       amdGetDateAsTimeIntervalSince1970;

-(SKScheduler*) amdGetSchedule;
-(NSString*)    amdGetClosestTarget;
-(void)         amdSetClosestTarget:(NSString*)inClosestTarget;
-(BOOL)         amdGetIsConnected;
-(NSInteger)    amdGetConnectionStatus;
-(NSString*)    amdGetFileUploadPath;
-(void)         amdDoUploadJSON;
-(void)         amdDoCreateUploadFile;
-(void)         amdDoUpdateDataUsage:(int)bytes;
-(int64_t)      amdGetDataUsageBytes;
-(void)         amdDoUploadLogFile;
-(void)         amdDoAppendOutputResultsArrayToLogFile:(NSMutableArray*)results networkType:(NSString*)networkType;

@end

@interface SKAppBehaviourDelegate : NSObject<CLLocationManagerDelegate, UIActionSheetDelegate, SKAutotestManagerDelegate>

// An instance of one of these MUST be called FROM main()... *before* the app fully starts-up.
// This can be called at any time...
+(SKAppBehaviourDelegate*) sGetAppBehaviourDelegate;

@property (nonatomic, retain) CLLocationManager* locationManager;
@property (nonatomic, retain) NSString *closestTarget;
@property double latitude;
@property double longitude;

@property (nonatomic, strong) NSString *deviceModel;
@property (nonatomic, strong) NSString *devicePlatform;
@property (nonatomic, strong) NSString *carrierName;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *networkCode;
@property (nonatomic, strong) NSString *isoCode;

@property (assign, nonatomic) double locationLatitude;
@property (assign, nonatomic) double locationLongitude;
@property (assign, nonatomic) NSTimeInterval locationDateAsTimeIntervalSince1970;
@property (assign, nonatomic) BOOL hasLocation;

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
- (NSString*)getLocationInformationForDate:(int)date;
- (NSString*)getPhoneIdentity:(int)date;
- (NSString*)getSimOperator:(int)date;
-(void)   amdSetClosestTarget:(NSString*)inClosestTarget;


- (BOOL)hasAgreed;
- (BOOL)hasNewAppAgreed;
- (BOOL)isActivated;
- (BOOL)getIsConnected;

+ (NSString*)getUploadFilePathNeverNil;
+ (NSString*)getUploadFilePath;
+ (NSString*)schedulePath;

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

- (void)updateReachabilityStatus:(Reachability*)curReach;

// Configuration - must be overriden by child class!
-(NSString *) getEnterpriseId;
-(NSString *) getBaseUrlString;
-(BOOL)       getDoesAppSupportServerBasedUploadSpeedTesting;

-(BOOL) getIsFooterSupported;
-(BOOL) getIsJitterSupported;
-(BOOL) getIsLossSupported;
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

// The New app might show T&C at start, but this is handled differently to the way the old app does it.
// Note that for the NewApp, the showInitialTermsAndConditions *must* return NO.
-(BOOL) getIsThisTheNewApp;
-(BOOL) getNewAppShowInitialTermsAndConditions;
  
// Return the device 'unique id' via the app_id value in the upload data *only* for some app variants;
// the default is NO.
-(BOOL) getShouldUploadDeviceId;

// By default, throttle query is not supported.
-(BOOL) isThrottleQuerySupported;
  
// Returns YES if using WiFi...
+(BOOL) getIsUsingWiFi;

-(BOOL) isTwitterExportSupported;
-(BOOL) isFacebookExportSupported;
-(BOOL) isSocialMediaExportSupported;
-(BOOL) isSocialMediaImageExportSupported;

// Zip file archiving!
+ (NSString*)getJSONArchiveZipFilePath;
+(BOOL) exportArchivedJSONFilesToZip:(int*)RpFiles;
+(void) deleteAllArchivedJSONFiles;

// Start/stop location monitoring!
// Only a test should invoke these methods.
- (void)startLocationMonitoring;
- (void)stopLocationMonitoring;

//
// Introduced for New app
//
// Optional method!
-(void) setLogoImage:(UIImageView*)uiImage;
-(SKBShowMetricsRule) getShowMetricsOnMainScreen;
-(NSArray*)getPassiveMetricsToDisplay;
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

// Splash screen (begin)
//-(UIColor*) getSplashBackgroundColour;
-(UILabel*) prepareLetterForAnimation:(UIView*)onView inArray:(NSMutableArray*)inArray inText:(NSString*)inText  wordFrame:(CGRect)wordFrame;
-(NSMutableArray *) getSplashLabelArray:(UIView*)onView;
// Splash screen (end)

+(NSString*)getNewJSONFilePath;
+(NSString*)getNewJSONArchiveFilePath;

+(NSString*)sGet_Prefs_LastTestSelection;
+(NSString*)sGet_Prefs_DateRange;
+(NSString*)sGet_Prefs_DataUsage;
+(NSString*)sGet_Prefs_DataDate;
+(NSString*)sGet_Prefs_DataCapValueBytes;
+(NSString*)sGet_Prefs_LastLocation;
+(NSString*)sGet_Prefs_TargetServer;
+(NSString*)sGetUpload_Url;
+(NSString*)sGetConfig_Url;

-(BOOL) getIsAlternativeResultsPanelLayoutRequired;
@end


NSString *skGetResourcePathFromBundleUsingClass(Class theClass, NSString *componentPath);
NSData *skGetFileDataFromBundleWithComponentPath(Class theClass, NSString *componentPath);

#endif // SKAPPBEHAVIOURDELEGATE_H