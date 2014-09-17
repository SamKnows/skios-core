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

-(void)intialiseViewOnMasterView:(UIView*)masterView_;
-(void)performLayout;

@optional
-(void)activate;
-(void)deactivate;

@end

@interface cTabController : NSObject <UIScrollViewDelegate>
{
    UIView* vOptionSelector;
    float optionWidth;
    bool shouldNOTAnimateColorsOnScroll;
}

@property (nonatomic) float GUI_MULTIPLIER;
@property (nonatomic) float GUI_WIDTH;

@property (nonatomic, weak) UIView* masterView;
@property (nonatomic, weak) UIScrollView* contentScrollView;
@property (nonatomic, weak) UIView* tabView;
@property (nonatomic) int numberOfOptions;
@property (nonatomic, strong) NSMutableArray* arrOptions;

@property (nonatomic) int selectedTab;

+(cTabController*)globalInstance;

-(void)initOnMasterView:(UIView*)masterView_
        withContentsView:(UIScrollView*)contentsScrollView_
        andTabView:(UIView*)tabView_
     andNumberOfOptions:(int)numberOfOptions_;
-(void)addView:(UIView*)view_ withTitle:(NSString*)title_ andImage:(UIImage*)image_ andColorView:(UIView*)colorView_;
-(void)performLayout;
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
