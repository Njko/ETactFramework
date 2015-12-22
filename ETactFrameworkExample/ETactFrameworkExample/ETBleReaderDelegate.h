//
//  ETBleReaderDelegate.h
//  ETactFrameworkExample
//
//  Created by Nicolas Linard on 14/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETBleData.h"
@import CoreBluetooth;

@protocol ETBleReaderDelegate <NSObject>

-(void) didUpdateState:(CBCentralManagerState)state;
-(void) didReceiveValue:(ETBleData*)value;

@end
