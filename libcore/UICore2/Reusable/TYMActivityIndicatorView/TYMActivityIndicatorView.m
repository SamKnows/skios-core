//
//  TYMActivityIndicatorView.m
//  TYMActivityIndicatorView
//
//  Created by Yiming Tang on 14-2-9.
//  Copyright (c) 2014 Yiming Tang. All rights reserved.
//

#import "TYMActivityIndicatorView.h"
#import "../SKAppColourScheme/SKAppColourScheme.h"

@interface TYMActivityIndicatorView ()

@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) UIImageView *indicatorImageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation TYMActivityIndicatorView

#pragma mark - Accessors

@synthesize animating = _animating;
@synthesize indicatorImage = _indicatorImage;
@synthesize backgroundImage = _backgroundImage;
@synthesize indicatorImageView = _indicatorImageView;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize hidesWhenStopped = _hidesWhenStopped;
@synthesize fullRotationDuration = _fullRotationDuration;
@synthesize progress = _progress;
@synthesize minProgressUnit = _minProgressUnit;
@synthesize activityIndicatorViewStyle = _activityIndicatorViewStyle;

-(CGPoint)getOuterPointFor:(CGPoint)point_ forCenter:(CGPoint)center_ atDistance:(float)distance_
{
    CGPoint directionVector;
    directionVector = CGPointMake(point_.x - center_.x, point_.y - center_.y);
    
    return CGPointMake(point_.x + distance_ * directionVector.x, point_.y + distance_ * directionVector.y);
}

#define C_LABEL_WIDTH   ([SKAppColourScheme sGet_GUI_MULTIPLIER] * 60)
#define C_LABEL_HEIGHT   ([SKAppColourScheme sGet_GUI_MULTIPLIER] * 10)

-(void)drawText:(NSString*)labelText_ atAngle:(float)angle_ inContext:(CGContextRef)context_
{
    CGRect labelRect;
    CGPoint labelCenter;
    
    float angleTransformed = angle_ + M_PI_4;
    
    float radiusInner = self.bounds.size.width * 0.36;
    CGPoint mainCenter = CGPointMake(self.bounds.origin.x + self.bounds.size.width/2, self.bounds.origin.y + self.bounds.size.width/2);
    
    CGContextBeginPath(context_);
    labelCenter = CGPointMake(mainCenter.x + radiusInner * sin(angleTransformed), mainCenter.y + radiusInner * cos(angleTransformed));
    
    UIFont* labelFont = [UIFont fontWithName:@"DINCondensed-Bold" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 12];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                labelFont, NSFontAttributeName,
                                style, NSParagraphStyleAttributeName,
                                [UIColor orangeColor], NSForegroundColorAttributeName,
                                nil];
    labelRect = CGRectMake(labelCenter.x - C_LABEL_WIDTH / 2, labelCenter.y - C_LABEL_HEIGHT / 2, C_LABEL_WIDTH, C_LABEL_HEIGHT);
    
    [labelText_ drawInRect:labelRect withAttributes:attributes];
    CGContextStrokePath(context_);
}

