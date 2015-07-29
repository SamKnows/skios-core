//
//  SKGateway.m
//  SKCore
//
//  Created by Pete Cole on 22/07/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKGateway.h"
#import "Reachability.h"

// http://stackoverflow.com/questions/2300149/how-can-i-determine-the-default-gateway-on-iphone

#include <stdio.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <sys/sysctl.h>
// http://stackoverflow.com/questions/22162197/why-net-route-h-can-be-included-and-compiled-in-ios6-1-simulator-while-cannot
#if TARGET_IPHONE_SIMULATOR
#import <net/route.h>
#else // TARGET_IPHONE_SIMULATOR
#import "route.h"
#endif // TARGET_IPHONE_SIMULATOR
#include <net/if.h>
#include <string.h>

#define ROUNDUP(a) \
((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))

/* getdefaultgateway() :
 * return value :
 *    0 : success
 *   -1 : failure    */
int getdefaultgateway(in_addr_t * addr);

int getdefaultgateway(in_addr_t * addr)
{
  int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET,
    NET_RT_FLAGS, RTF_GATEWAY};
  size_t l;
  char * buf, * p;
  struct rt_msghdr * rt;
  struct sockaddr * sa;
  struct sockaddr * sa_tab[RTAX_MAX];
  int i;
  int r = -1;
  if(sysctl(mib, sizeof(mib)/sizeof(int), 0, &l, 0, 0) < 0) {
    return -1;
  }
  if(l>0) {
    buf = malloc(l);
    if(sysctl(mib, sizeof(mib)/sizeof(int), buf, &l, 0, 0) < 0) {
      return -1;
    }
    for(p=buf; p<buf+l; p+=rt->rtm_msglen) {
      rt = (struct rt_msghdr *)p;
      sa = (struct sockaddr *)(rt + 1);
      for(i=0; i<RTAX_MAX; i++) {
        if(rt->rtm_addrs & (1 << i)) {
          sa_tab[i] = sa;
          sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
        } else {
          sa_tab[i] = NULL;
        }
      }
      
      if( ((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
         && sa_tab[RTAX_DST]->sa_family == AF_INET
         && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
        
        
        if(((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0) {
          char ifName[128];
          if_indextoname(rt->rtm_index,ifName);
          
          if(strcmp("en0",ifName)==0){
            
            *addr = ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr;
            r = 0;
            break;
          }
          
          #if TARGET_IPHONE_SIMULATOR
          if(strcmp("en1",ifName)==0){
            
            *addr = ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr;
            r = 0;
            break;
          }
          #endif // TARGET_IPHONE_SIMULATOR
        }
      }
    }
    free(buf);
  }
  return r;
}

@implementation SKGateway

- (instancetype)init
{
  self = [super init];
  if (self) {
    // TODO?
  }
  return self;
}

+(NSString *)sGetDefaultGateway {
  
  in_addr_t lAddr;
  memset(&lAddr, 0, sizeof(lAddr));
  int errCode = getdefaultgateway(&lAddr);
  if (errCode != 0) {
    return nil;
  }
  
  NSString *result = [Reachability makeAddressKey:lAddr];
  
  return result;
}

+(BOOL) sGetIsNetworkWiFi {
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  //BOOL bReachableViaWWan =[reachability isReachableViaWWAN];
  BOOL bReachableViaWiFi =[reachability isReachableViaWiFi];
  return bReachableViaWiFi;
}
@end