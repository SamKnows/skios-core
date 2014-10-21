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
-(UIColor*)getPanelColourBackground; // [UIColor whiteColor]
-(UIColor*)getTableCellColourText; // [UIColor whiteColor]
-(UIColor*)getResultColourText; // [UIColor whiteColor]
-(UIColor*)getSummaryGetMenuPanelBackgroundColour;
-(UIColor*)getSummaryGetCellBackgroundColour;
-(UIColor*)getSummaryGetTableSeparatorColour;

-(UIColor*)getGraphColourBackground;
-(UIColor*)getGraphColourTopLine;
-(UIColor*)getGraphColourVerticalGridLine;
-(UIColor*)getGraphColourTopAreaFill;
-(UIColor*)getGraphColourBottomAreaFill;

-(UIColor*)getActionSheetBackgroundColour;
-(UIColor*)getActionSheetOuterAreaColour;
-(UIColor*)getActionSheetInnerAreaBorderColour;
-(UIColor*)getActionSheetButtonColour;
-(UIColor*)getActionSheetTextColour;
-(UIColor*)getMetricsTextColour;

-(UIColor*)getBlinkerBorderColour;
-(UIColor*)getBlinkerBackgroundColour;
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
//+(UIColor*)sGetGraphColourTopLine;
//+(UIColor*)sGetGraphColourTitleText;
//+(UIColor*)sGetGraphColourAxisMain;
//+(UIColor*)sGetGraphColourAxisTick;
//+(UIColor*)sGetGraphColourAxisLabelText;
//+(UIColor*)sGetGraphColourSideLineColor;
//+(UIColor*)sGetGraphColourFillColor;
+(UIColor*)sGetGraphColourBackground;
+(UIColor*)sGetGraphColourTopLine;
+(UIColor*)sGetGraphColourVerticalGridLine;
+(UIColor*)sGetGraphColourTopAreaFill;
+(UIColor*)sGetGraphColourBottomAreaFill;
// Tab controll colours
+(UIColor*)sGetTabColourActiveText;
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
+(UIColor*)sGetResultColourText; // [UIColor whiteColor]
+(UIColor*)sGetSummaryGetMenuPanelBackgroundColour;
+(UIColor*)sGetSummaryGetCellBackgroundColour;
+(UIColor*)sGetSummaryGetTableSeparatorColour;
+(UIColor*)sGetActionSheetBackgroundColour;
+(UIColor*)sGetActionSheetOuterAreaColour;
+(UIColor*)sGetActionSheetInnerAreaBorderColour;
+(UIColor*)sGetActionSheetButtonColour;
+(UIColor*)sGetActionSheetTextColour;
+(UIColor*)sGetMetricsTextColour;
+(UIColor*)sGetBlinkerBorderColour;
+(UIColor*)sGetBlinkerBackgroundColour;

// The app can call this static method, in order to provide a custom app colour scheme!
+(void)sSetAppColourScheme:(NSObject<PSKAppColourScheme>*)theAppColourScheme;

@end
