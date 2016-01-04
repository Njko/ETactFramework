//
//  EtactReader.h
//  BodyCapSerial
//
//  Created by Yann Lapeyre on 29/07/2015.
//  Copyright (c) 2015 Medes-IMPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETReadHandlerDelegate.h"
#import "ETConstants.h"

@interface ETReadHandler : NSObject

@property (nonatomic, weak) id<ETReadHandlerDelegate> delegate;

@property (nonatomic) UInt8 mode;
@property (nonatomic) ETBartType expectedDataType;

-(void) newBytesRead:(NSData *)read;
-(void) reset;

@end


