//
//  ETBleData.m
//  ETactFrameworkExample
//
//  Created by Nicolas Linard on 14/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import "ETBleData.h"

@implementation ETBleData

- (instancetype) initWithData:(NSData *)data andDeviceId:(NSString *)deviceId{
    if (self = [super init]) {
        _rawData = data;
        _timestamp = [[NSDate date] timeIntervalSince1970];
        _deviceID = [NSString stringWithString:deviceId];
    }
    return self;
}

@end
