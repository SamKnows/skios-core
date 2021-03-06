//
//  SKJPassiveServerUploadTest.m
//  SKCore
//
//  Created by Pete Cole on 05/06/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//
// This file is a direct port from PassiveServerUploadTest.java
//

#import "SKJPassiveServerUploadTest.h"

const int extMonitorUpdateInterval = 500000;

@implementation SKJPassiveServerUploadTest

- (instancetype)initWithParams:(NSDictionary*)params
{
  self = [super initWithParams:params];
  if (self) {
  }
  return self;
}

-(NSString*) formPostHeaderRequestString:(int) threadIndex {
  NSMutableString *sb = [NSMutableString new];
 
  [sb appendString:[NSString stringWithFormat:@"POST /?UPTESTV1=%d HTTP/1.1\r\n", threadIndex]];
  [sb appendString:@"Host: "];
  [sb appendString:[NSString stringWithFormat:@"%@:%d\r\n", super.target, super.port]];
  [sb appendString:@"User-Agent: SamKnows HTTP Client 1.1(2)\r\n"];
  [sb appendString:@"Accept: */*\r\n"];
  [sb appendString:@"Content-Length: 4294967295\r\n"];
  [sb appendString:@"Content-Type: application/octet-stream\r\n"];
  [sb appendString:@"Expect: 100-continue\r\n"];
  [sb appendString:@"\r\n"];
  
  return sb;
}

-(NSData*) getPostHeaderRequestStringAsByteArray:(int) threadIndex {
  NSString *theString = [self formPostHeaderRequestString:threadIndex];
  return [theString dataUsingEncoding:NSUTF8StringEncoding];
}

