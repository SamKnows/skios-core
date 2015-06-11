//
//  SKJPassiveServerUploadTest.h
//  SKCore
//
//  Created by Pete Cole on 05/06/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//
// This file is a direct port from PassiveServerUploadTest.java
//

#import "SKJUploadTest.h"

@interface SKJPassiveServerUploadTest : SKJUploadTest

- (instancetype)initWithParams:(NSDictionary*)params;

+(BOOL) sGetTestIsRunning;

@end
