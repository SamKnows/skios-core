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

@implementation SKJPassiveServerUploadTest

- (instancetype)initWithParamArray:(NSArray*)params
{
  self = [super initWithParamArray:params];
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

-(int) getWarmupBytesPerSecond {
  return 100; // TODO!
}
-(int) getTransferBytesPerSecond {
  return 100; // TODO!
}
-(BOOL) isWarmupDone:(int)byteCount {
  return YES; // TODO!
}
-(BOOL) isTransferDone:(int)byteCount {
  return YES; // TODO!
}

-(BOOL) transmitToSocket:(GCDAsyncSocket *)socket ThreadIndex:(int) threadIndex IsWarmup:(BOOL)isWarmup {

  SKJRetIntBlock bytesPerSecond = nil;																			/* Generic method returning the current average speed across all thread  since thread started */
  SKJRetBoolBlock transmissionDone = nil;																			/* Generic method returning the transmission state */
  
  if (isWarmup) {
    // If warmup mode is active
    bytesPerSecond = ^{
      return [self getWarmupBytesPerSecond];
    };
    transmissionDone = ^(){
      return [self isWarmupDone:(int)super.buff.length];
    };
  } else {
    // If transmission mode is active
    bytesPerSecond = ^ {
      return [self getTransferBytesPerSecond];
    };
    transmissionDone = ^() {
      return [self isTransferDone:(int)super.buff.length];
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
  
  @try {
    NSData *headerByteArray = [self getPostHeaderRequestStringAsByteArray:threadIndex];
    if (headerByteArray.length > 0) {
      //SKLogger.d(this, "transmit() header write() ... thread:" + threadIndex);
      [socket writeData:headerByteArray withTimeout:-1.0 tag:0];
      //connOut.flush();
    }
    
    do {
//      if (connOut == null) {
//        break;
//      }
      
      // Write buffer to output socket
      //SKLogger.d(this, "transmit() calling write() ... thread:" + threadIndex);
      [socket writeData:super.buff withTimeout:-1.0 tag:0];
      //connOut.flush();
      
      if (bytesPerSecond() >= 0) {
        // -1 would mean no result found (as not enough time yet spent measuring)
        sSetLatestSpeedForExternalMonitorInterval(extMonitorUpdateInterval, "runUp1Normal", bytesPerSecond);
      }
      
      //// DEBUG TESTING!
      //throw new SocketException();
      // break; // DEBUG force effective error, just one buffer!
      
      //SKLogger.e(TAG(this), "DEBUG: speed in bytes per second" + getSpeedBytesPerSecond() + "<<<");
      //SKLogger.e(TAG(this), "DEBUG: isTransferDone=" + isTransferDone + ", totalTransferBytesSent=>>>" + getTotalTransferBytes() + ", time" + (sGetMicroTime() - start) + "<<<");
    } while (!transmissionDone.call());
    
  } @catch (NSException *e) {
    NSLog("Exception in setting up output stream, exiting... thread: %d, %@", threadIndex, e);
    
    // EXCEPTION: RECORD ERROR, AND SET BYTES TO 0!!!
    resetTotalTransferBytesToZero();
    error.set(true);
    
    // Verify thta we've set everything to zero properly!
    SK_ASSERT(getTotalTransferBytes() == 0L);
    try {
      SK_ASSERT(bytesPerSecond.call() == 0);
    } catch (Exception e1) {
      SK_ASSERT(false);
    }
    int bytesPerSecondMeasurement = Math.max(0, getTransferBytesPerSecond());
    SK_ASSERT(bytesPerSecondMeasurement == 0);
    
    sSetLatestSpeedForExternalMonitorInterval(extMonitorUpdateInterval, "runUp1Err", bytesPerSecond);
    //SKLogger.e(TAG(this), "loop - break 3");//haha
    return false;
  }
  
  //
  // If only 1 buffer "SENT": treat this as an error...
  //
  long btsTotal = getTotalTransferBytes();
  if (btsTotal == buff.length) {
    // ONLY 1 BUFFER "SENT": TREAT THIS AS AN ERROR, AND SET BYTES TO 0!!!
    SKLogger.e(this, "Only one buffer sent - treat this as an upload failure");
    resetTotalTransferBytesToZero();
    error.set(true);
    
    // Verify thta we've set everything to zero properly!
    SK_ASSERT(getTotalTransferBytes() == 0L);
    @try {
      SK_ASSERT(bytesPerSecond.call() == 0);
    } @catch (NSException *e1) {
      SK_ASSERT(false);
    }
    int bytesPerSecondMeasurement = Math.max(0, getTransferBytesPerSecond());
    SK_ASSERT(bytesPerSecondMeasurement == 0);
    return false;
  }
  
  //
  // To get here, the test ran OK!
  //
  int bytesPerSecondMeasurement = max(0, getTransferBytesPerSecond());
  SK_ASSERT(bytesPerSecondMeasurement >= 0);
  //hahaSKLogger.e(TAG(this), "Result is from the BUILT-IN MEASUREMENT, bytesPerSecondMeasurement= " + bytesPerSecondMeasurement + " thread: " + threadIndex);
  
  sSetLatestSpeedForExternalMonitor(bytesPerSecondMeasurement, cReasonUploadEnd);											/* Final external interface set up */
  
  //    if (connIn != null) {
  //      try {
  //        connIn.close();
  //      } catch (Exception e) {
  //        SK_ASSERT(false);
  //      }
  //    }
  
  return true;
}

@Override
protected boolean warmup(Socket socket, int threadIndex) {
  //SKLogger.d(this, "PassiveServerUploadTest, warmup()... thread: " + threadIndex);
  
  boolean isWarmup = true;
  boolean result = false;
  
  result = transmit(socket, threadIndex, isWarmup);
  
  if (error.get()) {
    // Warm up might have set a global error
    //SKLogger.e(TAG(this), "WarmUp Exits: Result FALSE, totalWarmUpBytes=>>> " + getTotalWarmUpBytes());//haha remove in production
    return false;
  }
  return result;
}

@Override
protected boolean transfer(Socket socket, int threadIndex) {
  //SKLogger.d(this, "PassiveServerUploadTest, transfer()... thread: " + threadIndex);
  
  boolean isWarmup = false;
  return transmit(socket, threadIndex, isWarmup);
}
}

@end
