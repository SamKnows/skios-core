//
//  SKKitJSONDataCaptureAndUpload.m
//  SKKit
//
//  Copyright (c) 2011-2016 SamKnows Limited. All rights reserved.
//

#import "SKAppBehaviourDelegate.h"

#import "SKJHttpTest.h"

@interface SKKitJSONDataCaptureAndUpload()

// Private methods...
+(NSMutableDictionary *)sCreateNetworkTypeMetric:(SKKitLocationManager*)locationManager;
+(NSMutableDictionary *)sCreateLocationMetric:(SKKitLocationManager*)locationManager;
+(void) sDoSaveJSONStringToNewFile:(NSString*)jsonString;

+(NSString*) sGetJsonDirectory;
+(NSString*) sGetNewJSONFilePath;

@end // SKKitJSONDataCaptureAndUpload

@implementation SKKitJSONDataCaptureAndUpload

+(void) sCreateFolderAtPathIfNotExists:(NSString*)thePath {
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

+ (NSString*)sGetJsonDirectory
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
  NSString *libraryPath = paths[0];
  
  NSString *docPath = [libraryPath stringByAppendingPathComponent:@"JSON"];
  [self sCreateFolderAtPathIfNotExists:docPath];
  
  return docPath;
}


+ (NSString*)sGetNewJSONFilePath
{
  NSString *docPath = [self sGetJsonDirectory];
  
  NSTimeInterval ti = [[SKCore getToday] timeIntervalSince1970];
  NSString *strDate = [NSString stringWithFormat:@"%d", (int)ti];
  
  return [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", strDate]];
}


+(void) sDeleteAllSavedJSONFiles {
  
  NSError *error = nil;
  NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[SKKitJSONDataCaptureAndUpload sGetJsonDirectory] error:&error];
  if (dirFiles == nil) {
    SK_ASSERT(false);
    return;
  }
  
  if (error != nil) {
    SK_ASSERT(false);
    return;
  }
  
  if (dirFiles.count == 0) {
    // Nothing to do!
    return;
  }
  
  for (NSString *theFile in dirFiles) {
    NSURL *url = [NSURL URLWithString:theFile];
    if ([[url pathExtension] isEqualToString:@"json"]) {
      NSString *fullFilePath = [[SKKitJSONDataCaptureAndUpload sGetJsonDirectory] stringByAppendingPathComponent:theFile];
      SK_ASSERT([[NSFileManager defaultManager] fileExistsAtPath:fullFilePath]);
      
      error = nil;
#ifdef DEBUG
      BOOL bRes =
#endif // DEBUG
      [[NSFileManager defaultManager] removeItemAtPath:fullFilePath error:&error];
#ifdef DEBUG
      SK_ASSERT(bRes == YES);
      SK_ASSERT(error == nil);
#endif // DEBUG
    }
  }
}

//===

+ (NSString*)sGetJsonArchiveDirectory
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
  NSString *libraryPath = paths[0];
  
  NSString *docPath = [libraryPath stringByAppendingPathComponent:@"JSONArchive"];
  [self sCreateFolderAtPathIfNotExists:docPath];
  
  return docPath;
}

+ (NSString*)sGetNewJSONArchiveFilePath
{
  NSString *docPath = [self sGetJsonArchiveDirectory];
  
  NSTimeInterval ti = [[SKCore getToday] timeIntervalSince1970];
  NSString *strDate = [NSString stringWithFormat:@"%d", (int)ti];
  
  return [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", strDate]];
}

+ (NSString*)sGetJSONArchiveZipFilePath
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *libraryPath = paths[0];
  NSString *docPath = [libraryPath stringByAppendingPathComponent:@"export.zip"];
  return docPath;
}

+(void) sDeleteAllArchivedJSONFiles {
  
  // Write to zip of JSON files!
  
  NSError *error = nil;
  NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self sGetJsonArchiveDirectory] error:&error];
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
      NSString *fullFilePath = [[self sGetJsonArchiveDirectory] stringByAppendingPathComponent:theFile];
      SK_ASSERT([[NSFileManager defaultManager] fileExistsAtPath:fullFilePath]);
      
      error = nil;
      __unused BOOL bRes = [[NSFileManager defaultManager] removeItemAtPath:fullFilePath error:&error];
      SK_ASSERT(bRes == YES);
      SK_ASSERT(error == nil);
      
      itemCount++;
    }
  }
}

