//
//  cActionSheet.m
//  FCCMckp001
//
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "cActionSheet.h"

@implementation cOptionDefinition

@end

@implementation cActionSheet

-(id)initOnView:(UIView*)parView withDelegate:(id<pActionSheetDelegate>)dlgt mainTitle:(NSString*)mainButtonTitle_
{
    if (self = [super init])
    {
        self.delegate = dlgt;
        self.parentView = parView;
        self.masterView = [[UIView alloc] initWithFrame:CGRectMake(parView.bounds.origin.x, parView.bounds.origin.y, parView.bounds.size.width, parView.bounds.size.height)];
        self.masterView.hidden = YES;
        self.masterView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
        [self.parentView addSubview:self.masterView];

        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        self.backgroundView.layer.cornerRadius = 3;
        self.backgroundView.layer.borderWidth = 1;
        self.backgroundView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
        
        self.backgroundView.clipsToBounds = YES;
        
        self.backgroundGradientView = [[UIViewWithGradient alloc] initWithFrame:self.backgroundView.bounds];
        
        self.backgroundGradientView.innerColor = [cTabController sGetInnerColor];
        self.backgroundGradientView.outerColor = [cTabController sGetOuterColor];
        
        [self.backgroundView addSubview:self.backgroundGradientView];

        [self.masterView addSubview:self.backgroundView];

        self.btCancel = [[UIButton alloc] initWithFrame:self.backgroundView.bounds];
        [self.btCancel addTarget:self action:@selector(mainButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.btCancel.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:[cTabController sGet_GUI_MULTIPLIER] * 14];
        self.btCancel.titleLabel.alpha = 0.7;
        
        [self.btCancel setTitle:mainButtonTitle_ forState:UIControlStateNormal];
        [self.btCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.backgroundView addSubview:self.btCancel];

        self.arrOptions = [[NSMutableArray alloc] init];
    }
    return self;
}

#define C_BUTTON_INSET_X    ([cTabController sGet_GUI_MULTIPLIER] * 20)

-(void)expand
{
    float optHeight = [cTabController sGet_GUI_MULTIPLIER] * 40;
    float optSpaceV = [cTabController sGet_GUI_MULTIPLIER] * 10;
    float cancelOffestV = [cTabController sGet_GUI_MULTIPLIER] * 50;
    
    CGRect rectEndBackground;
    rectEndBackground = CGRectMake(self.parentView.bounds.origin.x, self.parentView.bounds.origin.y, self.parentView.bounds.size.width, self.parentView.bounds.size.height);
    
    rectEndBackground.origin.x += 25;
    rectEndBackground.origin.y += 25;
    rectEndBackground.size.height -= 50;
    rectEndBackground.size.width -= 50;

    self.masterView.frame = self.parentView.bounds;
    self.backgroundView.frame = CGRectMake(rectEndBackground.size.width / 2, rectEndBackground.size.height / 2, 0, 0);
    
    self.masterView.alpha = 0;
    self.masterView.hidden = NO;
    self.btCancel.alpha = 0;
    
    for (cOptionDefinition *option in self.arrOptions) {
        option.label.alpha = 0;
        option.imageView.alpha = 0;
        option.button.alpha = 0;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.masterView.alpha = 1;
        self.backgroundView.frame = rectEndBackground;
        self.backgroundGradientView.frame = self.backgroundView.bounds;
    } completion:^(BOOL finished) {
        if (finished)
        {
            self.btCancel.frame = CGRectMake(0, rectEndBackground.size.height - cancelOffestV, rectEndBackground.size.width, [cTabController sGet_GUI_MULTIPLIER] * 30);
            float optionsStartY = (rectEndBackground.size.height - self.arrOptions.count * optHeight - (self.arrOptions.count - 1) * optSpaceV) / 2;
            
            int optionNumber;
            optionNumber = 0;
            for (cOptionDefinition *option in self.arrOptions) {
                option.label.frame = CGRectMake(0 + C_BUTTON_INSET_X, optionsStartY + optionNumber * (optHeight + optSpaceV), rectEndBackground.size.width - C_BUTTON_INSET_X - C_BUTTON_INSET_X, optHeight);
                option.button.frame = option.label.frame;
                
                //                CGRect paragraphRect = [option.label.text boundingRectWithSize:CGSizeMake(1000, 1000) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
                //                option.imageView.frame = CGRectMake((self.backgroundView.bounds.size.width - paragraphRect.size.width) / 2 - optHeight - 10, optionsStartY + optionNumber * (optHeight + optSpaceV) + 5, optHeight - 10, optHeight - 10 );
                
                option.imageView.frame = CGRectMake([cTabController sGet_GUI_MULTIPLIER] * 40, optionsStartY + optionNumber * (optHeight + optSpaceV) + [cTabController sGet_GUI_MULTIPLIER] * 5, optHeight - [cTabController sGet_GUI_MULTIPLIER] * 10, optHeight - [cTabController sGet_GUI_MULTIPLIER] * 10 );

                optionNumber++;
            }
            
            [UIView animateWithDuration:0.2 animations:^{
                self.btCancel.alpha = 1;
                for (cOptionDefinition *option in self.arrOptions) {
                    option.label.alpha = 1;
                    option.imageView.alpha = 1;
                    option.button.alpha = 1;
                }
            }];
        }
    }];
}

