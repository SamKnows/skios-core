//
//  SKDebugAssert.m
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

// http://nadeausoftware.com/articles/2012/01/c_c_tip_how_use_compiler_predefined_macros_detect_operating_system#OSXiOSandDarwin
#include <TargetConditionals.h>

#import "./SKDebugAssert.h"
#include <signal.h>

void sk_debugbreak(const char *PpFile, int PLine) {
#ifdef DEBUG
  NSLog(@"DEBUG: ASSERTION IN %s, sk_debugbreak - SET A BREAKPOINT AT (%d)!\n", PpFile, PLine);
#ifdef TARGET_CPU_ARM
  raise(SIGTRAP);
#else // TARGET_CPU_ARM
   {__asm__("int $3\n" : : );}
#endif // TARGET_CPU_ARM
#endif // DEBUG
}

@implementation SKDebugSupport

+(void) SK_ASSERTDEBUGINTERNAL:(BOOL)condition   File:(const char *)PpFile Line:(int)PLine {
  if (!(condition )) {
    GbSKAssertDetected = YES;
#ifdef DEBUG
    NSLog(@"DEBUG: SK_ASSERT - %s : %d\n", PpFile, PLine);
    sk_debugbreak(PpFile, PLine);
#endif // DEBUG
  }
}

+(void)SK_REPORT_NONSERROR_INTERNAL:(NSError*)error File:(const char *)PpFile Line:(int)PLine {
#ifdef DEBUG
  if (error == nil) {
    return;
  }

  NSLog(@"SK_ASSERT_NONSERROR_INTERNAL - %@",[error localizedDescription]);

  NSArray* detailedErrors = [error userInfo][NSDetailedErrorsKey];
  if(detailedErrors != nil && [detailedErrors count] > 0) {
    for(NSError* detailedError in detailedErrors) {
      NSLog(@"  DetailedError: %@", [detailedError userInfo]);
    }
  }
  else {
    NSLog(@"  %@", [error userInfo]);
  }
#endif // DEBUG
}


+(void)SK_ASSERT_NONSERROR_INTERNAL:(NSError*)error File:(const char *)PpFile Line:(int)PLine {
  if (error == nil) {
    return;
  }

  NSLog(@"SK_ASSERT_NONSERROR_INTERNAL - %@",[error localizedDescription]);

  NSArray* detailedErrors = [error userInfo][NSDetailedErrorsKey];
  if(detailedErrors != nil && [detailedErrors count] > 0) {
    for(NSError* detailedError in detailedErrors) {
      NSLog(@"  DetailedError: %@", [detailedError userInfo]);
    }
  }
  else {
    NSLog(@"  %@", [error userInfo]);
  }

#ifdef DEBUG
  GbSKAssertDetected = YES;
  sk_debugbreak(PpFile, PLine);
#endif // DEBUG
}

// The next two methods are designed for use by unit tests.
static BOOL GbSKAssertDetected = NO;

+(void)SK_ASSERT_DETECTED_RESET {
  GbSKAssertDetected = NO;
}

+(BOOL)SK_ASSERT_GET_DETECTED {
  return GbSKAssertDetected;
}

@end
