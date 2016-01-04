//
//  BleController.h
//  httpserver
//
//  Created by Yann Lapeyre on 18/06/2015.
//  Copyright (c) 2015 Medes-IMPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETBleReaderDelegate.h"
@import CoreBluetooth;

@interface ETBleController : NSObject <CBCentralManagerDelegate>

@property (nonatomic) id<ETBleReaderDelegate> delegate;
@property (nonatomic, readonly) BOOL isScanning;

- (void) startScanning;
- (void) stopScanning;

@end