-(void)mainButtonPressed
{
    [UIView animateWithDuration:0.2 animations:^{
        self.masterView.alpha = 0;
    } completion:^(BOOL finished) {
        self.masterView.hidden = YES;
        [self.delegate selectedMainButtonFrom:self];
    }];
}

+(void)formatView:(UIView*)view_
{
    view_.layer.borderColor = [UIColor colorWithWhite
                                 :1 alpha:0.5].CGColor;
    view_.layer.borderWidth = 1;
    view_.layer.cornerRadius = 3;
}

-(cOptionDefinition*)optionForButton:(UIButton*)button_
{
    cOptionDefinition* option = nil;
    for (int i = 0; i < self.arrOptions.count; i++) {
        if (((cOptionDefinition*)self.arrOptions[i]).button == button_)
        {
            option = self.arrOptions[i];
            i = (int)self.arrOptions.count;
        }
    }

    return option;
}

-(void)optionButtonPressed:(UIButton*)sender
{
    cOptionDefinition* option = [self optionForButton:sender];

    if (option.state < 0)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.masterView.alpha = 0;
        } completion:^(BOOL finished) {
            self.masterView.hidden = YES;
            [self.delegate selectedOption:(int)sender.tag from:self];
            [self formatButton:option];
        }];
    }
    else
    {
        option.state = 1 - option.state;
        [self formatButton:option];
    }
}

-(void)optionTouched:(UIButton*)sender
{
    sender.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
}

-(void)optionReleased:(UIButton*)sender
{
    [self formatButton:[self optionForButton:sender]];
}

-(void)addOption:(NSString *)optionTitle withImage:(UIImage *)optionImage andTag:(int)optionTag
{
    [self addOption:optionTitle withImage:optionImage andTag:optionTag andState:-1];
}

-(void)addOption:(NSString *)optionTitle withImage:(UIImage *)optionImage andTag:(int)optionTag andState:(int)state_
{
    cOptionDefinition* option;
    
    if (state_ > 1) state_ = 1;
    if (state_ < -1) state_ = -1;
    
    option = [[cOptionDefinition alloc] init];
    option.title = optionTitle;
    option.image = optionImage;
    option.tag = optionTag;
    option.label = [[UILabel alloc] init];
    option.label.text = optionTitle;
    option.label.textAlignment = NSTextAlignmentCenter;
    option.label.textColor = [UIColor whiteColor];
    option.label.font = [UIFont fontWithName:@"Roboto-Light" size:[cTabController sGet_GUI_MULTIPLIER] * 14];
    
    option.button = [[UIButton alloc] init];
    [option.button addTarget:self action:@selector(optionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [option.button addTarget:self action:@selector(optionTouched:) forControlEvents:UIControlEventTouchDown];
    [option.button addTarget:self action:@selector(optionReleased:) forControlEvents:UIControlEventTouchUpOutside];
    [option.button addTarget:self action:@selector(optionReleased:) forControlEvents:UIControlEventTouchDragExit];
    
    option.button.tag = optionTag;
    
    option.state = state_;
    [self formatButton:option];
    
    [cActionSheet formatView:option.button];
    
    option.imageView = [[UIImageView alloc] init];
    option.imageView.image = optionImage;
    
    [self.backgroundView addSubview:option.button];
    [self.backgroundView addSubview:option.label];
    [self.backgroundView addSubview:option.imageView];
    
    [self.arrOptions addObject:option];
}

-(void)formatButton:(cOptionDefinition*)optionDefinition_
{
    switch (optionDefinition_.state) {
        case -1:
        case 0:
            optionDefinition_.button.backgroundColor = [UIColor clearColor];
            optionDefinition_.label.textColor = [UIColor whiteColor];
            break;
        default:
            optionDefinition_.button.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            optionDefinition_.label.textColor = [UIColor colorWithRed:44.0/255.0 green:66.0/255.0 blue:149.0/255.0 alpha:1];
            break;
    }
}

@end
