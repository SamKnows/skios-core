//
//  UIWelcomeView.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWelcomeView : UIView
{
    BOOL isInitialised;
}

@property (nonatomic, strong) UILabel* l_S1;
@property (nonatomic, strong) UILabel* l_A;
@property (nonatomic, strong) UILabel* l_M;

@property (nonatomic, strong) UILabel* l_K;
@property (nonatomic, strong) UILabel* l_N;
@property (nonatomic, strong) UILabel* l_O;
@property (nonatomic, strong) UILabel* l_W;
@property (nonatomic, strong) UILabel* l_S2;

-(void)initializeWelcomeText;
-(void)startAnimationOnCompletion:(void (^)())completionBlock_;

@end
