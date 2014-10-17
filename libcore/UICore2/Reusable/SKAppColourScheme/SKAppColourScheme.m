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
+(UIColor*)sGetTabColourActiveBackground {
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
+(UIColor*)sGetMainColourStatusText {
  // TODO
  return [UIColor whiteColor];
}





+(UIColor*)sGetGraphColourBackground {
  return [[SKAppColourScheme sGetAppColourScheme] getGraphColourBackground];
}

+(UIColor*)sGetGraphColourTopLine {
  return [[SKAppColourScheme sGetAppColourScheme] getGraphColourTopLine];
}

+(UIColor*)sGetGraphColourTitleText {
  return [[SKAppColourScheme sGetAppColourScheme] getGraphColourTitleText];
}

+(UIColor*)sGetGraphColourAxisMain {
  return [[SKAppColourScheme sGetAppColourScheme] getGraphColourAxisMain];
}

+(UIColor*)sGetGraphColourAxisTick {
  return [[SKAppColourScheme sGetAppColourScheme] getGraphColourAxisTick];
}

+(UIColor*)sGetGraphColourAxisLabelText {
  return [[SKAppColourScheme sGetAppColourScheme] getGraphColourAxisLabelText];
}

+(UIColor*)sGetGraphColourSideLineColor {
  return [[SKAppColourScheme sGetAppColourScheme] getGraphColourSideLineColor];
}

+(UIColor*)sGetGraphColourFillColor {
  return [[SKAppColourScheme sGetAppColourScheme] getGraphColourFillColor];
}

+(float) sGet_GUI_MULTIPLIER {
  // TODO - this should be removed, so we work fully with storyboards,
  // in LANDSCAPE mode and with different layouts!
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    return 768.0 / 320.0;
  }
  
  return 1.0;
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
-(UIColor*)getMainColourPressTheStartButtonText {
  // TODO
  return [UIColor whiteColor];
}
-(UIColor*)getMainColourStatusText {
  // TODO
  return [UIColor whiteColor];
}










-(UIColor*)getGraphColourBackground {
  return [SKAppColourScheme sGetSamKnowsBlue];
}

// Graph colours!
-(UIColor*)getGraphColourTopLine {
  return [UIColor sSKCGetColor_cornflowerColor];
}

-(UIColor*)getGraphColourTitleText {
  return [UIColor whiteColor];
}

-(UIColor*)getGraphColourAxisMain {
  return [UIColor lightGrayColor];
}
          
-(UIColor*)getGraphColourAxisTick {
  return [UIColor lightGrayColor];
}

-(UIColor*)getGraphColourAxisLabelText {
  return [UIColor whiteColor];
}

-(UIColor*)getGraphColourSideLineColor {
  return [UIColor orangeColor];
}

-(UIColor*)getGraphColourFillColor {
  return [UIColor lightGrayColor];
}

@end