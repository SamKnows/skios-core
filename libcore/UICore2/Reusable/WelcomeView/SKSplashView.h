//
//  SKSplashView.h
//  SKCore
//

//  Copyright (c) 2014-2015 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKSplashView : UIView

-(void)initializeWelcomeText;
-(void)callWhenViewControllerResized:(void (^)())completionBlock_;

@end
