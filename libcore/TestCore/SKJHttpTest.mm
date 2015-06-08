//
//  SKJHttpTest.m
//  SKCore
//
//  Created by Pete Cole on 05/06/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//
// This file is a direct port from HttpTest.java
//

// STL C++ includes
#include <string>
using namespace::std;
#include <iostream>
#include <sstream>
#include <stack>
#include <vector>
#include <list>
#include <deque>
#include <utility>
#include <map>
#include <queue>
#include <algorithm>
#include <memory>
#include <thread>
#include <iostream>
#include <utility>
#include <chrono>
#include <functional>
#include <atomic>

#import "SKJHttpTest.h"

@interface SKJHttpTest()
//private Thread[] mThreads = null;										/* Array of all running threads */
@property std::vector<std::thread*> *mThreads;
/*
 * Atomic variables used as aggregate counters or (errors, etc. ) indicators updated from concurrently running threads
 */
@property std::atomic_long *totalWarmUpBytes;
@property std::atomic_long *totalTransferBytes;
@property std::atomic_bool *mError;
@property NSString *infoString;
@property NSString *ipAddress;

//boolean warmUpDone;

// warmup variables
@property std::atomic_long *mStartWarmupMicro;												/* Point in time when warm up process starts, uSecs */
@property std::atomic_long *mWarmupMicroDuration;											/* Total duration of warm up period, uSecs */
@property std::atomic_long *mWarmupTimeMicro;												/* Time elapsed since warm up process started, uSecs */
@property std::atomic_int *warmupDoneCounter;											/* Counter shows how many threads completed warm up process */
@property long mWarmupMaxTimeMicro;																	/* Max time warm up is allowed to continue, uSecs */
@property int mWarmupMaxBytes;																		/* Max bytes warm up is allowed to send */


// transfer variables
@property std::atomic_long *mStartTransferMicro;												/* Point in time when transfer process starts, uSecs */
@property std::atomic_long *mTransferMicroDuration;											/* Total duration of transfer period, uSecs */
@property std::atomic_long *transferTimeMicroseconds;										/* Time elapsed since transfer process started, uSecs */
@property std::atomic_int  *transferDoneCounter;										/* Counter shows how many threads completed trnasfer process */
@property long mTransferMaxTimeMicro;																/* Max time transfer is allowed to continue, uSecs*/
@property  int mTransferMaxBytes;																	/* Max bytes transfer is allowed to send */

//external monitor variables
@property std::atomic_long *timeElapsedSinceLastExternalMonitorUpdate;						/* Time elapsed since external monitor counter was updated last time, uSecs */

// Various HTTP tests variables
@property int nThreads;																					/* Number of send/receive threads */

//various buffers
@property int downloadBufferSize;
@property int desiredReceiveBufferSize;
@property int socketBufferSize;

//private int connectionCounter;
@property int receiveBufferSize;
@property int sendBufferSize;

@property BOOL noDelay;

@property NSString *testStatus;																	/* Test status, could be 'OK' or 'FAIL' */

// Connection variables
@property NSString *file;
@property UploadStrategy uploadStrategyServerBased;							/* Upload type selection strategy: simple upload or with server side measurements */

@property BOOL downstream;

@end

@implementation SKJHttpTest

@synthesize mThreads;

/*
 NOTES: See also https://svn.samknows.com/svn/tests/http_server/trunk/docs/protocol.txt ... where the protocol
 for the new service is defined.
 
 create socket
 connect
 
 ** Start by trying to do this in JUST ONE THREAD! **
 
 boolean bQuit = false
 
 Thread 1:
 write header :
 Example header as follows:
 */

//  POST /?CONTROL=1&UNITID=1&SESSIONID=281541010&NUM_CONNECTIONS=2&CONNECTION=1&AGGREGATE_WARMUP=0&RESULTS_INTERVAL_PERIOD=10&RESULT_NUM_INTERVALS=1&TEST_DATA_CAP=4294967295&TRANSFER_MAX_SIZE=4294967295&WARMUP_SAMPLE_TIME=5000&NUM_WARMUP_SAMPLES=1&MAX_WARMUP_SIZE=4294967295&MAX_WARMUP_SAMPLES=1&WARMUP_FAIL_ON_MAX=0&WARMUP_TOLERANCE=5 HTTP/1.1
//  Host: n1-the1.samknows.com:6500
//  Accept: */*
//  Content-Length: 4294967295
//  Content-Type: application/x-www-form-urlencoded
//  Expect: 100-continue

