//
//  SKCore.m
//

NSString *const Prefs_Username = @"USER_EMAIL";
NSString *const Prefs_UserId = @"USER_ID";
NSString *const Prefs_UnitId = @"UNIT_ID_V2"; // Changed this after having updated the unique identifier...
NSString *const Prefs_ViewableUnitId = @"VIEWABLE_UNIT_ID";

//
// Date forcing
//
static NSDate *GpForcedToday = nil;

@implementation SKCore

+(NSDate*) getToday {
  if (GpForcedToday != nil) {
    // Can use this instead of [NSDate date], to allow testing to force
    // working on a different effective date...
    NSLog(@"WARNING: getToday using forced date - %@", [GpForcedToday description]);
    return GpForcedToday;
  }
  
  return [NSDate date];
}

+(void) forceTodayTo:(NSDate*)inDate {
  // Can use this instead of [NSDate date], to allow testing to force
  // working on a different effective date...
  GpForcedToday = inDate;
}

//
// Debug log capture
//
static NSMutableString *spDebugLogString = nil;

// DEBUG LOGGING...

+(void) sAppendLogString:(NSString*)debugString IsError:(BOOL)isError {
  @synchronized(self) {
    if (spDebugLogString == nil) {
      spDebugLogString = [NSMutableString new];
    }
   
    /*
    // SPECIAL BUILDS - build-up a debug log string!
    // Special builds: build-up the log string!
    if (spDebugLogString.length > 0) {
      [spDebugLogString appendString:@"\n"];
    }
    [spDebugLogString appendString:debugString];
    */
  }
  
#ifdef DEBUG
  NSLog(@"DEBUG: %@", debugString);
#endif //  DEBUG
  
  SK_ASSERT(!isError);
}

+ (NSString*) sGetDebugLogString {
  @synchronized(self) {
    if (spDebugLogString == nil) {
      spDebugLogString = [NSMutableString new];
    }
    
    return [NSString stringWithString:spDebugLogString];
  }
}


// Singleton access...

static SKCore *sbCore = nil;

+(SKCore*) getInstance {
  if (sbCore == nil) {
    sbCore = [[SKCore alloc] init];
    SK_ASSERT([sSKCoreGetLocalisedString(@"CTRadioAccessTechnologyLTE") isEqualToString:@"LTE"]);
  }
 
  // Always initialise the operators singleton!
  [SKOperators getInstance];
  
  return sbCore;
}

@end

#define currentLanguageBundle [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[[NSLocale preferredLanguages] objectAtIndex:0] ofType:@"lproj"]]

NSString*sSKCoreGetLocalisedString(NSString*theString)
{
  // Allow the string to be looked-up from the app.
  NSString *theResult = NSLocalizedString(theString, nil);
  // If the app doesn't override, use the internal default!
  if ([theResult isEqualToString:theString]) {
    theResult = NSLocalizedStringFromTableInBundle(theString, @"libcore", currentLanguageBundle, @"");
    //NSLog(@"theResult=%@", theResult3);
    
    NSString *preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
#ifdef DEBUG
    NSLog(@"DEBUG: preferredLang=%@", preferredLang);
#endif // DEBUG
    NSString *localeCode = [[NSLocale currentLocale] localeIdentifier];
#ifdef DEBUG
    NSLog(@"DEBUG: LOCALE=%@", localeCode);
#endif // DEBUG
//    theResult = NSLocalizedStringFromTable(theString, @"libcore", nil);
//    NSLog(@"theResult=%@", theResult);
//#ifdef DEBUG
//    NSBundle *thisBundle = [NSBundle mainBundle];
//    NSString *theResult2 = [thisBundle localizedStringForKey:theString value:@"No translation" table:@"libcore"];
//    NSLog(@"theResult2=%@", theResult2);
//    //SK_ASSERT([theResult2 isEqualToString:theResult]);
//    
//    NSString *theResult3 = NSLocalizedStringFromTableInBundle(theString, @"libcore", currentLanguageBundle, @"");
//    NSLog(@"theResult3=%@", theResult3);
//#endif // DEBUG
  }
  
  if (theResult == nil) {
    SK_ASSERT(false);
    return @"";
  }
  return theResult;
}
