//
//  Graphing.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface cGraphValue : NSObject

@property (nonatomic) bool active;
@property (nonatomic) float sum;
@property (nonatomic) int numberOfElements;

@end

@interface Graphing : UIView
{
    CGContextRef context;
}

@property (nonatomic, strong) NSMutableArray* arrLabelsX;
@property (nonatomic, strong) NSMutableArray* arrLabelsY;
@property (nonatomic, strong) NSMutableArray* arrValues;

@property (nonatomic, strong) UIFont* fontXScale;
@property (nonatomic, strong) UIFont* fontYScale;
@property (nonatomic, strong) UIFont* fontChartTitle;
@property (nonatomic, strong) UIFont* fontYAxisTitle;

@property (nonatomic) float yMin;
@property (nonatomic) float yMax;

@property (nonatomic, strong) NSString* chartTitle;
@property (nonatomic, strong) NSString* axisYTitle;

-(void)setDefaultValues;
-(void)createAndInitialiseArrayOfValues:(int)numberOfValues_;
-(void)setupYAxis;
-(void)setupXAxis:(int)dataPeriod_ withStartDate:(NSDate*)beginDate_;
@end
