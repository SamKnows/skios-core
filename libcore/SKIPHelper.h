//
//  IPHelper.h
//  SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>

@interface SKIPHelper : NSObject

+ (NSString *)hostname;
+ (NSString *)localIPAddress;
+ (NSString *)hostIPAddress:(NSString*)host_;

@end
