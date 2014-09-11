//
//  SKOperators.h
//  SKCore
//
//  Created by Pete Cole on 12/02/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  SKOperators_Return_NoThrottleQuery = 0,
  SKOperators_Return_FiredThrottleQueryAwaitCallback = 1
} SKOperators_Return;

@interface SKThrottledQueryResult : NSObject
@property SKOperators_Return returnCode;
@property (copy) NSString *timestamp; // Unix time - seconds since 1970
//@property (copy) NSString *datetimeUTCMilliZ;  // UTC string
@property (copy) NSString *datetimeUTCSimple;  // UTC string
@property (copy) NSString *carrier;
@end


@interface SKOperators : NSObject

// Typically, this is called from -(void)SKAutoTest:runTheTests ...
// Returns NO in the event of an immediate error, otherwise YES (in which case, a callback
// would be expected in time...)
-(SKThrottledQueryResult*) fireThrottledWebServiceQueryWithCallback:(SKQueryCompleted)callback;
  
// Singleton access...
+(SKOperators*) getInstance;

@end
