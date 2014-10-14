//
//  Graphing.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "Graphing.h"
#import "SKHistoryViewMgr.h"

#define C_X_INSET_LEFT  ([SKAppColourScheme sGet_GUI_MULTIPLIER] * 30)
#define C_X_INSET_RIGHT  ([SKAppColourScheme sGet_GUI_MULTIPLIER] * 20)
#define C_Y_INSET_BOTTOM    ([SKAppColourScheme sGet_GUI_MULTIPLIER] * 20)
#define C_Y_INSET_TOP    ([SKAppColourScheme sGet_GUI_MULTIPLIER] * 30)

#define C_X_SCALEMARKER_SIZE    3
#define C_Y_SCALEMARKER_SIZE    3

@implementation Graphing

//TODO: Zachowanie bez danych

-(void)setDefaultValues
{
    self.chartTitle = @"--- Set the chart title ---";
    
    self.fontXScale = [UIFont fontWithName:@"RobotoCondensed-Regular" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 7];
    self.fontYScale = [UIFont fontWithName:@"RobotoCondensed-Regular" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 7];
    self.fontChartTitle = [UIFont fontWithName:@"RobotoCondensed-Regular" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 12];
    self.fontYAxisTitle = [UIFont fontWithName:@"RobotoCondensed-Regular" size:[SKAppColourScheme sGet_GUI_MULTIPLIER] * 9];
    self.axisYTitle = @"???";
    
    self.yMin = 0;
    self.yMax = 0;
//    self.arrValues = [[NSMutableArray alloc] init];
//    
//    cGraphValue *gv;
//    
//    for (int i = 0; i < 300; i++) {
//        gv = [[cGraphValue alloc] init];
//        gv.active = YES;
//        gv.numberOfElements = 1;
//        gv.sum = 1.05 + sin(1.0 * i / 45);
//        [self.arrValues addObject:gv];
//    }
}

-(void)createAndInitialiseArrayOfValues:(int)numberOfValues_
{
    self.arrValues = [[NSMutableArray alloc] initWithCapacity:numberOfValues_];
    
    for (int i = 0; i < numberOfValues_; i++) {
        [self.arrValues addObject:[[cGraphValue alloc] init]];
        ((cGraphValue*)self.arrValues[i]).active = NO;
        ((cGraphValue*)self.arrValues[i]).sum = 0;
        ((cGraphValue*)self.arrValues[i]).numberOfElements = 0;
    }
}

-(void)setupYAxis
{
    if (self.yMax == 0) self.yMax = 1;
    
    if (self.yMax < 4) self.yMax = ceilf(self.yMax / 0.25) * 0.25;
    else self.yMax = ceilf(self.yMax);
    
    float AXISY_NUMBER_OF_LABELS;
    if (self.yMax <= 4) AXISY_NUMBER_OF_LABELS = ceilf(self.yMax / 0.25);
    else if (self.yMax < 20) AXISY_NUMBER_OF_LABELS = self.yMax;
    else if (self.yMax < 100)
    {
        self.yMax = 10 *ceilf(self.yMax / 10);
        AXISY_NUMBER_OF_LABELS = self.yMax / 10;
    }
    else
    {
        self.yMax = 100 * ceilf(self.yMax / 100);
        AXISY_NUMBER_OF_LABELS = 10; //self.yMax / 100;
        
    }
    
    self.arrLabelsY = [[NSMutableArray alloc] init];
    for (float chartYLabel = 0; chartYLabel <= AXISY_NUMBER_OF_LABELS; chartYLabel++) {
        [self.arrLabelsY addObject:[NSString stringWithFormat:@"%.02f", self.yMax * chartYLabel / AXISY_NUMBER_OF_LABELS]];
    }
}

-(void)setupXAxis:(int)dataPeriod_ withStartDate:(NSDate*)beginDate_
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    
    float AXISX_NUMBER_OF_LABELS;
    self.arrLabelsX = [[NSMutableArray alloc] init];

    switch (dataPeriod_) {
        case C_FILTER_PERIOD_1DAY:
            AXISX_NUMBER_OF_LABELS = 12;
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dateFormatter setDateFormat:@"HH:mm"];

            for (int i = 0; i <= AXISX_NUMBER_OF_LABELS; i++) {
                [self.arrLabelsX addObject:[dateFormatter stringFromDate:[beginDate_ dateByAddingTimeInterval:i * 3600 * 24 / AXISX_NUMBER_OF_LABELS]]];
            }

            break;
        case C_FILTER_PERIOD_1WEEK:
            AXISX_NUMBER_OF_LABELS = 7;
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dateFormatter setDateFormat:@"MM/dd"];
            
            for (int i = 0; i <= AXISX_NUMBER_OF_LABELS; i++) {
                [self.arrLabelsX addObject:[dateFormatter stringFromDate:[beginDate_ dateByAddingTimeInterval:i * 3600 * 24 * 7 / AXISX_NUMBER_OF_LABELS]]];
            }

            break;
        case C_FILTER_PERIOD_1MONTH:
            AXISX_NUMBER_OF_LABELS = 6;
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dateFormatter setDateFormat:@"MM/dd"];
            
            for (int i = 0; i <= AXISX_NUMBER_OF_LABELS; i++) {
                [self.arrLabelsX addObject:[dateFormatter stringFromDate:[beginDate_ dateByAddingTimeInterval:i * 3600 * 24 * 31 / AXISX_NUMBER_OF_LABELS]]];
            }

            break;
        case C_FILTER_PERIOD_3MONTHS:
            AXISX_NUMBER_OF_LABELS = 6;
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dateFormatter setDateFormat:@"MM/dd"];

            for (int i = 0; i <= AXISX_NUMBER_OF_LABELS; i++) {
                [self.arrLabelsX addObject:[dateFormatter stringFromDate:[beginDate_ dateByAddingTimeInterval:i * 3600 * 24 * 31 * 3 / AXISX_NUMBER_OF_LABELS]]];
            }

            break;
        case C_FILTER_PERIOD_1YEAR:
            AXISX_NUMBER_OF_LABELS = 12;
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dateFormatter setDateFormat:@"MM/dd"];
            
            for (int i = 0; i <= AXISX_NUMBER_OF_LABELS; i++) {
                [self.arrLabelsX addObject:[dateFormatter stringFromDate:[beginDate_ dateByAddingTimeInterval:i * 3600 * 24 * 364 / AXISX_NUMBER_OF_LABELS]]];
            }

            break;
    }
}

