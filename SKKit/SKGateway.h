//
//  SKGateway.h
//  SKCore
//
//  Created by Pete Cole on 22/07/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//

//#ifndef SKGATEWAY_H
//#define SKGATEWAY_H 1

#import <Foundation/Foundation.h>

@interface SKGateway : NSObject
- (instancetype)init;
+(NSString *)sGetDefaultGateway;
+(BOOL) sGetIsNetworkWiFi;
@end
//#endif // SKGATEWAY_H 1