-(void)drawRect:(CGRect)rect
{
    NSString* labelText;
    float angleForDots;

    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    {
        context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 2.0);
        
        float angle = 0;
        CGPoint mainCenter = CGPointMake(self.bounds.origin.x + self.bounds.size.width/2, self.bounds.origin.y + self.bounds.size.width/2);
        float radiusOuter = self.bounds.size.width/ 2  ;
        float radiusInner = self.bounds.size.width/ 2  - (self.frame.size.width / 23);
        CGPoint smallCircleCenter;
        CGRect smallCircleRect;
        
        CGContextSaveGState(context);
        
        for (int i = 0; i <= 60; i++) {
            
            angle = i * (M_PI / 40);
            angleForDots = M_PI + M_PI_2 + M_PI_4 - i * (M_PI / 40);
            
            if (i % 10 == 0)
            {
            }
            
            {
                CGContextBeginPath(context);
                CGContextSetLineWidth(context, 3.0);
                if (i <= 60 * self.realAngle / 270)
                    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
                else
                    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
                
                smallCircleCenter = CGPointMake(mainCenter.x + radiusInner * sin(angleForDots), mainCenter.y + radiusInner * cos(angleForDots));
                smallCircleRect = CGRectMake(smallCircleCenter.x - 1.5, smallCircleCenter.y - 1.5, 3, 3);
                // CGContextAddEllipseInRect(context, smallCircleRect);
                CGContextStrokePath(context);
                angle += 3 * M_PI_4;
                
                CGContextBeginPath(context);
                
                if (self.realAngle > 0 && i <= 60.0 * self.realAngle / 270)
                    CGContextSetRGBStrokeColor(context, 255.0/255.0, 0.0/255.0, 0.0/255.0, 1.0);
                else
                    CGContextSetRGBStrokeColor(context, 255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0);
                
                CGContextSetLineWidth(context, C_ARCH_THICK_WIDTH);
                CGContextAddArc(context, mainCenter.x, mainCenter.y, radiusOuter - C_ARCH_THICK_WIDTH / 2, angle - M_PI / 95.0, angle + M_PI / 95.0, NO);
                CGContextStrokePath(context);
                
                if (i % 10 == 0)
                {
                    CGContextBeginPath(context);
                    CGContextSetRGBStrokeColor(context, 155.0/255.0, 155.0/255.0, 155.0/255.0, 1);
                    CGContextSetLineWidth(context, self.frame.size.width / 24);
                    CGContextAddArc(context, mainCenter.x, mainCenter.y, radiusInner - C_ARCH_THICK_WIDTH / 2, angle - M_PI / 95.0, angle + M_PI / 95.0, NO);
                    CGContextStrokePath(context);
                    
                    //Label
                    if (self.arrLabels.count == 0)
                        labelText = @"";
                    else
                        labelText = (NSString*)self.arrLabels[6 - i / 10];
                    [self drawText:labelText atAngle:i * (M_PI / 40) inContext:context];
                }
            }
        }

        CGContextRestoreGState(context);
    }
}

- (UIView *)vCenterFillingStopped
{
    if (!_vCenterFillingStopped) {
        _vCenterFillingStopped = [[UIView alloc] initWithFrame:self.bounds];
        _vCenterFillingStopped.backgroundColor = [UIColor greenColor];
        _vCenterFillingStopped.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _vCenterFillingStopped.layer.cornerRadius = self.bounds.size.width / 2;
        
        _vCenterFillingStopped.hidden = YES;
    }
    return _vCenterFillingStopped;
}

- (UIView *)vCenterFillingRunning
{
    if (!_vCenterFillingRunning) {
        _vCenterFillingRunning = [[UIView alloc] initWithFrame:self.bounds];
        _vCenterFillingRunning.backgroundColor = [UIColor redColor];
        _vCenterFillingRunning.alpha = 0;
        _vCenterFillingRunning.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _vCenterFillingRunning.layer.cornerRadius = self.bounds.size.width / 2;
        _vCenterFillingRunning.hidden = YES;
    }
    return _vCenterFillingRunning;
}

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.alpha = 0.3;
    }
    return _backgroundImageView;
}

- (UIImageView *)indicatorImageView
{
    if (!_indicatorImageView) {
        _indicatorImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _indicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _indicatorImageView.alpha = 0;
    }
    return _indicatorImageView;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = _backgroundImage;
    [self setNeedsLayout];
}

- (void)setIndicatorImage:(UIImage *)indicatorImage
{
    _indicatorImage = indicatorImage;
    self.indicatorImageView.image = _indicatorImage;
    [self setNeedsLayout];
}

-(void)setTopInfo:(NSString*)topInfo_
{
    self.lTopInfo1.text = topInfo_;
}

