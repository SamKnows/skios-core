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

NSBundle *getCurrentLanguageBundle(NSString *localeIdentifier) {
  
  // THis gets e.g. en_US, en_GB, pt_BR, pt, zh_HANS, zh_HANT etc.
  
  NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:localeIdentifier ofType:@"lproj"]];
  if (bundle != nil) {
    // Found match for e.g. en_GB
    return bundle;
  }
  
  // Split into e.g. [en, GB] and just use the en part.
  NSArray *stringArray = [localeIdentifier componentsSeparatedByString: @"_"];
  localeIdentifier = stringArray[0];
  bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:localeIdentifier ofType:@"lproj"]];
  if (bundle != nil) {
#ifdef DEBUG
    NSLog(@"DEBUG: localeIdentifier#2=%@", localeIdentifier);
#endif // DEBUG
    return bundle;
  }
  
  // Nothing found - default to English.
  localeIdentifier = @"en";
  bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:localeIdentifier ofType:@"lproj"]];
  SK_ASSERT(bundle != nil);
  return bundle;
}

NSString*sSKCoreGetLocalisedString(NSString*theString)
{
  // As iOS 8 mis re-reports the locale (e.g. returning en_GB when on a device configured
  // to use zh-Hant), base the locale on the "first preferred language" instead - which
  // always seems to return the correct value.
  // This returns e.g. en-GB, zh-Hans, zh-Hant etc.
  NSString *language =  [[NSLocale preferredLanguages] objectAtIndex:0];
#ifdef DEBUG
  NSLog(@"DEBUG: preferredLang=%@", language);
#endif // DEBUG
  
//#ifdef DEBUG
//  NSString *localeIdentifierIgnore = [[NSLocale currentLocale] localeIdentifier];
//  NSLog(@"DEBUG: localeIdentifierIgnore =%@", localeIdentifierIgnore);
//#endif // DEBUG
  NSString *localeIdentifier = language;
#ifdef DEBUG
  NSLog(@"DEBUG: localeIdentifier=%@", localeIdentifier);
#endif // DEBUG
  
  // Allow the string to be looked-up from the app.
  NSString *theResult = NSLocalizedString(theString, nil);
  // If the app doesn't override, use the internal default!
  if ([theResult isEqualToString:theString]) {
    NSString *theResult2 = NSLocalizedStringFromTableInBundle(theString, @"libcore", getCurrentLanguageBundle(localeIdentifier), @"");
    //NSLog(@"theResult=%@", theResult3);
    if (theResult2 != nil) {
      theResult = theResult2;
    }
  }
  
  if (theResult == nil) {
    SK_ASSERT(false);
    return @"";
  }
  return theResult;
}
