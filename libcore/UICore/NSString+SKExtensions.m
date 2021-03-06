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
  NSDictionary *attributesDictionary = @{NSFontAttributeName : font,
          NSForegroundColorAttributeName : color,
          NSParagraphStyleAttributeName : paragraphStyle};
  CGRect labelRect = [self boundingRectWithSize:size  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributesDictionary context:nil];
  return CGSizeMake(labelRect.size.width, labelRect.size.height);
}

//- (CGSize)skDrawInRect:(CGRect)rect withFont:(UIFont *)font {
//  return [self drawInRect:rect withFont:font];
//}

-(void)skDrawInRectNoRet:(CGRect)rect withFont:(UIFont *)font withTextColor:(UIColor*)withTextColor {
  NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping; // NSLineBreakMode.;
  paragraphStyle.alignment = NSTextAlignmentLeft;
  
  NSDictionary *attributesDictionary = @{NSFontAttributeName : font,
          NSForegroundColorAttributeName : withTextColor,
          NSParagraphStyleAttributeName : paragraphStyle};
  [self drawInRect:rect withAttributes:attributesDictionary];
}


//- (CGSize)skDrawAtPoint:(CGPoint)point withFont:(UIFont *)font {
//  return [self drawAtPoint:point withFont:font];
//}

-(void) skDrawAtPointNoRet:(CGPoint)point withFont:(UIFont *)font withTextColor:(UIColor*)withTextColor {
  NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping; // NSLineBreakMode.;
  paragraphStyle.alignment = NSTextAlignmentLeft;
  
  NSDictionary *attributesDictionary = @{NSFontAttributeName : font,
          NSForegroundColorAttributeName : withTextColor,
          NSParagraphStyleAttributeName : paragraphStyle};
  [self drawAtPoint:point withAttributes:attributesDictionary];
}

@end
