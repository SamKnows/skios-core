//
//  SKOperators.m
//  SKCore
//
//  Created by Pete Cole on 12/02/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKOperators.h"

// http://stackoverflow.com/questions/3468268/objective-c-sha1
#include <CommonCrypto/CommonDigest.h>

@implementation SKThrottledQueryResult : NSObject
- (id)init
{
  self = [super init];
  
  if (self) {
    NSDate *now = [NSDate date];
    
    self.returnCode = SKOperators_Return_NoThrottleQuery;
    self.timestamp = [NSString stringWithFormat:@"%ld", (long)[now timeIntervalSince1970]];
    //self.datetimeUTCMilliZ = [NSDate sGetDateAsIso8601StringMilliZ:now];
    self.datetimeUTCSimple = [NSDate sGetDateAsIso8601String:now];
    self.carrier = nil;
  }

  return self;
}
@end


@interface SKOperators()
@property NSArray *mpOperatorArray;
@end

@implementation SKOperators

- (id)init
{
  self = [super init];
  if (self) {
    [self doInitialize];
  }
  return self;
}

+ (id)dictionaryOrArrayFromJSONResourceFileNamed:(NSString *)fileName
{
  //    NSString *resource = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
  
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSString *resource = [bundle pathForResource:fileName ofType:@"json"];
  
  NSData *jsonData = [NSData dataWithContentsOfFile:resource];
  if (jsonData == nil) {
    // Nothing found!
    return nil;
  }
  
  NSError *jsonError = nil;
  id jsonDictionaryOrArray = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
  if(jsonError) {
    SK_REPORT_NONSERROR(jsonError);
    SK_ASSERT(false);
    return nil;
  }
  
  return jsonDictionaryOrArray;
}

-(void) doInitialize {
  self.mpOperatorArray = nil;
  
  NSObject *theArrayOrDictionary = [self.class dictionaryOrArrayFromJSONResourceFileNamed:@"operators"];
  if (theArrayOrDictionary == nil) {
    // There is NO operator data!
    return;
  }
  
  if ([theArrayOrDictionary.class isSubclassOfClass:NSDictionary.class] == NO) {
    SK_ASSERT(false);
    return;
  }
  
  // Find the operators!
  NSDictionary *theDictionary = (NSDictionary*)theArrayOrDictionary;
  // And now, we must store this for future reference!
  self.mpOperatorArray = theDictionary[@"operators"];
 
  // The operator array must really be present, and must have 1 or more entry.
  if (self.mpOperatorArray == nil) {
    SK_ASSERT(false);
  }
  if (self.mpOperatorArray.count == 0) {
    SK_ASSERT(false);
  }
  
  // Every entry must contain valid data!
  for (NSDictionary *operator in self.mpOperatorArray) {
    SK_ASSERT(operator[@"name"] != nil);
    SK_ASSERT([[operator[@"name"] class] isSubclassOfClass:NSString.class]);
    SK_ASSERT([operator[@"name"] length] > 0);

    // Only one supported type at the moment!
    SK_ASSERT(operator[@"class"] != nil);
    SK_ASSERT([[operator[@"class"] class] isSubclassOfClass:NSString.class]);
    SK_ASSERT([operator[@"class"] isEqualToString:@"isthrottledwebservice"] ||
              [operator[@"class"] isEqualToString:@"isthrottledwebservice_test"]);

    SK_ASSERT(operator[@"mcc+mnc"] != nil);
    SK_ASSERT([[operator[@"mcc+mnc"] class] isSubclassOfClass:NSArray.class]);
    NSArray *mccMncArray = (NSArray*)operator[@"mcc+mnc"];
    SK_ASSERT([mccMncArray count] > 0);

#ifdef DEBUG
    for (NSString *mccMnc in mccMncArray) {
      SK_ASSERT([mccMnc length] >= 5);
      SK_ASSERT([mccMnc length] <= 6);
    }
#endif // DEBUG
    SK_ASSERT(operator[@"url"] != nil);
    SK_ASSERT([[operator[@"url"] class] isSubclassOfClass:NSString.class]);
    SK_ASSERT([operator[@"url"] length] > 0);

    SK_ASSERT(operator[@"username"] != nil);
    SK_ASSERT([[operator[@"username"] class] isSubclassOfClass:NSString.class]);
    SK_ASSERT([operator[@"username"] length] > 0);
    
    SK_ASSERT(operator[@"password"] != nil);
    SK_ASSERT([[operator[@"password"] class] isSubclassOfClass:NSString.class]);
    SK_ASSERT([operator[@"password"] length] > 0);
  }
}

// Returns object containing immediate results.
// The async part of the result, will occur later (if at all!)

