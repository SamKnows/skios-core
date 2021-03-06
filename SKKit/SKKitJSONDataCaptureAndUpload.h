//
//  SKKitJSONDataCaptureAndUpload.h
//  SKKit
//
//  Copyright (c) 2011-2016 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#ifndef SKKitJSONDataCaptureAndUpload_H
#define SKKitJSONDataCaptureAndUpload_H 1

@protocol SKAutotestManagerDelegate

-(double)         amdLocationGetLatitude;
-(double)         amdLocationGetLongitude;
-(NSTimeInterval) amdLocationGetDateAsTimeIntervalSince1970;

-(SKScheduler*) amdGetSchedule;
-(NSString*)    amdGetClosestTarget;
-(void)         amdSetClosestTarget:(NSString*)inClosestTarget;
-(BOOL)         amdGetIsConnected;
-(NSInteger)    amdGetConnectionStatus;
-(NSString*)    amdGetFileUploadPath:(int)fileSizeBytes;
-(void)         amdDoCreateUploadFile:(int)fileSizeBytes;
-(void)         amdDoUpdateDataUsage:(int)bytes;
-(int64_t)      amdGetDataUsageBytes;

-(SKKitLocationManager*) amdGetSKKitLocationManager;

@end

// Example usage (in Swift format):
/*
  // Start location monitoring...
  let locationManager = SKKitLocationManager()
  locationManager.startLocationMonitoring()

  // Prepare jsonDictionary for saving test results and metrics
  let jsonDictionary = SKKitJSONDataCaptureAndUpload.sCreateJSONDictionary_IsContinuousTest(false)
  let networkLocationMetricArray = NSMutableArray()
 
  // Create and run a test...
  let skLatencyTest = SKKitTestLatency()
  skLatencyTest.start { (final:Bool, progress:Float, latency:Double, loss:Double , jitter:Double ) -> Void in
  }

  // Wait to finish/stop the test...

  // Capture results.
  let testResultsDictionary = skLatencyTest.getTestResultsDictionary()
  let metricsIgnore = SKKitJSONDataCaptureAndUpload.sAppendTestResultsDictionaryToJSONDictionary(
  testResultsDictionary as [NSObject : AnyObject],
  toDictionary: jsonDictionary,
  SKKitLocationManager: locationManager,
  accumulateNetworkTypeLocationMetricsToHere: networkLocationMetricArray)

  // Could append to metrics now, if we wanted.
  // Could run other tests, and capture their data.

  SKKitJSONDataCaptureAndUpload.sWriteJSONDictionaryToFileAndUploadFilesToServer(jsonDictionary, optionalRequestedTestTypes:[]);

  // Stop location monitoring...
  locationManager.stopLocationMonitoring()
*/

@interface SKKitJSONDataCaptureAndUpload : NSObject

//
// Methods that encapsulate JSON Test Data capture, saving to file, and uploading
//

// 1) Create Dictionary that will be saved and uploaded to the server (in JSON format...)
+(NSMutableDictionary*)sCreateJSONDictionary_IsContinuousTest:(BOOL)isContinuousTest;

//
// 2) Append test result into the jsonDictionary.
//    This is called once for every test you want to capture to the test dictionary.
//
+ (void)sAppendTestResultsDictionaryToJSONDictionary:(NSDictionary*)results ToDictionary:(NSMutableDictionary*)jsonDictionary SKKitLocationManager:(SKKitLocationManager*)locationManager AccumulateNetworkTypeLocationMetricsToHere:(NSMutableArray*)accumulatedNetworkTypeLocationMetrics;
//
// 3) Append metric data into the jsonDictionary.
// This is done, typically, after test data has been captured by call(s) to sAppendTestResultsDictionaryToJSONDictionary.
// This function returns a metric array to which you can append additional metric data, if required.
//
+ (NSMutableArray*)sWriteMetricsToJSONDictionary:(NSMutableDictionary*)jsonDictionary TestId:(NSString*)testId SKKitLocationManager:(SKKitLocationManager*)locationManager  AccumulatedNetworkTypeLocationMetrics:(NSArray*)accumulatedNetworkTypeLocationMetrics  WithDateTime:(NSString*)datetime WithTimeStamp:(NSString*)timestamp;

// 4) Write the Dictionary as JSON file, and upload to the server!
//    The method will look at the test data in the jsonDictionary,
//    and automatically configure the requested_tests block, merged
//    with any values found the optional array.
+(void) sWriteJSONDictionaryToFileAndUploadFilesToServer:(NSMutableDictionary*)jsonDictionary OptionalRequestedTestTypes:(NSArray*)optionalRequestedTestTypes;

// 5) This optional method could be called at app start, to push-out any accumulated JSON files
//    that have not yet been sent.
+(void) sDoUploadAllJSONFiles;

// 6) This optional method can be used to purge-out an files that are saved, but not yet uploaded.
+(void) sDeleteAllSavedJSONFiles;

+(NSString*)sGetJsonArchiveDirectory;
+(BOOL) sExportArchivedJSONFilesToZip:(int*)RpFiles;
+(void) sDeleteAllArchivedJSONFiles;
+(NSString*) sGetJSONArchiveZipFilePath;

@end // SKKitJSONDataCaptureAndUpload

#endif // SKKitJSONDataCaptureAndUpload_H 1