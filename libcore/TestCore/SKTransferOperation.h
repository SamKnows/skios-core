//
//  SKTransferOperation.h
//  SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SKTransferOperation.h"

@class SKTransferOperationStatus;

#define HTTP_DOWNLOAD_TIMEOUT 45
#define HTTP_UPLOAD_TIMEOUT   45

typedef enum { INITIALIZING, WARMING, TRANSFERRING, COMPLETE, CANCELLED, FAILED, FINISHED, IDLE } TransferStatus;

//@protocol SKTransferOperationDelegate;
@class SKAutotest;
@class SKHttpTest;


@interface SKTransferOperation : NSOperation<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

- (id)initWithTarget:(NSString*)_target
                port:(int)_port
            opStatus:(SKTransferOperationStatus*)inOpStatus
                file:(NSString*)_file
        isDownstream:(BOOL)_isDownstream
            nThreads:(int)_nThreads
            threadId:(int)_threadId
            SESSIONID:(uint32_t)sessionId
            ParentHttpTest:(SKHttpTest*)inParentHttpTest
            asyncFlag:(BOOL)_asyncFlag;

-(void)start;
-(BOOL)getAsyncFlag;

// Put in a method, so we can mock it out when required under testing!
- (NSURLConnection *)newAsynchronousRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate>)theDelegate startImmediately:(NSNumber*)inStartImmediately;

// static methods used simply to get NSStrings describing different states.
+(NSString*) getUpStream;
+(NSString*) getDownStream;
+(NSString*) getStatusInitializing;
+(NSString*) getStatusWarming;
+(NSString*) getStatusTransferring;
+(NSString*) getStatusComplete;
+(NSString*) getStatusCancelled;
+(NSString*) getStatusFailed;
+(NSString*) getStatusFinished;
+(NSString*) getStatusIdle;

// Used by the owning SKAutotest, to let the SKTransferOperation know what the owning autotest is...
-(void) setSKAutotest:(SKAutotest*)inSkAutotest;

+(int) sCreateAndConnectRawSocketForTarget:(NSString*)target Port:(int)port CustomBlock:(void (^)(int sockfd))customBlock;

@end

