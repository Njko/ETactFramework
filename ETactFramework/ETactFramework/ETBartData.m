//
//  ETBartData.m
//  ETactFramework
//
//  Created by Nicolas Linard on 08/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import "ETBartData.h"
#import "ETBartDataHelper.h"

@implementation ETBartData

-(instancetype) initWithData:(NSData *)data andType:(ETBartType) type {
    if (self = [super init]) {
        _rawData = data;
        _dataType = type;
        _isValid = [ETBartData isDataValid:data withType:type];
    }
    return self;
}

-(NSString *) description {
    NSTimeInterval timestamp = [ETBartDataHelper readTimestampFromData:self];
    NSDate * datetime = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    NSString * typeString;
    NSString * valueString;
    NSArray * acceleration;
    NSNumber * temperature;
    NSNumber * activity;
    switch (_dataType) {
        case BartValueType_acceleration:
            typeString = @"acceleration";
            if ([self.rawData length]< 7) {
                valueString = @"X:0 Y:0 Z:0";
                _isValid = NO;
                break;
            }
            acceleration = [ETBartDataHelper readAccelerationFromData:self];
            if ([acceleration count] == 3) {
                valueString = [NSString stringWithFormat:@"X:%@ Y:%@ Z:%@",
                               [acceleration objectAtIndex:0],
                               [acceleration objectAtIndex:1],
                               [acceleration objectAtIndex:2]];
            } else {
                valueString = @"X:0 Y:0 Z:0";
            }
            break;
        case BartValueType_activity:
            typeString = @"activity";
            if ([self.rawData length]< 5) {
                valueString = @"0";
                _isValid = NO;
                break;
            }
            activity = [ETBartDataHelper readActivityFromData:self];
            valueString = [NSString stringWithFormat:@"%@",activity];
            break;
        case BartValueType_temperature:
            typeString = @"temperature";
            if ([self.rawData length]< 6) {
                valueString = @"0";
                _isValid = NO;
                break;
            }
            temperature = [ETBartDataHelper readTemperatureFromData:self];
            valueString = [NSString stringWithFormat:@"%@",temperature];
            break;
        case BartValueType_timestamp:
            typeString = @"timestamp";
            break;
        default:
            typeString = @"unkown type";
            break;
    }
    
    return [NSString stringWithFormat:@"%@ - %@: %@ - valid? %@",datetime,typeString,valueString,_isValid?@"YES":@"NO"];
}

+(BOOL) isDataValid:(NSData *)data withType:(ETBartType) type{
    int buffer = 0;
    switch (type) {
        case BartValueType_acceleration:
            [data getBytes:&buffer range:NSMakeRange(4, 3)];
            if (buffer == 16777215) { //0xFFFFFF
                return NO;
            }
            return YES;
            break;
        case BartValueType_activity:
            [data  getBytes:&buffer range:NSMakeRange(4, 1)];
            if (buffer == 255) { //0xFF
                return NO;
            }
            return YES;
            break;
        case BartValueType_temperature:
            [data getBytes:&buffer range:NSMakeRange(4, 2)];
            if (buffer == 65535) { //0xFFFF
                return NO;
            }
            return YES;
            break;
        case BartValueType_timestamp:
        default:
            return YES;
            break;
    }
}
@end
