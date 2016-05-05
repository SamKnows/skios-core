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

-(SKKitLocationMonitor*) amdGetSKKitLocationMonitor;

@end

@interface SKKitJSONDataCaptureAndUpload : NSObject
+(NSString*) sGetJsonDirectory;
+(NSString*) sGetJsonArchiveDirectory;
+(NSString*) sGetNewJSONFilePath;
+(NSString*) sGetNewJSONArchiveFilePath;
+(NSString*) sGetJSONArchiveZipFilePath;

// Upload export and delete Archive zip files (deprecated)
+(void) sDeleteAllArchivedJSONFiles;
+(BOOL) sExportArchivedJSONFilesToZip:(int*)RpFiles;

// Upload and save JSON and Archive file data (the files are deleted automatically as they're uploaded)
+(void) sDoSaveJSONStringToNewFile:(NSString*)jsonString;
+(void) sDoUploadAllJSONFiles;

// Create Dictionary that will be saved and uploaded to the server (in JSON format...)
+(NSMutableDictionary*)sCreateJSONDictionary_IsContinuousTest:(BOOL)isContinuousTest;

// Write the Dictionary as JSON file, and upload to the server!
+(void) sWriteTestDataAsJSONAndUploadToServer:(NSMutableDictionary*)jsonDictionary RequestedTests:(NSArray*)requestedTests;

//
// Metric collection into the jsonDictionary!
//
+ (void)sWriteJSON_TestResultsDictionary:(NSDictionary*)results ToDictionary:(NSMutableDictionary*)jsonDictionary SKKitLocationMonitor:(SKKitLocationMonitor*)locationManager AccumulateNetworkTypeLocationMetricsToHere:(NSMutableArray*)accumulatedNetworkTypeLocationMetrics;
+ (NSMutableArray*)sWriteMetricsToJSONDictionary:(NSMutableDictionary*)jsonDictionary TestId:(NSString*)testId SKKitLocationMonitor:(SKKitLocationMonitor*)locationManager  AccumulatedNetworkTypeLocationMetrics:(NSArray*)accumulatedNetworkTypeLocationMetrics;

@end // SKKitJSONDataCaptureAndUpload

#endif // SKKitJSONDataCaptureAndUpload_H 1