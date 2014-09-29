//
//  SKInfoViewMgr.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKInfoViewMgr : UIView <UIWebViewDelegate>

@property (nonatomic, weak) UIView* masterView;
@property (weak, nonatomic) IBOutlet UIWebView *wvWebView;

-(void)intialiseViewOnMasterView:(UIView*)masterView_;
-(void)setColoursAndShowHideElements;
-(void)performLayout;

@end
