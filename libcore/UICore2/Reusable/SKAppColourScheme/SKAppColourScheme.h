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
-(UIColor*)getMainColourProgressFill;
-(CGFloat) getMainAlphaProgressFill;
-(UIColor*)getMainColourDialOuterTicksMeasuredValue; //[UIColor redColor]
-(UIColor*)getMainColourDialOuterTicksDefault; //[UIColor whiteColor]
-(UIColor*)getMainColourDialInnerTicks; // [UIColor colorFromHexString:@"#9b9b9b"]
-(UIColor*)getMainColourDialInnerLabelText; // [UIColor orangeColor]
-(UIColor*)getMainColourDialArcRedZone; // [UIColor redColor]
-(UIColor*)getMainColourDialArcGreyZone; // [UIColor lightGrayColor]
-(UIColor*)getMainColourDialTopText; // [UIColor orangeColor]
-(UIColor*)getMainColourDialCenterText; // [UIColor colorWithWhite:0.9 alpha:1]
-(UIColor*)getMainColourDialUnitText; // [UIColor orangeColor]
-(UIColor*)getMainColourDialMeasurementText; // [UIColor orangeColor]
-(UIColor*)getMainColourPressTheStartButtonText; // [UIColor whiteColor]
-(UIColor*)getMainColourStatusText;
-(UIColor*)getGraphColourBackground;
-(UIColor*)getPanelColourBackground; // [UIColor whiteColor]
-(UIColor*)getTableCellColourText; // [UIColor whiteColor]


-(UIColor*)getGraphColourTopLine;
-(UIColor*)getGraphColourTitleText;
-(UIColor*)getGraphColourAxisMain;
-(UIColor*)getGraphColourAxisTick;
-(UIColor*)getGraphColourAxisLabelText;
-(UIColor*)getGraphColourSideLineColor;
-(UIColor*)getGraphColourFillColor;
@end

@interface SKAppColourScheme : NSObject<PSKAppColourScheme>

// Call this to get a scaling factor, scaling iPhone to iPad layout.
// It should be deprecated as soon as possible!
+(float) sGet_GUI_MULTIPLIER;

+(UIColor*)sGetSamKnowsBlue;
+(UIColor*)sGetSamKnowsWhite;

// The app must use the following static methods to get elements of the current colour scheme.
+(UIColor*)sGetInnerColor;
+(UIColor*)sGetOuterColor;
+(UIColor*)sGetWelcomeSplashBackgroundColor;
+(UIColor*)sGetWelcomeSplashTextColor;
+(UIColor*)sGetGraphColourBackground;
//+(UIColor*)sGetGraphColourTopLine;
//+(UIColor*)sGetGraphColourTitleText;
//+(UIColor*)sGetGraphColourAxisMain;
//+(UIColor*)sGetGraphColourAxisTick;
//+(UIColor*)sGetGraphColourAxisLabelText;
//+(UIColor*)sGetGraphColourSideLineColor;
//+(UIColor*)sGetGraphColourFillColor;
// Tab controll colours
+(UIColor*)sGetTabColourActiveText;
+(UIColor*)sGetPanelColourBackground;
+(UIColor*)sGetTabColourInactiveText;
+(UIColor*)sGetTabColourInactiveBackground;
// Main screen colours
+(UIColor*)sGetMainColourProgressFill; //[UIColor redColor]
+(CGFloat) sGetMainAlphaProgressFill; // 0.3
+(UIColor*)sGetMainColourDialOuterTicksMeasuredValue; //[UIColor redColor]
+(UIColor*)sGetMainColourDialOuterTicksDefault; //[UIColor whiteColor]
+(UIColor*)sGetMainColourDialInnerTicks; // [UIColor colorFromHexString:@"#9b9b9b"]
+(UIColor*)sGetMainColourDialInnerLabelText; // [UIColor orangeColor]
+(UIColor*)sGetMainColourDialArcRedZone; // [UIColor redColor]
+(UIColor*)sGetMainColourDialArcGreyZone; // [UIColor lightGrayColor]
+(UIColor*)sGetMainColourDialTopText; // [UIColor orangeColor]
+(UIColor*)sGetMainColourDialCenterText; // [UIColor colorWithWhite:0.9 alpha:1]
+(UIColor*)sGetMainColourDialUnitText; // [UIColor orangeColor]
+(UIColor*)sGetMainColourDialMeasurementText; // [UIColor orangeColor]
+(UIColor*)sGetMainColourPressTheStartButtonText; // [UIColor whiteColor]
+(UIColor*)sGetMainColourStatusText; // [UIColor whiteColor]
// Table Cells
+(UIColor*)sGetPanelColourBackground; // [UIColor whiteColor]
+(UIColor*)sGetTableCellColourText; // [UIColor whiteColor]


// The app can call this static method, in order to provide a custom app colour scheme!
+(void)sSetAppColourScheme:(NSObject<PSKAppColourScheme>*)theAppColourScheme;

@end