#ifdef DEBUG
static void sAssertTestTypeValid(NSString* testType) {
  // Verify supplied values!
  if ([testType isEqualToString:DOWNSTREAMSINGLE]) {
  } else if ([testType isEqualToString:DOWNSTREAMMULTI]) {
  } else if ([testType isEqualToString:UPSTREAMSINGLE]) {
  } else if ([testType isEqualToString:UPSTREAMMULTI]) {
  } else if ([testType isEqualToString:UDPLATENCY]) {
  } else if ([testType isEqualToString:@"NETFLIX"]) {
  } else if ([testType isEqualToString:@"WWW"]) {
  } else if ([testType isEqualToString:CLOSESTTARGET]) {
  } else {
    SK_ASSERT(false); // Unexpected value!
  }
}
#endif // DEBUG

+(void) sWriteJSONDictionaryToFileAndUploadFilesToServer:(NSMutableDictionary*)jsonDictionary OptionalRequestedTestTypes:(NSArray*)optionalRequestedTestTypes {
  //
  // Save the JSON data, and write for upload to the server!
  //
  
  NSMutableArray *useRequestedTestTypes;
  if (optionalRequestedTestTypes != nil) {
    useRequestedTestTypes = [optionalRequestedTestTypes mutableCopy];
    
    SK_ASSERT(useRequestedTestTypes.count == optionalRequestedTestTypes.count);
    
#ifdef DEBUG
    // Verify supplied values!
    for (NSString *testType in useRequestedTestTypes) {
      sAssertTestTypeValid(testType);
    }
#endif // DEBUG
  } else {
    useRequestedTestTypes = [NSMutableArray new];
  }
  
  NSArray *tests = jsonDictionary[@"tests"];
  if (tests == nil) {
    SK_ASSERT(false);
  } else {
    for (NSDictionary *testDict in tests) {
      NSString *testType = testDict[@"type"];
      if (testType == nil) {
        SK_ASSERT(false);
      } else {
#ifdef DEBUG
       // Verify supplied value!
       sAssertTestTypeValid(testType);
#endif // DEBUG
        
        BOOL bFound = NO;
        for (NSString *checkTestId in useRequestedTestTypes) {
          if ([checkTestId isEqualToString:testType]) {
            // Already in list!
            bFound = YES;
            break;
          }
        }
        
        if (bFound == NO) {
          [useRequestedTestTypes addObject:testType];
        }
      }
    }
  }

  // Append data on the requested tests!
  SK_ASSERT(useRequestedTestTypes.count > 0);
  jsonDictionary[@"requested_tests"] = useRequestedTestTypes;

  NSString *jsonStr = [SKGlobalMethods sExportDictionaryToJSONString:jsonDictionary];
#ifdef DEBUG
  //NSLog(@"DEBUG: doSaveAndUploadJson - jsonStr=...\n%@", jsonStr);
  NSLog(@"DEBUG: doSaveAndUploadJson...");
#endif // DEBUG
  
  [SKKitJSONDataCaptureAndUpload sDoSaveJSONStringToNewFile:jsonStr];
  [SKKitJSONDataCaptureAndUpload sDoUploadAllJSONFiles];
}

+ (void) sDoSaveJSONStringToNewFile:(NSString*)jsonString {
  
  // 1. Write to JSON file for upload
  {
    NSString *path = [SKKitJSONDataCaptureAndUpload sGetNewJSONFilePath];
    NSError *error = nil;
    if ([jsonString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
      
#ifdef DEBUG
      NSLog(@"DEBUG: Wrote JSON Successfully to (%@)", path);
      BOOL bFileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
      SK_ASSERT(bFileExists);
#endif // DEBUG
    }
    else
    {
#ifdef DEBUG
      NSLog(@"Error writing JSON : %@", error.localizedDescription);
      SK_ASSERT(false);
#endif // DEBUG
    }

  }
  
  {
    // 2. Write to JSON file for archive (for subsequent export!)
    // Do this ONLY if supported by the app!
    if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] supportExportMenuItem] == YES)
    {
      NSString *path = [self sGetNewJSONArchiveFilePath];
      NSError *error = nil;
      if ([jsonString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error])
      {
        //NSLog(@"Wrote Archive JSON Successfully");
      }
      else
      {
#ifdef DEBUG
        NSLog(@"Error writing JSON archive : %@", error.localizedDescription);
        SK_ASSERT(false);
#endif // DEBUG
      }
    }
  }
  
