//
//  GlobalMethods.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKGlobalMethods.h"

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#define ARC4RANDOM_MAX 0x100000000

@implementation SKGlobalMethods

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    if ([[NSFileManager defaultManager] fileExistsAtPath: [URL path]])
    {
        NSError *error = nil;
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        
        if (success)
            NSLog(@"Added Skip backup attribute %@", [URL lastPathComponent]);
        else
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        
        return success;
    }
    else
    {
        return NO;
    }
}

+ (void)printNSData:(NSData *)data
{
    if (nil != data)
    {
        if ([data length] > 0)
        {
            NSString *str = [NSString stringWithUTF8String:[data bytes]];
            
            NSLog(@"NSData");
            NSLog(@"%s %d %@", __FUNCTION__, __LINE__, str);
        }
    }
}

+ (NSString*)getTodaysDate
{
    NSDate *date = [SKCore getToday];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter stringFromDate:date];
}

+ (float)randomFloat:(float)minValue maxValue:(float)maxValue
{
    return ((float)arc4random() / ARC4RANDOM_MAX) * (maxValue-minValue) + minValue;
}


#pragma mark - Formatting

static NSString *GLongDateFormat  = @"dd-MM-yyyy HH:mm";
static NSString *GShortDateFormat = @"dd/MM/yy";
static NSString *GGraphDateFormat = @"d/MM";
static NSString *GGraphTimeFormat  = @"HH:mm";

+(void) setLongDateFormat:(NSString*)inFormat {
  GLongDateFormat  = inFormat;
}

+(void) setShortDateFormat:(NSString*)inFormat {
  GShortDateFormat = inFormat;
}

+(void) setGraphDateFormat:(NSString*)inFormat {
  GGraphDateFormat = inFormat;
}

+(NSString*) getGraphDateFormat {
  return GGraphDateFormat;
}

+(NSString*) getGraphTimeFormat {
  return GGraphTimeFormat;
}

+(double) convertBytesPerSecondToMbps1024Based:(double)bytesPerSecond {
  return bytesPerSecond * 8.0 / (1024.0 * 1024.0);
}

+(double) convertMbps1024BasedToMBps1000Based:(double)value1024Based {
  return value1024Based * (1024.0 * 1024.0) / (1000.0 * 1000.0);
}

+ (NSString *)formatDate:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:GLongDateFormat];
    
    NSString *result = [formatter stringFromDate:date];
    
    return result;
}

+ (NSString *)formatShorterDate:(NSDate*)date
{
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:GShortDateFormat];
  
  //BOOL isUK = [@"GB" isEqual:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
  
  NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
  [timeFormat setDateFormat:@"HH:mm"];
  
  NSString *theDate = [dateFormat stringFromDate:date];
  NSString *theTime = [timeFormat stringFromDate:date];
  
  NSString *result = [NSString stringWithFormat:@"%@ %@", theDate, theTime];
  
  
  return result;
}

+ (NSString *)format2Milliseconds:(double)number
{
    number = number * 1000;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:2];
    [formatter setGeneratesDecimalNumbers:YES];
    [formatter setAlwaysShowsDecimalSeparator:YES];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [formatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
	
	return [NSString stringWithFormat:@"%@ ms", [formatter stringFromNumber:[NSNumber numberWithDouble:number]]];
}

+ (NSString *)formatMilliseconds:(double)number
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:2];
    [formatter setGeneratesDecimalNumbers:YES];
    [formatter setAlwaysShowsDecimalSeparator:YES];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [formatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
	
	return [NSString stringWithFormat:@"%@ ms", [formatter stringFromNumber:[NSNumber numberWithDouble:number]]];
}

+ (NSString *)format2DecimalPlaces:(double)number
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:2];
    [formatter setGeneratesDecimalNumbers:YES];
    [formatter setAlwaysShowsDecimalSeparator:YES];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [formatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
	
	NSString *result = [formatter stringFromNumber:[NSNumber numberWithDouble:number]];
  return result;
}

+ (NSString *)format3DecimalPlaces:(double)number
{
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:3];
    [formatter setMinimumFractionDigits:3];
    [formatter setGeneratesDecimalNumbers:YES];
    [formatter setAlwaysShowsDecimalSeparator:YES];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [formatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
	
	return [formatter stringFromNumber:[NSNumber numberWithDouble:number]];
}

