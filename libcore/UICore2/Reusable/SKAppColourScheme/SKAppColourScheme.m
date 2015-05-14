//
//  SKAppColourScheme.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKAppColourScheme.h"


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


static NSObject<PSKAppColourScheme> *spAppColourScheme;

@implementation SKAppColourScheme

+(UIColor*)sGetInnerColor {
  return [[SKAppColourScheme sGetAppColourScheme] getInnerColor];
}

+(UIColor*)sGetOuterColor {
  return [[SKAppColourScheme sGetAppColourScheme] getOuterColor];
}

+(UIColor*)sGetWelcomeSplashBackgroundColor {
  return [[SKAppColourScheme sGetAppColourScheme] getWelcomeSplashBackgroundColor];
}

+(UIColor*)sGetWelcomeSplashTextColor {
  return [[SKAppColourScheme sGetAppColourScheme] getWelcomeSplashTextColor];
}

// Tab controll colours
+(UIColor*)sGetTabColourActiveText {
  return [UIColor purpleColor];
}
+(UIColor*)sGetTabColourInactiveText {
  return [UIColor purpleColor];
}
+(UIColor*)sGetTabColourInactiveBackground {
  return [UIColor purpleColor];
}
// Main screen colours
+(UIColor*)sGetMainColourProgressFill {
  return [[SKAppColourScheme sGetAppColourScheme] getMainColourProgressFill];
}
+(CGFloat)sGetMainAlphaProgressFill {
  return [[SKAppColourScheme sGetAppColourScheme] getMainAlphaProgressFill];
}
+(UIColor*)sGetMainColourDialOuterTicksMeasuredValue {
  return [[SKAppColourScheme sGetAppColourScheme] getMainColourDialOuterTicksMeasuredValue];
}
+(UIColor*)sGetMainColourDialOuterTicksDefault {
  return [[SKAppColourScheme sGetAppColourScheme] getMainColourDialOuterTicksDefault];
}
+(UIColor*)sGetMainColourDialInnerTicks {
  return [[SKAppColourScheme sGetAppColourScheme] getMainColourDialInnerTicks];
}
+(UIColor*)sGetMainColourDialInnerLabelText {
  return [[SKAppColourScheme sGetAppColourScheme] getMainColourDialInnerLabelText];
}
+(UIColor*)sGetMainColourDialArcRedZone {
  return [[SKAppColourScheme sGetAppColourScheme] getMainColourDialArcRedZone];
}
+(UIColor*)sGetMainColourDialArcGreyZone {
  return [[SKAppColourScheme sGetAppColourScheme] getMainColourDialArcGreyZone];
}
+(UIColor*)sGetMainColourDialTopText {
  return [[SKAppColourScheme sGetAppColourScheme] getMainColourDialTopText];
}
+(UIColor*)sGetMainColourDialCenterText {
  return [[SKAppColourScheme sGetAppColourScheme] getMainColourDialCenterText];
}
+(UIColor*)sGetMainColourDialUnitText {
  return [[SKAppColourScheme sGetAppColourScheme] getMainColourDialUnitText];
}
+(UIColor*)sGetMainColourDialMeasurementText {
  return [[SKAppColourScheme sGetAppColourScheme] getMainColourDialMeasurementText];
}

+(UIColor*)sGetMainColourPressTheStartButtonText {
  return [[SKAppColourScheme sGetAppColourScheme] getMainColourPressTheStartButtonText];
}
+(UIColor*)sGetMainColourReadyToRunButtonText {
  return [[SKAppColourScheme sGetAppColourScheme] getMainColourReadyToRunButtonText];
}
+(UIColor*)sGetPanelColourBackground {
  return [[SKAppColourScheme sGetAppColourScheme] getPanelColourBackground ];
}
+(UIColor*)sGetTableCellColourText {
  return [[SKAppColourScheme sGetAppColourScheme] getTableCellColourText ];
}
+(UIColor*)sGetResultColourText {
  return [[SKAppColourScheme sGetAppColourScheme] getResultColourText ];
}
+(UIColor*)sGetSummaryGetMenuPanelBackgroundColour {
  return [[SKAppColourScheme sGetAppColourScheme] getSummaryGetMenuPanelBackgroundColour ];
}
+(UIColor*)sGetSummaryGetCellBackgroundColour {
  return [[SKAppColourScheme sGetAppColourScheme] getSummaryGetCellBackgroundColour ];
}
+(UIColor*)sGetSummaryGetTableSeparatorColour {
  return [[SKAppColourScheme sGetAppColourScheme] getSummaryGetTableSeparatorColour ];
}

