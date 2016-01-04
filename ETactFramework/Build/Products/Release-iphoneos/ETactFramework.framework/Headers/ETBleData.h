//
//  ETBleData.h
//  ETactFrameworkExample
//
//  Created by Nicolas Linard on 14/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETConstants.h"

@interface ETBleData : NSObject

@property (nonatomic, readonly) NSData * rawData;
@property (nonatomic, readonly) NSTimeInterval timestamp;

-(instancetype) initWithData: (NSData *)data;

@end
