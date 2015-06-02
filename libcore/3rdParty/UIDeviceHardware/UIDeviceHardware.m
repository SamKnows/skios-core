//
//  UIDeviceHardware.m
//
//  Used to determine EXACT version of device software is running on.
//
//  From https://gist.github.com/Jaybles/1323251
//

#import "UIDeviceHardware.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UIDeviceHardware

- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

// https://github.com/fahrulazmi/UIDeviceHardware/blob/master/UIDeviceHardware.m
- (NSString *) platformString {
  NSString *platform = [self platform];
  if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
  if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
  if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
  if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (GSM)";
  if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
  if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
  if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
  if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (CDMA)";
  if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
  if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
  if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
  if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
  if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
  if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
  
  if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
  if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
  if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
  if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
  if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
  
  if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
  if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
  if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
  if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
  if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
  if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
  if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
  if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (CDMA)";
  if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
  if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (CDMA)";
  if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
  if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
  if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
  if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
  
  if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
  if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (GSM)";
  if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air (CDMA)";
  if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
  if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (CDMA)";
  
  if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina (WiFi)";
  if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina (CDMA)";
  if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
  if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (CDMA)";
  if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (CDMA)";
  
  
  if ([platform isEqualToString:@"i386"])         return [UIDevice currentDevice].model;
  if ([platform isEqualToString:@"x86_64"])       return [UIDevice currentDevice].model;
  return platform;
}

@end