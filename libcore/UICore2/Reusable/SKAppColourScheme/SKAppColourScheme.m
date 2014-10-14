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

@implementation SKAppColourScheme

+(UIColor*)sGetInnerColor {
  return [UIColor colorWithRed:0.0/255.0 green:159.0/255.0 blue:227.0/255.0 alpha:1];
}

+(UIColor*)sGetOuterColor {
  return [UIColor colorWithRed:37.0/255.0 green:82.0/255.0 blue:164.0/255.0 alpha:1];
}

+(float) sGet_GUI_MULTIPLIER {
  // TODO - this should be removed, to work in LANDSCAPE mode and with different layouts!
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    return 768.0 / 320.0;
  }
  else {
    return 1.0;
  }
}

@end