/*
 }
 
 The server expects a query string with a "CONTROL" field. It's value should be set to "1.0", which specifies the version of the protocol.
 
 - UNITID
 Mandatory.
 
 - SESSIONID
 Mandatory.
 
 - NUM_CONNECTIONS
 Mandatory.
 
 - CONNECTION
 Mandatory.
 
 - WARMUP_SAMPLE_TIME
 Mandatory for POST requests.
 
 - NUM_WARMUP_SAMPLES
 Mandatory for POST requests.
 
 - MAX_WARMUP_SAMPLES
 Mandatory for POST requests.
 
 - WARMUP_TOLERANCE
 Mandatory for POST requests.
 
 - RESULTS_INTERVAL_PERIOD
 Mandatory for POST requests.
 
 - RESULT_NUM_INTERVALS
 Mandatory for POST requests.
 
 - AGGREGATE_WARMUP
 Optional. Default: false.
 
 - TEST_DATA_CAP
 Optional. Default: no limit.
 
 - TRANSFER_MAX_SIZE
 Optional. Default: no limit.
 
 - MAX_WARMUP_SIZE
 Optional. Default: no limit.
 
 - WARMUP_FAIL_ON_MAX
 Optional. Default: false.
 
 - TRACE_INTERVAL
 Optional. Default: no tracing.
 
 - TCP_CONG
 Optional. Default: server system default.
 
 The values must be sent to the server (e.g TEST_DATA_CAP).
 Once the server reaches the limits it will send the result up to that point.
 This makes the limit "maximum bytes to *RECEIVE*".
 To keep it as "maximum bytes to *SENT*" you could keep your own counter
 and close the connection when you have sent a fixed amount of bytes...
 }
 while (bQuit == false) {
 write(socket, buffer...)
 }
 
 Thread 2:
 while (bQuit == false) {
 if (read (socket, intobuffer, timeout)) succeeds:
 {
 Extract upload speed results from server response, which will be in this format:
 SAMKNOWS_HTTP_REPLY\n
 VERSION: <major>.<minor>\n
 RESULT: <OK|FAIL>\n
 END_TIME: <end time>
 SECTION: WARMUP\n
 NUM_WARMUP: <num>\n
 WARMUP_SESSION <seconds> <nanoseconds> <bytes>\n
 WARMUP_SESSION <seconds> <nanoseconds> <bytes>\n
 SECTION: MEASUR\n
 NUM_MEASUR: <num>\n
 MEASUR_SESSION <seconds> <nanoseconds> <bytes>\n
 MEASUR_SESSION <seconds> <nanoseconds> <bytes>\n
 
 In terms of sample data etc., the server will give you something like this:
 ...
 NUM_MEASUR: 2\n
 MEASUR_SESSION 5 0 5000000\n
 MEASUR_SESSION 10 0 15000000\n
 ...
 ... It's the client job to calculate that during the first five seconds the speed has been 5,000,000 / 5 = 1,000,000 bytes/sec; and during the next 10 seconds 15,000,000 / 10 = 1,500,000 bytes/sec. Meaning that the speed between seconds 5 and 10 has been (15,000,000 - 5,000,000) / (10 - 5) = 2,000,000 bytes/sec.
 ... send this "final upload speed result value from the server" to the application.
 bQuit = true;
 }
 }
 */

/* Abstract methods to be implemented in derived classes */
-(BOOL) transferToSocket:(GCDAsyncSocket*)socket ThreadIndex:(int)threadIndex {	/* Generate main traffic for metrics measurements */
  SK_ASSERT(NO);
  return NO;
}

-(BOOL) warmupToSocket:(GCDAsyncSocket*)socket ThreadIndex:(int)threadIndex {		/* Generate initial traffic for setting optimal TCP parameters */
  SK_ASSERT(NO);
  return NO;
}

//protected abstract int getWarmupBytesPerSecond();						/* Initial traffic speed */
//protected abstract int getTransferBytesPerSecond();						/* Main traffic speed */

/* Time helper functions */
+(long) sGetMicroTime {
  NSTimeInterval seconds = [NSDate timeIntervalSinceReferenceDate];
  long micro = (long)(seconds * 1000000.0);
  return micro;
}

+(long) sGetMilliTime {
  NSTimeInterval seconds = [NSDate timeIntervalSinceReferenceDate];
  long milli = (long)(seconds * 1000.0);
  return milli;
}

