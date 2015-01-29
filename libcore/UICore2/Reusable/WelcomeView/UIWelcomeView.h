//
//  UIWelcomeView.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWelcomeView : UIView


-(void)initializeWelcomeText;
-(void)callWhenViewControllerResized:(void (^)())completionBlock_;

@end