- (void)setActivityIndicatorViewStyle:(TYMActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    self.arrLabels = [[NSMutableArray alloc] init];
//    [self.arrLabels addObject:@"*"];

    self.lCurrentResult = [[UILabel alloc] initWithFrame:self.bounds];
    self.lCurrentResult.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.lCurrentResult.textAlignment = NSTextAlignmentCenter;
    self.lCurrentResult.font = [UIFont fontWithName:@"DINCondensed-Bold" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 80];
    self.lCurrentResult.textColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.lCurrentResult.backgroundColor = [UIColor clearColor];
    self.lCurrentResult.adjustsFontSizeToFitWidth = YES;
    self.lCurrentResult.minimumFontSize = 12;
    [self addSubview:self.lCurrentResult];
    
    _activityIndicatorViewStyle = activityIndicatorViewStyle;
    
    NSString *backgroundImageName;
    NSString *indicatorImageName;
    switch (_activityIndicatorViewStyle) {
        case TYMActivityIndicatorViewStyleNormal:
            backgroundImageName = @"TYMActivityIndicatorView.bundle/spbackground";
            indicatorImageName = @"TYMActivityIndicatorView.bundle/spprogress";
            break;
        case TYMActivityIndicatorViewStyleLarge:
            backgroundImageName = @"TYMActivityIndicatorView.bundle/background-large";
            indicatorImageName = @"TYMActivityIndicatorView.bundle/spinner-large";
            break;
    }

    backgroundImageName = @"background-large";
    indicatorImageName = @"spinner-large";

//    _backgroundImage = [UIImage imageNamed:backgroundImageName];
//    _indicatorImage = [UIImage imageNamed:indicatorImageName];
    
    self.backgroundImageView.image = _backgroundImage;
    self.indicatorImageView.image = _indicatorImage;
    
    self.lTopInfo1 = [[UILabel alloc] initWithFrame:self.bounds];
    self.lTopInfo1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.lTopInfo1.textAlignment = NSTextAlignmentCenter;
    self.lTopInfo1.font = [UIFont fontWithName:@"DINCondensed-Bold" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 25];
    self.lTopInfo1.textColor = [UIColor orangeColor];
    self.lTopInfo1.adjustsFontSizeToFitWidth = YES;
    self.lTopInfo1.minimumFontSize = 12;
    [self addSubview:self.lTopInfo1];
    
    self.lUnit = [[UILabel alloc] initWithFrame:self.bounds];
    self.lUnit.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.lUnit.textAlignment = NSTextAlignmentCenter;
    self.lUnit.font = [UIFont fontWithName:@"DINCondensed-Bold" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 25];
    self.lUnit.textColor = [UIColor orangeColor];
    [self addSubview:self.lUnit];

    self.lMeasurement = [[UILabel alloc] initWithFrame:self.bounds];
    self.lMeasurement.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.lMeasurement.textAlignment = NSTextAlignmentCenter;
    self.lMeasurement.font = [UIFont fontWithName:@"Roboto-Regular" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 12];
    self.lMeasurement.textColor = [UIColor orangeColor];
    [self addSubview:self.lMeasurement];

    self.btButton = [[UIButton alloc] initWithFrame:self.bounds];
    [self.btButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.btButton addTarget:self action:@selector(buttonTouched) forControlEvents:UIControlEventTouchDown];
    [self.btButton addTarget:self action:@selector(buttonReleased) forControlEvents:UIControlEventTouchUpOutside];
    self.btButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.btButton];
    
    [self setNeedsLayout];
    
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 0.04
                                                  target:self
                                                selector:@selector(handleTimer)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer: self.timer forMode: NSRunLoopCommonModes];
}

- (BOOL)isAnimating
{
    return self.animating;
}

-(void)buttonPressed
{
//    [self buttonReleased];
    [self.activityOwner buttonPressed];
}

