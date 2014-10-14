//
//  SKAppColourScheme.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../UIViewWithGradient/UIViewWithGradient.h"
//#import "SKRunTestViewMgr.h"

@protocol PSKAppColourScheme
-(UIColor*)getInnerColor;
-(UIColor*)getOuterColor;
-(UIColor*)getWelcomeSplashBackgroundColor;
-(UIColor*)getWelcomeSplashTextColor;
@end

@interface SKAppColourScheme : NSObject<PSKAppColourScheme>

// Call this to get a scaling factor, scaling iPhone to iPad layout.
// It should be deprecated as soon as possible!
+(float) sGet_GUI_MULTIPLIER;

// The app must use the following static methods to get elements of the current colour scheme.
+(UIColor*)sGetInnerColor;
+(UIColor*)sGetOuterColor;
+(UIColor*)sGetWelcomeSplashBackgroundColor;
+(UIColor*)sGetWelcomeSplashTextColor;

+(UIColor*)sGetSamKnowsBlue;
+(UIColor*)sGetSamKnowsWhite;

// The app can call this static method, in order to provide a custom app colour scheme!
+(void)sSetAppColourScheme:(NSObject<PSKAppColourScheme>*)theAppColourScheme;

@end
