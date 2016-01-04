//
//  ETDataReaderDelegate.h
//  ETactFramework
//
//  Created by Nicolas Linard on 07/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#ifndef ETDataReaderDelegate_h
#define ETDataReaderDelegate_h
#import "ETConstants.h"
#import "ETBartData.h"

@protocol ETDataReaderDelegate <NSObject>

- (void) didChangeStatus:(ETReaderStatus)status;
- (void) didUpdateHardwareVersionNumber:(NSNumber *)versionNumber;
- (void) didUpdateSoftwareVersionNumber:(NSNumber *)versionNumber;
- (void) didUpdateBartVersionNumber:(ETBartData *)versionNumber;
- (void) didReceiveValues:(NSArray *)values ofType:(ETBartType)type;
- (void) didChangeConnectionStatus:(BOOL)connected;
- (void) didUpdateNumberOfValuesToUnload:(NSNumber*)valueCount;

@optional
-(void) lastCommandAcknoledged:(ETBartCommandType)cmd;

@end
#endif /* ETDataReaderDelegate_h */
