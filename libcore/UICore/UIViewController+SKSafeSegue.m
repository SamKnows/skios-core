//
//  UIViewController+SKSafeSegue.m
//  SKCore
//
//  Created by Pete Cole on 29/07/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "UIViewController+SKSafeSegue.h"
#import <objc/runtime.h>

@implementation UIViewController (SKSafeSegue)

-(void) SKSafePerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
  
  UINavigationController *theNC = self.navigationController;
  if (theNC.topViewController == self) {
    [self performSegueWithIdentifier:identifier sender:sender];
  } else {
    if ([self.class isSubclassOfClass:UITabBarController.class]) {
      // e.g. from tab bar controller...
      UITabBarController *theTBC = (UITabBarController*)self;
      UIViewController *selectedVC = theTBC.selectedViewController;
      NSLog(@"Class is %@", [selectedVC description]);
      if ([selectedVC.class isSubclassOfClass:UINavigationController.class]) {
        UINavigationController *topNC = (UINavigationController *)selectedVC;
        [topNC performSegueWithIdentifier:identifier sender:sender];
      } else {
        // Warning!
        SK_ASSERT(false);
      }
    } else  {
      // Warning!
      // CHECK: are you calling this from a view controller that is CONTAINED?
      UIViewController *parentViewController = self.parentViewController;
      if (parentViewController != nil) {
        [parentViewController performSegueWithIdentifier:identifier sender:sender];
      } else {
        SK_ASSERT(false);
      }
    }
  }
}

- (void)SKSafePushViewController:(UIViewController *)viewController animated:(BOOL)animated {
  
  if (self.navigationController.topViewController == self) {
    [self.navigationController pushViewController:viewController animated:animated];
  } else {
    SK_ASSERT(false);
  }
}

- (UIViewController *)SKSafePopViewControllerAnimated:(BOOL)animated {
  
  if (self.navigationController.topViewController == self) {
    return [self.navigationController popViewControllerAnimated:animated];
  } else {
    SK_ASSERT(false);
    return nil;
  }
}

+ (UIViewController*) sKGetTopMostController
{
  UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
  
  while (topController.presentedViewController) {
    topController = topController.presentedViewController;
  }
  
  return topController;
}

@end