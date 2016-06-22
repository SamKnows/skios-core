//
//  GlobalMethods.h
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <mach/mach.h>

typedef double SKTimeIntervalMicroseconds;

@interface SKGlobalMethods : NSObject

+ (float)randomFloat:(float)minValue maxValue:(float)maxValue;

+ (NSString*)getTodaysDate;

#pragma mark - Calculations

#pragma mark - Formatting

+ (NSString *)formatDate:(NSDate*)date;

+ (NSString *)formatShorterDate:(NSDate*)date;

+ (NSString *)formatDouble:(double)number DecimalPlaces:(int)decimalPlaces;
+ (NSString *)format3DecimalPlaces:(double)number;
+ (NSString *)format2DecimalPlaces:(double)number;

+ (NSString *)formatMilliseconds:(double)number;

+ (NSString *)format2Milliseconds:(double)number;

+ (NSString *)bytesToString:(double)value WithDecimalPlaces:(int)decimalPlaces;
+ (NSString *)bytesToString:(double)value;

+ (NSString *)getTimeStampForTimeInteralSince1970:(NSTimeInterval)timeIntervalSince1970;
+ (NSTimeInterval)getTimeNowAsTimeIntervalSince1970;
+ (NSString *)getTimeStamp;

#pragma mark - Miscellaneous

+ (NSString*)getCredentials:(NSString*)username password:(NSString*)password;

+ (BOOL)isActivated;

+ (NSString *)getLocalizedConnectionString:(ConnectionStatus)value;

+ (NSString *)getConnectionResultString:(ConnectionStatus)value;

+ (float)getCpuUsage;

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL*)URL;

+ (BOOL)deviceIsCurrentUnitId;
+ (void)printNSData:(NSData*)data;

+(NSString*)getCarrierName;
+(NSString*)getNetworkType;
+(NSString*)getNetworkTypeLocalized:(NSString*)theType;
+(NSString*)getCarrierMobileCountryCode;
+(NSString*)getCarrierNetworkCode;
+(NSString*)getCarrierIsoCountryCode;
+(NSString*)getSimOperatorCodeMCCAndMNC;
+(NSString*)getDeviceModel;
+(NSString*)getDevicePlatform;
+(NSString*)getNetworkOrGps;
+(NSString*)getNetworkTypeString;

+(NSString*)getNetworkType:(int)date networkType:(NSString*)networkType ForConnectionStatus:(ConnectionStatus)inConnectionStatus;
+(NSString*)getNetworkState:(int)date ForConnectionStatus:(ConnectionStatus)inConnectionStatus;
+(NSString*)getPhoneIdentity:(int)date;
+(NSString*)getSimOperator:(int)date;
+(NSString*)getCarrierInformation:(int)date;

+(void) setLongDateFormat:(NSString*)inFormat;
+(void) setShortDateFormat:(NSString*)inFormat;
+(void) setGraphDateFormat:(NSString*)inFormat;
+(NSString*) getGraphDateFormat;
+(NSString*) getGraphTimeFormat;

+(double) convertMbps1000BasedToMbps1024Based:(double)mbps1000Based;
+(double) convertMbps1024BasedToMBps1000Based:(double)value1024Based;
+(double) convertBytesPerSecondToMbps1024Based:(double)bytesPerSecond;
+(double) convertBytesPerSecondToMbps1000Based:(double)bytesPerSecond;
+(double) convertMpbs1024BasedToBytesPerSecond:(double)value1024Based;
+(NSString*) bitrateMbps1000BasedToString:(double)bitrateMbps1000Based;
+(NSString*) bitrateMbps1024BasedToString:(double)bitrateMbps1024Based;
+(NSString*)sGet3DigitsNumber:(float)number_;
+(double) convertLocalNumberStringToDouble:(NSString*)value;
+(NSString*) bitrateMbps1024BasedLocalNumberStringBasedToString:(NSString*)bitrateMbps1024BasedAsLocalString;
+(double)getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:(double)transferTimeMicroseconds transferBytes:(double)transferBytes;

+ (NSString *)sCurrentWifiSSID;
// Queries, returing last known value.
+(NSString*) sQueryWlanCarrier:(void(^)(NSString* wlanCarrier))completion;

+(NSString *)sGetDateAsIso8601String:(NSDate*)date;

// Utility
+ (BOOL)sIsWholeNumber:(double)number;

+ (NSString*) sExportDictionaryToJSONString:(NSDictionary*)dictionary;

@end
