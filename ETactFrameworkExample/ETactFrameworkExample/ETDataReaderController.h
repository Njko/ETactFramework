//
//  ViewController.h
//  e-TactCheck
//
//  Created by Yann Lapeyre on 09/10/2015.
//  Copyright © 2015 Medes-IMPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RscMgr.h"
#import "ETReadHandler.h"
#import "ETDataReaderDelegate.h"
#import "ETConstants.h"
#import "ETBartData.h"

@interface ETDataReaderController : NSObject <RscMgrDelegate, ETReadHandlerDelegate>

@property (nonatomic) id<ETDataReaderDelegate> delegate;

- (void) resetDeviceStatus;

#pragma mark - Device commands
- (void) askDeviceForVersionNumbers;
- (void) askDeviceForValuesStoredAvailable;
- (void) askDeviceToReset;
- (void) askDeviceToSetSleepMode:(BOOL)isOn;
- (void) askDeviceForAccelerationData;
- (void) askDeviceForTemperaturData;
- (void) askDeviceForActivityData;
@end