// The 'bitrate' value return is calculated like this:
// bitrate = bytes * 8 / (1024 / 1024)
// The value returned for *display*, is calculated like this to return the ORIGINAL BYTE VALUE.
// bytes = (bitrate * 1024 * 1024) / 8
+ (double)getBitrateMbps1024BasedDoubleForTransferTimeMicroseconds:(double)transferTimeMicroseconds transferBytes:(double)transferBytes
{     
  double time = transferTimeMicroseconds / 1000000.0;   // convert microseconds -> seconds
  
  double bytesPerSecond = ((double)transferBytes) / time;
  
  double bitrate1024Based = [SKGlobalMethods convertBytesPerSecondToMbps1024Based:bytesPerSecond];
  
  return bitrate1024Based;
}

+(double) convertLocalNumberStringToDouble:(NSString*)value {
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
  double result = [[formatter numberFromString:value] doubleValue];
  return result;
}

+(NSString*) bitrateMbps1024BasedLocalNumberStringBasedToString:(NSString*)bitrateMbps1024BasedAsLocalString {
  double bitrateMbps1024Based = [SKGlobalMethods convertLocalNumberStringToDouble:bitrateMbps1024BasedAsLocalString];
  NSString *result1 = [SKGlobalMethods bitrateMbps1024BasedToString:(double)bitrateMbps1024Based];
  return result1;
}


+(NSString*) bitrateMbps1024BasedToString:(double)bitrateMbps1024Based {
  
  double bitrateMbps1000Based = [SKGlobalMethods convertMbps1024BasedToMBps1000Based:bitrateMbps1024Based];
  double bitrateBitsPerSecond = 1000000.0 * bitrateMbps1000Based;
  
  NSString *result;
  
		if (bitrateBitsPerSecond < 1000){
			result = [NSString stringWithFormat:@"%@ bps", [SKGlobalMethods format2DecimalPlaces:bitrateBitsPerSecond]];
		} else if(bitrateBitsPerSecond < 1000000) {
			result = [NSString stringWithFormat:@"%@ Kbps",[SKGlobalMethods format2DecimalPlaces:bitrateBitsPerSecond/1000.0]];
		} else {
			result = [NSString stringWithFormat:@"%@ Mbps",[SKGlobalMethods format2DecimalPlaces:bitrateBitsPerSecond/1000000.0]];
		}
    return result;
}


+ (NSString *)bytesToString:(double)value
{
  const double cOneMegaByte = 1000.0 * 1000.0;
  double mb = value / cOneMegaByte;
  
  NSString *result = [NSString stringWithFormat:@"%@ MB", [SKGlobalMethods format2DecimalPlaces:mb]];
  
  if ([result isEqualToString:@"0.00 MB"]) {
    const double cOneKiloByte = 1000.0;
    double kb = value / cOneKiloByte;
    
    result = [NSString stringWithFormat:@"%@ kB", [SKGlobalMethods format2DecimalPlaces:kb]];
  }
  
  return result;
}

#pragma mark - Miscellaneous
+ (NSString *)getTimeStamp
{
    return [NSString stringWithFormat:@"%d", (int)([[SKCore getToday] timeIntervalSince1970])] ;
}

+ (BOOL)deviceIsCurrentUnitId
{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  
  if ([prefs objectForKey:Prefs_UnitId] && [prefs objectForKey:Prefs_ViewableUnitId])
  {
    NSString *unit_id = [prefs objectForKey:Prefs_UnitId];
    NSString *view_id = [prefs objectForKey:Prefs_ViewableUnitId];
    
#ifdef DEBUG
    NSLog(@"DEBUG: unit_id from Prefs_UnitId=%@", unit_id);
    NSLog(@"DEBUG: view_id from Prefs_ViewableUnitId=%@", view_id);
    //NSLog(@"DEBUG: compare the two values!");
#endif // DEBUG
    
    return [unit_id isEqualToString:view_id];
  }
  
  return NO;
}

+ (BOOL)isActivated
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    return ( nil != [prefs stringForKey:Prefs_UnitId]);
}

