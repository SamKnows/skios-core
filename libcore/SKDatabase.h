//
//  SKDatabase.h
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKDatabase : NSObject

+(void) sEmptyTheDatabase;
  
+ (NSString *)dbPath;

+ (void)createDatabase;

+ (NSNumber*)storeBatchTestMapData:(double)latitude longitude:(double)longitude target:(NSString*)target;

+ (void)storeUpload:(NSDate*)dateTime BitrateMbps1024Based:(double)bitrateMbps1024Based testId:(NSNumber*)testId testName:(NSString*)testName;
+ (void)storeDownload:(NSDate*)dateTime BitrateMbps1024Based:(double)bitrateMbps1024Based testId:(NSNumber*)testId testName:(NSString*)testName;
+ (void)storeLatency:(NSDate*)dateTime latency:(double)latency testId:(NSNumber*)testId testName:(NSString*)testName;
+ (void)storePacketLoss:(NSDate*)dateTime packetLoss:(double)packetLoss testId:(NSNumber*)testId testName:(NSString*)testName;
+ (void)storeJitter:(NSDate*)dateTime jitter:(double)jitter testId:(NSNumber*)testId testName:(NSString*)testName;

+ (NSDictionary*)getDownloadResultsForTestId:(NSNumber*)testId;
+ (NSDictionary*)getUploadResultsForTestId:(NSNumber*)testId;
+ (NSDictionary*)getLatencyResultsForTestId:(NSNumber*)testId;
+ (NSDictionary*)getLossResultsForTestId:(NSNumber*)testId;
+ (NSDictionary*)getJitterResultsForTestId:(NSNumber*)testId;

+ (void)updateMetricForTestId:(NSNumber*)testId
                 MetricColumn:(NSString*)metricColumn
                  MetricValue:(NSString*)metricValue;

+ (void)storeMetrics:(NSNumber*)testId
              device:(NSString*)device
                  os:(NSString*)os
         carrierName:(NSString*)carrierName
         countryCode:(NSString*)countryCode
             isoCode:(NSString*)isoCode
         networkCode:(NSString*)networkCode
         networkType:(NSString*)networkType
           radioType:(NSString*)radioType
              target:(NSString*)target;

// Used only by SKA project, as EAQ project doesn't save metrics!
+ (NSMutableDictionary*)getMetricsForTestId:(NSNumber*)testId;

+ (void)removeTestDataForTestId:(NSNumber*)testId;

+ (void)storeData:(NSDictionary*)data dataType:(TestDataType)dataType;

+ (double)getAverageTestDataJoinToMetrics:(NSDate*)fromDate toDate:(NSDate*)toDate testDataType:(TestDataType)testDataType WhereNetworkTypeAsStringEquals:(NSString*)whereNetworkTypeAsStringEquals;
+ (double)getAverageTestDataJoinToMetrics:(NSDate*)fromDate toDate:(NSDate*)toDate testDataType:(TestDataType)testDataType WhereNetworkTypeAsStringEquals:(NSString*)whereNetworkTypeAsStringEquals RetCount:(int*)retCount;

+ (NSMutableArray*)getTestMetaDataWhereNetworkTypeEquals:(NSString*)whereNetworkTypeAsStringEquals;

+ (NSMutableArray*)getNonAveragedTestData:(NSDate*)fromDate ToDate:(NSDate*)toDate TestDataType:(TestDataType)testDataType WhereNetworkTypeAsStringEquals:(NSString*)whereNetworkTypeAsStringEquals;

+ (NSMutableDictionary*)getDailyAveragedTestDataAsDictionaryKeyByDay:(NSDate*)fromDate ToDate:(NSDate*)toDate TestDataType:(TestDataType)testDataType WhereNetworkTypeAsStringEquals:(NSString*)whereNetworkTypeAsStringEquals;

+ (NSDate*)getLastRunDateWhereNetworkTypeEquals:(NSString*)whereNetworkTypeAsStringEquals;


//###HG
+ (NSMutableArray*)getTestDataForNetworkType:(NSString*)networkType_ afterDate:(NSDate*)minDate_;

@end
