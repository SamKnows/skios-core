//
//  cAnimatedStatusView.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface cAnimatedStatusView : UIView

@property (weak, nonatomic) IBOutlet UILabel* l1h;
@property (weak, nonatomic) IBOutlet UILabel* l1n;
@property (weak, nonatomic) IBOutlet UIView* v1;

@property (weak, nonatomic) IBOutlet UILabel* l2h;
@property (weak, nonatomic) IBOutlet UILabel* l2n;
@property (weak, nonatomic) IBOutlet UIView* v2;

//@property (nonatomic, strong) UIImageView* iv1;
//@property (nonatomic, strong) UIImageView* iv2;

-(void)initialize;
-(void)setText:(NSString*)text_ forever:(bool)forever_;
-(void)animate:(BOOL)forever_;

@end
