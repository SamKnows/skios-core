//
//  IPHelper.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKIPHelper.h"

@implementation SKIPHelper

// retun the host name
+ (NSString *)hostname
{
    char baseHostName[256]; 
    int success = gethostname(baseHostName, 255);
    if (success != 0) return nil;
    baseHostName[255] = '\0';
    
#if !TARGET_IPHONE_SIMULATOR
    return [NSString stringWithFormat:@"%s.local", baseHostName];
#else
    return [NSString stringWithFormat:@"%s", baseHostName];
#endif
}

// return IP Address
+ (NSString *)localIPAddress
{
    struct hostent *host = gethostbyname([[self hostname] UTF8String]);
    if (!host) {
      SK_ASSERT(false);
      herror("resolv");
      return @"error";
    }
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    return [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
}

// return IP Address
+ (NSString *)hostIPAddress:(NSString*)host_
{
  if (host_ == nil) {
    // Probably found that socket connection failed!
    return @"error";
  }
  
  struct hostent *host = gethostbyname([host_ UTF8String]);
  if (!host) {
    SK_ASSERT(false);
    herror("resolv");
    return @"error";
  }
  struct in_addr **list = (struct in_addr **)host->h_addr_list;
  return [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
}

@end