//  // 2. Write to JSON file for archive (for subsequent export!)
//  {
//    NSString *path = [SKKitJSONDataCaptureAndUpload sGetNewJSONArchiveFilePath];
//    NSError *error = nil;
//    if ([jsonString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error])
//    {
//      NSLog(@"Wrote Archive JSON Successfully");
//    }
//    else
//    {
//#ifdef DEBUG
//      NSLog(@"Error writing archive JSON : %@", error.localizedDescription);
//      SK_ASSERT(false);
//#endif // DEBUG
//    }
//  }
}

+(void) sDoUploadAllJSONFiles {
  
  NSString *jsonDirectory = [SKKitJSONDataCaptureAndUpload sGetJsonDirectory];
  
  NSError *error = nil;
  NSArray *jsonFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:jsonDirectory error:&error];
  SK_ASSERT(error == nil);
  
  if (jsonFiles == nil) {
    SK_ASSERT(false);
    return;
  }
  
  if (jsonFiles.count == 0) {
    return;
  }
  
  for (NSString *fileName in jsonFiles)
  {
    NSString *pathToFile = [jsonDirectory stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToFile]) // ultra paranoid
    {
      NSURL *fileUrl = [NSURL fileURLWithPath:pathToFile];
      
      NSData *json = nil;
      
      @autoreleasepool {
        json = [NSData dataWithContentsOfURL:fileUrl options:NSUTF8StringEncoding error:NULL];
      }
      
      if (nil == json) {
        break;
      }
      
      if ([json length] == 0) {
        break;
      }
      
#if DEBUG
      NSLog(@"DEBUG: loaded JSON file data from filePath=%@", pathToFile);
      BOOL bFileExists = [[NSFileManager defaultManager] fileExistsAtPath:pathToFile];
      SK_ASSERT(bFileExists);
#endif // DEBUG
      
      [self sPostResultsJsonToServer:json filePath:pathToFile];
    }
  }
}

+ (void)sHandleUploadAsyncResponse:(NSURLResponse*)response data:(NSData *)data filePath:(NSString *)filePath testId:(NSNumber *)testId error:(NSError *)error
{
  SK_ASSERT_NONSERROR(error);

  BOOL bFileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
#ifdef DEBUG
  if (bFileExists == false) {
    NSLog(@"DEBUG: WARNING: JSON file no longer exists at %@", filePath);
  }
#endif // DEBUG
  
  if (error != nil)
  {
#ifdef DEBUG
    NSLog(@"DEBUG: Error uploading JSON file : %@", error.description);
#endif // DEBUG
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
#ifdef DEBUG
      NSLog(@"DEBUG: JSON file upload, httpResponse.statusCode: %d", (int)httpResponse.statusCode);
#endif // DEBUG
      if ( (data != nil) && // Defend against terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'data parameter is nil'
           (httpResponse.statusCode == 200)
         )
      {
        //
        // File upload successfully!
        //
#ifdef DEBUG
        NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"DEBUG: sHandleUploadAsyncResponse - jsonStr=...\n%@", jsonStr);
#endif // DEBUG
        
        NSError *error = nil;
        NSDictionary *theObject = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:NSJSONReadingMutableLeaves
                                                                    error:&error];
#ifdef DEBUG
        NSLog(@"DEBUG: sHandleUploadAsyncResponse - resultDictionaryFromJson=%@", theObject);
#endif // DEBUG
        if (testId != nil && ![testId isEqual:[NSNull null]])
        {
          // Write the data to the database, along with the
          // other passive metrics associated with the test!
          // Notify the app, in case it is interested in showing it.
          NSString *thePublicIp = theObject[@"public_ip"];
          SK_ASSERT(thePublicIp != nil);
          NSString *theSubmissionId = theObject[@"submission_id"];
          SK_ASSERT(theSubmissionId != nil);
          
          // This is an attempt to cater for the following exception:
          // "Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '*** -[__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object from objects[1]'"
          if ((thePublicIp == nil) || ([thePublicIp isEqual:[NSNull null]]))
          {
            SK_ASSERT(false);
            thePublicIp = @"";
          }
          if ((theSubmissionId == nil) || ([theSubmissionId isEqual:[NSNull null]]))
          {
            SK_ASSERT(false);
            theSubmissionId = @"";
          }
          
          // For testing only.
          //theSubmissionId = (NSString*)[NSNull null];
          //thePublicIp = (NSString*)[NSNull null];
          
          [SKDatabase updateMetricForTestId:testId
                               MetricColumn:@"Public_IP"
                                MetricValue:thePublicIp];
          
          [SKDatabase updateMetricForTestId:testId
                               MetricColumn:@"Submission_ID"
                                MetricValue:theSubmissionId];
          
          // Send the notification - it is used ONLY if it matches THE CURRENT TEST ID!
          NSDictionary *theDictionary = @{@"test_id":testId, @"Public_IP": thePublicIp, @"Submission_ID":theSubmissionId};
          
          dispatch_async(dispatch_get_main_queue(), ^{
            // Posting to NSNotificationCenter *must* be done in the main thread!
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SKB_public_ip_and_Submission_ID" object:testId userInfo:theDictionary];
          });
        }
        
        // file upload successfully.. remove the uploaded file ... if it exists!
        if (bFileExists == YES) {
          error = nil;
          if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
          {
#ifdef DEBUG
            NSString *reason = @"Unknown";
            if (error != nil) {
              reason = error.localizedDescription;
            }
            NSLog(@"DEBUG: WARNING: Uploaded JSON file, but unable to remove JSON file (%@) from the file system (reason=%@)", filePath, reason);
#endif // DEBUG
          }
          else
          {
#ifdef DEBUG
            NSLog(@"DEBUG: Uploaded JSON File, and removed from the file system!");
#endif // DEBUG
          }
        } else {
#ifdef DEBUG
          NSLog(@"DEBUG: Uploaded JSON File; did not remove from the file system as it no longer existed");
#endif // DEBUG
        }
      }
      else
      {
        SK_ASSERT(false);
#ifdef DEBUG
        if (nil != data)
        {
          NSString* newStr = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
          
          NSLog(@"DEBUG: sHandleUploadAsyncResponse Error Response : %@", newStr);
        }
#endif // DEBUG
      }
    }
  }
}

