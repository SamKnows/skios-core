//
//  UIViewWithGradient.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "UIViewWithGradient.h"

@implementation UIViewWithGradient

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    @try {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        if (self.innerColor == nil) self.innerColor = [UIColor redColor];
        if (self.outerColor == nil) self.outerColor = [UIColor greenColor];
        
        NSArray *rectangleGradientColors = @[(id)self.innerColor.CGColor,
                                             (id)self.outerColor.CGColor];
        
        CGFloat rectangleGradientLocations[] = {0.00,1.00};
        CGGradientRef rectangleGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)rectangleGradientColors, rectangleGradientLocations);
        
        CGContextDrawRadialGradient(context, rectangleGradient,
                                    CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2), 20,
                                    CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2), self.bounds.size.height / 2,
                                    kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    }
    @catch (NSException *exception) {
        
    }

    CGContextRestoreGState(context);
}

@end
