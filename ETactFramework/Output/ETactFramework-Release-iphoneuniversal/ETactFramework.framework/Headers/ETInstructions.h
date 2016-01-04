//
//  HdwCommands.h
//  BodyCapSerial
//
//  Created by Yann Lapeyre on 19/07/2015.
//  Copyright (c) 2015 Medes-IMPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETConstants.h"

@interface ETInstructions : NSObject

+(NSData *) hardwareVersion;
+(NSData *) softwareVersion;
+(NSData *) bartVersion;
+(NSData *) hardwareDescription;
+(NSData *) softwareDescription;
+(NSData *) dataCount;
+(NSData *) activateSleepMode;
+(NSData *) deactivateSleepMode;
+(NSData *) resetDevice;
+(NSData *) resetTimestamp;
+(NSData *) unloadData:(UInt8)type fromIndex:(UInt32)minIndex toIndex:(UInt32)maxIndex;
+(UInt8)computeCrc:(NSData *)data;
+(NSData *)buildAck:(UInt8)cmd;

@end
