/*
 CGaugeView.m
 CGaugeView
 
 Created by Yiming Tang on 14-2-9.
 Copyright (c) 2014 Yiming Tang. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "CGaugeView.h"
#import "../SKAppColourScheme/SKAppColourScheme.h"

@interface CGaugeView ()

@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) UIImageView *indicatorImageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation CGaugeView

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

-(void)drawText:(NSString*)labelText_ atAngle:(float)angle_ inContext:(CGContextRef)context_ WithColor:(UIColor*)withColor
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
                              withColor, NSForegroundColorAttributeName,
                              nil];
  labelRect = CGRectMake(labelCenter.x - C_LABEL_WIDTH / 2, labelCenter.y - C_LABEL_HEIGHT / 2, C_LABEL_WIDTH, C_LABEL_HEIGHT);
  
  [labelText_ drawInRect:labelRect withAttributes:attributes];
  CGContextStrokePath(context_);
}

-(void)drawRect:(CGRect)rect
{
  NSString* labelText;
  //float angleForDots;
  
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
    //CGPoint smallCircleCenter;
    //CGRect smallCircleRect;
    
    CGContextSaveGState(context);
    
    for (int i = 0; i <= 60; i++) {
      
      angle = i * (M_PI / 40);
      // angleForDots = M_PI + M_PI_2 + M_PI_4 - i * (M_PI / 40);
      
      if (i % 10 == 0)
      {
      }
      
      {
        CGContextBeginPath(context);
        CGContextSetLineWidth(context, 3.0);
        if (i <= 60 * self.realAngle / 270) {
          CGContextSetStrokeColorWithColor(context, [SKAppColourScheme sGetMainColourDialArcRedZone].CGColor);
        }
        else {
          CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
        }
        
        //smallCircleCenter = CGPointMake(mainCenter.x + radiusInner * sin(angleForDots), mainCenter.y + radiusInner * cos(angleForDots));
        //smallCircleRect = CGRectMake(smallCircleCenter.x - 1.5, smallCircleCenter.y - 1.5, 3, 3);
        // CGContextAddEllipseInRect(context, smallCircleRect);
        CGContextStrokePath(context);
        angle += 3 * M_PI_4;
        
        CGContextBeginPath(context);
        
        if (self.realAngle > 0 && i <= 60.0 * self.realAngle / 270)
          CGContextSetStrokeColorWithColor(context, [SKAppColourScheme sGetMainColourDialOuterTicksMeasuredValue].CGColor);
        else
          CGContextSetStrokeColorWithColor(context, [SKAppColourScheme sGetMainColourDialOuterTicksDefault].CGColor);
        
        CGContextSetLineWidth(context, C_ARCH_THICK_WIDTH);
        CGContextAddArc(context, mainCenter.x, mainCenter.y, radiusOuter - C_ARCH_THICK_WIDTH / 2, angle - M_PI / 95.0, angle + M_PI / 95.0, NO);
        CGContextStrokePath(context);
        
        if (i % 10 == 0)
        {
          CGContextBeginPath(context);
          CGContextSetStrokeColorWithColor(context, [SKAppColourScheme  sGetMainColourDialInnerTicks].CGColor);
          CGContextSetLineWidth(context, self.frame.size.width / 24);
          CGContextAddArc(context, mainCenter.x, mainCenter.y, radiusInner - C_ARCH_THICK_WIDTH / 2, angle - M_PI / 95.0, angle + M_PI / 95.0, NO);
          CGContextStrokePath(context);
          
          // Label
          if (self.arrLabels.count == 0)
            labelText = @"";
          else
            labelText = (NSString*)self.arrLabels[6 - i / 10];
          [self drawText:labelText atAngle:i * (M_PI / 40) inContext:context WithColor:[SKAppColourScheme  sGetMainColourDialInnerLabelText]];
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
    _vCenterFillingRunning.backgroundColor = [SKAppColourScheme sGetMainColourDialArcRedZone];
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

-(void)setTopText:(NSString*)topInfo_
{
  self.mTopText.text = topInfo_;
}

- (void)setActivityIndicatorViewStyle:(CGaugeViewStyle)activityIndicatorViewStyle
{
  self.arrSegmentMinValues = [[NSMutableArray alloc] init];
  self.arrSegmentMaxValues = [[NSMutableArray alloc] init];
  self.arrLabels = [[NSMutableArray alloc] init];
  //    [self.arrLabels addObject:@"*"];
  
  self.mCenterText = [[UILabel alloc] initWithFrame:self.bounds];
  self.mCenterText.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.mCenterText.textAlignment = NSTextAlignmentCenter;
  self.mCenterText.font = [UIFont fontWithName:@"DINCondensed-Bold" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 80];
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    // Actually, make smaller on iPad
    self.mCenterText.font = [UIFont fontWithName:@"DINCondensed-Bold" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 66];
  }
  else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
  {
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height < 568)
    {
      // iPhone 4 or earlier!
      self.mCenterText.font = [UIFont fontWithName:@"DINCondensed-Bold" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 66];
    }
  }
  self.mCenterText.textColor = [SKAppColourScheme  sGetMainColourDialCenterText];
  self.mCenterText.backgroundColor = [UIColor clearColor];
  self.mCenterText.adjustsFontSizeToFitWidth = YES;
  self.mCenterText.minimumScaleFactor = 0.1; // minimumFontSize = 12 is deprecated from iOS 6
  [self addSubview:self.mCenterText];
  
  _activityIndicatorViewStyle = activityIndicatorViewStyle;
  
  self.backgroundImageView.image = _backgroundImage;
  self.indicatorImageView.image = _indicatorImage;
  
  self.mTopText = [[UILabel alloc] initWithFrame:self.bounds];
  self.mTopText.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.mTopText.textAlignment = NSTextAlignmentCenter;
  self.mTopText.font = [UIFont fontWithName:@"DINCondensed-Bold" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 25];
  self.mTopText.textColor = [SKAppColourScheme  sGetMainColourDialTopText];
  self.mTopText.adjustsFontSizeToFitWidth = YES;
  self.mTopText.minimumScaleFactor = 0.1; // minimumFontSize = 12 is deprecated from iOS 6
  self.mTopText.numberOfLines = 2;
  [self addSubview:self.mTopText];
  
  self.mUnitText = [[UILabel alloc] initWithFrame:self.bounds];
  self.mUnitText.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.mUnitText.textAlignment = NSTextAlignmentCenter;
  self.mUnitText.font = [UIFont fontWithName:@"DINCondensed-Bold" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 25];
  if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
  {
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height < 568)
    {
      // iPhone 4 or earlier!
      self.mUnitText.font = [UIFont fontWithName:@"DINCondensed-Bold" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 20];
    }
  }
  self.mUnitText.textColor = [SKAppColourScheme  sGetMainColourDialUnitText];
  [self addSubview:self.mUnitText];
  
  self.mMeasurementText = [[UILabel alloc] initWithFrame:self.bounds];
  self.mMeasurementText.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.mMeasurementText.textAlignment = NSTextAlignmentCenter;
  self.mMeasurementText.font = [UIFont fontWithName:@"Roboto-Regular" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 12];
  self.mMeasurementText.textColor = [SKAppColourScheme  sGetMainColourDialMeasurementText];
  [self addSubview:self.mMeasurementText];
  
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

- (id)initWithActivityIndicatorStyle:(CGaugeViewStyle)style
{
  if ((self = [self initWithFrame:CGRectZero])) {
    self.activityIndicatorViewStyle = style;
    [self sizeToFit];
  }
  
  return self;
}

- (void)layoutSubviews
{
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
  
  self.mCenterText.frame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * 0.2, self.bounds.origin.y + 0.18 * self.mCenterText.font.pointSize, self.bounds.size.width * 0.6, self.bounds.size.height);
  
  self.mTopText.frame = CGRectMake(self.bounds.origin.x + 0.27 * self.bounds.size.width, 0.20 * self.bounds.size.height, 0.46 * self.bounds.size.width, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 35);
  
  self.mUnitText.frame = CGRectMake(self.bounds.origin.x, self.bounds.size.height * 0.67, self.bounds.size.width, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 25);
  self.mMeasurementText.frame = CGRectMake(self.bounds.origin.x, self.bounds.size.height * 0.77, self.bounds.size.width, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 20);
  
  self.btButton.frame = self.indicatorImageView.frame;

  // Make this call last!
  // http://stackoverflow.com/questions/24731552/assertion-failure-in-myclass-layoutsublayersoflayer
  [super layoutSubviews];
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
  
 // NSMutableArray* arrTmp = self.arrLabels;

  [self.arrLabels removeAllObjects];
  
  //    self.btButton.userInteractionEnabled = NO;
  
  [UIView animateWithDuration:0.2 animations:^{
    self.vCenterFillingRunning.alpha = 0;
    self.vCenterFillingStopped.alpha = 1;
    self.indicatorImageView.alpha = 0;
    self.backgroundImageView.alpha = 0.3;
    
    self.mMeasurementText.alpha = 0;
    self.mUnitText.alpha = 0;
    
  } completion:^(BOOL finished) {
    if (finished)
    {
      self.animating = NO;
      
      self.mMeasurementText.text = nil;
      self.mUnitText.text = nil;
      self.mMeasurementText.alpha = 1;
      self.mUnitText.alpha = 1;
      
      [self.indicatorImageView.layer removeAllAnimations];
      if (self.hidesWhenStopped) {
        self.hidden = YES;
      }
      self.btButton.userInteractionEnabled = YES;
    }
  }];
  
  [self setNeedsDisplay];
  
 // self.arrLabels = arrTmp;
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
  rotationAnimation.repeatCount = repeatCount;
  rotationAnimation.removedOnCompletion = NO;
  rotationAnimation.fillMode = kCAFillModeForwards;
  [self.indicatorImageView.layer addAnimation:rotationAnimation forKey:@"rotation"];
}

-(void)setCenterText:(NSString*)value
{
  self.mCenterText.text = value;
}

-(void)setAngle:(float)angle_
{
  SK_ASSERT(angle_ >= 0.0F);
  SK_ASSERT(angle_ <= 270.0F);
  
  if (angle_ > 270) angle_ = 271;
  self.desiredAngle = angle_;
}

-(void)setAngleByValue:(float)value
{
  const float anglePerSegment = 45.0F;
  
  double useAngle = 0.0F;
  
  int index = 0;
  int items = (int)self.arrSegmentMaxValues.count;
  SK_ASSERT(items == 6);
  
  float maxAngleFound = 0.0F;
  float maxValueFound = 0.0F;
  
  for (index = 0; index < items; index++) {
    float thisSegmentStartsAtAngle = anglePerSegment * ((float)index);
    maxAngleFound = fmax(maxAngleFound, thisSegmentStartsAtAngle);
    
    NSNumber *segmentMinFloatValue = self.arrSegmentMinValues[index];
    NSNumber *segmentMaxFloatValue = self.arrSegmentMaxValues[index];
    
    maxValueFound = fmax(maxValueFound, segmentMaxFloatValue.floatValue);
    
    SK_ASSERT(value >= segmentMinFloatValue.floatValue);
    
    if (value <= segmentMaxFloatValue.floatValue) {
      // Use this segment!
      useAngle = thisSegmentStartsAtAngle + (anglePerSegment * (value - segmentMinFloatValue.floatValue) / (segmentMaxFloatValue.floatValue - segmentMinFloatValue.floatValue));
      break;
    }
   
    // Keep looking!
  }
 
  if (value >= maxValueFound) {
    useAngle = maxAngleFound + anglePerSegment;
    SK_ASSERT(useAngle == 270.0);
  }
  
  [self setAngle:useAngle];
}

-(void)setCenterTextWithAnimation:(NSString*)nextValue_
{
  [UIView animateWithDuration:0.3 animations:^{
    self.mCenterText.alpha = 0;
  } completion:^(BOOL finished) {
    self.mCenterText.text = nextValue_;
    [UIView animateWithDuration:0.3 animations:^{
      self.mCenterText.alpha = 1;
    }];
  }];
}

-(void)setUnitMeasurement:(NSString*)unit_ measurement:(NSString*)measurement_
{
  self.mUnitText.alpha = 0;
  self.mUnitText.text = unit_;
  self.mMeasurementText.alpha = 0;
  self.mMeasurementText.text = measurement_;
  
  [UIView animateWithDuration:0.5 animations:^{
    self.mUnitText.alpha = 1;
    self.mMeasurementText.alpha = 1;
  } completion:^(BOOL finished) {
  }];
}

-(void)setSixSegmentMaxValues:(NSArray*)arrayOfSixValues {
  SK_ASSERT(arrayOfSixValues.count == 6);
  
  self.arrSegmentMinValues = [[NSMutableArray alloc] init];
  self.arrSegmentMaxValues = [[NSMutableArray alloc] init];
  self.arrLabels = [[NSMutableArray alloc] init];
  
  [self.arrLabels addObject:@"0"];
  
  NSNumber *lastMaxValue = @0.0F;
  
  for (NSNumber *value in arrayOfSixValues) {
    [self.arrSegmentMinValues addObject:lastMaxValue];
    [self.arrSegmentMaxValues addObject:value];
    
    lastMaxValue = value;
   
    double doubleValue = value.doubleValue;
    double fractionalPart = doubleValue - ((double)value.integerValue);
    if (fractionalPart > 0.4) {
      // Something like 0.5, 1.5 etc.
      [self.arrLabels addObject:[NSString localizedStringWithFormat:@"%.1f", doubleValue]];
    } else {
      [self.arrLabels addObject:[NSString localizedStringWithFormat:@"%ld", (long)value.integerValue]];
    }
  }
  
}
@end