/* Constructor. Accepts list of Param objects, each representing a certain parameter read from settings XML file */
//  protected HttpTest(String direction, List<Param> params)
- (instancetype)initWithDirection:(NSString*)direction Parameters:(NSArray*)params
{
  self = [super init];
  if (self) {
    self.totalWarmUpBytes = new std::atomic_long(0);		/* Total num of bytes transmitted during warmup period */
    self.totalTransferBytes = new std::atomic_long(0);	/* Total num of bytes transmitted during trnasfer period */
    self.mError = new std::atomic_bool(false);						/* Global error indicator */
    
    self.infoString = @"";
    self.ipAddress = @"";
    
    self.randomEnabled = false;																			/* Upload buffer randomisation is required */
    //boolean warmUpDone = false;
    
    self.postDataLength = 0;
    
    // warmup variables
    self.mStartWarmupMicro = new std::atomic_long(0);												/* Point in time when warm up process starts, uSecs */
    self.mWarmupMicroDuration = new std::atomic_long(0);											/* Total duration of warm up period, uSecs */
    self.mWarmupTimeMicro = new std::atomic_long(0);												/* Time elapsed since warm up process started, uSecs */
    self.warmupDoneCounter = new std::atomic_int(0);											/* Counter shows how many threads completed warm up process */
    self.mWarmupMaxTimeMicro = 0;																	/* Max time warm up is allowed to continue, uSecs */
    self.mWarmupMaxBytes = 0;																		/* Max bytes warm up is allowed to send */
    
    
    // transfer variables
    self.mStartTransferMicro = new std::atomic_long(0);												/* Point in time when transfer process starts, uSecs */
    self.mTransferMicroDuration = new std::atomic_long(0);											/* Total duration of transfer period, uSecs */
    self.transferTimeMicroseconds = new std::atomic_long(0);										/* Time elapsed since transfer process started, uSecs */
    self.transferDoneCounter = new std::atomic_int(0);										/* Counter shows how many threads completed trnasfer process */
    self.mTransferMaxTimeMicro = 0;																/* Max time transfer is allowed to continue, uSecs*/
    self.mTransferMaxBytes = 0;																	/* Max bytes transfer is allowed to send */
    
    //external monitor variables
    self.timeElapsedSinceLastExternalMonitorUpdate = new std::atomic_long(0);						/* Time elapsed since external monitor counter was updated last time, uSecs */
    
    // Various HTTP tests variables
    self.nThreads = 0;																					/* Number of send/receive threads */
    
    //various buffers
    self.downloadBufferSize = 0;
    self.desiredReceiveBufferSize = 0;
    self.socketBufferSize = 0;
    self.uploadBufferSize = 0;
    
    //private int connectionCounter = 0;
    self.receiveBufferSize = 0;
    self.sendBufferSize = 0;
    
    self.noDelay = false;
    
    self.testStatus = @"FAIL";																	/* Test status, could be 'OK' or 'FAIL' */
    
    // Connection variables
    self.target = @"";
    self.file = @"";
    self.port = 0;
    self.uploadStrategyServerBased = PASSIVE;							/* Upload type selection strategy: simple upload or with server side measurements */
    
    self.downstream = true;
    
    mThreads = new std::vector<std::thread*>();
    
    [self setDirection:direction];											/* Legacy. To be removed */
    [self.class sLatestSpeedReset:(self.downstream ? cReasonResetDownload : cReasonResetUpload)];
    
    [self setParams:params];													/* Initialisation */
  }
  
  return self;
}

- (void)dealloc
{
  for (auto theThread : *self.mThreads) {
    delete theThread;
  }
  delete mThreads;
}

-(void) setParams:(NSArray*)params { // List<Param> params) /* Initialisation helper function */
  self.initialised = true;

  /*
   !!! TODO TODO TODO !!! TODO TODO TODO !!!
  try {
    for (Param param : params) {
      String value = param.getValue();
      if (param.contains(TARGET)) {
        target = value;
      } else if (param.contains(PORT)) {
        port = Integer.parseInt(value);
      } else if (param.contains(FILE)) {
        file = value;
      } else if (param.contains(WARMUPMAXTIME)) {
        mWarmupMaxTimeMicro = Integer.parseInt(value);
      } else if (param.contains(WARMUPMAXBYTES)) {
        mWarmupMaxBytes = Integer.parseInt(value);
      } else if (param.contains(TRANSFERMAXTIME)) {
        mTransferMaxTimeMicro = Integer.parseInt(value);
      } else if (param.contains(TRANSFERMAXBYTES)) {
        mTransferMaxBytes = Integer.parseInt(value);
      } else if (param.contains(NTHREADS)) {
        nThreads = Integer.parseInt(value);
      } else if (param.contains(UPLOADSTRATEGY)) {
        uploadStrategyServerBased = UploadStrategy.ACTIVE;		// If strategy parameter is present ActiveServerload class is used
      } else if (param.contains(BUFFERSIZE)) {
        downloadBufferSize = Integer.parseInt(value);
      } else if (param.contains(SENDBUFFERSIZE)) {
        socketBufferSize = Integer.parseInt(value);
      } else if (param.contains(RECEIVEBUFFERSIZE)) {
        desiredReceiveBufferSize = Integer.parseInt(value);
        downloadBufferSize = Integer.parseInt(value);
      } else if (param.contains(SENDDATACHUNK)) {
        uploadBufferSize = Integer.parseInt(value);
      } else if (param.contains(POSTDATALENGTH)) {
        postDataLength = Integer.parseInt(value);
      } else {
        SKLogger.e(this, "setParams()");
        initialised = false;
        break;
      }
    }
  } catch (NumberFormatException nfe) {
    initialised = false;
  }
*/
}

