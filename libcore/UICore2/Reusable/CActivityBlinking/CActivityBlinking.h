//
//  CActivityBlinking.h
//  SKCore
//
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CActivityBlinking : UIView
{
    bool isInitialised;
    UIView *V_Blinker;
}

- (id)initWithFrame:(CGRect)frame;
- (void)initialize;
- (void)startAnimating;
- (void)stopAnimating;

@end
