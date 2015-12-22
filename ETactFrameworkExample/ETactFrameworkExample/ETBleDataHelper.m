//
//  ETBleDataHelper.m
//  ETactFrameworkExample
//
//  Created by Nicolas Linard on 14/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import "ETBleDataHelper.h"
#import "ETByteUtils.h"

@implementation ETBleDataHelper

+(NSDictionary *) dataToBleDataValues:(ETBleData *)source {
    return @{@"companyID":[self dataToCompanyID:source],
             @"softVersion":[self dataToSoftwareVersion:source],
             @"batteryLevel":[self dataToBatteryLevel:source],
             @"temperature":[self dataToTemperature:source],
             @"activity":[self dataToActivity:source],
             @"acceleration":[self dataToAcceleration:source]};
}

+(NSNumber *) dataToCompanyID:(ETBleData *)source {
    return [NSNumber numberWithLong:[ETByteUtils readLong:[source.rawData subdataWithRange:NSMakeRange(0, 4)]]];
}

+(NSNumber *) dataToSoftwareVersion:(ETBleData *)source {
    return [NSNumber numberWithInt:[ETByteUtils readInt:[source.rawData subdataWithRange:NSMakeRange(4, 1)]]];
}

+(NSNumber *) dataToBatteryLevel:(ETBleData *)source {
    return [NSNumber numberWithInt:[ETByteUtils readInt:[source.rawData subdataWithRange:NSMakeRange(5, 1)]]];
}

+(NSNumber *) dataToTemperature:(ETBleData *)source {
    return [NSNumber numberWithInt:[ETByteUtils readInt:[source.rawData subdataWithRange:NSMakeRange(6,2)]]];
}

+(NSNumber *) dataToActivity:(ETBleData *)source {
    return [NSNumber numberWithInt:[ETByteUtils readInt:[source.rawData subdataWithRange:NSMakeRange(8, 1)]]];
}
+(NSDictionary *) dataToAcceleration:(ETBleData *)source {
    int xAxis,yAxis,zAxis;
    float pitch, roll;
    xAxis = [ETByteUtils readSignedInt:[source.rawData subdataWithRange:NSMakeRange(9, 1)]];
    yAxis = [ETByteUtils readSignedInt:[source.rawData subdataWithRange:NSMakeRange(10, 1)]];
    zAxis = [ETByteUtils readSignedInt:[source.rawData subdataWithRange:NSMakeRange(11, 1)]];
    
    pitch = atan2f(yAxis, sqrt(pow(xAxis, 2)+pow(zAxis, 2)));
    pitch = (pitch*180)/M_PI;
    
    roll = atan2f(xAxis, sqrt(pow(yAxis, 2)+pow(zAxis, 2)));
    roll = (roll*180)/M_PI;
    
    return @{@"xAxis":[NSNumber numberWithInt:xAxis],
             @"yAxis":[NSNumber numberWithInt:yAxis],
             @"zAxis":[NSNumber numberWithInt:zAxis],
             @"pitch":[NSNumber numberWithFloat:pitch],
             @"roll" :[NSNumber numberWithFloat:roll]};
}

@end
