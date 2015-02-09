//
//  SKTestRunner.h
//  SKKit
//
//  Created by Pete Cole on 26/01/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKScheduleParser;

@interface SKTestRunner : NSObject
- (instancetype)initFromScheduleParser:(SKScheduleParser *)scheduleParser;
@end
