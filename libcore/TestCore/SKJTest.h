//
//  SKJTest.h
//  SKCore
//
//  Created by Pete Cole on 05/06/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//
// This file is a direct port from Test.java
//

#import <Foundation/Foundation.h>

typedef enum t_STATUS {
  WAITING = 0,
  RUNNING = 1,
  DONE    = 2
} STATUS;

typedef int (^SKJRetIntBlock)(void);
typedef BOOL (^SKJRetBoolBlock)(void);

@interface SKJTest : NSObject


#define TARGET @"target"
#define PORT @"port"
#define FILE @"file"

@property STATUS status;
@property BOOL finished;

@property BOOL initialised;

//public abstract void execute();
-(void) execute;

-(NSString*) getStringID;
-(BOOL) isSuccessful;
-(void) run;
-(NSString*) getHumanReadableResult;

//abstract public HashMap<String, String> getResults();
-(NSDictionary*) getResults;

-(BOOL) isProgressAvailable;
-(int)  getProgress; 										/* from 0 to 100 */
-(BOOL) isReady;										/* Checks if the test is ready to run */
-(int)  getNetUsage;										/* The test has to provide the amount of data used */

-(long) unixTimeStamp;
-(void) start;
-(void) finish;

-(void) setError:(NSString*) error;
-(BOOL) setErrorIfEmpty:(NSString*) error Exception:(NSException *)e;
-(BOOL) setErrorIfEmpty:(NSString *)error;

#pragma mark Test Cancel control (begin)
// The SKJHttpTest class detects this stage and allow quick Cancelling of the test
// even while it is running.
// Other implements of SKJTest do not yet support this approach.
-(BOOL) getShouldCancel;
-(void) setShouldCancel;
#pragma mark Test Cancel control (end)
@end
