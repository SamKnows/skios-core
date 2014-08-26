//
//  cTabController.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "cTabController.h"


#define C_TAB_HEIGHT    50

#define C_OPTIONIMAGE_SIZE   29
#define C_OPTION_TEXT_Y 30
#define C_OPTION_IMAGE_Y 2
#define C_OPTION_SELECTOR_Y 45
#define C_OPTION_SELECTOR_HEIGHT    5

//#define C_OPTIONIMAGE_SIZE   20
//#define C_OPTION_TEXT_Y 4
//#define C_OPTION_IMAGE_Y 17
//#define C_OPTION_SELECTOR_Y 45
//#define C_OPTION_SELECTOR_HEIGHT    5

@implementation cTabController

-(void)initOnMasterView:(UIView*)masterView_
       withContentsView:(UIScrollView*)contentsScrollView_
             andTabView:(UIView*)tabView_
     andNumberOfOptions:(int)numberOfOptions_
{
    self.numberOfOptions = numberOfOptions_;
    
    self.masterView = masterView_;
    self.contentScrollView = contentsScrollView_;
    self.tabView = tabView_;
    
    self.contentScrollView.pagingEnabled = YES;
    self.arrOptions = [[NSMutableArray alloc] initWithCapacity:numberOfOptions_];
    
    vOptionSelector = [[UIView alloc] init];
    vOptionSelector.backgroundColor = [UIColor orangeColor];
    
    [self.tabView addSubview:vOptionSelector];
    self.selectedTab = 0;
    
    self.contentScrollView.delegate = self;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.bounces = NO;
    self.contentScrollView.backgroundColor = [UIColor clearColor];
    self.tabView.backgroundColor = [UIColor clearColor];
    
    self.GUI_WIDTH = self.masterView.bounds.size.width;
}

-(void)performLayout
{
    float optionStart;
    
    self.contentScrollView.frame = CGRectMake(0, 0, self.masterView.bounds.size.width, self.masterView.bounds.size.height - C_TAB_HEIGHT);
    self.tabView.frame = CGRectMake(0, self.masterView.bounds.size.height - C_TAB_HEIGHT, self.masterView.bounds.size.width, C_TAB_HEIGHT);
    self.contentScrollView.contentSize = CGSizeMake(self.masterView.bounds.size.width * self.numberOfOptions, self.masterView.bounds.size.height - C_TAB_HEIGHT);
    
    optionWidth = self.masterView.bounds.size.width / self.numberOfOptions;

    for (int i = 0; i < self.arrOptions.count; i++) {
        ((cTabOption*)self.arrOptions[i]).view.frame = CGRectMake(self.masterView.bounds.size.width * i, 0, self.masterView.bounds.size.width, self.masterView.bounds.size.height - C_TAB_HEIGHT);
        
        ((cTabOption*)self.arrOptions[i]).colorView.frame = self.masterView.bounds;
        
        optionStart = i * optionWidth;
        
        //TODO: Define protocol for these 2 methods.
        [((id<pViewManager>)((cTabOption*)self.arrOptions[i]).view) performLayout];
        
        ((cTabOption*)self.arrOptions[i]).imageViewer.frame = CGRectMake(optionStart, C_OPTION_IMAGE_Y, optionWidth, C_OPTIONIMAGE_SIZE);
        
        ((cTabOption*)self.arrOptions[i]).label.frame = CGRectMake(optionStart, C_OPTION_TEXT_Y, optionWidth, ((cTabOption*)self.arrOptions[i]).label.font.pointSize + 5);
        
        ((cTabOption*)self.arrOptions[i]).button.frame = CGRectMake(optionStart, 0, optionWidth, C_TAB_HEIGHT);
    }
    
    vOptionSelector.frame = CGRectMake(self.selectedTab * optionWidth, C_OPTION_SELECTOR_Y, optionWidth, C_OPTION_SELECTOR_HEIGHT);
    
    [self scrollViewDidScroll:self.contentScrollView];
    [self scrollViewDidEndDecelerating:self.contentScrollView];
}

