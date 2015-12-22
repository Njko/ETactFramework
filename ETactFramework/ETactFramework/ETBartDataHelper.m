//
//  ETBartDataTemperatureHelper.m
//  ETactFramework
//
//  Created by Nicolas Linard on 09/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import "ETBartDataHelper.h"
#import "ETByteUtils.h"

@implementation ETBartDataHelper

+(NSTimeInterval)readTimestampFromData:(ETBartData *)data {
    long byteBuffer = [ETByteUtils readLong:[data.rawData subdataWithRange:NSMakeRange(0, 4)]];
    NSTimeInterval result = byteBuffer;
    return result ;
}

+(NSArray *)readAccelerationFromData:(ETBartData *)data {
    if (data.dataType != BartValueType_acceleration) {
        return nil;
    }
    
    int valueX,valueY,valueZ;
    valueX = [ETByteUtils readSignedInt:[data.rawData subdataWithRange:NSMakeRange(4, 1)]];
    valueY = [ETByteUtils readSignedInt:[data.rawData subdataWithRange:NSMakeRange(5, 1)]];
    valueZ = [ETByteUtils readSignedInt:[data.rawData subdataWithRange:NSMakeRange(6, 1)]];

    return @[[NSNumber numberWithInt:valueX],[NSNumber numberWithInt:valueY],[NSNumber numberWithInt:valueZ]];
}

+(NSNumber *)readTemperatureFromData:(ETBartData *)data {
    if (data.dataType != BartValueType_temperature) {
        return nil;
    }
    
    int temperature = [ETByteUtils readInt:[data.rawData subdataWithRange:NSMakeRange(4, 2)]];
    return [NSNumber numberWithInt:temperature];
}

+(NSNumber *)readActivityFromData:(ETBartData *)data {
    if (data.dataType != BartValueType_activity) {
        return nil;
    }
    
    int activity;
    [data.rawData getBytes:&activity range:NSMakeRange(4, 1)];
    
    return [NSNumber numberWithInt:activity];
}

+(NSString *)readBartVersionNumberFromData:(ETBartData *)data {
    int W,X,Y,Z;
    W = [ETByteUtils readInt:[data.rawData subdataWithRange:NSMakeRange(0, 1)]];
    X = [ETByteUtils readInt:[data.rawData subdataWithRange:NSMakeRange(1, 1)]];
    Y = [ETByteUtils readInt:[data.rawData subdataWithRange:NSMakeRange(2, 1)]];
    Z = [ETByteUtils readInt:[data.rawData subdataWithRange:NSMakeRange(3, 1)]];
    return [NSString stringWithFormat:@"%d.%d.%d.%d",W,X,Y,Z];
    //return @"0.0.0.0";
}

+(NSString *)bartCommandTypeToString:(ETBartCommandType)type {
    switch (type) {
        case CompNAME:
            return @"CompNAME";
            break;
        case ProdNAME:
            return @"ProdNAME";
            break;
        case HardDESC:
            return @"HardDESC";
            break;
        case SoftDESC:
            return @"SoftDESC";
            break;
        case HardVER:
            return @"HardVER";
            break;
        case SoftVER:
            return @"SoftVER";
            break;
        case BartVER:
            return @"BartVER";
            break;
        case LocalID:
            return @"LocalID";
            break;
        case StockDATA:
            return @"StockDATA";
            break;
        case SetStockDATA:
            return @"SetStockDATA";
            break;
        case NbLINKData:
            return @"NbLinkDATA";
            break;
        case Reset:
            return @"Reset";
            break;
        case Timestamp:
            return @"Timestamp";
            break;
        case UnloadDATA:
            return @"UnloadDATA";
            break;
        default:
            return @"Not Available";
            break;
    }
}

+(NSString *) bartTypeToString:(ETBartType)type {
    switch (type) {
        case BartValueType_acceleration:
            return @"Acceleration";
            break;
        case BartValueType_activity:
            return @"Activity";
            break;
        case BartValueType_timestamp:
            return @"Timestamp";
            break;
        case BartValueType_temperature:
            return @"Temperature";
            break;
        case BartValueType_version:
            return @"Version";
            break;
        case BartValueType_unavailabe:
        default:
            return @"Unavailable";
            break;
    }
}
@end
