//
//  SKJUploadTest.h
//  SKCore
//
//  Created by Pete Cole on 05/06/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//
// This file is a direct port from UploadTest.java
//

#import "SKJHttpTest.h"

@interface SKJUploadTest : SKJHttpTest

@property double bitrateMpbs1024Based;
@property NSMutableData *buff;

- (instancetype)initWithParamArray:(NSArray*)params;

@end
