//
//  PWLoggerDecorator.h
//  Pods
//  Based on CocoaLubmerjack custom formatters:
//  https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/Documentation/CustomFormatters.md
//  Created by Nicolas Linard on 12/11/2015.
//
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface LoggerDecorator : NSObject <DDLogFormatter> {
    int loggerCount;
    NSDateFormatter *threadUnsafeDateFormatter;
}

@end
