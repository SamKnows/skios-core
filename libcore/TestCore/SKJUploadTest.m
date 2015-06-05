//
//  SKJUploadTest.m
//  SKCore
//
//  Created by Pete Cole on 05/06/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//
// This file is a direct port from UploadTest.java
//

#import "SKJUploadTest.h"

@implementation SKJUploadTest


@synthesize bitrateMpbs1024Based;
@synthesize buff;

- (instancetype)initWithParamArray:(NSArray*)params
{
  self = [super init];
  if (self) {
    bitrateMpbs1024Based = -1.0;
    buff = nil;
  }
  return self;
}

@end
