//
//  SKJUploadTest.m
//  SKCore
//
//  Created by Pete Cole on 05/06/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//
// This file is a direct port from UploadTest.java
//

#import "SKJUploadTest.h"

@implementation SKJUploadTest

@synthesize bitrateMpbs1024Based;
@synthesize buff;

- (instancetype)initWithParams:(NSDictionary*)params
{
  self = [super initWithDirection:_UPSTREAM Parameters:params];
  if (self) {
    bitrateMpbs1024Based = -1.0;
    buff = nil;
    
    // Always enable data buffer randomization by default...
    self.randomEnabled = YES;
    
    arc4random_stir();
    
    [self doInit];
  }
  return self;
}

-(NSUInteger) getBufferLength {
  return buff.length;
}

-(NSMutableData*) getBufferDoNotRandomize {
  return buff;
}

-(NSMutableData*) getBufferWithOptionalRandomize {
  if (self.randomEnabled == YES) {
    // Randomize it!
    void *theData = self.buff.mutableBytes;
    
    //int *theDataInt = (int*)theData;
    //NSLog(@"PRE! theDataInt[0]=%d", theDataInt[0]);

    int theLength = self.buff.length;
    arc4random_buf(theData, theLength);
    
    //NSLog(@"POST theDataInt[0]=%d", theDataInt[0]);
  }
  return buff;
}


//private String[] formValuesArr()
-(NSArray*) formValuesArr {
  NSMutableArray *values = [NSMutableArray new];
  [values addObject:[NSString stringWithFormat:@"%.2d", (MAX(0,[super getTransferBytesPerSecond]) * 8 / 1000000)]];
    
  return values;
}
  
-(void) doInit {											/* don't forget to check error state after this method */
  /* getSocket() is a method from the parent class */
  const int maxSendDataChunkSize = 32768;
  
  // Generate this value in case we need it.
  // It is a random value from [0...2^32-1]
  // TODO? Random sRandom = new Random();								/* Used for initialisation of upload array */
  
  if ( super.uploadBufferSize > 0 &&  super.uploadBufferSize <= maxSendDataChunkSize){
    buff = [[NSMutableData alloc] initWithLength:self.uploadBufferSize];
  }
  else{
    buff = [[NSMutableData alloc] initWithLength:maxSendDataChunkSize];
    SK_ASSERT(false);
  }
}
  
-(NSString*) getStringID {
  NSString *ret = @"";
  if ([self getThreadsNum] == 1) {
    ret = UPSTREAMSINGLE;
  } else {
    ret = UPSTREAMMULTI;
  }
  return ret;
}
  
-(int) getNetUsage {
  return (int)([self getTotalTransferBytes] + [self getTotalWarmUpBytes]);
}

// TODO
//HashMap<String,String> HashMap<String, String> getResults()
//-(NSMutableDictionary*) getResults {
//  //HashMap<String, String> ret = new HashMap<String, String>();
//  NSMutableDictionary *ret = [NSMutableDictionary new];
//  if (![super.testStatus isEqualToString:@"FAIL"]) {
//    String[] values = formValuesArr();
//    ret.put("upspeed", values[0]);
//  }
//  return ret;
//}

-(BOOL) isReady {
  [super isReady];
  
  if (super.uploadBufferSize == 0 || super.postDataLength == 0) {
    [super setError:@"Upload parameter missing"];
    return false;
  }
  
  return true;
}

// This is never used!
//-(NSString*) getHumanReadableResult {
//  String ret = "";
//  String direction = "upload";
//  String type = getThreadsNum() == 1 ? "single connection" : "multiple connection";
//  if (testStatus.equals("FAIL")) {
//    ret = String.format("The %s has failed.", direction);
//  } else {
//    ret = String.format(Locale.UK,"The %s %s test achieved %.2f Mbps.", type, direction, (Math.max(0, getTransferBytesPerSecond()) * 8d / 1000000));
//  }
//  return ret;
//}


/*	@Override
 public String getResultsAsString(){							 New Human readable implementation
	if (testStatus.equals("FAIL")){
 return "";
	}else{
 String[] values = formValuesArr();
 return String.format(Locale.UK, values[0]);
	}
 }*/
/*	@Override
 public String getResults(String locale){			 New Human readable implementation
	if (testStatus.equals("FAIL")){
 return locale;
	}else{
 String[] values = formValuesArr();
 return String.format(locale, values[0]);
	}
 }*/


/*public class HumanReadable {
 public TEST_STRING testString;
 public String[] values;
 
 public String getString(String locale) {
	switch (testString) {
	case DOWNLOAD_SINGLE_SUCCESS:
	case DOWNLOAD_MULTI_SUCCESS:
	case UPLOAD_SINGLE_SUCCESS:
	case UPLOAD_MULTI_SUCCESS:
 return String.format(locale, values[0]);
	case LATENCY_SUCCESS:
 return String.format(locale, values[0], values[1], values[2]);
	case DOWNLOAD_FAILED:
	case UPLOAD_FAILED:
	case LATENCY_FAILED:
 return locale;
	case NONE:
 return "";
	}
	return "";
 }
 
 public HashMap<String, String> getValues() {
	HashMap<String, String> ret = new HashMap<String, String>();
	switch (testString) {
	case DOWNLOAD_SINGLE_SUCCESS:
	case DOWNLOAD_MULTI_SUCCESS:
 ret.put("downspeed", values[0]);
 break;
	case UPLOAD_SINGLE_SUCCESS:
	case UPLOAD_MULTI_SUCCESS:
 ret.put("upspeed", values[0]);
 break;
	case LATENCY_SUCCESS:
 ret.put("latency", values[0]);
 ret.put("packetloss", values[1]);
 ret.put("jitter", values[2]);
 break;
	default:
	}
	return ret;
 }
 }*/

@end