-(int)getNetUsage {												/* Total number of bytes transfered */
  return (int) [self getTotalTransferBytes] + [self getTotalWarmUpBytes];
}

-(BOOL) isReady {												/* Test sanity checker. Virtual */
  if (!self.initialised) {
    return NO;
  }
  
  if (self.target.length == 0) {
    [self setError:@"Target empty"];
    return NO;
  }
  if (self.port == 0) {
    [self setError:@"Port is zero"];
    return false;
  }
  if (self.mWarmupMaxTimeMicro == 0 && self.mWarmupMaxBytes == 0) {
    [self setError:@"No warmup parameter defined"];
    return false;
  }
  if (self.mTransferMaxTimeMicro == 0 && self.mTransferMaxBytes == 0) {
    [super setError:@"No transfer parameter defined"];
    return false;
  }
  if (self.downstream && self.downloadBufferSize == 0) {
    [self setError:@"Buffer size missing for download"];
    return false;
  }
  if (self.nThreads < 1 && self.nThreads > MAXNTHREADS) {
    [self setError:[NSString stringWithFormat:@"Number of threads error, current is: %d, Min=1, Max=%d", self.nThreads, MAXNTHREADS]];
    return false;
  }
  return true;
}

//  void sendTestPing(String token) {
//    //
//    DatagramSocket socket = null;
//    try {
//      socket = new DatagramSocket();
//
//      try {
//        InetAddress address = InetAddress.getByName("192.168.2.105");
//        byte[] buf = token.getBytes(Charset.forName("UTF-8"));
//        DatagramPacket packet = new DatagramPacket(buf, buf.length, address, 90);
//        socket.send(packet);
//      } catch (Exception e) {
//        SKLogger.sAssert(false);
//      }
//    } catch (SocketException e2) {
//      socket.close();
//      SKLogger.sAssert(false);
//    } finally {
//      if (socket != null) {
//        socket.close();
//      }
//    }
//  }

void threadEntry(SKJHttpTest *pSelf) {
  [pSelf myThreadEntry];
}

-(BOOL)  isSuccessful {
  return [self.testStatus isEqualToString:@"OK"];
}		/* Returns test run result */

//	public int getSendBufferSize() 	  {	return sendBufferSize;		}
//	public int getReceiveBufferSize() { return receiveBufferSize;	}
//	public String getInfo() 		  {	return infoString; 			}

-(void) execute {													/* Execute test */
  //smDebugSocketSendTimeMicroseconds.clear();
  //Context context = SKApplication.getAppInstance().getBaseContext();
  
  //sendTestPing("TIMING_Start");
  
  if (self.downstream) {
    //SKLogger.d(this, "DOWNLOAD HTTP TEST - execute()");
    self.infoString = HTTPGETRUN;
  } else {
    //SKLogger.d(this, "UPLOAD HTTP TEST - execute()");
    self.infoString = HTTPPOSTRUN;
  }
  
  [self start];
  
  for (auto theThread : *self.mThreads) {
    delete theThread;
  }
  mThreads->clear();
  
  for (int i = 0; i < self.nThreads; i++) {
    std::thread *newThread = new std::thread(threadEntry, self);
    self.mThreads->push_back(newThread);
  }
  
  @try {
    for (auto theThread : *self.mThreads) {
      theThread->join();
    }
  } @catch (NSException *e) {
    //[self setErrorIfEmpty:@"Thread join exception: ", e];
    NSLog(@"Thread join exception()");
    SK_ASSERT(false);
    self.testStatus = @"FAIL";
  }
  
  if (self.downstream) {
    self.infoString = HTTPGETDONE;
  } else {
    self.infoString = HTTPPOSTDONE;
  }
  
  //sendTestPing("TIMING_Stop");
  
  [self output];
  [self finish];
}

-(GCDAsyncSocket*) getSocket {															/* Socket initialiser */
  //SKLogger.d(this, "HTTP TEST - getSocket()");
  
  dispatch_queue_t mainQueue = dispatch_get_main_queue();
  GCDAsyncSocket *retSocket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                         delegateQueue:mainQueue];
  
  NSError *error = nil;
  if ([retSocket connectToHost:self.target onPort:self.port withTimeout:CONNECTIONTIMEOUT error:&error] == NO) {
    // FAILED!
    SK_ASSERT(false);
    retSocket = nil;
  } else {
    int sockerr = 0;
    
    int buff_size = self.socketBufferSize/2;
    socklen_t socklen = sizeof(buff_size);
    sockerr = setsockopt(retSocket.socketFD,SOL_SOCKET,SO_SNDBUF,(const void*)&buff_size,socklen);
    SK_ASSERT(sockerr == 0);
    
    if (self.downstream) {
      // Read / download
      //socklen = sizeof(timeout);
      struct timeval tv;
      memset(&tv, 0, sizeof(tv));
      tv.tv_sec  = READTIMEOUT;
      tv.tv_usec = 0;
      sockerr = setsockopt(retSocket.socketFD,SOL_SOCKET,SO_SNDTIMEO,(const void*)&tv,sizeof(tv));
      SK_ASSERT(sockerr == 0);
    } else {
      //socklen = sizeof(timeout);
      struct timeval tv;
      memset(&tv, 0, sizeof(tv));
      tv.tv_sec  = WRITETIMEOUT;
      tv.tv_usec = 0;
      sockerr = setsockopt(retSocket.socketFD,SOL_SOCKET,SO_SNDTIMEO,(const void*)&tv,sizeof(tv));
      SK_ASSERT(sockerr == 0);
      //ret.setSoTimeout(1);
    }
  }
  return retSocket;
}

