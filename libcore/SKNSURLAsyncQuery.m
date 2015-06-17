//
//  SKNSURLAsyncQuery.m
//

#import "SKNSURLAsyncQuery.h"

@interface SKNSURLAsyncQuery()
@property (atomic, strong) SKQueryCompleted mpCallback;
@property (atomic) NSInteger responseCode;
@property (atomic, strong) NSDictionary *responseHeaders;
@property (atomic, strong) NSMutableData* responseData;

@property UIBackgroundTaskIdentifier bgTask;
@property UIApplication *app;
@property BOOL outstanding;
@end

@implementation SKNSURLAsyncQuery

@synthesize mTimeout;
@synthesize mpCallback;
@synthesize responseCode;
@synthesize responseData;
@synthesize responseHeaders;
@synthesize bgTask;
@synthesize app;

//-(NSMutableURLRequest*)createURLRequestInTask:(NSString*)urlString;
- (id)initWithURLRequest:(NSString*)urlString InjectDictionaryIntoHeader:(NSDictionary*)injectDictionaryIntoHeader Callback:(SKQueryCompleted)callback WithTimeout:(NSTimeInterval)timeout
{
  self = [super init];
  if (self) {
    mTimeout = timeout;
    mpCallback = callback;
    SK_ASSERT(mpCallback != nil);
    responseCode = 0;
    responseData = nil;
    responseHeaders = nil;
    bgTask = UIBackgroundTaskInvalid;
    app = [UIApplication sharedApplication];
    
    NSMutableURLRequest *urlRequest = [self createURLRequestInTask:urlString];
    
    if (urlRequest == nil) {
      NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
      [errorDetail setValue:@"URL request failed" forKey:NSLocalizedDescriptionKey];
      NSError *theError =[NSError errorWithDomain:@"SKErrorDomain" code:100 userInfo:errorDetail];
      mpCallback(theError, 0, nil, nil, nil);
    } else {
     
      // If we've been so asked - inject data into the header!
      if (injectDictionaryIntoHeader != nil) {
        for (NSString *key in injectDictionaryIntoHeader) {
          NSString *value = injectDictionaryIntoHeader[key];
          [urlRequest addValue:value forHTTPHeaderField:key];
        }
      }
      
      BOOL bRes = [self initiateRequest:urlRequest];
      
      if (bRes == NO) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"URL request failed" forKey:NSLocalizedDescriptionKey];
        NSError *theError =[NSError errorWithDomain:@"SKErrorDomain" code:100 userInfo:errorDetail];
        mpCallback(theError, 0, nil, nil, nil);
      }
    }
  }
  return self;
}

- (BOOL)isCommandAlreadyRunning {
  
  if (self.bgTask == UIBackgroundTaskInvalid) {
    return NO;
  }
  
  return YES;
}

-(NSMutableURLRequest*)createURLRequestInTask:(NSString*)urlString {
  
  if (self.bgTask != UIBackgroundTaskInvalid) {
#ifdef DEBUG
    NSLog(@"DEBUG: query is already running");
#endif // DEBUG
    SK_ASSERT(false);
    return nil;
  }
  
  bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
    [app endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
  }];
  
  NSMutableURLRequest *urlRequest =
  [NSMutableURLRequest
   requestWithURL:[NSURL URLWithString:urlString]
   cachePolicy:NSURLRequestReloadIgnoringCacheData
   timeoutInterval:mTimeout];
  
  responseData = [NSMutableData data];
  responseCode = 0;
  
  return urlRequest;
}

-(void)endTask {
  
  responseData = [NSMutableData data];
  responseCode = 0;
  
  if (bgTask != UIBackgroundTaskInvalid) {
    [app endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
  }
}

// Create and initiate request
-(BOOL) initiateRequest:(NSMutableURLRequest*)request {
  NSURLConnection* requestConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  if (requestConnection == nil) {
    SK_ASSERT(false);
    
    return NO;
  }
  
  return YES;
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  [responseData setLength:0];
  
  responseCode = [(NSHTTPURLResponse*)response statusCode];
  responseHeaders =  [(NSHTTPURLResponse*)response allHeaderFields];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  responseData = nil;
  
  //SK_ASSERT_NONSERROR(error);
  
#ifdef DEBUG
  NSLog(@"DEBUG: WARNING - SKNSURLAsyncQuery - Connection problem");
#endif // DEBUG
  
  if (bgTask != UIBackgroundTaskInvalid) {
    [app endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
  }
  
  mpCallback(error, responseCode, responseData, nil, responseHeaders);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  NSString* responseDataAsString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
 
  // Trim-off any whitespace!
  NSString *trimmedResponse = [responseDataAsString stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  // Finally - report the response.
  mpCallback(nil, responseCode, responseData, trimmedResponse, responseHeaders);
  
  [self endTask];
}

+(void) fireURLRequest:(NSString*)urlString InjectDictionaryIntoHeader:(NSDictionary*)injectDictionaryIntoHeader Callback:(SKQueryCompleted)callback WithTimeout:(NSTimeInterval)timeout {
  (void)[[SKNSURLAsyncQuery alloc] initWithURLRequest:urlString InjectDictionaryIntoHeader:injectDictionaryIntoHeader Callback:callback WithTimeout:timeout];
}

+(void) fireURLRequest:(NSString*)urlString InjectDictionaryIntoHeader:(NSDictionary*)injectDictionaryIntoHeader Callback:(SKQueryCompleted)callback {
  (void)[[SKNSURLAsyncQuery alloc] initWithURLRequest:urlString InjectDictionaryIntoHeader:injectDictionaryIntoHeader Callback:callback WithTimeout:60.0];
}

+(void) fireURLRequest:(NSString*)urlString InjectDictionaryIntoHeader:(NSDictionary*)injectDictionaryIntoHeader JsonCallback:(SKQueryCompletedWithJsonDictionary)callback WithTimeout:(NSTimeInterval)timeout {
  (void)[[SKNSURLAsyncQuery alloc] initWithURLRequest:urlString InjectDictionaryIntoHeader:injectDictionaryIntoHeader Callback:^(NSError *error, NSInteger responseCode, NSMutableData *responseData, NSString *responseDataAsString, NSDictionary *responseHeaders) {
    
    if (responseCode == 200)
    {
      NSError *error = nil;
      NSDictionary *theObject = [NSJSONSerialization JSONObjectWithData:responseData
                                                                options:NSJSONReadingMutableLeaves
                                                                  error:&error];
#ifdef DEBUG
      NSLog(@"DEBUG: postResultsJsonToServer - resultDictionaryFromJson=%@", theObject);
#endif // DEBUG
      callback(error, responseCode, theObject,  responseHeaders);
    } else {
      callback(nil, responseCode, nil,  responseHeaders);
    }
    
  } WithTimeout:timeout];
}

+(void) fireURLRequest:(NSString*)urlString InjectDictionaryIntoHeader:(NSDictionary*)injectDictionaryIntoHeader JsonCallback:(SKQueryCompletedWithJsonDictionary)callback {
  [SKNSURLAsyncQuery fireURLRequest:urlString InjectDictionaryIntoHeader:injectDictionaryIntoHeader JsonCallback:callback WithTimeout:60.0];
}

@end
