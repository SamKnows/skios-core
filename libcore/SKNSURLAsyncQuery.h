//
//  SKNSURLAsyncQuery.h
//

#import <Foundation/Foundation.h>

// This class implements the basic creation of a NSMutableURLRequest within a task,
// the submission of that request, and the handling of the NSURLConnectionDelegate calls.

// If error is nil, there was no error.
typedef void (^SKQueryCompleted)(NSError *error, NSInteger responseCode, NSMutableData *responseData, NSString *responseDataAsString, NSDictionary *responseHeaders);
typedef void (^SKQueryCompletedWithJsonDictionary)(NSError *error, NSInteger responseCode, NSDictionary *jsonResponse,  NSDictionary *responseHeaders);

@interface SKNSURLAsyncQuery : NSObject<NSURLConnectionDelegate>

@property NSTimeInterval mTimeout;

+(void) fireURLRequest:(NSString*)urlString InjectDictionaryIntoHeader:(NSDictionary*)injectDictionaryIntoHeader Callback:(SKQueryCompleted)callback;
+(void) fireURLRequest:(NSString*)urlString InjectDictionaryIntoHeader:(NSDictionary*)injectDictionaryIntoHeader Callback:(SKQueryCompleted)callback WithTimeout:(NSTimeInterval)timeout;
+(void) fireURLRequest:(NSString*)urlString InjectDictionaryIntoHeader:(NSDictionary*)injectDictionaryIntoHeader JsonCallback:(SKQueryCompletedWithJsonDictionary)callback;
+(void) fireURLRequest:(NSString*)urlString InjectDictionaryIntoHeader:(NSDictionary*)injectDictionaryIntoHeader JsonCallback:(SKQueryCompletedWithJsonDictionary)callback WithTimeout:(NSTimeInterval)timeout;

@end
