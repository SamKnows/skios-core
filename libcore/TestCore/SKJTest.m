//
//  SKJTest.m
//  SKCore
//
//  Created by Pete Cole on 05/06/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//
// This file is a direct port from Test.java
//

#import "SKJTest.h"

@interface SKJTest ()
//private String[] outputFields = null;
@property NSArray *outputFields;
//private String errorString = "";
@property NSString *errorString;
//private JSONObject json_output = null;
@property BOOL mbShouldCancel;
@end

@implementation SKJTest

@synthesize outputFields;
@synthesize errorString;
@synthesize status;
@synthesize mbShouldCancel;

- (instancetype)init
{
  self = [super init];
  if (self) {
    outputFields = nil;
    errorString = @"";
    status = WAITING;
    mbShouldCancel = false;
  }
  return self;
}

//
// "Abstract" methods...
//

-(void) execute {
  SK_ASSERT(false);
  // TODO!
  return;
}

-(NSString*) getStringID {
  SK_ASSERT(false);
  // TODO!
  return @"";
}

-(BOOL) isSuccessful {
  SK_ASSERT(false);
  // TODO!
  return NO;
}

-(void) run {
  SK_ASSERT(false);
  // TODO!
  return;
}

-(NSString*) getHumanReadableResult {
  SK_ASSERT(false);
  // TODO!
  return @"";
}

//abstract public HashMap<String, String> getResults();
-(NSDictionary*) getResults {
  SK_ASSERT(false);
  // TODO!
  return nil;
}

-(BOOL) isProgressAvailable {
  SK_ASSERT(false);
  // TODO!
  return NO;
}

-(int)  getProgress { 										/* from 0 to 100 */
  SK_ASSERT(false);
  // TODO!
  return 0;
}

-(int) getNetUsage {												/* Total number of bytes transfered */
  SK_ASSERT(false);
  // TODO!
  return 0;
}

-(BOOL) isReady {												/* Test sanity checker. Virtual */
  SK_ASSERT(false);
  // TODO!
  return NO;
}

-(void) setOutput:(NSString*) o {
  outputFields = @[o];
}

// TODO public JSONObject getJSONResult(){ 							return json_output; 	}
// TODO void setJSONResult(Map<String, Object> output){ 	json_output = new JSONObject(output);	}

-(long) unixTimeStamp {
		return (long)([NSDate timeIntervalSinceReferenceDate] * 1000.0);
}


-(void) start {
  status = RUNNING;
}

-(void) finish {
		status = DONE;
}

-(NSString*) getOutputField:(int) i {
		
		if (i >= outputFields.count) {
      SK_ASSERT(false);
      return @"";
    }
		
		NSString *result = outputFields[i];
		
		if (result == nil) {
      SK_ASSERT(false);
      return @"";
    }
		
		return result;
}

//public String[] getOutputFields() { 		return outputFields;		}
//public String getOutputString() {
//		if (null == outputFields) {
//      return "";
//    }
//		return getOutputString(";");
//}
//public String getOutputString(String d) {
//		String ret = "";
//		if (outputFields == null) {
//      return ret;
//    }
//		StringBuilder sb = new StringBuilder();
//		for (int i = 0; i < outputFields.length - 1; i++) {
//      sb.append(outputFields[i] + d);
//    }
//		sb.append(outputFields[outputFields.length - 1]);
//		return sb.toString();
//}

-(BOOL) setErrorIfEmpty:(NSString*) error Exception:(NSException *)e {
		NSString *exErr = e.description;
		return [self setErrorIfEmpty:[NSString stringWithFormat:@"%@ %@", error, exErr]];
}

-(BOOL) setErrorIfEmpty:(NSString *)error {
		BOOL ret = false;
		@synchronized (errorString) {
#ifdef DEBUG
      NSLog(@"DEBUG: WARNING: setErrorIfEmpty=%@", errorString);
#endif // DEBUG
      if (errorString.length == 0) {
        errorString = error;
        ret = true;
      }
    }
		return ret;
}

-(void) setError:(NSString*) error {
		@synchronized (errorString) {
      errorString = error;
#ifdef DEBUG
      NSLog(@"DEBUG: WARNING: setError1=%@", errorString);
#endif // DEBUG
    }
}

#pragma mark Test Cancel control (begin)
// The SKJPassiveServerUploadTest class detect this stage and allow quick Cancelling of the test
// even while it is running.
// Other implementations of SJKTest do not yet support this approach.

-(BOOL) getShouldCancel {
		return mbShouldCancel;
}

-(void) setShouldCancel {
		mbShouldCancel = true;
}

#pragma mark Test Cancel control (end)

@end