-(void) output {
  //SKLogger.d(this, "HTTP TEST - output()");
  
  /*
   !!! TODO TODO TODO !!! TODO TODO TODO !!!
   ArrayList<String> o = new ArrayList<String>();
   Map<String, Object> output = new HashMap<String, Object>();
   // string id
   o.add(getStringID());
   output.put(JsonData.JSON_TYPE, getStringID());
   // time
   long time_stamp = unixTimeStamp();
   o.add(time_stamp + "");
   output.put(JsonData.JSON_TIMESTAMP, time_stamp);
   output.put(JsonData.JSON_DATETIME, SKDateFormat.sGetDateAsIso8601String(new java.util.Date(time_stamp * 1000)));
   
   long transferBytes = getTotalTransferBytes();
   //SKLogger.d(this, "HTTP TEST - output(), transferBytes=" + transferBytes);
   if (transferBytes == 0) {
   // 30/03/2015 - note that if transferBytes is ZERO, we must also tag this with "success": false
   error.set(true);
   }
   
   // status
   if (error.get()) {
   o.add("FAIL");
   output.put(JsonData.JSON_SUCCESS, false);
   } else {
   o.add("OK");
   output.put(JsonData.JSON_SUCCESS, true);
   }
   // target
   o.add(target);
   output.put(JsonData.JSON_TARGET, target);
   // target ip address
   o.add(ipAddress);
   output.put(JsonData.JSON_TARGET_IPADDRESS, ipAddress);
   // transfer time
   o.add(Long.toString(getTransferTimeMicro()));//TODO check
   output.put(JsonData.JSON_TRANFERTIME, getTransferTimeMicro());
   // transfer bytes
   o.add(Long.toString(getTotalTransferBytes()));
   output.put(JsonData.JSON_TRANFERBYTES, totalTransferBytes);
   // byets_sec
   o.add(Integer.toString(Math.max(0, getTransferBytesPerSecond())));
   output.put(JsonData.JSON_BYTES_SEC, Math.max(0, getTransferBytesPerSecond()));
   // warmup time
   o.add(Long.toString(getWarmUpTimeMicro()));  //TODO check
   output.put(JsonData.JSON_WARMUPTIME, getWarmUpTimeMicro());
   // warmup bytes
   o.add(Long.toString(getTotalWarmUpBytes()));
   output.put(JsonData.JSON_WARMUPBYTES, getTotalWarmUpBytes());
   // number of threads
   o.add(Integer.toString(nThreads));
   output.put(JsonData.JSON_NUMBER_OF_THREADS, nThreads);
   
   //    // TODO: remove the following block in production?
   //    if (OtherUtils.isDebuggable(SKApplication.getAppInstance())) {
   //      StringBuilder sb = new StringBuilder();
   //      Iterator<Entry<String, Object>> iter = output.entrySet().iterator();
   //      while (iter.hasNext()) {
   //        Entry<String, Object> entry = iter.next();
   //        sb.append(entry.getKey());
   //       sb.append('=').append('"');
   //        sb.append(entry.getValue());
   //        sb.append('"');
   //        if (iter.hasNext()) {
   //          sb.append(',').append(' ');
   //        }
   //      }
   //
   //      //SKLogger.d(TAG(this), "Output data: \n" + sb.toString());
   //    }
   
   setOutput(o.toArray(new String[1]));
   setJSONResult(output);
   */
}

/* The following set of methods relates to a  communication with the external UI TODO move prototypes to test */

static std::atomic_long sLatestSpeedForExternalMonitorBytesPerSecond(0);
static std::atomic_long sBytesPerSecondLast(0);

static NSString *sLatestSpeedForExternalMonitorTestId = @"";

+(void) sLatestSpeedReset:(NSString *)theReasonId {
  sLatestSpeedForExternalMonitorBytesPerSecond = 0;
  sBytesPerSecondLast = 0;
  sLatestSpeedForExternalMonitorTestId = theReasonId;
}

