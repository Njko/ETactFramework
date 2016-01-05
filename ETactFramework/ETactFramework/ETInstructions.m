//
//  HdwCommands.m
//  BodyCapSerial
//
//  Created by Yann Lapeyre on 19/07/2015.
//  Copyright (c) 2015 Medes-IMPS. All rights reserved.
//

#import "ETInstructions.h"
#import "ETByteUtils.h"

@implementation ETInstructions


// Hardware description
+(NSData *) hardwareDescription {
    UInt8 cmd[3] = {0x02,0x00,0x02};
    return [[NSData alloc]initWithBytes:cmd length:3];
}

// sofwtare description
+(NSData *) softwareDescription {
    UInt8 cmd[3] = {0x03,0x00,0x03};
    return [[NSData alloc]initWithBytes:cmd length:3];
}


// Veriosn of the connected hardware
+(NSData *) hardwareVersion {
    UInt8 cmd[3] = {0x04,0x00,0x04};
    return [[NSData alloc]initWithBytes:cmd length:3];
}

// Version of the software
+(NSData *) softwareVersion {
    UInt8 cmd[3] = {0x05,0x00,0x05};
    return [[NSData alloc]initWithBytes:cmd length:3];
}

// Version of the serial protocol
+(NSData *) bartVersion {
    UInt8 cmd[3] = {0x06,0x00,0x06};
    return [[NSData alloc]initWithBytes:cmd length:3];
}


// Count available data stored in the device
+(NSData *)dataCount {
    UInt8 cmd[3] = {0x60,0x00,0x60};
    return [[NSData alloc]initWithBytes:cmd length:3];
}

//Activate sleep mode: stop listening the sensors and write the data on the buffers
+ (NSData *)activateSleepMode {
    UInt8 cmd[5] = {0x42,0x03,0xA1,0x01,0x01};
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:cmd length:5];
    UInt8 crc = [ETInstructions computeCrc:data];
    [data appendBytes:&crc length:sizeof(crc)];
    return data;
}

//Deactivate sleep mode: lock the buffer and start listening the sensors
+ (NSData *)deactivateSleepMode {
    UInt8 cmd[5] = {0x42,0x03,0xA1,0x01,0x00};
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:cmd length:5];
    UInt8 crc = [ETInstructions computeCrc:data];
    [data appendBytes:&crc length:sizeof(crc)];
    return data;
}

//Reset the memory of the patch
+ (NSData *)resetDevice {
    //Init the command
    UInt8 cmd[6] = {0xE1,0x04,0x00,0x00,0x00,0x00};
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:cmd length:6];
    
    // add the CRC
    UInt8 crc = [ETInstructions computeCrc:data];
    [data appendBytes:&crc length:sizeof(crc)];
    
    return data;
}

//Reset the memory of the patch
+ (NSData *)resetTimestamp {
    //Init the command
    UInt8 cmd[2] = {0x11,0x04};
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:cmd length:2];
    
    //append timestamp big endian int
    long int now = lround([[NSDate date] timeIntervalSince1970]);
    //1 - reduce the data size from long (native) to int (target)
    NSData * nowData = [[NSData alloc] initWithBytes:&now length:4];
    //2 - use byte array in tool to convert int little to bing endian
    int finalNowDate = CFSwapInt32HostToBig(*(int*)[nowData bytes]);
    //3 - write result as big endian int (4 bytes only)
    [data appendBytes:&finalNowDate length:4];
    
    // add the CRC
    UInt8 crc = [ETInstructions computeCrc:data];
    [data appendBytes:&crc length:sizeof(crc)];
    
    return data;
}

// unload data rom device for the given type and range
+(NSData *)unloadData:(UInt8)type fromIndex:(UInt32)minIndex toIndex:(UInt32)maxIndex {
    
    //TODO - check coherence between the type and the index range
    //UInt8 cmd[12] = {0x63,0x0A,0x00,0x8D,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x05};
    UInt8 cmd[3] = {0x63,0x0A,0x00};
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:cmd length:3];
    [data appendBytes:&type length:1];
    
    
    // add the index range
    [data appendData:[ETByteUtils reverseUInt32:minIndex]];
    [data appendData:[ETByteUtils reverseUInt32:maxIndex]];
    
    // add the CRC
    UInt8 crc = [ETInstructions computeCrc:data];
    [data appendBytes:&crc length:sizeof(crc)];
    
    return data;
}

+(NSData *)buildAck:(UInt8)cmd {
    UInt8 ack[3]={cmd,0x01,0xA5};
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:ack length:3];
    // add the CRC
    UInt8 crc = [ETInstructions computeCrc:data];
    [data appendBytes:&crc length:sizeof(crc)];
    return data;
}

// Compute CRC for the given bytes
+(UInt8)computeCrc:(NSData *)data {
    UInt8 crc = 0;
    UInt8 datas[data.length];
    [data getBytes:&datas length:data.length];
    for(int i=0; i<data.length; i++){
        crc ^= datas[i];
    }
    return crc;
}

@end