// http://stackoverflow.com/questions/6785069/get-cpu-percent-usage
// This simply doesn't match what is reported by the instrumentation in XCode...
//+(float) getAlternativeCpuUsage {
//  processor_info_array_t cpuInfo = NULL;
//  mach_msg_type_number_t numCpuInfo;
//  
//  natural_t numCPUs = 0U;
//  kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUs, &cpuInfo, &numCpuInfo);
//  if(err != KERN_SUCCESS) {
//    SK_ASSERT(false);
//    return 0.0F;
//  }
//  
//  if (numCPUs <= 0) {
//    SK_ASSERT(false);
//    return 0.0F;
//  }
//  
//  float fCpuPercent = 0.0F;
// 
//  unsigned int i;
//  for(i = 0U; i < numCPUs; ++i) {
//    float user   = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER];
//    float system = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM];
//    float nice   =  cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
//    float inUse = user + system + nice;
//    float idle   =  cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
//    float total = inUse + idle;
//    
//    NSLog(@"Core: %u, user=%f, system=%f, nice=%f | idle=%f (inUse=%f)", i, 100.0F*user/total, 100.0F*system/total, 100.0F*nice/total, 100.0F*idle/total, 100.0F*(inUse/total));
//    
//    float thisCpuPercent = 100.0F * (inUse / total);
//    fCpuPercent += thisCpuPercent;
//    NSLog(@"Core: %u, Usage: %f %%",i,thisCpuPercent);
//  }
//  
//  fCpuPercent /= (float)numCPUs;
//  
//  NSLog(@"Average CPU Percent = %g", fCpuPercent);
//  
//  if(cpuInfo) {
//    size_t cpuInfoSize = sizeof(integer_t) * numCpuInfo;
//    vm_deallocate(mach_task_self(), (vm_address_t)cpuInfo, cpuInfoSize);
//  }
//  
//  return fCpuPercent;
//}

//
// The following code is from
// http://stackoverflow.com/questions/8223348/ios-get-cpu-usage-from-application
// It matches very closely the value reported in the XCode instrumentation.
// That is to say, a measure of the total available CPU power that the current application
// is taking on a single core.
// However, a dual core system will actually have "200%" power available, in these terms.
//
+ (float)getCpuUsage
{
  //[self getAlternativeCpuUsage];
    
  kern_return_t kr;
  task_info_data_t tinfo;
  mach_msg_type_number_t task_info_count;
  
  task_info_count = TASK_INFO_MAX;
  kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
  if (kr != KERN_SUCCESS) {
    return -1;
  }
  
  //task_basic_info_t      basic_info;
  thread_array_t         thread_list;
  mach_msg_type_number_t thread_count;
  
  thread_info_data_t     thinfo;
  mach_msg_type_number_t thread_info_count;
  
  thread_basic_info_t basic_info_th;
  //uint32_t stat_thread = 0; // Mach threads
  
  //basic_info = (task_basic_info_t)tinfo;
  
  // get threads in the task
  kr = task_threads(mach_task_self(), &thread_list, &thread_count);
  if (kr != KERN_SUCCESS) {
    SK_ASSERT(false);
    return -1;
  }
  
  // if (thread_count > 0) {
  //   stat_thread += thread_count;
  // }
  
  long tot_sec = 0;
  long tot_usec = 0;
  float tot_cpu = 0;
  int j;
  
  for (j = 0; j < thread_count; j++)
  {
    thread_info_count = THREAD_INFO_MAX;
    kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                     (thread_info_t)thinfo, &thread_info_count);
    if (kr != KERN_SUCCESS) {
      SK_ASSERT(false);
      return -1;
    }
    
    basic_info_th = (thread_basic_info_t)thinfo;
    
    if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
      tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
      tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
      tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
    }
    
  } // for each thread
  
  kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
  SK_ASSERT(kr == KERN_SUCCESS);
  
  if (tot_cpu > 100)
  {
    tot_cpu = 100;
  }
  
  NSLog(@"tot_cpu = %g", tot_cpu);
  
  return tot_cpu;
}

+ (NSString *)getConnectionResultString:(ConnectionStatus)value
{
    if (value == WIFI)
    {
        return @"WIFI";
    }
    else if (value == CELLULAR)
    {
        return @"MOBILE";
    }
    else
    {
        return @"OFFLINE";
    }
}

+ (NSString *)getLocalizedConnectionString:(ConnectionStatus)value
{
    if (value == WIFI)
    {
        return NSLocalizedString(@"ConnectionString_WiFi",nil);
    }
    else if (value == CELLULAR)
    {
        return NSLocalizedString(@"ConnectionString_Cellular",nil);
    }
    else
    {
        return NSLocalizedString(@"ConnectionString_Offline",nil);
    }
}

+ (NSString*)getCredentials:(NSString*)username password:(NSString*)password
{
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", username, password];
  
#ifdef DEBUG
  NSLog(@"DEBUG: authStr=%@", authStr);
#endif // DEBUG
  
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authHeader = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedString]];
  
#ifdef DEBUG
  NSLog(@"DEBUG: authHeader=%@", authHeader);
#endif // DEBUG
  
    return authHeader;
}

+(NSString*)getCarrierName {
  CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];

  if (netinfo == nil)
  {
    return @"";
  }
  
  CTCarrier *carrier = [netinfo subscriberCellularProvider];
  
  if (carrier == nil)
  {
    return @"";
  }
  
  return [carrier carrierName];
}