// Report-back a running average, to keep the UI moving...
// Returns -1 if sample time too short.
// Static!
std::pair<double, NSString*> sGetLatestSpeedForExternalMonitorAsMbps() {
  // use moving average of the last 2 items!
  double bytesPerSecondToUse = (double)(sBytesPerSecondLast + sLatestSpeedForExternalMonitorBytesPerSecond);
  bytesPerSecondToUse /= 2;
  
  double mbps = (bytesPerSecondToUse * 8.0) / 1000000.0;
  return std::pair<double, NSString*>(mbps, sLatestSpeedForExternalMonitorTestId);
}

+(void) sSetLatestSpeedForExternalMonitorBytesPerSecond:(long)bytesPerSecond TestId:(NSString *)testId {
  long value = sLatestSpeedForExternalMonitorBytesPerSecond;
  sBytesPerSecondLast = value;
  if (bytesPerSecond == 0) {
    SK_ASSERT([testId isEqualToString:cReasonUploadEnd]);
  }
  sLatestSpeedForExternalMonitorBytesPerSecond = bytesPerSecond;
  sLatestSpeedForExternalMonitorTestId = testId;
}

-(void) sSetLatestSpeedForExternalMonitorInterval:(long)pause InId:(NSString *)inId TransferCallback:(SKJRetIntBlock) transferSpeed {
  long updateTime = /*timeElapsedSinceLastExternalMonitorUpdate.get() == 0 ? pause * 5 : */ pause;					/* first update is delayed 3 times of a given pause */
  
  if (self.timeElapsedSinceLastExternalMonitorUpdate == 0) {
    *self.timeElapsedSinceLastExternalMonitorUpdate = [SKJHttpTest sGetMicroTime]; 										/* record update time */
  }
  
  if ([SKJHttpTest sGetMicroTime] - *self.timeElapsedSinceLastExternalMonitorUpdate > updateTime/*uSec*/) {				/* update should be called only if 'pause' is expired */
    int currentSpeed;
    
    @try {
      currentSpeed = transferSpeed();																/* current speed could be for warm up, transfer or possibly others processes */
    } @catch (NSException *e) {
      currentSpeed = 0;
    }
    
    [self.class sSetLatestSpeedForExternalMonitorBytesPerSecond:(long) (currentSpeed /*/ 1000000.0*/) TestId:inId];							/* update speed parameter + indicative ID */
    
    *self.timeElapsedSinceLastExternalMonitorUpdate = [SKJHttpTest sGetMicroTime];											/* set new update time */
    
    //			SKLogger.d(TAG(this), "External Monitor updated at " + (new java.text.SimpleDateFormat("HH:mm:ss.SSS")).format(new java.util.Date()) +
    //					" as " +  ( currentSpeed / 1000000.0) +
    //					" thread: " + getThreadIndex());//haha remove in production
  }
}

/* This is the end of the block related to communication with UI */

-(BOOL) isWarmupDone:(int) bytes {
  //SKLogger.d(this, "isWarmupDone("+ bytes+")");
  
  BOOL timeExceeded = false;
  BOOL bytesExceeded = false;
  
  if (bytes == BYTESREADERR) {													/* if there is an error the test must stop and report it */
    [super setErrorIfEmpty:@"read error"];
    bytes = 0; 																	/* do not modify the bytes counters ??? */
    *self.mError = true;
    return true;
  }
  
  if (*self.mWarmupMicroDuration != 0)											/* if some other thread has already finished warmup there is no need to proceed */
    return true;
  
  [self addTotalWarmUpBytes:bytes];														/* increment atomic total bytes counter */
  
  if (*self.mStartWarmupMicro == 0) {
    *self.mStartWarmupMicro = [SKJHttpTest sGetMicroTime]; 									/* record start up time should be recorded only by one thread */
  }
  
  [self setWarmUpTimeMicro:([SKJHttpTest sGetMicroTime] - *self.mStartWarmupMicro)];					/* current warm up time should be atomic*/
  
  if (self.mWarmupMaxTimeMicro > 0) {													/*if warmup max time is set and time has exceeded its values set time warmup to true */
    timeExceeded = (*self.mWarmupTimeMicro >= self.mWarmupMaxTimeMicro);
  }
  
  if (self.mWarmupMaxBytes > 0) {														/* if warmup max bytes is set and bytes counter exceeded its value set bytesWarmup to true */
    bytesExceeded = ([self getTotalWarmUpBytes] >= self.mWarmupMaxBytes);
  }
  
  if (timeExceeded) {																/* if maximum warmup time is reached */
    if (*self.mWarmupMicroDuration == 0) {
      *self.mWarmupMicroDuration = ([SKJHttpTest sGetMicroTime] - *self.mStartWarmupMicro);	/* Register the time duration up to this moment */
    }
    self.warmupDoneCounter->fetch_add(1);												/* and increment warmup counter */
    return true;
  }
  
  if (bytesExceeded) {																/* if max warmup bytes transferred */
    if (*self.mWarmupMicroDuration == 0) {
      *self.mWarmupMicroDuration = ([SKJHttpTest sGetMicroTime] - *self.mStartWarmupMicro);	/* Register the time duration up to this moment */
    }
    self.warmupDoneCounter->fetch_add(1);												/* and increment warmup counter */
    return true;
  }
  
  return false;
}

