//
//  SKAAppDelegate.m
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKAAppDelegate.h"

//#import "SKATermsAndConditionsController.h"
//#import "SKAMainResultsController.h"
//#import "SKAActivationController.h"

@interface SKAAppDelegate()
//@property (retain, atomic) SKAppBehaviourDelegate *mpAppBehaviourDelegate;
@end

@implementation SKAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  SKAppBehaviourDelegate *appBehaviourDelegate = [SKAppBehaviourDelegate sGetAppBehaviourDelegate];
  SK_ASSERT(appBehaviourDelegate != nil);
  
  [appBehaviourDelegate checkDataUsageReset];
  
  if ([appBehaviourDelegate getIsThisTheNewApp] == NO) {
    
    if (![appBehaviourDelegate hasAgreed]) {
      // Not yet agreed to T&C - start (modally) with the T&C navigation controller, instead!
      UIStoryboard *storyboard = [SKAAppDelegate getStoryboard];
      self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditionsNavigationController"];
    } else if (![[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isActivated]) {
      [self didFinishAppLaunching_NotActivatedYet];
    }
  }
  
  [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // STOP monitoring location data, as we background!
  [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] stopLocationMonitoring];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // STOP monitoring location data, as we background!
  if ([SKAutotest sGetIsTestRunning] == YES) {
    // Resume monitoring!
    [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] startLocationMonitoring];
  }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

+(SKAAppDelegate*) getAppDelegate {
  SKAAppDelegate *appDelegate = (SKAAppDelegate*)[UIApplication sharedApplication].delegate;
  return appDelegate;
}

+(UIStoryboard*) getStoryboard {
  // http://stackoverflow.com/questions/8025248/uistoryboard-get-first-view-controller-from-applicationdelegate
  NSString *storyBoardName = [NSBundle mainBundle].infoDictionary[@"UIMainStoryboardFile"];
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:[NSBundle mainBundle]];
  return storyboard;
}

-(void) didFinishAppLaunching_NotActivatedYet {
  UIStoryboard *storyboard = [self.class getStoryboard];
  self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ActivationNavigationController"];
}

+(void) sResetUserInterfaceBackToMainScreen  {
  SKAAppDelegate *instance = [SKAAppDelegate getAppDelegate];
  [instance performSelector:@selector(moveToRootScreenAfterDelay) withObject:nil afterDelay:0.1];
}

+(void) sResetUserInterfaceBackToRunTestsScreenFromViewController { // :(UIViewController*)fromViewController {
  SKAAppDelegate *instance = [SKAAppDelegate getAppDelegate];
  [instance performSelector:@selector(moveToRootScreenAfterDelay) withObject:nil afterDelay:0.1];
}

-(void) moveToRootScreenAfterDelay
{
  UIStoryboard *storyboard = [SKAAppDelegate getStoryboard];
  UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"theRootNavigationController"];
  SK_ASSERT(self.window != nil);
  [[UIApplication sharedApplication].keyWindow setRootViewController:nc];
  //self.window.rootViewController = nc;
}
@end