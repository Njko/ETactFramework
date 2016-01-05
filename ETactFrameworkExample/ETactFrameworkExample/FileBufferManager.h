//
//  FileBufferManager.h
//  PulwaveAnalyser
//
//  Created by Nicolas Linard on 24/11/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETBartData.h"

@interface FileBufferManager : NSObject

+ (id) sharedInstance;
-(BOOL) writeArrayBuffer:(NSArray *)buffer;
-(NSArray *) readArrayBuffer;
-(BOOL) writeDataBuffer:(NSData *)buffer;
-(NSData *) readDataBuffer;
-(BOOL) pushValueToBuffer:(ETBartData *) value;

-(void) openBuffer;
-(void) closeBuffer;
-(void) testBinaryBuffer;
-(NSDictionary *)readBinaryBuffer;
@end