-(BOOL) isTransferDone:(int) bytes {
  BOOL timeExceeded = false;
  BOOL bytesExceeded = false;
  
  //SKLogger.d(this, "isTransferDone("+ bytes+")");
  
  //boolean ret = false;
  if (bytes == BYTESREADERR) {														/* if there is an error the test must stop and report it */
    [super setErrorIfEmpty:@"read error"];
    bytes = 0; 																		/* do not modify the bytes counters ??? */
    *self.mError = true;
#ifdef DEBUG
    NSLog(@"DEBUG: isTransferDone, bytes == BYTESREADERR!");
#endif // DEBUG
    SK_ASSERT(false);
    return true;
  }
  
  if (*self.mTransferMicroDuration != 0) {
    /* if some other thread has already finished warmup there is no need to proceed */
    //SKLogger.d(this, "isTransferDone, mTransferMicroDuration != 0");
    return true;
  }
  
 
  [self addTotalTransferBytes:bytes];														/* increment atomic total bytes counter */
  
  /* record start up time should be recorded only by one thread */
  long testZero = 0;
  self.mStartTransferMicro->compare_exchange_strong(testZero, [SKJHttpTest sGetMicroTime]);
  //SKLogger.d(TAG(this), "Setting transfer start  == " + mStartTransferMicro.get() + " by thread: " + this.getThreadIndex());//TODO remove in production
  
  [self setTransferTimeMicro:([SKJHttpTest sGetMicroTime] - *self.mStartTransferMicro)];					/* How much time transfer took up to now */
  
  if (self.mTransferMaxTimeMicro > 0) {													/* If transfer time is more than max time, then transfer is done */
    //SKLogger.d(this, "transfer Time so far milli =" + getTransferTimeMicro()/1000);
    
    timeExceeded = ([self getTransferTimeMicro] >= self.mTransferMaxTimeMicro);
  }
  
  //SKLogger.d(this, "transfer Bytes so far =" + getTotalTransferBytes());
  if (self.mTransferMaxBytes > 0) {
    bytesExceeded = ([self getTotalTransferBytes] >= self.mTransferMaxBytes);
  }
  
  if ([self getTotalTransferBytes] > 0) {
    self.testStatus = @"OK";
  }
  
  if (timeExceeded) {																	/* if maximum transfer time is reached */
    /* Register the time duration up to this moment */
    long testZero = 0;
    self.mStartTransferMicro->compare_exchange_strong(testZero, [SKJHttpTest sGetMicroTime] - *self.mStartTransferMicro);
    self.transferDoneCounter->fetch_add(1);												/* and increment transfer counter */
    //SKLogger.d(this, "isTransferDone, timeExceeded");
    return true;
  }
  
  if (bytesExceeded) {																/* if max transfer bytes transferred */
    long testZero = 0;
    self.mTransferMicroDuration->compare_exchange_strong(testZero, [SKJHttpTest sGetMicroTime] - *self.mStartTransferMicro);
    //SKLogger.d(this, "isTransferDone, bytesExceeded");
    self.transferDoneCounter->fetch_add(1);												/* and increment transfer counter */
    return true;
  }
  
  //SKLogger.d(this, "isTransferDone, still waiting...");
  return false;
}

#include <pthread.h>

-(int) getThreadIndex {
  int threadIndex = 0;
  
  std::thread::id this_id = std::this_thread::get_id();
  
  //@synchronized (mThreads)
  @synchronized (self) {
    
    BOOL bFound = false;
    
    int i = 0;
    for (auto theThread : *self.mThreads) {
      if (this_id == theThread->get_id()) {
        threadIndex = i;
        bFound = true;
        break;
      }
      
      i++;
    }
    
    if (bFound == false) {
      SK_ASSERT(false);
    }
  }
  return threadIndex;
}


-(GCDAsyncSocket*) getOutput:(GCDAsyncSocket *)socket {
  return socket;										/* return output stream */
}

-(GCDAsyncSocket*) getInput:(GCDAsyncSocket *)socket {
  return socket;										/* return output stream */
}


//public void setDownstream() {								downstream = true;				}
//public void setUpstream() {									downstream = false;				}

-(void) setDirection:(NSString *)d {
  if ([d isEqualToString:_DOWNSTREAM]) {
    self.downstream = true;
  } else if ([d isEqualToString:_UPSTREAM]) {
    self.downstream = false;
  } else {
    SK_ASSERT(false);
  }
}

-(BOOL) isProgressAvailable {//TODO check with new interface
  BOOL ret = false;
  if (self.mTransferMaxTimeMicro > 0) {
    ret = true;
  } else if (self.mTransferMaxBytes > 0) {
    ret = true;
  }
  return ret;
}