-(void)buttonTouched
{
    if (self.isAnimating)
    {
        self.vCenterFillingStopped.alpha = 0;
        self.vCenterFillingRunning.alpha = 0.5;
    }
    else
        self.vCenterFillingStopped.alpha = 0.5;
}

-(void)buttonReleased
{
    if (self.isAnimating)
    {
        self.vCenterFillingRunning.alpha = 1;
        self.vCenterFillingStopped.alpha = 1;
    }
    else
        self.vCenterFillingStopped.alpha = 1;
}

#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self _initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self _initialize];
    }
    return self;
}

- (id)initWithActivityIndicatorStyle:(TYMActivityIndicatorViewStyle)style
{
    if ((self = [self initWithFrame:CGRectZero])) {
        self.activityIndicatorViewStyle = style;
        [self sizeToFit];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;

//    CGSize backgroundImageSize = self.backgroundImageView.image.size;
//    CGSize indicatorImageSize = self.indicatorImageView.image.size;

    CGSize backgroundImageSize = self.backgroundImageView.bounds.size;
    CGSize indicatorImageSize = self.indicatorImageView.bounds.size;

    // Center
    
    self.backgroundColor = [UIColor clearColor];
    
    self.backgroundImageView.frame = CGRectMake(roundf((size.width - backgroundImageSize.width) / 2.0f), roundf((size.height - backgroundImageSize.height) / 2.0f), backgroundImageSize.width, backgroundImageSize.height);
    self.indicatorImageView.frame = CGRectMake(roundf((size.width - indicatorImageSize.width) / 2.0f), roundf((size.height - indicatorImageSize.height) / 2.0f), indicatorImageSize.width, indicatorImageSize.height);

    float centerFillingSize = self.indicatorImageView.frame.size.width - 34;
    
    self.vCenterFillingStopped.frame = CGRectMake(roundf((self.indicatorImageView.frame.size.width - centerFillingSize) / 2.0f), roundf((self.indicatorImageView.frame.size.height - centerFillingSize) / 2.0f), centerFillingSize, centerFillingSize);
    self.vCenterFillingStopped.layer.cornerRadius = centerFillingSize / 2;

    self.vCenterFillingRunning.frame = CGRectMake(self.vCenterFillingStopped.frame.origin.x - 1, self.vCenterFillingStopped.frame.origin.y - 1, self.vCenterFillingStopped.frame.size.width + 2, self.vCenterFillingStopped.frame.size.height + 2);
    self.vCenterFillingRunning.layer.cornerRadius = self.vCenterFillingRunning.frame.size.width / 2;
    
    self.lCurrentResult.frame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * 0.2, self.bounds.origin.y + 0.18 * self.lCurrentResult.font.pointSize, self.bounds.size.width * 0.6, self.bounds.size.height);

    self.lTopInfo1.frame = CGRectMake(self.bounds.origin.x + 0.25 * self.bounds.size.width, 0.25 * self.bounds.size.height, 0.5 * self.bounds.size.width, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 25);
    
    self.lUnit.frame = CGRectMake(self.bounds.origin.x, self.bounds.size.height * 0.67, self.bounds.size.width, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 25);
    self.lMeasurement.frame = CGRectMake(self.bounds.origin.x, self.bounds.size.height * 0.77, self.bounds.size.width, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 20);
    
    self.btButton.frame = self.indicatorImageView.frame;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize backgroundImageSize = self.backgroundImageView.image.size;
    CGSize indicatorImageSize = self.indicatorImageView.image.size;
    
    return CGSizeMake(fmaxf(backgroundImageSize.width, indicatorImageSize.width), fmaxf(backgroundImageSize.height, indicatorImageSize.height));
}

#pragma mark - Public

