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
  
  if (self.navigationController.topViewController == self) {
    [self performSegueWithIdentifier:identifier sender:sender];
  } else {
    SK_ASSERT(false);
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

@end