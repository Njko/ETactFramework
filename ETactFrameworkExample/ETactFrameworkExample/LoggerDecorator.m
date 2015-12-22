//
//  PWLoggerDecorator.m
//  Pods
//
//  Created by Nicolas Linard on 12/11/2015.
//
//

#import "LoggerDecorator.h"

@implementation LoggerDecorator

- (id)init {
    if((self = [super init])) {
        threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
        [threadUnsafeDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss:SSS"];
    }
    return self;
}

- (NSString *) formatLogMessage:(DDLogMessage *)logMessage {
    NSString * logLevel;
    switch (logMessage->_flag) {
        case DDLogFlagError    : logLevel = @"Error  "; break;
        case DDLogFlagWarning  : logLevel = @"Warning"; break;
        case DDLogFlagInfo     : logLevel = @"Info   "; break;
        case DDLogFlagDebug    : logLevel = @"Debug  "; break;
        default                : logLevel = @"Verbose"; break;
    }
    
    NSString *dateAndTime = [threadUnsafeDateFormatter stringFromDate:(logMessage->_timestamp)];
    NSString *logMsg = logMessage->_message;
    NSString *function = logMessage->_function;
    NSUInteger lineNumber = logMessage->_line;
    
    return [NSString stringWithFormat:@"%@ - %@ %@ [line %lu] | %@\n", logLevel, dateAndTime, function, (unsigned long)lineNumber, logMsg];
}

- (void)didAddToLogger:(id <DDLogger>)logger {
    loggerCount++;
    NSAssert(loggerCount <= 1, @"This logger isn't thread-safe");
}

- (void)willRemoveFromLogger:(id <DDLogger>)logger {
    loggerCount--;
}

@end