+(UIColor*)sGetGraphColourBackground {
  return [[SKAppColourScheme sGetAppColourScheme] getGraphColourBackground];
}
+(UIColor*)sGetGraphColourTopLine {
  return [[SKAppColourScheme sGetAppColourScheme] getGraphColourTopLine];
}
+(UIColor*)sGetGraphColourVerticalGridLine {
  return [[SKAppColourScheme sGetAppColourScheme] getGraphColourVerticalGridLine];
}
+(UIColor*)sGetGraphColourTopAreaFill {
  return [[SKAppColourScheme sGetAppColourScheme] getGraphColourTopAreaFill];
}
+(UIColor*)sGetGraphColourBottomAreaFill {
  return [[SKAppColourScheme sGetAppColourScheme] getGraphColourBottomAreaFill];
}

+(UIColor*)sGetActionSheetBackgroundColour {
  return [[SKAppColourScheme sGetAppColourScheme] getActionSheetBackgroundColour];
}
+(UIColor*)sGetActionSheetOuterAreaColour {
  return [[SKAppColourScheme sGetAppColourScheme] getActionSheetOuterAreaColour];
}
+(UIColor*)sGetActionSheetInnerAreaBorderColour {
  return [[SKAppColourScheme sGetAppColourScheme] getActionSheetInnerAreaBorderColour];
}

// This is used if selected...
+(UIColor*)sGetActionSheetButtonSelectedColour {
  return [[SKAppColourScheme sGetAppColourScheme] getActionSheetButtonSelectedColour];
}
+(UIColor*)sGetActionSheetButtonTextSelectedColour {
  return [[SKAppColourScheme sGetAppColourScheme] getActionSheetButtonTextSelectedColour];
}

// This is used if not selected, and also for the "Cancel" button...
+(UIColor*)sGetActionSheetButtonNotSelectedColour {
  return [[SKAppColourScheme sGetAppColourScheme] getActionSheetButtonNotSelectedColour];
}
+(UIColor*)sGetActionSheetButtonTextNotSelectedColour {
  return [[SKAppColourScheme sGetAppColourScheme] getActionSheetButtonTextNotSelectedColour];
}
+(UIColor*)sGetMetricsTextColour {
  return [[SKAppColourScheme sGetAppColourScheme] getMetricsTextColour];
}
+(UIColor*)sGetBlinkerBorderColour {
  return [[SKAppColourScheme sGetAppColourScheme] getBlinkerBorderColour];
}
+(UIColor*)sGetBlinkerBackgroundColour {
  return [[SKAppColourScheme sGetAppColourScheme] getBlinkerBackgroundColour];
}

+(UIFont*)sGetFontWithName:(NSString*)name size:(CGFloat)withSize {
  return [[SKAppColourScheme sGetAppColourScheme] getFontWithName:name size:withSize];
}

+(float) sGet_GUI_MULTIPLIER {
  // TODO - this should be removed, so we work fully with storyboards,
  // in LANDSCAPE mode and with different layouts!
  
  float width = [UIScreen mainScreen].bounds.size.width;
  return (width / 320);
//  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//    return 768.0 / 320.0;
//  }
//  
//  return 1.0;
}

//
// Base implementation, overridden for different colour schemes!
//

// The app can call this static method, in order to provide a custom app colour scheme!
+(void)sSetAppColourScheme:(NSObject<PSKAppColourScheme>*)theAppColourScheme {
  spAppColourScheme = theAppColourScheme;
}

+(NSObject<PSKAppColourScheme>*)sGetAppColourScheme {
  
  if (spAppColourScheme == nil) {
    spAppColourScheme = [SKAppColourScheme new];
  }
  
  return spAppColourScheme;
}

+(UIColor*)sGetSamKnowsBlue {
  // "#009fe3"
  return [UIColor sSKCGetColor_samKnowsBlueColor];
  //return [UIColor colorWithRed:0.0/255.0 green:159.0/255.0 blue:227.0/255.0 alpha:1];
}

+(UIColor*)sGetSamKnowsDarkBlue {
  return [UIColor colorWithRed:37.0/255.0 green:82.0/255.0 blue:164.0/255.0 alpha:1];
}


+(UIColor*)sGetSamKnowsWhite {
  return [UIColor whiteColor];
}


-(UIColor*)getInnerColor {
  return [SKAppColourScheme sGetSamKnowsBlue];
}

-(UIColor*)getOuterColor {
  return [SKAppColourScheme sGetSamKnowsDarkBlue];
}

-(UIColor*)getWelcomeSplashBackgroundColor {
  return [SKAppColourScheme sGetSamKnowsBlue];
}

-(UIColor*)getWelcomeSplashTextColor {
  return [SKAppColourScheme sGetSamKnowsWhite];
}