-(void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  
  context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  {
    [self drawChartFrom:self.arrValues];
    
    [self drawXAxis];
    [self drawYAxis];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.fontChartTitle, NSFontAttributeName,
                                style, NSParagraphStyleAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName,
                                nil];
    
    [self.chartTitle drawInRect:CGRectMake(0, 0, self.bounds.size.width, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 15) withAttributes:attributes];
    
    attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                  self.fontYAxisTitle, NSFontAttributeName,
                  style, NSParagraphStyleAttributeName,
                  [UIColor whiteColor], NSForegroundColorAttributeName,
                  nil];
    
    [self.axisYTitle drawInRect:CGRectMake(0, C_Y_INSET_TOP - 4 * self.fontYScale.pointSize, C_X_INSET_LEFT, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 15) withAttributes:attributes];
  }
}

-(void)drawXAxis
{
    int numberOfPoints;
    float xStep;
    NSString* labelText;
    
    numberOfPoints = (int)self.arrLabelsX.count;
    if (numberOfPoints == 0) return;
    
    xStep = (self.bounds.size.width - C_X_INSET_LEFT - C_X_INSET_RIGHT) / (numberOfPoints - 1);
    CGContextSaveGState(context);
    
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextMoveToPoint(context, C_X_INSET_LEFT, self.bounds.size.height - C_Y_INSET_BOTTOM);
    CGContextAddLineToPoint(context, self.bounds.size.width - C_X_INSET_RIGHT, self.bounds.size.height - C_Y_INSET_BOTTOM);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    for (int i = 0; i < numberOfPoints; i++) {
        
        CGContextMoveToPoint(context, C_X_INSET_LEFT + i * (xStep), self.bounds.size.height - C_Y_INSET_BOTTOM);
        CGContextAddLineToPoint(context, C_X_INSET_LEFT + i * (xStep), self.bounds.size.height - C_Y_INSET_BOTTOM + C_X_SCALEMARKER_SIZE);
    }
    CGContextStrokePath(context);

    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.fontXScale, NSFontAttributeName,
                                style, NSParagraphStyleAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName,
                                nil];
    
    for (int i = 0; i < numberOfPoints; i++) {
    
        labelText = [self.arrLabelsX objectAtIndex:i];
        
        [labelText drawInRect:CGRectMake(C_X_INSET_LEFT + i * (xStep) - xStep / 2, self.bounds.size.height - C_Y_INSET_BOTTOM + C_X_SCALEMARKER_SIZE, xStep, [SKAppColourScheme sGet_GUI_MULTIPLIER] * 10) withAttributes:attributes];
    }
    
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

-(void)drawYAxis
{
    int numberOfPoints;
    float yStep;
    NSString* labelText;
    
    numberOfPoints = (int)self.arrLabelsY.count;
    if (numberOfPoints == 0) return;
    
    yStep = (self.bounds.size.height - C_Y_INSET_BOTTOM - C_Y_INSET_TOP) / (numberOfPoints - 1);
    
    CGContextSaveGState(context);
    
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    
    CGContextMoveToPoint(context, C_X_INSET_LEFT, self.bounds.size.height - C_Y_INSET_BOTTOM);
    CGContextAddLineToPoint(context, C_X_INSET_LEFT, C_Y_INSET_TOP);

    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    for (int i = 0; i < numberOfPoints; i++) {
        CGContextMoveToPoint(context, C_X_INSET_LEFT, self.bounds.size.height - C_Y_INSET_BOTTOM - i * (yStep));
        CGContextAddLineToPoint(context, C_X_INSET_LEFT - C_Y_SCALEMARKER_SIZE, self.bounds.size.height - C_Y_INSET_BOTTOM - i * (yStep));
        
    }
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextSetFillColorWithColor(context, [UIColor sSKCGetColor_grassColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor sSKCGetColor_cornflowerColor].CGColor);
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.fontXScale, NSFontAttributeName,
                                style, NSParagraphStyleAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName,
                                nil];
    
    for (int i = 0; i < numberOfPoints; i++) {
        labelText = [self.arrLabelsY objectAtIndex:i];
        
        [labelText drawInRect:CGRectMake(0, self.bounds.size.height - C_Y_INSET_BOTTOM - i * yStep - 0.85 * self.fontYScale.pointSize, C_X_INSET_LEFT - C_Y_SCALEMARKER_SIZE, self.fontYScale.pointSize * 2) withAttributes:attributes];
    }
    
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