-(BOOL) transmitToSocket:(int)sockfd ThreadIndex:(int) threadIndex IsWarmup:(BOOL)isWarmup {

  SKJRetIntBlock bytesPerSecond = nil;																			/* Generic method returning the current average speed across all thread  since thread started */
  SKJRetBoolBlock transmissionDone = nil;																			/* Generic method returning the transmission state */
  
  if (isWarmup) {
    // If warmup mode is active
    bytesPerSecond = ^{
      return [super getWarmupBytesPerSecond];
    };
    transmissionDone = ^{
      if ([self getShouldCancel]) {
#ifdef DEBUG
       NSLog(@"DEBUG: SKJPassiveServerUploadTest - getTransmissionDone - warmup - cancel test!");
#endif // DEBUG
        return YES;
      }
      return [super isWarmupDone:(int)[super getBufferLength]];
    };
  } else {
    // If transmission mode is active
    bytesPerSecond = ^ {
      return [self getTransferBytesPerSecond];
    };
    transmissionDone = ^() {
      if ([self getShouldCancel]) {
#ifdef DEBUG
       NSLog(@"DEBUG: SKJPassiveServerUploadTest - getTransmissionDone - main loop - cancel test!");
#endif // DEBUG
        return YES;
      }
      return [super isTransferDone:(int)[super getBufferLength]];
    };
  }
  
  // Access output stream
//  OutputStream connOut = getOutput(socket);
//  
//  if (connOut == null) {
//    closeConnection(socket);
//    SKLogger.e(this, "Error in setting up output stream, exiting... thread: " + threadIndex);
//    return false;
//  }
  
  bool bSuccess = YES;
  
  @try {
    NSData *headerByteArray = [self getPostHeaderRequestStringAsByteArray:threadIndex];
    if (headerByteArray.length > 0) {
      //SKLogger.d(this, "transmit() header write() ... thread:" + threadIndex);
      write(sockfd, headerByteArray.bytes, headerByteArray.length);
      //connOut.flush();
    }
    
    do {
//      if (connOut == null) {
//        break;
//      }
      
      // Write buffer to output socket
      //NSLog(@"transmit() calling write() with %d bytes, threadIndex=%d", (int)[super getBufferLength], threadIndex);
      NSMutableData *theData = [super getBufferWithOptionalRandomize];
      ssize_t res = write(sockfd, theData.bytes, theData.length);
      if (res != theData.length) {
        bSuccess = NO;
        
#ifdef _DEBUG
        int testError = errno;
        SK_ASSERT(testError != 0);
        NSLog(@"Error in stream write (%d), exiting... thread: %d",, testError, threadIndex);
        SK_ASSERT(false);
#endif // DEBUG
        
        break;
      }
      
      //NSLog(@"transmit() called write() with %d bytes, threadIndex=%d", (int)[super getBufferLength], threadIndex);
      //connOut.flush();
      
      if (bytesPerSecond() >= 0) {
        // -1 would mean no result found (as not enough time yet spent measuring)
        [super sSetLatestSpeedForExternalMonitorInterval:extMonitorUpdateInterval InId:@"runUp1Normal" TransferCallback:bytesPerSecond];
      }
      
      //// DEBUG TESTING!
      //throw new SocketException();
      // break; // DEBUG force effective error, just one buffer!
      
      //SKLogger.e(TAG(this), "DEBUG: speed in bytes per second" + getSpeedBytesPerSecond() + "<<<");
      //SKLogger.e(TAG(this), "DEBUG: isTransferDone=" + isTransferDone + ", totalTransferBytesSent=>>>" + getTotalTransferBytes() + ", time" + (sGetMicroTime() - start) + "<<<");
    } while (!transmissionDone());
    
  } @catch (NSException *e) {
    // EXCEPTION: RECORD ERROR, AND SET BYTES TO 0!!!
#ifdef DEBUG
    NSLog(@"Exception in setting up output stream, exiting... thread: %d, %@", threadIndex, e);
    SK_ASSERT(false);
#endif // DEBUG
    bSuccess = NO;
  }
  
  if (bSuccess == NO) {
    // ERROR, AND SET BYTES TO 0!!!
    [super resetTotalTransferBytesToZero];
    [super setError:@"?"]; //super.mError = true;
    
    // Verify thta we've set everything to zero properly!
    SK_ASSERT([super getTotalTransferBytes] == 0L);
    @try {
      if (isWarmup == NO) {
        SK_ASSERT(bytesPerSecond() == 0);
      }
    } @catch (NSException *e1) {
      SK_ASSERT(false);
    }
#ifdef DEBUG
    int bytesPerSecondMeasurement = MAX(0, [super getTransferBytesPerSecond]);
    SK_ASSERT(bytesPerSecondMeasurement == 0);
#endif // DEBUG
    
    [super sSetLatestSpeedForExternalMonitorInterval:extMonitorUpdateInterval InId:@"runUp1Err" TransferCallback:bytesPerSecond];
    //SKLogger.e(TAG(this), "loop - break 3");
    return false;
  }
  
  //
  // If only 1 buffer "SENT": treat this as an error...
  //
  if (isWarmup == NO) {
    long btsTotal = [super getTotalTransferBytes];
    if (btsTotal == [super getBufferLength]) {
      // ONLY 1 BUFFER "SENT": TREAT THIS AS AN ERROR, AND SET BYTES TO 0!!!
      SK_ASSERT(false); // .e(this, "Only one buffer sent - treat this as an upload failure");
      [super resetTotalTransferBytesToZero];
      [super setError:@"?"]; //super.mError = true;
      
      // Verify thta we've set everything to zero properly!
      SK_ASSERT([super getTotalTransferBytes] == 0L);
      @try {
        SK_ASSERT(bytesPerSecond() == 0);
      } @catch (NSException *e1) {
        SK_ASSERT(false);
      }
#ifdef DEBUG
      int bytesPerSecondMeasurement = MAX(0, [super getTransferBytesPerSecond]);
      SK_ASSERT(bytesPerSecondMeasurement == 0);
#endif // DEBUG
      return false;
    }
    
    //
    // To get here, the test ran OK!
    //
    int bytesPerSecondMeasurement = MAX(0, [self getTransferBytesPerSecond]);
    SK_ASSERT(bytesPerSecondMeasurement >= 0);
    //SKLogger.e(TAG(this), "Result is from the BUILT-IN MEASUREMENT, bytesPerSecondMeasurement= " + bytesPerSecondMeasurement + " thread: " + threadIndex);
    
    [super.class sSetLatestSpeedForExternalMonitorBytesPerSecond:bytesPerSecondMeasurement TestId:cReasonUploadEnd];											/* Final external interface set up */
  }
  
  //    if (connIn != null) {
  //      try {
  //        connIn.close();
  //      } catch (Exception e) {
  //        SK_ASSERT(false);
  //      }
  //    }
  
  return true;
}

-(BOOL) warmupToSocket:(int)sockfd ThreadIndex:(int)threadIndex {		/* Generate initial traffic for setting optimal TCP parameters */
#ifdef DEBUG
  NSLog(@"*** DEBUG: PassiveServerUploadTest, warmup()... thread: %d", threadIndex);
#endif // DEBUG
  
  BOOL isWarmup = true;
  BOOL result = false;
  
  result = [self transmitToSocket:sockfd ThreadIndex:threadIndex IsWarmup:isWarmup];
  
  if ([super getError]) {
    // Warm up might have set a global error
#ifdef DEBUG
    NSLog(@"*** DEBUG: WARNING: WarmUp Exits: Result FALSE, totalWarmUpBytes=%d", (int)[self getTotalWarmUpBytes]);
#endif // DEBUG
    //SK_ASSERT(false);
    return false;
  }
  return result;
}

-(BOOL) transferToSocket:(int)sockfd ThreadIndex:(int)threadIndex {
  //SKLogger.d(this, "PassiveServerUploadTest, transfer()... thread: " + threadIndex);
  
  BOOL isWarmupFalse = false;
  return [self transmitToSocket:sockfd ThreadIndex:threadIndex IsWarmup:isWarmupFalse];
}

static BOOL sbTestIsRunning = NO;

-(void) execute {
  
  sbTestIsRunning = YES;
  [super execute];
  sbTestIsRunning = NO;
}

+(BOOL) sGetTestIsRunning {
  return sbTestIsRunning;
}

@end