- (void)startAnimating
{
    if (self.animating) return;
    
    self.animating = YES;
    self.hidden = NO;
    
//    self.btButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.vCenterFillingRunning.alpha = 1;
        self.vCenterFillingStopped.alpha = 0;
        self.indicatorImageView.alpha = 0.1;
        self.backgroundImageView.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) self.btButton.userInteractionEnabled = YES;
    }];

    [self _rotateImageViewFrom:0.0f to:M_PI*2 duration:self.fullRotationDuration repeatCount:HUGE_VALF];
}

- (void)stopAnimating
{
    if (!self.animating) return;
    
    NSMutableArray* arrTmp = self.arrLabels;
    
    self.arrLabels = nil;
//    self.btButton.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.vCenterFillingRunning.alpha = 0;
        self.vCenterFillingStopped.alpha = 1;
        self.indicatorImageView.alpha = 0;
        self.backgroundImageView.alpha = 0.3;
        
        self.lMeasurement.alpha = 0;
        self.lUnit.alpha = 0;
        
    } completion:^(BOOL finished) {
        if (finished)
        {
            self.animating = NO;
            
            self.lMeasurement.text = nil;
            self.lUnit.text = nil;
            self.lMeasurement.alpha = 1;
            self.lUnit.alpha = 1;

            [self.indicatorImageView.layer removeAllAnimations];
            if (self.hidesWhenStopped) {
                self.hidden = YES;
            }
            self.btButton.userInteractionEnabled = YES;
        }
    }];
    
    [self setNeedsDisplay];
    
    self.arrLabels = arrTmp;
}

-(void)handleTimer
{
    if (fabsf(self.realAngle - self.desiredAngle) < C_ANGLE_STEP / 2) return;
    
    if (self.realAngle < self.desiredAngle)
    {
        self.realAngle += C_ANGLE_STEP;
    }
    else if (self.realAngle > self.desiredAngle)
    {
        self.realAngle -= C_ANGLE_STEP;
    }
    [self setNeedsDisplay];
}

#pragma mark - Private

- (void)_initialize
{
    _animating = NO;
    _hidesWhenStopped = YES;
    _fullRotationDuration = 3.0f;
    _minProgressUnit = 0.01f;
    _progress = 0.0f;
    
    [self addSubview:self.backgroundImageView];
    [self addSubview:self.vCenterFillingStopped];
    [self addSubview:self.vCenterFillingRunning];
    [self addSubview:self.indicatorImageView];
    [self addSubview:self.btButton];
}

- (void)_rotateImageViewFrom:(CGFloat)fromValue to:(CGFloat)toValue duration:(CFTimeInterval)duration repeatCount:(CGFloat)repeatCount
{
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:fromValue];
    rotationAnimation.toValue = [NSNumber numberWithFloat:toValue];
    rotationAnimation.duration = duration;
    rotationAnimation.RepeatCount = repeatCount;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    [self.indicatorImageView.layer addAnimation:rotationAnimation forKey:@"rotation"];
}

-(void)setCurrentResult:(NSString*)currentResult
{
    self.lCurrentResult.text = currentResult;
}

-(void)setAngle:(float)angle_
{
    if (angle_ > 270) angle_ = 271;
    self.desiredAngle = angle_;
}

-(void)displayReset:(NSString*)nextValue_
{
    [UIView animateWithDuration:0.3 animations:^{
        self.lCurrentResult.alpha = 0;
    } completion:^(BOOL finished) {
        self.lCurrentResult.text = nextValue_;
        [UIView animateWithDuration:0.3 animations:^{
            self.lCurrentResult.alpha = 1;
        }];
    }];
}

-(void)setUnitMeasurement:(NSString*)unit_ measurement:(NSString*)measurement_
{
    self.lUnit.alpha = 0;
    self.lUnit.text = unit_;
    self.lMeasurement.alpha = 0;
    self.lMeasurement.text = measurement_;

    [UIView animateWithDuration:0.5 animations:^{
        self.lUnit.alpha = 1;
        self.lMeasurement.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}
@end
