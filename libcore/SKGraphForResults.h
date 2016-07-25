//
//  SKGraphForResults.h
//  SKCore
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// This protocol must be defined manually prior to XCode 8 (where it has been added as a formal protocol)
// https://developer.apple.com/library/ios/documentation/QuartzCore/Reference/CALayerDelegate_protocol/#//apple_ref/occ/instm/NSObject/actionForLayer:forKey:
//#import <QuartzCore/QuartzCore.h>
//#import <QuartzCore/CALayer.h>
@protocol CALayerDelegate
@optional
- (void)displayLayer:(CALayer *)layer;
- (void)layoutSublayersOfLayer:(CALayer *)layer;
- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)key;
  
@end

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
