/*
     File: SKReachability.m
 Abstract: Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
  Version: 3.5
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>

#import <CoreFoundation/CoreFoundation.h>

#import "SKReachability.h"
#import "SimplePing.h"

//NSString *kReachabilityChangedNotification = @"kNetworkReachabilityChangedNotification";


#pragma mark - Supporting functions

#ifdef _DEBUG
#define kShouldPrintReachabilityFlags 1
#endif // _DEBUG

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment)
{
#if kShouldPrintReachabilityFlags

    NSLog(@"DEBUG: SKReachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)				? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',

          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}


static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
	NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
	NSCAssert([(__bridge NSObject*) info isKindOfClass: [SKReachability class]], @"info was wrong class in ReachabilityCallback");

    SKReachability* noteObject = (__bridge SKReachability *)info;
    // Post a notification to notify the client that the network reachability changed.
    // Posting to NSNotificationCenter *must* be done in the main thread!
    //SK_ASSERT([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName: kReachabilityChangedNotification object: noteObject];
}


#pragma mark - SKReachability implementation

// IM addition!
@interface MyPingWithDelegate : SimplePing<SimplePingDelegate>
@end

// Assume YES unless we find otherwise!!
static BOOL sbLastKnownPingStatus = YES;

@implementation MyPingWithDelegate
- (id)initWithHostName:(NSString *)hostName address:(NSData *)hostAddress
    // The initialiser common to both of our construction class methods.
{
  assert( (hostName != nil) == (hostAddress == nil) );
  self = [super initWithHostName:hostName address:hostAddress];
  if (self != nil) {
    self.delegate = self;
  }
  return self;
}

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
  // Send the first ping straight away.
  [self sendPingWithData:nil];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet {
  sbLastKnownPingStatus = YES;
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
  sbLastKnownPingStatus = NO;
}
@end


@interface SKReachability() <SimplePingDelegate>
@property NSString *mpHostName;
@property MyPingWithDelegate *mpPinger;
@end

@implementation SKReachability
{
	BOOL _alwaysReturnLocalWiFiStatus; //default is NO
	SCNetworkReachabilityRef _reachabilityRef;
}

+ (instancetype)newReachabilityWithHostName:(NSString *)hostName
{
  
	SKReachability* returnValue = NULL;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
	if (reachability != NULL)
	{
		returnValue= [[self alloc] init];
		if (returnValue != NULL)
		{
      returnValue.mpHostName = hostName;
			returnValue->_reachabilityRef = reachability;
			returnValue->_alwaysReturnLocalWiFiStatus = NO;
    } else {
      SK_ASSERT(false);
      CFRelease(reachability);
    }
	}
	return returnValue;
}


+ (instancetype)newReachabilityWithAddress:(const struct sockaddr_in *)hostAddress
{
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);

	SKReachability* returnValue = NULL;

	if (reachability != NULL)
	{
		returnValue = [[self alloc] init];
		if (returnValue != NULL)
		{
			returnValue->_reachabilityRef = reachability;
			returnValue->_alwaysReturnLocalWiFiStatus = NO;
    } else {
      SK_ASSERT(false);
      CFRelease(reachability);
    }
	}
	return returnValue;
}



+ (instancetype)newReachabilityForInternetConnection
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    
	return [self newReachabilityWithAddress:&zeroAddress];
}


+ (instancetype)newReachabilityForLocalWiFi
{
	struct sockaddr_in localWifiAddress;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;

	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0.
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);

	SKReachability* returnValue = [self newReachabilityWithAddress: &localWifiAddress];
	if (returnValue != NULL)
	{
		returnValue->_alwaysReturnLocalWiFiStatus = YES;
	}
    
	return returnValue;
}


#pragma mark - Start and stop notifier

- (BOOL)startNotifier
{
	BOOL returnValue = NO;
	SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};

	if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context))
	{
		if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
		{
			returnValue = YES;
		}
	}
    
	return returnValue;
}


- (void)stopNotifier
{
	if (_reachabilityRef != NULL)
	{
		SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	}
}


- (void)dealloc
{
	[self stopNotifier];
	if (_reachabilityRef != NULL)
	{
		CFRelease(_reachabilityRef);
	}
  
  [super dealloc];
}


#pragma mark - Network Flag Handling

- (NetworkStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	PrintReachabilityFlags(flags, "localWiFiStatusForFlags");
	NetworkStatus returnValue = NotReachable;

	if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))
	{
		returnValue = ReachableViaWiFi;
	}
    
	return returnValue;
}


- (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	PrintReachabilityFlags(flags, "networkStatusForFlags");
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
	{
		// The target host is not reachable.
		return NotReachable;
	}

    NetworkStatus returnValue = NotReachable;

	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
	{
		/*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
		returnValue = ReachableViaWiFi;
	}

	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
	{
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */

        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = ReachableViaWiFi;
        }
    }

	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
	{
		/*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
		returnValue = ReachableViaWWAN;
	}
    
	return returnValue;
}


- (BOOL)connectionRequired
{
	NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
	SCNetworkReachabilityFlags flags;

	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
	{
    if (flags & kSCNetworkReachabilityFlagsConnectionRequired) {
      return YES;
    }
	}

  return NO;
}


- (int)currentReachabilityStatus
{
	NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
	NetworkStatus returnValue = NotReachable;
	SCNetworkReachabilityFlags flags;
    
	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
  {
    if (_alwaysReturnLocalWiFiStatus)
    {
      returnValue = [self localWiFiStatusForFlags:flags];
    }
    else
    {
      returnValue = [self networkStatusForFlags:flags];
      
    }
    
    // http://webcache.googleusercontent.com/search?q=cache:aWSC07iJpkoJ:forums.macrumors.com/showthread.php%3Ft%3D942439&hl=en&gl=uk&strip=1
    // SKReachability returns "ReachableViaWWAN" even if 3G is disabled. If you get ReachableViaWWAN, check connectionRequired (is YES if 3G is disabled).
    if (returnValue == ReachableViaWWAN) {
//      if (self.mpHostName == nil)
//        return returnValue;
//      
//      // WWAN is the only option - we have a deferred decision to make, via a ping!
//      self.mpPinger = [[MyPingWithDelegate alloc] initWithHostName:self.mpHostName address:nil];
//      [self.mpPinger start];
//      
//      if (sbLastKnownPingStatus == NO) {
//        return NotReachable;
//      }
      
      return ReachableViaWWAN;
    }
  }
    
	return returnValue;
}


- (BOOL) isReachable {
  
  NSAssert(_reachabilityRef, @"isReachable called with NULL reachabilityRef");
  
  SCNetworkReachabilityFlags flags = 0;
  NetworkStatus status = kNotReachable;
  
  if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
    
    //		logReachabilityFlags(flags);
    
    status = [self networkStatusForFlags: flags];
    
    //		logNetworkStatus(status);
    
    return (kNotReachable != status);
    
  }
  
  return NO;
  
} // isReachable

// Added by SamKnows...
+ (NSString *) makeAddressKey: (in_addr_t) addr {
  // TODO!
  SK_ASSERT(false);
  return nil;
}


// Simple test for Internet reachability!
+ (BOOL) sGetIsReachable { // Could also be called sGetIsConnected...?
  SKReachability *reachability = [[SKReachability newReachabilityForInternetConnection] autorelease];
  BOOL test = [reachability isReachable];
  return test;
}

@end