+ (void)sPostResultsJsonToServer:(NSData*)jsonData filePath:(NSString*)filePath {
  
  if (jsonData == nil) {
    // Defend against terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'data parameter is nil'
    SK_ASSERT(false);
    return;
  }
  
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
      if (theDict[@"test_id"]) {
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
    testId = @(test_id.longLongValue);
    NSLog(@"DEBUG: test_id = %@", testId);
  }
  
  NSString *serverUrlForUpload = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getBaseUrlForUpload];
  NSString *fullUploadUrl = [NSString stringWithFormat:@"%@%@", serverUrlForUpload, [SKAppBehaviourDelegate sGetUpload_Url]];
#ifdef DEBUG
  NSLog(@"fullUploadUrl=%@", fullUploadUrl);
#endif // DEBUG
  
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getShouldTestResultsBeUploadedToTestSpecificServer] == YES) {
    // TODO: For SOME systems, we need to determine the server to use FROM THE DATA!
    
    NSString *targetServerUrl = nil;
    NSArray *testArray = theDictionaryToSend[@"tests"];
    for (NSDictionary *theTestDict in testArray) {
      //NSLog(@"DEBUG: description = %@", jsonObject.description);
      if (theTestDict[@"target"]) {
        targetServerUrl = theTestDict[@"target"];
        break;
      }
    }
    
    if (targetServerUrl == nil) {
      SK_ASSERT(false);
    } else {
#ifdef DEBUG
      NSLog(@"targetServerUrl=%@", targetServerUrl);
#endif // DEBUG
      
      NSRange result = [targetServerUrl rangeOfString:@"http:"];
      if (result.location == 0) {
        // Already starts http
      } else {
        // Need to add http:// prefix!
        targetServerUrl = [NSString stringWithFormat:@"http://%@", targetServerUrl];
        result = [targetServerUrl rangeOfString:@"http:"];
        SK_ASSERT (result.location == 0);
        
        // Use this overriding server URL!
        targetServerUrl = [NSString stringWithFormat:@"%@/log/receive_mobile.php", targetServerUrl];
        fullUploadUrl = targetServerUrl;
#ifdef DEBUG
        NSLog(@"overriding fullUploadUrl=%@", fullUploadUrl);
#endif // DEBUG
      }
    }
  }
  
  NSURL *url = [NSURL URLWithString:fullUploadUrl];
  SK_ASSERT(url != nil);
  
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setURL:url];
  [request setHTTPMethod:@"POST"];
  //[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  //[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setTimeoutInterval:60];
  [request setValue:@"false" forHTTPHeaderField:@"X-Encrypted"];
  
  NSString *enterpriseId = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getEnterpriseId];
  SK_ASSERT(enterpriseId != nil);
  [request setValue:enterpriseId forHTTPHeaderField:@"X-Enterprise-ID"];
  [request setHTTPBody:jsonData];
  
