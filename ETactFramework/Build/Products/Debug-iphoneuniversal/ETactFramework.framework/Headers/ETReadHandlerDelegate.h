//
//  ETReadHandlerDelegate.h
//  ETactFramework
//
//  Created by Nicolas Linard on 07/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#ifndef ETReadHandlerDelegate_h
#define ETReadHandlerDelegate_h
#import "ETConstants.h"

@protocol ETReadHandlerDelegate <NSObject>

-(void)readerStatusChanged:(ETReaderStatus)status :(NSString *)optionalText;

-(void)responseReceived:(ETBartCommandType)cmd :(NSObject *)result;

@optional
-(void)ackReceivedForCommand:(ETBartCommandType)cmd;
@end

#endif /* ETReadHandlerDelegate_h */
