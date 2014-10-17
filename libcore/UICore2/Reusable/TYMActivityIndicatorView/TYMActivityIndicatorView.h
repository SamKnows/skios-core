/*
TYMActivityIndicatorView.h
TYMActivityIndicatorView

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

#import <UIKit/UIKit.h>

#define C_ARCH_THICK_WIDTH  (self.frame.size.width / 30)

@protocol pTYMAOwner <NSObject>
@required
    -(void)buttonPressed;
@end

/**
 Activity indicator type.
 */
typedef NS_ENUM(NSInteger, TYMActivityIndicatorViewStyle) {
    /** A large activity indicator view. About 157 * 157 in size. */
    TYMActivityIndicatorViewStyleLarge,
    /** A normal activity indicator view. About 37 * 37 in size */
    TYMActivityIndicatorViewStyleNormal,
};

/**
 A simple activity indicator view. You can customize it's appearance with images.
 */

#define C_ANGLE_STEP (360.0/80.0)

//IB_DESIGNABLE
@interface TYMActivityIndicatorView : UIView
{
    int mode;
    int currentpixel;
    int direction; //==0 right !=0 left
}

@property (nonatomic, weak) id<pTYMAOwner> activityOwner;

///-----------------
/// @name Properties
///-----------------

@property (nonatomic, strong) UIView* vCenterFillingStopped;
@property (nonatomic, strong) UIView* vCenterFillingRunning;
@property (nonatomic, strong) UILabel* mTopText;
@property (nonatomic, strong) UILabel* mCenterText;
@property (nonatomic, strong) UILabel* mUnitText;
@property (nonatomic, strong) UILabel* mMeasurementText;
@property (nonatomic, strong) UIButton* btButton;

@property (nonatomic, strong) NSMutableArray* arrLabels;
@property (nonatomic) float desiredAngle;
@property (nonatomic) float realAngle;
@property (nonatomic, strong) NSTimer* timer;

/**
 The background image.
 
 Should use the same size as the indicator view's for performance issue.
 */
@property (nonatomic, strong) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;

/**
 The indicator image which may be applied with a rotarion animation.
 
 Usually, it's a circular progress bar. Should use the same size as the indicator view's.
 */
@property (nonatomic, strong) UIImage *indicatorImage UI_APPEARANCE_SELECTOR;

/**
 It determines whether the view will be hidden when the animation was stopped.
 
 The view sets its `hidden` property to accomplish it.
 */
@property (nonatomic, assign) BOOL hidesWhenStopped;

/**
 The duration time it takes the indicator to finish a 360-degree clockwise rotation.
 */
@property (nonatomic, assign) CFTimeInterval fullRotationDuration UI_APPEARANCE_SELECTOR;

/**
 The overall progress of the indicator. The acceptable value is `0.0f` to `1.0f`.
 
 The default value is 0.
 
 @warning For performance issue, you'd better control your invoking frequency during a period of time.
 */
@property (nonatomic, assign) CGFloat progress;

/**
 The minimal progress unit.
 
 The indicator will only be rotated when the delta value of the progress is larger than the unit value. The default value is `0.01f`.
 */
@property (nonatomic, assign) CGFloat minProgressUnit UI_APPEARANCE_SELECTOR;

/**
 The activity indicator view style. Default is `TYMActivityIndicatorViewStyleNormal`.
 */
@property (nonatomic, assign) TYMActivityIndicatorViewStyle activityIndicatorViewStyle;

///-------------------
/// @name Initializing
///-------------------

/**
 Initialize a indicator view with built-in sizes and resources according to the specific style.
 */
- (id)initWithActivityIndicatorStyle:(TYMActivityIndicatorViewStyle)style;


///-----------------------------
/// @name Controlling Animations
///-----------------------------

/**
 Start animating. 360-degree clockwise rotation. Repeated forever.
 */
- (void)startAnimating;

/**
 Stop animating.
 */
- (void)stopAnimating;

/**
 Whether the indicator is animating.
 */
- (BOOL)isAnimating;

-(void)setCenterText:(NSString*)currentResult;
-(void)setAngle:(float)angle; //In Degrees

-(void)setUnitMeasurement:(NSString*)unit_ measurement:(NSString*)measurement_;
-(void)layoutSubviews;
-(void)setTopText:(NSString*)topInfo_;

-(void)setCenterTextWithAnimation:(NSString*)nextValue_;

@end