#ifdef DEBUG
  //NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  //NSLog(@"DEBUG: sPostResultsJsonToServer - jsonStr=...\n%@", jsonStr);
  NSLog(@"DEBUG: sPostResultsJsonToServer ...");
#endif // DEBUG
  
  NSOperationQueue *idQueue = [[NSOperationQueue alloc] init];
  [idQueue setName:@"com.samknows.uploadqueue"];
  
  [NSURLConnection sendAsynchronousRequest:request queue:idQueue completionHandler:^(NSURLResponse *response,
                                                                                     NSData *data,
                                                                                     NSError *error)
   {
     [self sHandleUploadAsyncResponse:response data:data filePath:filePath testId:testId error:error];
   }];
}


+(NSMutableDictionary*)sCreateJSONDictionary_IsContinuousTest:(BOOL)isContinuousTest {
  NSMutableDictionary *jsonDictionary = [NSMutableDictionary new];
  
  NSString *enterpriseId = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getEnterpriseId];
  jsonDictionary[@"enterprise_id"] = enterpriseId;
  
  jsonDictionary[@"sim_operator_code"] = [SKGlobalMethods getSimOperatorCodeMCCAndMNC];
#ifdef DEBUG
  NSLog(@"DEBUG: sim_operator_code=%@", [SKGlobalMethods getSimOperatorCodeMCCAndMNC]);
#endif // DEBUG
  
  if (isContinuousTest) {
    jsonDictionary[@"submission_type"] = @"continuous_testing";
  } else {
    jsonDictionary[@"submission_type"] = @"manual_test";
  }
  
  NSString *appVersionName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  jsonDictionary[@"app_version_name"] = appVersionName;
#ifdef DEBUG
  NSLog(@"DEBUG: app_version_name=%@", appVersionName);
#endif // DEBUG
  
  NSString *appVersionCode = [appVersionName stringByReplacingOccurrencesOfString:@"." withString:@""];
  jsonDictionary[@"app_version_code"] = appVersionCode;
#ifdef DEBUG
  NSLog(@"DEBUG: app_version_code=%@", appVersionCode);
#endif // DEBUG
  
  jsonDictionary[@"timestamp"] = [SKGlobalMethods getTimeStamp];
  
  jsonDictionary[@"datetime"] = [NSDate sGetDateAsIso8601String:[SKCore getToday]];
  
  NSTimeZone *tz = [NSTimeZone systemTimeZone];
  NSTimeInterval ti = [tz secondsFromGMT];
  
  ti = ti / 3600; // convert to hours
  
  NSString *result = nil;
  
  if ([SKGlobalMethods sIsWholeNumber:ti])
  {
    result = [NSString stringWithFormat:@"%d", (int)ti];
  }
  else
  {
    result = [NSString stringWithFormat:@"%@", [SKGlobalMethods format2DecimalPlaces:ti]];
  }
  
  NSString *prefix = (ti <= 0) ? @"" : @"+";
  NSString *timeZone = [NSString stringWithFormat:@"%@%@", prefix, result];
  
  jsonDictionary[@"timezone"] = timeZone;
  
#ifdef DEBUG
  NSLog(@"DEBUG: jsonDictionary=%@", [jsonDictionary description]);
#endif // DEBUG
  
  return jsonDictionary;
}

//=========
//
// Metric collection into the jsonDictionary!
//

