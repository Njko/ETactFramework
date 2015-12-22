//
//  ETBartDataTemperatureHelper.h
//  ETactFramework
//
//  Created by Nicolas Linard on 09/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ETBartData.h"
#import "ETConstants.h"

@interface ETBartDataHelper : NSObject

+(NSTimeInterval) readTimestampFromData:(ETBartData *) data;
+(NSArray *) readAccelerationFromData:(ETBartData *) data;
+(NSNumber *) readTemperatureFromData:(ETBartData*) data;
+(NSNumber *) readActivityFromData:(ETBartData *) data;
+(NSString *)readBartVersionNumberFromData:(ETBartData *)data;
+(BOOL) isDataValid:(ETBartData *)data;
//TO REFACTOR
+(NSString *) bartCommandTypeToString:(ETBartCommandType)type;
+(NSString *) bartTypeToString:(ETBartType)type;

@end
