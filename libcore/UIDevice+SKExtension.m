//
//  UIDevice+SKExtension.m
//

#import "UIDevice+SKExtension.h"

@implementation UIDevice (SKExtension)

- (NSString *) uniqueDeviceIdentifier
{
  // http://stackoverflow.com/questions/13420788/developing-apps-for-multiple-ios-version
  SK_ASSERT ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]);
  // http://stackoverflow.com/questions/19013245/ios7-device-unique-identifier
  // Use this on iOS 6 and later!
  NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
  
  NSString *deviceIdentifier = [oNSUUID UUIDString];
  // e.g. E621E1F8-C36C-495A-93FC-0C247A3E6E5F
#ifdef DEBUG
  NSLog(@"DEBUG: deviceIdentifier=%@", deviceIdentifier);
#endif // DEBUG
  
  return deviceIdentifier;
}

@end