// Main screen colours
-(UIColor*)getMainColourProgressFill {
  return [UIColor colorFromHexString:@"#00000000"];
}
-(CGFloat)getMainAlphaProgressFill {
  return 0.3;
}
-(UIColor*)getMainColourDialOuterTicksMeasuredValue {
  return [UIColor redColor];
}
-(UIColor*)getMainColourDialOuterTicksDefault {
  return[UIColor whiteColor];
}
-(UIColor*)getMainColourDialInnerTicks {
  return [UIColor colorFromHexString:@"#9b9b9b"];
}
-(UIColor*)getMainColourDialInnerLabelText {
  return [UIColor orangeColor];
}
-(UIColor*)getMainColourDialArcRedZone {
  return [UIColor redColor];
}
-(UIColor*)getMainColourDialArcGreyZone {
  return [UIColor lightGrayColor];
}
-(UIColor*)getMainColourDialTopText {
  return [UIColor orangeColor];
}
-(UIColor*)getMainColourDialCenterText {
  return[UIColor colorWithWhite:0.9 alpha:1];
}
-(UIColor*)getMainColourDialUnitText {
  return [UIColor orangeColor];
}
-(UIColor*)getMainColourDialMeasurementText {
  return [UIColor orangeColor];
}
-(UIColor*)getMainColourReadyToRunButtonText {
  return [UIColor lightGrayColor];
}
-(UIColor*)getMainColourPressTheStartButtonText {
  // TODO
  return [UIColor whiteColor];
}
-(UIColor*)getMainColourStatusText {
  // TODO
  return [UIColor whiteColor];
}

-(UIColor*)getPanelColourBackground {
  return [UIColor colorWithWhite:0 alpha:0.2];
}
-(UIColor*)getTableCellColourText {
  return [UIColor whiteColor];
}

-(UIColor*)getResultColourText {
  return [UIColor colorWithWhite:0.85 alpha:1];
}

-(UIColor*)getSummaryGetMenuPanelBackgroundColour {
  return [UIColor colorWithWhite:0 alpha:0.1];//[UIColor clearColor];
}
-(UIColor*)getSummaryGetCellBackgroundColour {
  return [UIColor clearColor];
}

-(UIColor*)getSummaryGetTableSeparatorColour {
  return [UIColor clearColor];
}

-(UIColor*)getGraphColourBackground {
  return [SKAppColourScheme sGetSamKnowsBlue];
}

// Graph colours!

-(UIColor*)getGraphColourTopLine {
  return [UIColor colorFromHexString:@"#2b6da3"];
}

-(UIColor*)getGraphColourVerticalGridLine {
  return [UIColor colorFromHexString:@"#cce5e5e5"];
}

-(UIColor*)getGraphColourTopAreaFill {
  return [UIColor colorFromHexString:@"#b8d3e1"];
}

-(UIColor*)getGraphColourBottomAreaFill {
  return [UIColor colorFromHexString:@"#6dadce"];
}

// Action sheet colours!

// This is on TOP of the background gradient.
-(UIColor*)getActionSheetBackgroundColour {
  return [UIColor colorWithWhite:1 alpha:0.5];
}

-(UIColor*)getActionSheetOuterAreaColour {
  return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
}

-(UIColor*)getActionSheetInnerAreaBorderColour {
  return [UIColor colorWithWhite:1 alpha:0.5];
}

-(UIColor*)getActionSheetButtonSelectedColour {
  return [UIColor clearColor];
}

-(UIColor*)getActionSheetButtonTextSelectedColour {
  return [UIColor whiteColor];
}

-(UIColor*)getActionSheetButtonNotSelectedColour {
  return [UIColor clearColor];
  //return [UIColor colorWithWhite:0.95 alpha:1];
  //return [UIColor redColor];
}

-(UIColor*)getActionSheetButtonTextNotSelectedColour {
  return [UIColor colorWithRed:44.0/255.0 green:66.0/255.0 blue:149.0/255.0 alpha:1];
}


-(UIColor*)getMetricsTextColour {
  return [UIColor colorWithRed:255.0/255.0 green:166.0/255.0 blue:26.0/255.0 alpha:1];
}

-(UIColor*)getBlinkerBorderColour {
  return [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
}

-(UIColor*)getBlinkerBackgroundColour {
 return [UIColor orangeColor];
}

-(UIFont*)getFontWithName:(NSString*)name size:(CGFloat)withSize {
  // By default, use the requested font!
  return [UIFont fontWithName:name size:withSize];
}


//-(UIColor*)getGraphColourTitleText {
//  return [UIColor blackColor];
//}
//
//-(UIColor*)getGraphColourAxisMain {
//  return [UIColor clearColor];
//}
//          
//-(UIColor*)getGraphColourAxisTick {
//  return [UIColor clearColor];
//}
//
//-(UIColor*)getGraphColourAxisLabelText {
//  return [UIColor clearColor];
//}


@end