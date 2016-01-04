//
//  ETBartData.h
//  ETactFramework
//
//  Created by Nicolas Linard on 08/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETConstants.h"

@interface ETBartData : NSObject

@property (nonatomic, readonly) NSData * rawData;
@property (nonatomic, readonly) ETBartType dataType;
@property (nonatomic) BOOL isValid;

-(instancetype) initWithData: (NSData *)data andType:(ETBartType)type;
-(BOOL) isValid;

@end
