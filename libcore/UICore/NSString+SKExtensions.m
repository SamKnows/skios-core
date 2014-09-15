//
//  NSString+SKExtensions.m
//  SKCore
//
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "NSString+SKExtensions.h"

@implementation NSString (SKExtensions)

// Alternative to sizeWithFont, which is deprecated!

- (CGSize)skSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakModeIn {
  
  NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.lineBreakMode = lineBreakModeIn;
  paragraphStyle.alignment = NSTextAlignmentLeft;
  
  UIColor *color = [UIColor blackColor];
  NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        font, NSFontAttributeName,
                                        color, NSForegroundColorAttributeName,
                                        paragraphStyle, NSParagraphStyleAttributeName,
                                        nil];
  CGRect labelRect = [self boundingRectWithSize:size  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributesDictionary context:nil];
  return CGSizeMake(labelRect.size.width, labelRect.size.height);
}

@end