+(NSString*)getNetworkTypeLocalized:(NSString*)theType {
  
//  NSLog(@"%@", CTRadioAccessTechnologyGPRS);
//  NSLog(@"%@", CTRadioAccessTechnologyEdge);
//  NSLog(@"%@", CTRadioAccessTechnologyWCDMA);
//  NSLog(@"%@", CTRadioAccessTechnologyHSDPA);
//  NSLog(@"%@", CTRadioAccessTechnologyHSUPA);
//  NSLog(@"%@", CTRadioAccessTechnologyCDMA1x);
//  NSLog(@"%@", CTRadioAccessTechnologyCDMAEVDORev0);
//  NSLog(@"%@", CTRadioAccessTechnologyCDMAEVDORevA);
//  NSLog(@"%@", CTRadioAccessTechnologyCDMAEVDORevB);
//  NSLog(@"%@", CTRadioAccessTechnologyeHRPD);
//  NSLog(@"%@", CTRadioAccessTechnologyLTE);
  
  if (theType == nil)
  {
    return NSLocalizedString(@"CTRadioAccessTechnologyUnknown",nil);
  }
  
  if ([theType isEqualToString:@"Unknown"]) {
    return NSLocalizedString(@"CTRadioAccessTechnologyUnknown",nil);
  }
  
  return NSLocalizedString(theType,nil);
}

+(NSString*)getNetworkType {
  CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
  
  if (netinfo == nil)
  {
    return @"NA";
  }
  
  NSString *result = [netinfo currentRadioAccessTechnology];
  
  if (result == nil)
  {
    return @"NA";
  }
  
  return result;
}

+(NSString*)getCarrierMobileCountryCode {
  CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
  
  if (netinfo == nil)
  {
    return @"";
  }
  
  CTCarrier *carrier = [netinfo subscriberCellularProvider];
  
  if (carrier == nil)
  {
    return @"";
  }
  
  return [carrier mobileCountryCode];
}

+(NSString*)getCarrierNetworkCode {
  CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
  
  if (netinfo == nil)
  {
    return @"";
  }
  
  CTCarrier *carrier = [netinfo subscriberCellularProvider];
  
  if (carrier == nil)
  {
    return @"";
  }
  
  return [carrier mobileNetworkCode];
}

+(NSString*)getSimOperatorCodeMCCAndMNC {
  // c.f. http://developer.android.com/reference/android/telephony/TelephonyManager.html#getSimOperator()
  
  CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
  
  if (netinfo == nil)
  {
    SK_ASSERT(false);
    return @"";
  }
  
  CTCarrier *carrier = [netinfo subscriberCellularProvider];
  
  if (carrier == nil)
  {
    // This WILL happen on the Simulator!
#if TARGET_IPHONE_SIMULATOR
#ifdef DEBUG
    NSLog(@"DEBUG: warning - on simulator, there is no subscriberCellularProvider...");
#endif // DEBUG
#else // TARGET_IPHONE_SIMULATOR
    NSLog(@"DEBUG: warning - on iDevice, there is no subscriberCellularProvider... is this a WiFi only device?");
#endif // TARGET_IPHONE_SIMULATOR
    return @"";
  }
  
  NSString *mcc = [carrier mobileCountryCode];
  SK_ASSERT(mcc != nil);
  SK_ASSERT(mcc.length >= 2);
  SK_ASSERT(mcc.length <= 3);
  
  NSString *mnc = [carrier mobileNetworkCode];
  SK_ASSERT(mnc != nil);
  SK_ASSERT(mnc.length >= 2);
  SK_ASSERT(mnc.length <= 3);
  
  NSString *simOperatorCode = [NSString stringWithFormat:@"%@%@", mcc, mnc];
  SK_ASSERT(simOperatorCode.length >= 5);
  SK_ASSERT(simOperatorCode.length <= 6);
  
  return simOperatorCode;
}

+(NSString*)getCarrierIsoCountryCode {
  CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
  
  if (netinfo == nil)
  {
    return @"";
  }
  
  CTCarrier *carrier = [netinfo subscriberCellularProvider];
  
  if (carrier == nil)
  {
    return @"";
  }
  
  return [carrier isoCountryCode];
}

+(NSString*)getDeviceModel {
  UIDeviceHardware *dh = [[UIDeviceHardware alloc] init];
  
  if (dh == nil)
  {
    return @"";
  }
  
  return [dh platformString];
}

