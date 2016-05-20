//
//  SKTestResults.m
//  SKCore
//
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKTestResults.h"

@implementation SKATestResults
- (instancetype)init
{
    self = [super init];
    if (self) {
      self.metricsDictionary = [NSMutableDictionary new];
    }
    return self;
}

+(void)placeText:(NSString*)text_ intoRect:(CGRect)rectangle_ withFont:(UIFont*)font_ withTextColor:(UIColor*)withTextColor
{
    NSDictionary *attributes = @{NSFontAttributeName : font_,
            NSParagraphStyleAttributeName : [NSParagraphStyle defaultParagraphStyle]};
    
    CGRect paragraphRect = [text_ boundingRectWithSize:CGSizeMake(1000, 1000) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
    
    float rx;
    float ry;
    
    if (paragraphRect.size.width > rectangle_.size.width) rx = rectangle_.origin.x - (paragraphRect.size.width - rectangle_.size.width) / 2;
    else rx = rectangle_.origin.x + (rectangle_.size.width - paragraphRect.size.width) / 2;
    
    if (paragraphRect.size.height > rectangle_.size.height) ry = rectangle_.origin.y - (paragraphRect.size.height - rectangle_.size.height) / 2;
    else ry = rectangle_.origin.y + (rectangle_.size.height - paragraphRect.size.height) / 2;
    
  [text_ skDrawInRectNoRet:CGRectMake(rx, ry, paragraphRect.size.width, paragraphRect.size.height) withFont:font_ withTextColor:withTextColor];
}

+(UIImage*)generateSocialShareImage:(SKATestResults*)testResults_
{
#define C_SHARE_IMAGE_WIDTH  1000
#define C_SHARE_IMAGE_HEIGHT  1000
  
#define C_SHARE_IMAGE_SHIFT_Y   20
  
  //UIColor* colorLightBlue = [UIColor colorWithRed:109.0/255.0 green:211.0/255.0 blue:244.0/255.0 alpha:1];
  //UIColor* colorDarkBlue = [UIColor colorWithRed:44.0/255.0 green:66.0/255.0 blue:149.0/255.0 alpha:1];
  
  UIGraphicsBeginImageContext(CGSizeMake(C_SHARE_IMAGE_WIDTH, C_SHARE_IMAGE_HEIGHT));
  
  [[UIImage imageNamed:@"shareBackground"] drawInRect:CGRectMake(0, 0, C_SHARE_IMAGE_WIDTH, C_SHARE_IMAGE_HEIGHT)];
  
  UIImage* networkSymbol;
  if ([testResults_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_NETWORK_TYPE] isEqualToString:C_NETWORKTYPEASSTRING_MOBILE])
    networkSymbol = [UIImage imageNamed:@"sgsm.png"];
  else
    networkSymbol = [UIImage imageNamed:@"swifi.png"];
  
  [networkSymbol drawInRect:CGRectMake(20, 100 + C_SHARE_IMAGE_SHIFT_Y, C_SHARE_IMAGE_WIDTH / 4, C_SHARE_IMAGE_HEIGHT / 4)];
  
  //    [[UIColor colorWithWhite:0.9 alpha:1] set];
  //    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, C_SHARE_IMAGE_WIDTH, 105));
  
  NSString *labelText = sSKCoreGetLocalisedString(@"Network performance test");
  UIFont *labelFont = [SKAppColourScheme sGetFontWithName:@"Roboto-Regular" size:70];
  
  NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  [style setAlignment:NSTextAlignmentCenter];
  NSDictionary *attributes = @{NSFontAttributeName : labelFont,
          NSParagraphStyleAttributeName : style,
          NSForegroundColorAttributeName : [UIColor whiteColor]};
  CGRect labelRect = CGRectMake(0, 10, C_SHARE_IMAGE_WIDTH, C_SHARE_IMAGE_HEIGHT);
  
  [labelText drawInRect:labelRect withAttributes:attributes];
  
  [[UIColor whiteColor] set];
  //    [labelText drawAtPoint:CGPointMake(140, 10) withFont:labelFont];
  
  //Download figure
  NSString* speedFigure;
  if (testResults_.downloadSpeed1000Based < 0)
    speedFigure = @"-";
  else
    speedFigure = [NSString stringWithFormat:@"%.02f Mbps", testResults_.downloadSpeed1000Based];
  
  UIFont *speedFont = [SKAppColourScheme sGetFontWithName:@"DINCondensed-Bold" size:170];
  labelText = sSKCoreGetLocalisedString(@"Test_Download");
  labelFont = [SKAppColourScheme sGetFontWithName:@"Roboto-Light" size:50];
  
  //UIColor *textColor = [SKAppColourScheme sGetTableCellColourText];
  UIColor *textColor = [UIColor whiteColor];
  [textColor set];
  [speedFigure skDrawAtPointNoRet:CGPointMake(0.3 * C_SHARE_IMAGE_WIDTH , 130 + C_SHARE_IMAGE_SHIFT_Y) withFont:speedFont withTextColor:textColor];
  [textColor set];
  [labelText skDrawAtPointNoRet:CGPointMake(0.3 * C_SHARE_IMAGE_WIDTH , 250 + C_SHARE_IMAGE_SHIFT_Y) withFont:labelFont withTextColor:textColor];
  
  //Upload figure
  if (testResults_.uploadSpeed1000Based < 0)
    speedFigure = @"-";
  else
    speedFigure = [NSString stringWithFormat:@"%.02f Mbps", testResults_.uploadSpeed1000Based];
  labelText = sSKCoreGetLocalisedString(@"Test_Upload");
  
  //[[UIColor colorWithWhite:0.75 alpha:1] set];
  [speedFigure skDrawAtPointNoRet:CGPointMake(0.3 * C_SHARE_IMAGE_WIDTH , 330 + C_SHARE_IMAGE_SHIFT_Y) withFont:speedFont withTextColor:textColor];
  [textColor set];
  [labelText skDrawAtPointNoRet:CGPointMake(0.3 * C_SHARE_IMAGE_WIDTH , 450 + C_SHARE_IMAGE_SHIFT_Y) withFont:labelFont withTextColor:textColor];
  
  labelFont = [SKAppColourScheme sGetFontWithName:@"Roboto-Light" size:35];
  speedFont = [SKAppColourScheme sGetFontWithName:@"DINCondensed-Bold" size:100];
  
  //Latency
  if (testResults_.latency < 0)
    speedFigure = @"-";
  else
    speedFigure = [NSString stringWithFormat:@"%.00f ms", testResults_.latency];
  labelText = sSKCoreGetLocalisedString(@"Test_Latency");
  //[[UIColor colorWithWhite:0.75 alpha:1] set];
  [speedFigure skDrawAtPointNoRet:CGPointMake(0.3 * C_SHARE_IMAGE_WIDTH , 545 + C_SHARE_IMAGE_SHIFT_Y) withFont:speedFont withTextColor:textColor];
  [textColor set];
  [labelText skDrawAtPointNoRet:CGPointMake(0.3 * C_SHARE_IMAGE_WIDTH , 620 + C_SHARE_IMAGE_SHIFT_Y) withFont:labelFont withTextColor:textColor];
  
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getIsLossSupported]) {
    //Loss
    if (testResults_.loss < 0)
      speedFigure = @"-";
    else
      speedFigure = [NSString stringWithFormat:@"%.00f %%", testResults_.loss];
    
    labelText = sSKCoreGetLocalisedString(@"Test_Packetloss");
    //[[UIColor colorWithWhite:0.75 alpha:1] set];
    [speedFigure skDrawAtPointNoRet:CGPointMake(0.3 * C_SHARE_IMAGE_WIDTH , 685 + C_SHARE_IMAGE_SHIFT_Y) withFont:speedFont withTextColor:textColor];
    [textColor set];
    [labelText skDrawAtPointNoRet:CGPointMake(0.3 * C_SHARE_IMAGE_WIDTH , 760 + C_SHARE_IMAGE_SHIFT_Y) withFont:labelFont withTextColor:textColor];
  }
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setTimeStyle:NSDateFormatterFullStyle    ];
  [dateFormatter setDateStyle:NSDateFormatterShortStyle];
  
  //    [[UIColor black75PercentColor] set];
  //    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(60, 900, 380, 50));
  
  
  NSString* timeString;
  
  timeString = [dateFormatter stringFromDate:testResults_.testDateTime];
  
  [dateFormatter setDateFormat:@"ZZZ"];
  
  [textColor set];
  //[[UIColor colorWithWhite:1 alpha:0.6] set];
  labelFont = [SKAppColourScheme sGetFontWithName:@"Roboto-Light" size:35];
  [[NSString stringWithFormat:@"%@ / %@", timeString, [dateFormatter stringFromDate:testResults_.testDateTime] ] skDrawAtPointNoRet:CGPointMake(140, 923) withFont:labelFont withTextColor:textColor];
  
  NSString *networkName;
  
  if ([testResults_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_NETWORK_TYPE] isEqualToString:C_NETWORKTYPEASSTRING_MOBILE])
    networkName = testResults_.metricsDictionary[SKB_TESTVALUERESULT_C_PM_CARRIER_NAME];
  else
    networkName = @"wi-fi";
  
  //    [[UIColor colorWithRed:0 green:129.0/255.0 blue:220.0/255.0 alpha:1] set];
  //[[SKAppColourScheme sGetMetricsTextColour] set];
  
  labelFont = [SKAppColourScheme sGetFontWithName:@"DINCondensed-Bold" size:50];
  [SKATestResults placeText:networkName intoRect:CGRectMake(20, 350, C_SHARE_IMAGE_WIDTH / 4, 50) withFont:labelFont withTextColor:textColor];
  
  UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return newImage;
}

// MPC

-(NSString*)getTextForSocialMedia:(NSString*)socialNetwork {
  NSString *carrierName = self.metricsDictionary[SKB_TESTVALUERESULT_C_PM_CARRIER_NAME];
  return [SKAppBehaviourDelegate
          sBuildSocialMediaMessageForCarrierName:carrierName
          SocialNetwork:socialNetwork
          Upload:[SKGlobalMethods bitrateMbps1024BasedToString:self.uploadSpeed1000Based]
          Download:[SKGlobalMethods bitrateMbps1024BasedToString:self.downloadSpeed1000Based]
          ThisDataIsAveraged:NO];
}

@end