-(void)addView:(UIView*)view_ withTitle:(NSString*)title_ andImage:(UIImage*)image_ andColorView:(UIViewWithGradient*)colorView_
{
    cTabOption* tabOption;
    
    tabOption = [[cTabOption alloc] init];
    
    tabOption.view = view_;
    tabOption.view.backgroundColor = [UIColor clearColor];
    tabOption.title = title_;
    tabOption.label = [[UILabel alloc] init];
    tabOption.label.text = tabOption.title;
    tabOption.label.font = [UIFont fontWithName:@"Roboto-Light" size:10];
    tabOption.label.textAlignment = UITextAlignmentCenter;
    tabOption.label.textColor = [UIColor lightGrayColor];
    tabOption.label.hidden = NO;
    
    tabOption.image = image_;
    tabOption.imageViewer = [[UIImageView alloc] init];
    tabOption.imageViewer.contentMode = UIViewContentModeScaleAspectFit;
    tabOption.imageViewer.image = tabOption.image;
    
    tabOption.button = [[UIButton alloc] init];
    tabOption.button.tag = self.arrOptions.count;
    [tabOption.button addTarget:self action:@selector(tabSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    tabOption.colorView = colorView_;
    
    [self.arrOptions addObject:tabOption];
    [self.tabView addSubview:tabOption.imageViewer];
    [self.tabView addSubview:tabOption.label];
    [self.tabView addSubview:tabOption.button];
    [((id<pViewManager>)view_) intialiseViewOnMasterView:self.masterView];
}

#pragma mark Tab Scroll View Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int cvF;
    int cvC;
    
    vOptionSelector.frame = CGRectMake(scrollView.contentOffset.x / scrollView.frame.size.width * optionWidth, C_OPTION_SELECTOR_Y, optionWidth, C_OPTION_SELECTOR_HEIGHT);

    if (shouldNOTAnimateColorsOnScroll) return;

    if (scrollView.contentOffset.x / scrollView.frame.size.width == roundf(scrollView.contentOffset.x / scrollView.frame.size.width))
    //Aligned to one of the screens
    {
        for (int i = 0; i < self.arrOptions.count; i++) {
            if (i <= roundf(scrollView.contentOffset.x / scrollView.frame.size.width))
                ((cTabOption*)self.arrOptions[i]).colorView.alpha = 1;
            else
                ((cTabOption*)self.arrOptions[i]).colorView.alpha = 0;
        }
    }
    else //Transition
    {
        cvF = floorf(scrollView.contentOffset.x / scrollView.frame.size.width);
        cvC = ceilf(scrollView.contentOffset.x / scrollView.frame.size.width);

        for (int i = 0; i < self.arrOptions.count; i++) {
            if (i <= cvF)
                ((cTabOption*)self.arrOptions[i]).colorView.alpha = 1;
            else if (i == cvC)
                ((cTabOption*)self.arrOptions[i]).colorView.alpha = scrollView.contentOffset.x / scrollView.frame.size.width - cvC + 1;
            else
                ((cTabOption*)self.arrOptions[i]).colorView.alpha = 0;
        }
    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [ ((id<pViewManager>)((cTabOption*)self.arrOptions[self.selectedTab]).view) deactivate];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.selectedTab == (int)roundf(self.contentScrollView.contentOffset.x / self.masterView.bounds.size.width))
    {
        [((id<pViewManager>)((cTabOption*)self.arrOptions[self.selectedTab]).view) activate];
        return;
    }
    
    [ ((id<pViewManager>)((cTabOption*)self.arrOptions[self.selectedTab]).view) deactivate];

    ((cTabOption*)self.arrOptions[self.selectedTab]).colorView.alpha = 0;
    self.selectedTab = (int)roundf(self.contentScrollView.contentOffset.x / self.masterView.bounds.size.width);
    
    [((id<pViewManager>)((cTabOption*)self.arrOptions[self.selectedTab]).view) activate];
}

-(void)tabSelected:(id)sender {
    if (self.contentScrollView.contentOffset.x == ((UIButton*)sender).tag * self.masterView.bounds.size.width) return;
    
    [((id<pViewManager>)((cTabOption*)self.arrOptions[self.selectedTab]).view) deactivate];
    self.selectedTab = (int)((UIButton*)sender).tag;
    [((id<pViewManager>)((cTabOption*)self.arrOptions[self.selectedTab]).view) activate];
    
    shouldNOTAnimateColorsOnScroll = YES;
    
    //This part of the transition can be animated as well. For know it is not.
    [UIView animateWithDuration:0.0 animations:^{

        self.contentScrollView.alpha = 0;
        vOptionSelector.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.contentScrollView.contentOffset = CGPointMake(((UIButton*)sender).tag * self.masterView.bounds.size.width, 0);
        shouldNOTAnimateColorsOnScroll = NO;
        
        [UIView animateWithDuration:0.2 animations:^{

            for (int i = 0; i < self.arrOptions.count; i++)
            {
                if (i <= self.selectedTab) ((cTabOption*)self.arrOptions[i]).colorView.alpha = 1;
                else ((cTabOption*)self.arrOptions[i]).colorView.alpha = 0;
            }
            
            self.contentScrollView.alpha = 1;
            vOptionSelector.alpha = 1;
            
        } completion:^(BOOL finished) {
        }];
    }];
}

-(UIColor*)getInnerColor
{
    if (self.arrOptions.count == 0) return [UIColor colorWithRed:0.0/255.0 green:159.0/255.0 blue:227.0/255.0 alpha:1];
    return ((cTabOption*)self.arrOptions[self.selectedTab]).colorView.innerColor;
}

-(UIColor*)getOuterColor
{
    if (self.arrOptions.count == 0) return [UIColor colorWithRed:37.0/255.0 green:82.0/255.0 blue:164.0/255.0 alpha:1];
    return ((cTabOption*)self.arrOptions[self.selectedTab]).colorView.outerColor;
}

+(cTabController*)globalInstance
{
    static cTabController *globalTabController = nil;

    if (globalTabController == nil)
    {
        globalTabController = [[self alloc] init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            globalTabController.GUI_MULTIPLIER = 768.0 / 320.0;
        else
            globalTabController.GUI_MULTIPLIER = 1;
        globalTabController.GUI_WIDTH = globalTabController.masterView.bounds.size.width;
    }

    return globalTabController;
}

@end

@implementation cTabOption

@end