+(NSString*)getDevicePlatform {
  UIDeviceHardware *dh = [[UIDeviceHardware alloc] init];
  
  if (dh == nil)
  {
    return @"";
  }
  
  return [dh platform];
}

+(NSString*)getNetworkOrGps {
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  [reachability startNotifier];
  
  NetworkStatus status = [reachability currentReachabilityStatus];
  if (status == ReachableViaWWAN) {
    return @"gps";
  }
  
  return @"network";
}

+(NSString*)getNetworkTypeString {
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  [reachability startNotifier];
  
  NetworkStatus status = [reachability currentReachabilityStatus];
  if (status == ReachableViaWWAN) {
    return @"mobile";
  }
  
  return @"network";
}

+ (NSString*)getNetworkType:(int)date networkType:(NSString*)networkType ForConnectionStatus:(ConnectionStatus)inConnectionStatus
{
  NSString *connection = [SKGlobalMethods getConnectionResultString:inConnectionStatus];
  
  NSString *status = nil;
  NSString *netType = nil;
  
  if (nil != networkType)
  {
    if ([networkType length] > 0)
    {
      netType = [networkType uppercaseString]; // mobile -> MOBILE, wifi ->WIFI
      status = [netType isEqualToString:connection] ? @"SUCCESS" : @"FAIL";
    }
    else
    {
      netType = @"MOBILE";
      status = [netType isEqualToString:connection] ? @"SUCCESS" : @"FAIL";
    }
  }
  else
  {
    netType = @"MOBILE";
    status = [netType isEqualToString:connection] ? @"SUCCESS" : @"FAIL";
  }
  
  NSString *str = [NSString stringWithFormat:@"NETWORKTYPE;%d;%@;%@;%@;",
                   date,
                   status,
                   netType,
                   connection];
  
  return str;
}

+ (NSString*)getNetworkState:(int)date ForConnectionStatus:(ConnectionStatus)inConnectionStatus
{
  // # NETWORKSTATE;TIMESTAMP;CDMA/GSM/Unknown; 2G/EDGE/3G/HSDPA/Unknown;MOBILE/WIFI; CONNECTED?; ROAMING?
  NSString *str = [NSString stringWithFormat:@"NETWORKSTATE;%d;%@;%@;%@;%@;%@;",
                   date,
                   @"Unknown",
                   @"Unknown",
                   [SKGlobalMethods getConnectionResultString:inConnectionStatus],
                   inConnectionStatus < 2 ? @"1" : @"0",
                   @"-1"];
  return str;
  
}

+ (NSString*)getPhoneIdentity:(int)date
{
  // PHONEIDENTITY;TIMESTAMP;IMEI;IMSI;Manufacturer;Model;OsType;OsVersion
  
  UIDeviceHardware *dh = [[UIDeviceHardware alloc] init];
  
  NSString *model = nil;
  if (nil != dh)
  {
    model = [dh platformString];
    
  }
  else
  {
    model = [[UIDevice currentDevice] model];
  }
  
  NSString *str = [NSString stringWithFormat:@"PHONEIDENTITY;%d;;;Apple;%@;%@;%@;",
                   date,
                   model,
                   [[UIDevice currentDevice] systemName],
                   [[UIDevice currentDevice] systemVersion]];
  return str;
}

+ (NSString*)getSimOperator:(int)date
{
  CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
  
  if (nil != netinfo)
  {
    // CTCarrier provides info from the SIM, not dynamic carrier info.
    
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    
    if (nil != carrier)
    {
      NSString *carrierName_ = [carrier.carrierName stringByReplacingOccurrencesOfString:@" "
                                                                              withString:@""];
      
      // # SIMOPERATOR;TIMESTAMP; SIM_OPERATOR_CODE; SIM_OPERATOR_NAME
      
      NSString *str = [NSString stringWithFormat:@"SIMOPERATOR;%d;%@;%@;",
                       date,
                       carrier.mobileNetworkCode,
                       carrierName_];
      
      return str;
    }
  }
  return nil;
}

+ (NSString*)getCarrierInformation:(int)date
{
  CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
  
  if (nil != netinfo)
  {
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    
    if (nil != carrier)
    {
      NSString *carrierName = [carrier.carrierName stringByReplacingOccurrencesOfString:@" "
                                                                             withString:@""];
      
      NSString *str = [NSString stringWithFormat:@"CARRIERINFO;%d;%@;%@;%@;%@;",
                       date,
                       carrierName,
                       carrier.mobileCountryCode,
                       carrier.mobileNetworkCode,
                       carrier.isoCountryCode];
      
      return str;
    }
  }
  return nil;
}

@end
