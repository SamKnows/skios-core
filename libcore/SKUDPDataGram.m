//
//  UDPDataGram.m
//  SamKnows
//
//  Copyright 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKUDPDataGram.h"

@implementation SKUDPDataGram

@synthesize tag;
@synthesize cookie;
@synthesize packetData;

- (id)initWithData:(NSData*)_data
{
    self = [super init];
    
    if (self)
    {
        packetData = [[NSMutableData alloc] initWithData:_data];
        
        if (nil != packetData)
        {
            if ([packetData length] >= PACKET_SIZE)
            {
                // Get tag (first 4 bytes)
                NSData *tagData = [packetData subdataWithRange:NSMakeRange(0, 4)];
                int tagValue = CFSwapInt32BigToHost(*(int*)([tagData bytes]));
                tag = tagValue;
                
                /* Middle 8 bytes are for optional timestamp - ignore */
                
                // Get cookie (last 4 bytes)
                NSData *cookieData = [packetData subdataWithRange:NSMakeRange(12, 4)];
                int cookieValue = CFSwapInt32BigToHost(*(int*)([cookieData bytes]));
                cookie = cookieValue;
            }
        }
    }
    
    return self;
}

- (id)initWithTagAndMagicCookie:(int32_t)_tag :(int32_t)_cookie
{
    self = [super init];
    
    if (self)
    {
        tag = _tag;
        cookie = _cookie;

        char *byteArray = (char*)malloc(sizeof(char) * PACKET_SIZE);
        
        // Append Tag
        byteArray[0] = (int8_t)(tag>>24);
        byteArray[1] = (int8_t)(tag>>16);
        byteArray[2] = (int8_t)(tag>>8);
        byteArray[3] = (int8_t)(tag);
        
        // Append Time (Currently filled with 0's)
        byteArray[4] = (int8_t)0;
        byteArray[5] = (int8_t)0;
        byteArray[6] = (int8_t)0;
        byteArray[7] = (int8_t)0;
        byteArray[8] = (int8_t)0;
        byteArray[9] = (int8_t)0;
        byteArray[10] = (int8_t)0;
        byteArray[11] = (int8_t)0;
        
        // Append Cookie
        byteArray[12] = (uint8_t)(cookie>>24);
        byteArray[13] = (uint8_t)(cookie>>16);
        byteArray[14] = (uint8_t)(cookie>>8);
        byteArray[15] = (uint8_t)(cookie);
        
        packetData = [[NSMutableData alloc] initWithBytes:byteArray length:PACKET_SIZE];

        free(byteArray);
        byteArray = 0;
    }
    
    return self;
}


@end
