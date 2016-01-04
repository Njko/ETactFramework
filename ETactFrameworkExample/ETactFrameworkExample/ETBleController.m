//
//  BleController.m
//  httpserver
//
//  Created by Yann Lapeyre on 18/06/2015.
//  Copyright (c) 2015 Medes-IMPS. All rights reserved.
//

#import "ETBleController.h"
#import "ETBleData.h"

@interface ETBleController ()

@property (nonatomic, strong)  CBCentralManager *cbManager;

@end

@implementation ETBleController

#pragma mark - View control

- (instancetype)init {
    if (self = [super init]) {
        self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    }
    return self;
}

-(void) startScanning {
    if (!self.isScanning) {
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        [options setObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
        [self.cbManager scanForPeripheralsWithServices:nil options:options];
        _isScanning = YES;
    }
}

-(void) stopScanning {
    if (self.isScanning) {
        [self.cbManager stopScan];
        _isScanning = NO;
    }
}

#pragma mark - BLE status

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [self.delegate didUpdateState:central.state];
}

#pragma mark - Read Data with BLE

/**
 * Peripheral is discovered, so we log information about it
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSString *periphID = peripheral.identifier.UUIDString;
    //NSLog(@"Peripheral discovered %@",periphID);
    
    NSData *source = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    
    NSLog(@"advert data: %@",[source description]);
    if (source && [source length] > 12) {
        ETBleData * value = [[ETBleData alloc] initWithData:source andDeviceId:periphID];
        [self.delegate didReceiveValue:value];
    }
}
@end
