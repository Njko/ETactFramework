//
//  ETBleDataHelper.h
//  ETactFrameworkExample
//
//  Created by Nicolas Linard on 14/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETBleData.h"

@interface ETBleDataHelper : NSObject

+(NSDictionary *) dataToBleDataValues:(ETBleData *) source;
+(NSNumber *) dataToCompanyID:(ETBleData *) source;
+(NSNumber *) dataToSoftwareVersion:(ETBleData *)source;
+(NSNumber *) dataToBatteryLevel:(ETBleData *) source;
+(NSNumber *) dataToTemperature:(ETBleData *) source;
+(NSNumber *) dataToActivity:(ETBleData *) source;
+(NSDictionary *) dataToAcceleration:(ETBleData *) source;

@end