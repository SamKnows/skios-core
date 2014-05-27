//
//  UIView+IMExtensions.m
//

#import "UIAlertView+SKExtensions.h"
#import <objc/runtime.h>

NSString * const kSKUIAlertViewClickedBlockKey = @"kSKUIAlertViewClickedBlockKey";
NSString * const kSKUIAlertViewCancelBlockKey = @"kSKUIAlertViewCancelBlockKey";

@implementation UIAlertView (SKExtensions)

-(void)showWithBlock:(SKUIAlertViewClickedBlock)inClickedBlock {
  
  self.delegate = self;
  
  self.clickedBlock = inClickedBlock;
  self.cancelBlock = nil;
  
  [self show];
}

-(void)showWithBlock:(SKUIAlertViewClickedBlock)inClickedBlock cancelBlock:(SKUIAlertViewCancelBlock)inCancelBlock {
  
  self.delegate = self;
  
  self.clickedBlock = inClickedBlock;
  self.cancelBlock = inCancelBlock;
  
  [self show];
}

- (void)setClickedBlock:(SKUIAlertViewClickedBlock)aObject {
  objc_setAssociatedObject(self, (__bridge const void *)(kSKUIAlertViewClickedBlockKey), [aObject copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SKUIAlertViewClickedBlock)clickedBlock {
  return objc_getAssociatedObject(self, (__bridge const void *)(kSKUIAlertViewClickedBlockKey));
}

- (void)setCancelBlock:(SKUIAlertViewCancelBlock)aObject {
  objc_setAssociatedObject(self, (__bridge const void *)(kSKUIAlertViewCancelBlockKey), [aObject copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SKUIAlertViewCancelBlock)cancelBlock {
  return objc_getAssociatedObject(self, (__bridge const void *)(kSKUIAlertViewCancelBlockKey));
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == self.cancelButtonIndex) {
    [self alertViewCancel:alertView];
  } else if (buttonIndex > 0) {
    if (self.clickedBlock) {
      self.clickedBlock(self, buttonIndex);
    }
  }
}

-(void)alertViewCancel:(UIAlertView *)alertView {
  if (self.cancelBlock) {
    self.cancelBlock(self);
  }
}


@end
