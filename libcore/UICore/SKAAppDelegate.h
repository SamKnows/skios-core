//
//  SKAAppDelegate.h
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "UIColor+Colours.h"
#import "UIView+SKView.h"

// This is imported automatically via SKCore.h (through the pre-compiled header)
//#import "SKAppBehaviourDelegate.h"

#ifndef SKAAPPDELEGATE_H
#define SKAAPPDELEGATE_H 1

//
// Simple base app delegate...
//

@interface SKAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

+(SKAAppDelegate*) getAppDelegate;

-(void) didFinishAppLaunching_NotActivatedYet;

+(UIStoryboard*) getStoryboard;
+(void) sResetUserInterfaceBackToMainScreen;
+(void) sResetUserInterfaceBackToRunTestsScreenFromViewController;

@end
  
// Splash screen (begin)
CGFloat getGuiMultiplier();
CGFloat scaleWidthHeightTo(CGFloat value);
// Splash screen (end)


#endif // SKAAPPDELEGATE_H 1