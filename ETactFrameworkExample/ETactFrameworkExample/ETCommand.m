//
//  EtactCmd.m
//  e-TactCheck
//
//  Created by Yann Lapeyre on 09/10/2015.
//  Copyright © 2015 Medes-IMPS. All rights reserved.
//

#import "ETCommand.h"

@implementation ETCommand

-(instancetype) initWithData:(NSData *)data mode:(UInt8)mode andExpectedDataType:(ETBartType)type {
    if(self = [super init]) {
        _rawData = data;
        _mode = mode;
        _expectedDataType = type;
    }
    return self;
}

-(instancetype) initWithData:(NSData *)data andMode:(UInt8)mode {
    return [self initWithData:data mode:mode andExpectedDataType:BartValueType_unavailabe];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"ETCommand - rawdata:%@ ; mode:%hhu ; expectedDataType: %hhu",
            [self.rawData description],
            self.mode,
            self.expectedDataType];
}

@end