// Private method (can be used for mock testing purposes)
-(SKThrottledQueryResult*) fireThrottledWebServiceQueryForDeviceMccMnc:(NSString*)deviceMccMnc  Callback:(SKQueryCompleted)callback {
  
  SKThrottledQueryResult *throttledQueryResult = [SKThrottledQueryResult new];
  
  if (self.mpOperatorArray == nil) {
    // No operators at all!
    return throttledQueryResult;
  }
 
  NSString *lookForService = @"isthrottledwebservice";
#if TARGET_IPHONE_SIMULATOR
#ifdef DEBUG
  // On simulator in debug mode...!
  SK_ASSERT (deviceMccMnc.length == 0);
  lookForService = @"isthrottledwebservice_test";
  if (deviceMccMnc.length == 0) {
    deviceMccMnc = @"tester";
  }
#endif // DEBUG
#endif // TARGET_IPHONE_SIMULATOR
 
#ifdef DEBUG
  NSLog(@"DEBUG: search for %@, using deviceMccMnc=(%@)", lookForService, deviceMccMnc);
#endif // DEBUG
  
  // Every entry must contain valid data!
  for (NSDictionary *operator in self.mpOperatorArray) {
    if ([operator[@"class"] isEqualToString:lookForService]) {
      // This is a potential match by MMC/MNC!
      
      NSArray *mccMncArray = (NSArray*)operator[@"mcc+mnc"];
      SK_ASSERT([mccMncArray count] > 0);
      
      //for (__strong NSString *mccMnc in mccMncArray) {
      //  mccMnc = @"23410";
      for (NSString *mccMnc in mccMncArray) {
        
        if ([mccMnc isEqualToString:deviceMccMnc]) {
          
          SK_ASSERT(operator[@"url"] != nil);
          SK_ASSERT([[operator[@"url"] class] isSubclassOfClass:NSString.class]);
          
          NSString *urlString = operator[@"url"];
          SK_ASSERT(urlString.length > 0);
          
          throttledQueryResult.carrier = operator[@"name"];
          SK_ASSERT(throttledQueryResult.carrier != nil);
          
          /*
          The following items shall be sent to the API via the REQUEST HEADERS:
          username - provide
          password - combination (concatenation of first 8 numbers/characters of UTC field
          and the CODEWORD, and then SHA-1 hashed ...!)
          UTC      - UTC time.
          For example, the password will be sha1sum(2014-02-codeword) ...
          */
          NSString *username = operator[@"username"];
          NSString *utcDateTimeSimple = throttledQueryResult.datetimeUTCSimple;
          NSString *passwordBase = operator[@"password"];
          NSMutableString *password = [NSMutableString stringWithString:[utcDateTimeSimple substringToIndex:8]];
          // The following will be something like "2014-03-dummypassword"
          [password appendString:passwordBase];
          
          // Turn 'password' into something like "f4401e54f4472a576281375e3f89f87a8e7547af"
          unsigned char digest[CC_SHA1_DIGEST_LENGTH];
          NSData *stringBytes = [password dataUsingEncoding: NSUTF8StringEncoding];
          if (CC_SHA1([stringBytes bytes], (int)[stringBytes length], digest)) {
            // SHA-1 hash has been calculated and stored in 'digest'.
            [password setString:@""];
            for (int i=0;i<CC_SHA1_DIGEST_LENGTH;i++) {
              [password appendFormat:@"%02x", digest[i]];
            }
          }
          
          NSDictionary *injectDictionaryIntoHttpRequestHeader = @{
            @"username" : username,
            @"UTC" :      utcDateTimeSimple,
            @"password":  password};
          
#ifdef DEBUG
          NSLog(@"DEBUG: password mutated to (%@)", password);
#endif // DEBUG

          // TODO - fire the query!
#ifdef DEBUG
          NSLog(@"DEBUG: found isthrottledwebservice for device - TODO fire the query!");
#endif // DEBUG
          [SKNSURLAsyncQuery
           fireURLRequest:urlString
           InjectDictionaryIntoHeader:injectDictionaryIntoHttpRequestHeader
           Callback:callback];

          throttledQueryResult.returnCode = SKOperators_Return_FiredThrottleQueryAwaitCallback;
          
          return throttledQueryResult;
        }
      }
    }
  }
  
  // To reach here, there wa no match...
#ifdef DEBUG
  NSLog(@"DEBUG: no isthrottledwebservice found for device...");
#endif // DEBUG
  // No operator match!
  return throttledQueryResult;
}

// Public method
-(SKThrottledQueryResult*) fireThrottledWebServiceQueryWithCallback:(SKQueryCompleted)callback  {
  NSString *deviceMccMnc = [SKGlobalMethods getSimOperatorCodeMCCAndMNC];
  return [self fireThrottledWebServiceQueryForDeviceMccMnc:deviceMccMnc Callback:callback];
}

// Singleton access...

static SKOperators *sbOperators = nil;

+(SKOperators*) getInstance {
  if (sbOperators == nil) {
    sbOperators = [[SKOperators alloc] init];
  }
  
  return sbOperators;
}
@end
