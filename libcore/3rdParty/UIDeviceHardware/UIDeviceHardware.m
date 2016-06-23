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
  return [SKGlobalMethods sGetDeviceStringForPlatform:platform];
}

@end