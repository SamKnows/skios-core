//
//  cTabController.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../UIViewWithGradient/UIViewWithGradient.h"
//#import "SKRunTestViewMgr.h"

#define C_TABINDX_HISTORY   1

@protocol pViewManager <NSObject>

-(void)intialiseViewOnMasterViewController:(UIViewController*)masterViewController_;
-(void)performLayout;

@optional
-(void)activate;
-(void)deactivate;

@end

@interface cTabController : NSObject

-(UIColor*)getOuterColor;
-(UIColor*)getInnerColor;

// Added for the storyboard rework...
+(UIColor*)sGetInnerColor;
+(UIColor*)sGetOuterColor;
+(float) sGet_GUI_MULTIPLIER;

@end

@interface cTabOption : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UILabel* label;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImageView* imageViewer;
@property (nonatomic, weak) UIView* view;
@property (nonatomic, strong) UIViewWithGradient* colorView;
@property (nonatomic, strong) UIButton* button;

@end
