//
//  cAnimatedStatusView.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface cAnimatedStatusView : UIView

@property (nonatomic, strong) UILabel* l1h;
@property (nonatomic, strong) UILabel* l1n;
@property (nonatomic, strong) UIView* v1;

@property (nonatomic, strong) UILabel* l2h;
@property (nonatomic, strong) UILabel* l2n;
@property (nonatomic, strong) UIView* v2;

//@property (nonatomic, strong) UIImageView* iv1;
//@property (nonatomic, strong) UIImageView* iv2;

@property (nonatomic) int activeLabel;

-(void)initialize;
-(void)setText:(NSString*)text_ forever:(bool)forever_;
-(void)animate:(BOOL)forever_;

@end