-(void)drawChartFrom:(NSMutableArray*)arrValues_
{
  bool started = NO;
  cGraphValue* dataValue;
  CGPoint point = CGPointMake(C_X_INSET_LEFT, 0);
  CGPoint point0 = point;
  
  CGContextSaveGState(context);
  
  float xLength = self.bounds.size.width - C_X_INSET_LEFT - C_X_INSET_RIGHT;
  float yLength = self.bounds.size.height - C_Y_INSET_TOP - C_Y_INSET_BOTTOM;
  
  UIBezierPath *aPath = [UIBezierPath bezierPath];
  UIBezierPath *aPathTop = [UIBezierPath bezierPath];
 
  for (int i = 0; i < arrValues_.count; i++)
  {
    dataValue = arrValues_[i];
    
    //        if (dataValue.sum / dataValue.numberOfElements > 70)
    //            NSLog(@">=70");
    //        
    //        dataValue.sum = 70;
    //        dataValue.numberOfElements = 1;
    
    if (dataValue.active)
    {
      point = CGPointMake(i * xLength / arrValues_.count + C_X_INSET_LEFT, - dataValue.sum / dataValue.numberOfElements * yLength / (self.yMax - self.yMin) + self.bounds.size.height - C_Y_INSET_BOTTOM);
      
      if (started)
      {
        // If we don't offset the first value,  then a single result is never visible!
        point.x += 10;
        [aPath addLineToPoint:point];
        [aPathTop addLineToPoint:point];
      }
      else
      {
        started = YES;
        [aPath moveToPoint:point];
        [aPathTop moveToPoint:point];
        point0 = point;
      }
    }
  }
  
  if (started) {
    
    CGContextSaveGState(context);
    
    point.y = self.bounds.size.height - C_Y_INSET_BOTTOM;
    [aPath addLineToPoint:point];
    point = point0;
    point.y = self.bounds.size.height - C_Y_INSET_BOTTOM;
    [aPath addLineToPoint:point];
    [aPath addLineToPoint:point0];
   
    // If we don't give a thick line width, then a single result is never shown!
    CGContextSetLineWidth(context, 10);
    CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
    [aPath stroke];
    //NSLog(@"aPath:%@", [aPath description]);
   
    // This is critical, in that without the following line, there is nothing drawn at all - it defines the outer bounds of the shape that is filled subsequently!
    [aPath addClip];
    
#define C_BACK_GRAY_DARK 80.0
#define C_BACK_GRAY_LIGHT 240.0
    
    size_t num_locations            = 2;
    CGFloat locations[2]            = {0.1, 0.9};
    
    CGFloat colorComponents[8]      = {C_BACK_GRAY_DARK/255.0, C_BACK_GRAY_DARK/255.0, C_BACK_GRAY_DARK/255.0, 1.0,
      C_BACK_GRAY_LIGHT/255.0, C_BACK_GRAY_LIGHT/255.0, C_BACK_GRAY_LIGHT/255.0, 1.0};
    CGColorSpaceRef myColorspace    = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient          = CGGradientCreateWithColorComponents (myColorspace, colorComponents, locations, num_locations);
    
    CGPoint centerPoint             = CGPointMake(self.bounds.size.width / 2.0,
                                                  self.bounds.size.height / 2.0);
    
    // Draw the gradient
    CGContextDrawRadialGradient(context, gradient, centerPoint, self.bounds.size.width, centerPoint, 0, (kCGGradientDrawsBeforeStartLocation));
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(myColorspace);
    
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    
    float xStep = (self.bounds.size.width - C_X_INSET_LEFT - C_X_INSET_RIGHT) / (self.arrLabelsX.count - 1);
    for (int i = 0; i < self.arrLabelsX.count; i++) {
      CGContextMoveToPoint(context, C_X_INSET_LEFT + i * (xStep), self.bounds.size.height - C_Y_INSET_BOTTOM);
      CGContextAddLineToPoint(context, C_X_INSET_LEFT + i * (xStep), C_Y_INSET_TOP);
    }
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor sSKCGetColor_cornflowerColor].CGColor);
    [aPathTop stroke];
  }
  
  CGContextRestoreGState(context);
}
@end

@implementation cGraphValue

-(id)init
{
    if (self = [super init])
    {
        self.active = NO;
        self.sum = 0;
        self.numberOfElements = 1;
    }
    
    return self;
}

@end