//
//  EtactCmd.h
//  e-TactCheck
//
//  Created by Yann Lapeyre on 09/10/2015.
//  Copyright © 2015 Medes-IMPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETReadHandler.h"

@interface ETCommand : NSObject

@property (nonatomic, strong, readonly) NSData *rawData;
@property (nonatomic, readonly) UInt8 mode;
@property (nonatomic, readonly) ETBartType expectedDataType;

@property (nonatomic, strong) ETCommand * nextCommand;

-(instancetype) initWithData:(NSData *)data mode:(UInt8)mode andExpectedDataType:(ETBartType)type;
-(instancetype) initWithData:(NSData *)data andMode:(UInt8)mode;

@end
