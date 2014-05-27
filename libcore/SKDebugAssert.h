//
//  SKDebugAssert.h
//

#ifndef SK_DEBUGASSERT_H
#define SK_DEBUGASSERT_H

void sk_debugbreak(const char *PpFile, int PLine);

@interface SKDebugSupport : NSObject
    
+(void) SK_ASSERTDEBUGINTERNAL:(BOOL)condition File:(const char *)PpFile Line:(int)PLine;
+(void)SK_ASSERT_NONSERROR_INTERNAL:(NSError*)error File:(const char *)PpFile Line:(int)PLine;
+(void)SK_REPORT_NONSERROR_INTERNAL:(NSError*)error File:(const char *)PpFile Line:(int)PLine;

// The next two methods are designed for use by unit tests.
+(void)SK_ASSERT_DETECTED_RESET;
+(BOOL)SK_ASSERT_GET_DETECTED;
@end


#define SK_ASSERT(PCondition) [SKDebugSupport SK_ASSERTDEBUGINTERNAL:(PCondition) File:__FILE__ Line:__LINE__]
#define SK_ASSERT_NONSERROR(PError) [SKDebugSupport SK_ASSERT_NONSERROR_INTERNAL:(PError) File:__FILE__ Line:__LINE__]
#define SK_REPORT_NONSERROR(PError) [SKDebugSupport SK_REPORT_NONSERROR_INTERNAL:(PError) File:__FILE__ Line:__LINE__]

#endif
