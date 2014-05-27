//
//  UDPDataGram.h
//  SamKnows
//
// Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define PACKET_SIZE 9216
#define PACKET_SIZE 16

@interface SKUDPDataGram : NSObject
{
    int32_t tag;
    int32_t cookie;
    
    NSMutableData *packetData;
}

@property (nonatomic, assign) int32_t tag;
@property (nonatomic, assign) int32_t cookie;

@property (nonatomic, strong) NSMutableData *packetData;

- (id)initWithData:(NSData*)_data;
- (id)initWithTagAndMagicCookie:(int32_t)_tag :(int32_t)_cookie;

@end