+ (void)sAppendTestResultsDictionaryToJSONDictionary:(NSDictionary*)results ToDictionary:(NSMutableDictionary*)jsonDictionary SKKitLocationManager:(SKKitLocationManager*)locationManager AccumulateNetworkTypeLocationMetricsToHere:(NSMutableArray*)accumulatedNetworkTypeLocationMetrics
{
  // if results is nil, that historically would result in an assertion when adding to tests
  // at the end of the function. This was seen historically, and should be detected at runtime.
  // Note that the code now checks that results is not nil before trying to add it to the
  // tests array.
  SK_ASSERT(results != nil);
  
  NSMutableArray *tests;
  
  if (jsonDictionary[@"tests"] == nil)
  {
    // Create a new, empty array of tests.
    tests = [NSMutableArray array];
  }
  else {
    // Use the already part-populated array of tests.
    tests = jsonDictionary[@"tests"];
  }
  
  // Generate a pair of METRICS to capture "location" and "network_type"...
  
  // These are added to the passive METRICS
  NSMutableDictionary *locationDictionary = [self sCreateLocationMetric:locationManager];
  if (results[@"timestamp"] != nil) {
    locationDictionary[@"timestamp"] = results[@"timestamp"];
  }
  if (results[@"datetime"] != nil) {
    locationDictionary[@"datetime"] = results[@"datetime"];
  }
  
  if (locationDictionary != nil) {
    [accumulatedNetworkTypeLocationMetrics  addObject:locationDictionary];
  }
  
  NSMutableDictionary *networkTypeDictionary = [self sCreateNetworkTypeMetric:locationManager];
  if (results[@"timestamp"] != nil) {
    networkTypeDictionary[@"timestamp"] = results[@"timestamp"];
  }
  if (results[@"datetime"] != nil) {
    networkTypeDictionary[@"datetime"] = results[@"datetime"];
  }
  
  [accumulatedNetworkTypeLocationMetrics  addObject:networkTypeDictionary];
  
  if (results != nil) {
    [tests addObject:results];
  }
  
  jsonDictionary[@"tests"] = tests;
}

+ (NSMutableDictionary *)sCreateNetworkTypeMetric:(SKKitLocationManager*)locationManager
{
  /*
   
   "type":"network_data",
   "active_network_type":api android.net.ConnectivityManager.getActiveNetworkInfo().getTypeName(),
   "active_network_type_code":api android.net.ConnectivityManager.getActiveNetworkInfo().getType(),
   "connected":api android.net.ConnectivityManager.getActiveNetworkInfo().isConnected(),
   "datetime":"Fri Jan 25 15:35:07 GMT 2013",
   "network_operator_code":api android.telephony.TelephonyManager.getNetworkOperator(),
   "network_operator_name":api android.telephony.TelephonyManager.getNetworkOperatorName(),
   "network_type_code":api android.telephony.TelephonyManager.getNetworkType(),
   "network_type":"HSDPA",
   "phone_type_code":api android.telephony.TelephonyManager.getPhoneType(),
   "phone_type":"GSM",
   "roaming":api android.telephony.TelephonyManager.isNetworkRoaming(),
   "sim_operator_code":api android.telephony.TelephonyManager.getSimOperator(),
   "sim_operator_name":api android.telephony.TelephonyManager.getSimOperatorName(),
   "timestamp":"1359128107"
   
   */
  
  // Updates the reachability status...
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsConnected];
  
  NSMutableDictionary *network = [NSMutableDictionary dictionary];
  network[@"type"] = @"network_data";
  network[@"connected"] = @"true";   // must be true, seeing as we completed the test(s)
  network[@"datetime"] = [NSDate sGetDateAsIso8601String:[SKCore getToday]];
  network[@"active_network_type"] = [SKGlobalMethods getConnectionResultString:(ConnectionStatus) [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] amdGetConnectionStatus]];
  network[@"active_network_type_code"] = @"NA";
  
  // Note: the sim_operator_code and network_operator_code values should both be the same,
  // i.e. they should both be the result of a call to getSimOperatorCodeMCCAndMNC...
  NSString *simOperatorCodeMCCAndMNC = [SKGlobalMethods getSimOperatorCodeMCCAndMNC];
  network[@"network_operator_code"] = simOperatorCodeMCCAndMNC;
  network[@"sim_operator_code"] = simOperatorCodeMCCAndMNC;
  
  NSString *carrierName = [SKGlobalMethods getCarrierName];
  //carrierName = @"SamKnows测试移动运营商"; @"SamKnows Test Mobile Operator"
  network[@"network_operator_name"] = carrierName;
  
  network[@"network_type_code"] = @"NA";
  //[network setObject:[SKGlobalMethods getConnectionResultString:[[SKAppBehaviourDelegate sGetAppBehaviourDelegate] amdGetConnectionStatus]]
  network[@"network_type"] = [SKGlobalMethods getNetworkType];
  network[@"phone_type_code"] = [SKGlobalMethods getDevicePlatform];
#ifdef DEBUG
  NSLog(@"DEBUG: sim_operator_code=%@", [SKGlobalMethods getSimOperatorCodeMCCAndMNC]);
#endif // DEBUG
  //[network setObject:[SKGlobalMethods getCarrierName]
  //            forKey:@"sim_operator_name"];
  network[@"sim_operator_name"] = carrierName;
  
  network[@"timestamp"] = [SKGlobalMethods getTimeStamp];
  network[@"phone_type"] = [SKGlobalMethods getDeviceModel];
  network[@"roaming"] = @"NA";
  return network;
}


