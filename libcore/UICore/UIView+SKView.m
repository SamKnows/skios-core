//
//  UIView+SKView.m
//  SKCore
//
//  Created by Pete Cole on 24/03/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "UIView+SKView.h"

@implementation UIView (SKView)

-(UIImage*) skTakeScreenshot {
  // http://stackoverflow.com/questions/2200736/how-to-take-a-screenshot-programmatically?rq=1
  UIGraphicsBeginImageContext(self.window.bounds.size);
  if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
    UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, NO, [UIScreen mainScreen].scale);
  } else {
    UIGraphicsBeginImageContext(self.window.bounds.size);
  }
  [self.window.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *exportImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return exportImage;
}


@end
