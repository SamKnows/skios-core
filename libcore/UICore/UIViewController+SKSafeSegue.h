//
//  UIViewController+SKSafeSegue.h
//  SKCore
//
//  Created by Pete Cole on 29/07/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (SKSafeSegue)

-(void) SKSafePerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender;
- (void)SKSafePushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)SKSafePopViewControllerAnimated:(BOOL)animated;

@end