+ (NSMutableDictionary *)sCreateLocationMetric:(SKKitLocationManager*)locationManager
{
  /*
   
   "type":"location",
   "accuracy":api android.location.Location.getAccuracy(),
   "datetime":"Thu Jan 24 22:40:05 EST 2013",
   "latitude":api android.location.Location.getLatitude(),
   "location_type":gps
   "longitude":api android.location.Location.getLongitude(),
   "timestamp":api android.location.Location.getTime()
   
   */
  
  NSMutableDictionary *location = nil;
  CLAuthorizationStatus appLocationPermission = [CLLocationManager authorizationStatus];
  
  if (kCLAuthorizationStatusAuthorizedWhenInUse ==  appLocationPermission || kCLAuthorizationStatusAuthorizedAlways == appLocationPermission) {
      
      location = [NSMutableDictionary dictionary];
      
      location[@"type"] = @"location";
      location[@"accuracy"] = @"NA";
      location[@"datetime"] = [NSDate sGetDateAsIso8601String:[SKCore getToday]];
      location[@"latitude"] = [NSString localizedStringWithFormat:@"%f", locationManager.locationLatitude];
      location[@"longitude"] = [NSString localizedStringWithFormat:@"%f", locationManager.locationLongitude];
      location[@"location_type"] = [SKGlobalMethods getNetworkOrGps];
      location[@"timestamp"] = [SKGlobalMethods getTimeStampForTimeInteralSince1970:locationManager.locationDateAsTimeIntervalSince1970];
  }
  
  return location;
}

//
// Important notes on metrics:
//
// 1. All test metrics are stored IN THE OUTER BLOCK, in the metrics array,
//    they are *NOT* stored within any sub-block of the test itself.
//
// 2. Any metrics that are associated specifically with a test, must
//    must be such that their datetime/timestamp fields are an exact match with the associated test.
//      "datetime" : "<THE VALUE FROM THE OWNING TEST!>
//      "timestamp" : "<THE VALUE FROM THE OWNING TEST!>
//
// 3. Any *accumulated passive metrics* (such as location data) are NOT time-stamped to match a specific test;
//    they are free to use whatever datetime/timestamp values they wish.
//      "datetime" : "<THE TIME THE PASSIVE METRIC WAS OBTAINED>"
//      "timestamp" : "<THE TIME THE PASSIVE METRIC WAS OBTAINED>"
//

