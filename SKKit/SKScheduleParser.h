//
//  SKScheduleParser.h
//  SKKit
//
//  Created by Pete Cole on 26/01/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//

#import <Foundation/Foundation.h>

//===

#import "SKTestRunner.h"

@interface SKScheduleHost : NSObject
- (NSString *)getDnsName;
- (NSString *)getDisplayName;
@end



@interface SKScheduleParser : NSObject <NSXMLParserDelegate>
- (instancetype)initFromXMLString:(NSString *)fromXMLString;
- (NSMutableArray *)getHostArray;
- (NSMutableArray *)getTestArray;
- (double)getDataCapMbps;
-(SKTestRunner*)createTestRunner;
- (void)helloWorld;
@end