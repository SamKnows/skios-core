//
//  SKCore.h
//

#import <Social/Social.h>

typedef enum { CELLULAR, WIFI, NONE } ConnectionStatus;
typedef enum { DOWNLOAD_DATA, UPLOAD_DATA, LATENCY_DATA, LOSS_DATA, JITTER_DATA } TestDataType;

// SKA:
typedef enum {
  DATERANGE_1w1m3m1y_ONE_WEEK,
  DATERANGE_1w1m3m1y_ONE_MONTH,
  DATERANGE_1w1m3m1y_THREE_MONTHS,
  DATERANGE_1w1m3m1y_SIX_MONTHS,
  DATERANGE_1w1m3m1y_ONE_YEAR,
  DATERANGE_1w1m3m1y_ONE_DAY
} DATERANGE_1w1m3m1y;

//#define CTwoToThePowerOfTwenty 1048576L
#define CBytesInAMegabyte      1000000

#import "./SKDebugAssert.h"
#import "./SKDatabase.h"
#import "./SKGlobalMethods.h"
//#import "./SKPreloadData.h"
#import "./SKIPHelper.h"
#import "./SKUDPDataGram.h"
#import "./UIDevice+SKExtension.h"
#import "./3rdParty/cocoaasyncsocket/AsyncUdpSocket.h"
#import "./3rdParty/cocoaasyncsocket/GCD/GCDAsyncSocket.h"
#import "./3rdParty/cocoaasyncsocket/GCD/GCDAsyncUdpSocket.h"
#import "./TestCore/SKTransferOperation.h"
#import "./TestCore/SKTestConfig.h"
#import "./TestCore/SKTest.h"
#import "./TestCore/SKLatencyOperation.h"
#import "./TestCore/SKClosestTargetTest.h"
#import "./TestCore/SKHttpTest.h"
#import "./TestCore/SKLatencyTest.h"
#import "./TestCore/SKScheduler.h"
#import "./TestCore/SKTestConfig.h"
#import "./TestCore/SKAutotest.h"
#import "./3rdParty/KeychainItemWrapper/KeychainItemWrapper.h"
#import "./3rdParty/NSData+Base64.h"
#import "./3rdParty/NSDate+Helper.h"
#import "./3rdParty/NSDictionary+AFNetworkAdditions.h"
#import "./3rdParty/NSURLRequest+AFNetworkAdditions.h"
#import "./3rdParty/fmdb/src/FMDatabase.h"
#import "./3rdParty/KeychainItemWrapper/KeychainItemWrapper.h"
#import "./3rdParty/Reachability/Reachability.h"
#import "./3rdParty/UIDeviceHardware/UIDeviceHardware.h"
#import "./3rdParty/xmldocument/SMXMLDocument.h"
#import "./3rdParty/ZipArchive/ZipArchive.h"
#import "../core-plot-build/CorePlotHeaders/CorePlot-CocoaTouch.h"
#import "./SKGraphForResults.h"
#import "./SKNSURLAsyncQuery.h"
#import "./SKOperators.h"

#import "./UICore/SKAAppDelegate.h"
#import "./UICore/UIAlertView+SKExtensions.h"
#import "./UICore/UIViewController+SKSafeSegue.h"
#import "./UICore/NSString+SKExtensions.h"

#import "./UICore2/Reusable/SKAppColourScheme/SKAppColourScheme.h"
#import "./UICore2/ViewManagers/SKBTestResultValue.h"

FOUNDATION_EXPORT NSString *const Prefs_Username;
FOUNDATION_EXPORT NSString *const Prefs_UserId;
FOUNDATION_EXPORT NSString *const Prefs_UnitId;
FOUNDATION_EXPORT NSString *const Prefs_ViewableUnitId;

@interface SKCore : NSObject

+(NSDate*) getToday;
+(void) forceTodayTo:(NSDate*)inDate;

+(void) sAppendLogString:(NSString*)debugString IsError:(BOOL)isError;
+ (NSString*) sGetDebugLogString;

// This should be called, always, when the app first starts-up!
+(SKCore*) getInstance;

typedef enum C_FILTER_NETWORKTYPE_T {
  C_FILTER_NETWORKTYPE_WIFI = 0,
  C_FILTER_NETWORKTYPE_GSM  = 1,
  C_FILTER_NETWORKTYPE_ALL  = 2
} C_FILTER_NETWORKTYPE;

typedef enum C_FILTER_PERIOD_T {
  C_FILTER_PERIOD_1DAY    = 0,
  C_FILTER_PERIOD_1WEEK   = 1,
  C_FILTER_PERIOD_1MONTH  = 2,
  C_FILTER_PERIOD_3MONTHS = 3,
  C_FILTER_PERIOD_1YEAR   = 4
} C_FILTER_PERIOD;

@end

NSString*sSKCoreGetLocalisedString(NSString*theString);