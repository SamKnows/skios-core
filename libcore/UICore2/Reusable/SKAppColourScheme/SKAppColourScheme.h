//
//  SKAppColourScheme.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../UIViewWithGradient/UIViewWithGradient.h"
//#import "SKRunTestViewMgr.h"

@interface SKAppColourScheme : NSObject

+(UIColor*)sGetInnerColor;
+(UIColor*)sGetOuterColor;
+(float) sGet_GUI_MULTIPLIER;

@end
