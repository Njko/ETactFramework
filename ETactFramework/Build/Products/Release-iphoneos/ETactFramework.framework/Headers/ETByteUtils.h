//
//  ByteUtils.h
//  BodyCapSerial
//
//  Created by Yann Lapeyre on 20/07/2015.
//  Copyright (c) 2015 Medes-IMPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETByteUtils : NSObject

+(NSData *)reverseUInt32:(UInt32)source;

+(NSData *)reverseData:(NSData *)source;

+(NSString *)dataToString:(NSData *)data;

+(UInt32)dataToUInt32:(NSData *)data;

+(UInt8)readOneByteFrom:(NSData *)source atIndex:(int)index;

+(int)readInt:(NSData *)data;

+(int)readSignedInt:(NSData *)data;

+(long)readLong:(NSData *)data;

+(NSData *)reverseNSData:(NSData *)data;

@end
