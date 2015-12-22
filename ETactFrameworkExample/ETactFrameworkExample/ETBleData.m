//
//  ETBleData.m
//  ETactFrameworkExample
//
//  Created by Nicolas Linard on 14/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import "ETBleData.h"

@implementation ETBleData

- (instancetype) initWithData:(NSData *)data {
    if (self = [super init]) {
        _rawData = data;
        _timestamp = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

@end