-(int) getProgress {//TODO check with new interface
  double ret = 0;
  
  if (*self.mStartWarmupMicro == 0) {
    ret = 0;
  } else if (self.mTransferMaxTimeMicro != 0) {
    long currTime = [SKJHttpTest sGetMicroTime] - *self.mStartWarmupMicro;
    ret = (double) currTime / (self.mWarmupMaxTimeMicro + self.mTransferMaxTimeMicro);
    
  } else {
    long currBytes = [self getTotalWarmUpBytes] + [self getTotalTransferBytes];
    ret = (double) currBytes / (self.mWarmupMaxBytes + self.mTransferMaxBytes);
  }
  //}
  ret = ret < 0 ? 0 : ret;
  ret = ret >= 1 ? 0.99 : ret;
  return (int) (ret * 100);
}

-(void) closeConnection:(GCDAsyncSocket *)socket {											/* Closes connections  and winds socket out*/
  //SKLogger.d(this, "closeConnection()");
  
  /*
   * Should be run inside thread
   */
  if (socket != nil) {
    [socket setDelegate:nil];
    [socket disconnect];
  }
}

-(void) myThreadEntry {
  BOOL result = false;
  int threadIndex = [self getThreadIndex];
  
  GCDAsyncSocket *socket = [self getSocket];
  
  if (socket == nil) {
    SK_ASSERT(false);
    return;
  }
  
  result = [self warmupToSocket:socket ThreadIndex:threadIndex];
  
  if (!result) {
    [self closeConnection:socket];
    return;
  }
  
  result = [self transferToSocket:socket ThreadIndex: threadIndex];
  
  [self closeConnection:socket];
}


/*
 * Accessors to atomic variables
 */
-(long) getTotalWarmUpBytes {
  return *self.totalWarmUpBytes;
}

-(long) getTotalTransferBytes {
  return *self.totalTransferBytes;
}

-(long) getWarmUpTimeMicro {
  return *self.mWarmupTimeMicro;
}

-(long) getWarmUpTimeDurationMicro {
  return *self.mWarmupMicroDuration;
}

-(long) getTransferTimeMicro {
  return *self.transferTimeMicroseconds;
}

-(long) getTransferTimeDurationMicro {
  return *self.mTransferMicroDuration;
}

-(long) getStartTransferMicro {
  return *self.mStartTransferMicro;
}

-(long) getStartWarmupMicro {
  return *self.mStartWarmupMicro;
}

-(void) addTotalTransferBytes:(long) bytes {
  self.totalTransferBytes->fetch_add(bytes);
}

-(void) resetTotalTransferBytesToZero {
  *self.totalTransferBytes = 0;
}

-(void) addTotalWarmUpBytes:(long) bytes {
  self.totalWarmUpBytes->fetch_add(bytes);
}

-(void) setWarmUpTimeMicro:(long) uTime {
  *self.mWarmupTimeMicro = uTime;
}

-(void) setTransferTimeMicro:(long) uTime {
  *self.transferTimeMicroseconds = uTime;
}

-(int) getThreadsNum {
  return self.nThreads;
}														/* Accessor for number of threads */

-(BOOL) getError {
  return *self.mError;
}


+(int) sGetBytesPerSecond:(long) duration BtsTotal:(long) btsTotal {
  int btsPerSec = 0;
  
  if (duration != 0) {
    double timeSeconds = ((double) duration) / 1000000.0;
    btsPerSec = (int) (((double) btsTotal) / timeSeconds);
  }
  
  //SKLogger.d(TAG(this), "getWarmupSpeedBytesPerSecond, using CLIENT value = " + btsPerSec);//HAHA remove in production
  return btsPerSec;
}


-(int) getWarmupBytesPerSecond {
  long btsTotal = [self getTotalWarmUpBytes];
  long duration = [self getWarmUpTimeDurationMicro] == 0 ?
    ([SKJHttpTest sGetMicroTime] - [self getStartWarmupMicro]) :
    [self getWarmUpTimeDurationMicro];
  
  return [self.class sGetBytesPerSecond:duration BtsTotal:btsTotal];
}


// Returns -1 if not enough time has passed for sensible measurement.
-(int) getTransferBytesPerSecond {
  long btsTotal = [self getTotalTransferBytes];
  long duration = [self getTransferTimeDurationMicro] == 0 ?
    ([SKJHttpTest sGetMicroTime] - [self getStartTransferMicro]) :
    [self getTransferTimeDurationMicro];
  
  if (duration < 1000000.0) // At least a second!
  {
    // Not yet possible to return a valid result!
    return -1;
  }
  
  return [self.class sGetBytesPerSecond:duration BtsTotal:btsTotal];
}

-(void) setError:(NSString*) error {
		@synchronized (self) {
      [super setError:error];
      *self.mError = true;
    }
}

@end

