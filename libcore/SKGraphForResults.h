//
//  SKGraphForResults.h
//  SKCore
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKGraphForResults : NSObject<CALayerDelegate, CPTScatterPlotDataSource, CPTScatterPlotDelegate, CPTAxisDelegate>

// The properties are here, for ease of testing.
@property (retain) NSArray *mpCorePlotDataPoints;
@property (retain) NSArray *mpCorePlotDates;
@property double corePlotMinValue;
@property double corePlotMaxValue;

@property  BOOL hidden;

- (id)init;

-(void)updateGraphWithTheseResults:(NSData*)jsonData OnParentView:(UIView*)inParentView InFrame:(CGRect)inFrame StartHidden:(BOOL)inStartHidden WithDateFilter:(DATERANGE_1w1m3m1y)inDateFilter;

+(NSString*) sConvertJsonDataToString:(NSData*)jsonData;
  
@end