// Returns array of metrics!
+ (NSMutableArray*)sWriteMetricsToJSONDictionary:(NSMutableDictionary*)jsonDictionary TestId:(NSString*)testId SKKitLocationManager:(SKKitLocationManager*)locationManager  AccumulatedNetworkTypeLocationMetrics:(NSArray*)accumulatedNetworkTypeLocationMetrics WithDateTime:(NSString*)datetime WithTimeStamp:(NSString*)timestamp
{
  // Phone info ////////////////////////////////////////////////////////////////////////////////////////////////
  
  /*
   "type":"phone_identity",
   "datetime":"Fri Jan 25 15:35:07 GMT 2013",
   "manufacturer":api android.os.Build.MANUFACTURER,
   "model":api android.os.Build.MODEL,
   "os_type":"android",
   "os_version":api android.os.Build.VERSION.SDK_INT,
   "timestamp":1359128107
   "test_id":"190329108"
   */
  // If no specific timestamp/datetime specified,
  // use those given to us.
  if (datetime == nil) {
    datetime = [NSDate sGetDateAsIso8601String:[SKCore getToday]];
  }
  if (timestamp == nil) {
    timestamp = [SKGlobalMethods getTimeStamp];
  }
  
  NSMutableDictionary *phone = [NSMutableDictionary dictionary];
  
  phone[@"type"] = @"phone_identity";
  phone[@"datetime"] = datetime;
  phone[@"timestamp"] = timestamp;
  // Return the device 'unique id' via the app_id value in the upload data *only* for some app variants.
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getShouldUploadDeviceId]) {
    phone[@"app_id"] = [[UIDevice currentDevice] uniqueDeviceIdentifier];
  }
  phone[@"manufacturer"] = @"Apple";
  phone[@"model"] = [SKGlobalMethods getDeviceModel];
  //NSString *oldSystemName =  [[UIDevice currentDevice] systemName];
  // Override, as iOS 9 reports iOS rather than "iPhone OS" as reported by iOS 8...
  phone[@"os_type"] = @"iPhone OS";
  phone[@"os_version"] = [[UIDevice currentDevice] systemVersion];
  phone[@"test_id"] = testId;
  
  
  // Location ////////////////////////////////////////////////////////////////////////////////////////////////
  
  NSMutableDictionary *location;
  location = [self.class sCreateLocationMetric:locationManager];
  location[@"datetime"] = datetime;
  location[@"timestamp"] = timestamp;
  
  
  // Last Known Location /////////////////////////////////////////////////////////////////////////////////////
  
  NSMutableDictionary *lastLocation = [NSMutableDictionary dictionary];
  CLAuthorizationStatus appLocationPermission = [CLLocationManager authorizationStatus];
  BOOL locationAllowed = kCLAuthorizationStatusAuthorizedWhenInUse ==  appLocationPermission || kCLAuthorizationStatusAuthorizedAlways == appLocationPermission;
  
  if (locationAllowed) {
      NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
      double latitude = 0.0;
      double longitude = 0.0;
      
      NSDictionary *loc = [prefs objectForKey:[SKAppBehaviourDelegate sGet_Prefs_LastLocation]];
      if (loc != nil) {
          latitude = [loc[@"LATITUDE"] doubleValue];
          longitude = [loc[@"LONGITUDE"] doubleValue];
      }
      
      lastLocation[@"type"] = @"last_known_location";
      lastLocation[@"datetime"] = datetime;
      lastLocation[@"timestamp"] = timestamp;
      lastLocation[@"accuracy"] = @"NA";
      lastLocation[@"latitude"] = [NSString localizedStringWithFormat:@"%f", latitude];
      lastLocation[@"longitude"] = [NSString localizedStringWithFormat:@"%f", longitude];
      lastLocation[@"location_type"] = [SKGlobalMethods getNetworkOrGps];
  }
  
  // Network ////////////////////////////////////////////////////////////////////////////////////////////////
  
  NSMutableDictionary *network;
  network = [self sCreateNetworkTypeMetric:locationManager];
  network[@"datetime"] = datetime;
  network[@"timestamp"] = timestamp;
 
  //
  // Note that the "metrics" array might already exist - in which case, we *append* to it!
  //
  NSMutableArray *metrics = [NSMutableArray array];
  
  NSArray *suppliedMetrics = jsonDictionary[@"metrics"];
  if (suppliedMetrics != nil) {
    for (NSDictionary *suppliedMetricItem in suppliedMetrics) {
//      NSMutableDictionary *mutableDictItem = [[NSMutableDictionary alloc] initWithDictionary:suppliedMetricItem];
//      mutableDictItem[@"datetime"] = datetime;
//      mutableDictItem[@"timestamp"] = timestamp;
//      [metrics addObject:mutableDictItem];
      [metrics addObject:suppliedMetricItem];
    }
  }
  
  [metrics addObject:phone];
  [metrics addObject:network];
  
  if (locationAllowed) {
      [metrics addObject:lastLocation];
  }
  
  if (location != nil) {
      [metrics addObject:location];
  }

  // Accumulated location metrics are passive,
  // and therefore do NOT share timestamp values with any specific test.
  for (NSDictionary *accumulatedMetric in accumulatedNetworkTypeLocationMetrics) {
    [metrics  addObject:accumulatedMetric];
  }
  
  
  jsonDictionary[@"metrics"] = metrics;
  
  return metrics;
}

+(BOOL) sExportArchivedJSONFilesToZip:(int*)RpFiles {
  
  // Write to zip of JSON files!
  
  NSString *zipFilePath = [self sGetJSONArchiveZipFilePath];
  
  NSError *error = nil;
  NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self sGetJsonArchiveDirectory] error:&error];
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
      NSString *fullFilePath = [[self sGetJsonArchiveDirectory] stringByAppendingPathComponent:theFile];
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
  NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self sGetJsonArchiveDirectory] error:&error];
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
      NSString *fullFilePath = [[self sGetJsonArchiveDirectory] stringByAppendingPathComponent:theFile];
      SK_ASSERT([[NSFileManager defaultManager] fileExistsAtPath:fullFilePath]);
      
      error = nil;
      __unused BOOL bRes = [[NSFileManager defaultManager] removeItemAtPath:fullFilePath error:&error];
      SK_ASSERT(bRes == YES);
      SK_ASSERT(error == nil);
      
      itemCount++;
    }
  }
}

@end // SKKitJSONDataCaptureAndUpload
