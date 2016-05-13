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
  NSString *libraryPath = [paths objectAtIndex:0];
  
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

#ifdef DEBUG
static void sAssertTestTypeValid(NSString* testType) {
  // Verify supplied values!
  if ([testType isEqualToString:DOWNSTREAMSINGLE]) {
  } else if ([testType isEqualToString:DOWNSTREAMMULTI]) {
  } else if ([testType isEqualToString:UPSTREAMSINGLE]) {
  } else if ([testType isEqualToString:UPSTREAMMULTI]) {
  } else if ([testType isEqualToString:UDPLATENCY]) {
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
  [jsonDictionary setObject:useRequestedTestTypes forKey:@"requested_tests"];

  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];
  
  NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
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
      
      NSData *json = [NSData dataWithContentsOfURL:fileUrl options:NSUTF8StringEncoding error:NULL];
      
      if (nil == json) {
        break;
      }
      
      if ([json length] == 0) {
        break;
      }
      
      [self sPostResultsJsonToServer:json filePath:pathToFile];
    }
  }
}

+ (void)sHandleUploadAsyncResponse:(NSURLResponse*)response data:(NSData *)data filePath:(NSString *)filePath testId:(NSNumber *)testId error:(NSError *)error
{
  SK_ASSERT_NONSERROR(error);
  
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
      if (httpResponse.statusCode == 200)
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
        
        // file upload successfully.. remove the uploaded file
        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL])
        {
#ifdef DEBUG
          NSLog(@"DEBUG: Uploaded JSON file, but unable to remove JSON file from the file system!");
#endif // DEBUG
          SK_ASSERT(false);
        }
        else
        {
#ifdef DEBUG
          NSLog(@"DEBUG: Uploaded JSON File, and removed from the file system!");
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
      if ([theTestDict objectForKey:@"target"]) {
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
  [jsonDictionary setObject:enterpriseId forKey:@"enterprise_id"];
  
  [jsonDictionary setObject:[SKGlobalMethods getSimOperatorCodeMCCAndMNC]
                     forKey:@"sim_operator_code"];
#ifdef DEBUG
  NSLog(@"DEBUG: sim_operator_code=%@", [SKGlobalMethods getSimOperatorCodeMCCAndMNC]);
#endif // DEBUG
  
  if (isContinuousTest) {
    [jsonDictionary setObject:@"continuous_testing" forKey:@"submission_type"];
  } else {
    [jsonDictionary setObject:@"manual_test" forKey:@"submission_type"];
  }
  
  NSString *appVersionName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  [jsonDictionary setObject:appVersionName forKey:@"app_version_name"];
#ifdef DEBUG
  NSLog(@"DEBUG: app_version_name=%@", appVersionName);
#endif // DEBUG
  
  NSString *appVersionCode = [appVersionName stringByReplacingOccurrencesOfString:@"." withString:@""];
  [jsonDictionary setObject:appVersionCode forKey:@"app_version_code"];
#ifdef DEBUG
  NSLog(@"DEBUG: app_version_code=%@", appVersionCode);
#endif // DEBUG
  
  [jsonDictionary setObject:[SKGlobalMethods getTimeStamp]
                     forKey:@"timestamp"];
  
  [jsonDictionary setObject:[NSDate sGetDateAsIso8601String:[SKCore getToday]] forKey:@"datetime"];
  
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
  
  [jsonDictionary setObject:timeZone forKey:@"timezone"];
  
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
  
  if ([jsonDictionary objectForKey:@"tests"] == nil)
  {
    // Create a new, empty array of tests.
    tests = [NSMutableArray array];
  }
  else {
    // Use the already part-populated array of tests.
    tests = [jsonDictionary objectForKey:@"tests"];
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
  
  [accumulatedNetworkTypeLocationMetrics  addObject:locationDictionary];
  
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
  
  [jsonDictionary setObject:tests forKey:@"tests"];
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
  [network setObject:@"network_data"
              forKey:@"type"];
  [network setObject:@"true"
              forKey:@"connected"];   // must be true, seeing as we completed the test(s)
  [network setObject:[NSDate sGetDateAsIso8601String:[SKCore getToday]] forKey:@"datetime"];
  [network setObject:[SKGlobalMethods getConnectionResultString:(ConnectionStatus)[[SKAppBehaviourDelegate sGetAppBehaviourDelegate] amdGetConnectionStatus]]
              forKey:@"active_network_type"];
  [network setObject:@"NA"
              forKey:@"active_network_type_code"];
  
  // Note: the sim_operator_code and network_operator_code values should both be the same,
  // i.e. they should both be the result of a call to getSimOperatorCodeMCCAndMNC...
  NSString *simOperatorCodeMCCAndMNC = [SKGlobalMethods getSimOperatorCodeMCCAndMNC];
  [network setObject:simOperatorCodeMCCAndMNC
              forKey:@"network_operator_code"];
  [network setObject:simOperatorCodeMCCAndMNC
              forKey:@"sim_operator_code"];
  
  NSString *carrierName = [SKGlobalMethods getCarrierName];
  //carrierName = @"SamKnows测试移动运营商"; @"SamKnows Test Mobile Operator"
  [network setObject:carrierName forKey:@"network_operator_name"];
  
  [network setObject:@"NA"
              forKey:@"network_type_code"];
  //[network setObject:[SKGlobalMethods getConnectionResultString:[[SKAppBehaviourDelegate sGetAppBehaviourDelegate] amdGetConnectionStatus]]
  [network setObject:[SKGlobalMethods getNetworkType]
              forKey:@"network_type"];
  [network setObject:[SKGlobalMethods getDevicePlatform]
              forKey:@"phone_type_code"];
#ifdef DEBUG
  NSLog(@"DEBUG: sim_operator_code=%@", [SKGlobalMethods getSimOperatorCodeMCCAndMNC]);
#endif // DEBUG
  //[network setObject:[SKGlobalMethods getCarrierName]
  //            forKey:@"sim_operator_name"];
  [network setObject:carrierName
              forKey:@"sim_operator_name"];
  
  [network setObject:[SKGlobalMethods getTimeStamp]
              forKey:@"timestamp"];
  [network setObject:[SKGlobalMethods getDeviceModel]
              forKey:@"phone_type"];
  [network setObject:@"NA"
              forKey:@"roaming"];
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
  
  NSMutableDictionary *location = [NSMutableDictionary dictionary];
  
  [location setObject:@"location"
               forKey:@"type"];
  
  [location setObject:@"NA"
               forKey:@"accuracy"];
  
  [location setObject:[NSDate sGetDateAsIso8601String:[SKCore getToday]] forKey:@"datetime"];
  
  [location setObject:[NSString localizedStringWithFormat:@"%f", locationManager.locationLatitude] forKey:@"latitude"];
  
  [location setObject:[NSString localizedStringWithFormat:@"%f", locationManager.locationLongitude] forKey:@"longitude"];
  
  [location setObject:[SKGlobalMethods getNetworkOrGps] forKey:@"location_type"];
  
  [location setObject:[SKGlobalMethods getTimeStampForTimeInteralSince1970:locationManager.locationDateAsTimeIntervalSince1970] forKey:@"timestamp"];
  
  return location;
}

// Returns array of metrics!
+ (NSMutableArray*)sWriteMetricsToJSONDictionary:(NSMutableDictionary*)jsonDictionary TestId:(NSString*)testId SKKitLocationManager:(SKKitLocationManager*)locationManager  AccumulatedNetworkTypeLocationMetrics:(NSArray*)accumulatedNetworkTypeLocationMetrics
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
  
  NSMutableDictionary *phone = [NSMutableDictionary dictionary];
  
  [phone setObject:@"phone_identity" forKey:@"type"];
  
  // Return the device 'unique id' via the app_id value in the upload data *only* for some app variants.
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getShouldUploadDeviceId]) {
    [phone setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"app_id"];
  }
  
  [phone setObject:[NSDate sGetDateAsIso8601String:[SKCore getToday]] forKey:@"datetime"];
  
  [phone setObject:@"Apple" forKey:@"manufacturer"];
  
  [phone setObject:[SKGlobalMethods getDeviceModel] forKey:@"model"];
  
  //NSString *oldSystemName =  [[UIDevice currentDevice] systemName];
  // Override, as iOS 9 reports iOS rather than "iPhone OS" as reported by iOS 8...
  [phone setObject:@"iPhone OS" forKey:@"os_type"];
  
  [phone setObject:[[UIDevice currentDevice] systemVersion] forKey:@"os_version"];
  
  [phone setObject:[SKGlobalMethods getTimeStamp] forKey:@"timestamp"];
  
  [phone setObject:testId forKey:@"test_id"];
  
  
  // Location ////////////////////////////////////////////////////////////////////////////////////////////////
  
  NSMutableDictionary *location;
  location = [self.class sCreateLocationMetric:locationManager];
  
  
  // Last Known Location /////////////////////////////////////////////////////////////////////////////////////
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  double latitude = 0.0;
  double longitude = 0.0;
  //NSTimeInterval locationdate = 0;
  NSDictionary *loc = [prefs objectForKey:[SKAppBehaviourDelegate sGet_Prefs_LastLocation]];
  if (loc != nil) {
    latitude = [[loc objectForKey:@"LATITUDE"] doubleValue];
    longitude = [[loc objectForKey:@"LONGITUDE"] doubleValue];
    //locationdate = [[loc objectForKey:@"LOCATIONDATE"] doubleValue];
  }
  
  //  if (locationdate == 0) {
  //    locationdate = [[SKCore getToday] timeIntervalSince1970];
  //  }
  
  NSMutableDictionary *lastLocation = [NSMutableDictionary dictionary];
  
  [lastLocation setObject:@"last_known_location"
                   forKey:@"type"];
  
  [lastLocation setObject:@"NA"
                   forKey:@"accuracy"];
  
  [lastLocation setObject:[NSDate sGetDateAsIso8601String:[SKCore getToday]] forKey:@"datetime"];
  
  [lastLocation setObject:[NSString localizedStringWithFormat:@"%f", latitude]
                   forKey:@"latitude"];
  
  [lastLocation setObject:[NSString localizedStringWithFormat:@"%f", longitude]
                   forKey:@"longitude"];
  
  [lastLocation setObject:[SKGlobalMethods getNetworkOrGps]
                   forKey:@"location_type"];
  
  [lastLocation setObject:[SKGlobalMethods getTimeStamp]
                   forKey:@"timestamp"];
  
  
  // Network ////////////////////////////////////////////////////////////////////////////////////////////////
  
  NSMutableDictionary *network;
  network = [self sCreateNetworkTypeMetric:locationManager];
  
  NSMutableArray *metrics = [NSMutableArray array];
  [metrics addObject:phone];
  [metrics addObject:location];
  [metrics addObject:lastLocation];
  [metrics addObject:network];
  
  for (NSDictionary *accumulatedMetric in accumulatedNetworkTypeLocationMetrics) {
    [metrics  addObject:accumulatedMetric];
  }
  
  
  [jsonDictionary setObject:metrics forKey:@"metrics"];
  
  return metrics;
}


@end // SKKitJSONDataCaptureAndUpload