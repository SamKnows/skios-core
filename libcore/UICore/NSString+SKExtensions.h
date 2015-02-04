//
//  NSString+SKExtensions.h
//  SKCore
//
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SKExtensions)

- (CGSize)skSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;
//- (CGSize)skDrawInRect:(CGRect)rect withFont:(UIFont *)font;
-(void)skDrawInRectNoRet:(CGRect)rect withFont:(UIFont *)font withTextColor:(UIColor*)withTextColor;
//- (CGSize)skDrawAtPoint:(CGPoint)point withFont:(UIFont *)font;
-(void) skDrawAtPointNoRet:(CGPoint)point withFont:(UIFont *)font withTextColor:(UIColor*)withTextColor;

@end
