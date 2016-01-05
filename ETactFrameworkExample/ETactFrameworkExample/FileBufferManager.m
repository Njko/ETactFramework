//
//  FileBufferManager.m
//  PulwaveAnalyser
//
//  Created by Nicolas Linard on 24/11/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import "FileBufferManager.h"
#import "AppDelegate.h"
#import "ETBartDataHelper.h"
#define SAMPLING_FREQUENCY 1
#define DEVICE_ID 102
#define COEFF_MAX_VALUE 65535
@import CocoaLumberjack;

@interface FileBufferManager()

@property (nonatomic, strong) NSArray * paths;
@property (nonatomic, strong) NSString * filename;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSData *csvDataSeparator;
@property (nonatomic) int coeff ;
//@property (nonatomic, strong) ETBartData * lastValue;
@property (nonatomic) BOOL isBufferOpened;
@property (nonatomic) BOOL isBufferCSV;
@property (nonatomic) BOOL isBufferInitialized;
@property (nonatomic) long startDateTime;

@end

@implementation FileBufferManager

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
static const NSString * csvDataSeparatorString = @",";

-(instancetype)init
{
    self = [super init];
    if(self){
    }
    return self;
}

- (void)dealloc
{
    [self.fileHandle closeFile];
}

-(BOOL) writeArrayBuffer:(NSArray *)buffer {
    return [buffer writeToFile:self.filename atomically:NO];
}

-(NSArray *) readArrayBuffer {
    return [[NSArray alloc] initWithContentsOfFile:self.filename];
}

+ (id) sharedInstance {
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once (&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

-(BOOL) writeDataBuffer:(NSData *) buffer {
    return [buffer writeToFile:self.filename atomically:NO];
}

-(NSData *) readDataBuffer {
    return [[NSData alloc] initWithContentsOfFile:self.filename];
}

-(BOOL) pushValueToBuffer:(ETBartData *)value {
    if(self.isBufferOpened) {
        if (!self.isBufferInitialized) {
            self.isBufferInitialized = YES;
            //self.lastValue = value;
            //self.coeff = 0;
        }
        /*
        if (value == self.lastValue && self.coeff < COEFF_MAX_VALUE) {
            self.coeff++;
            return YES;
        }
        
        //Write a string if the buffer is a CSV file, write binary otherwise
        if (self.isBufferCSV) {
            NSString *stringValue = [NSString stringWithFormat:@"%@%d%@%d",csvDataSeparatorString,value,csvDataSeparatorString,self.coeff];
            [self.fileHandle writeData:[stringValue dataUsingEncoding:NSUTF16StringEncoding]];
        } else {
            int finalValue = self.lastValue;
            NSMutableData *data = [[NSMutableData alloc] initWithBytes:&finalValue length:2];
            int finalCoeff = self.coeff;
            [data appendBytes:&finalCoeff length:2];
            [self.fileHandle writeData:data];
        }
        
        self.coeff = 1;
        self.lastValue = value;*/
        
        switch (value.dataType) {
            case BartValueType_acceleration:
                [ETBartDataHelper readAccelerationFromData:value];
                break;
            case BartValueType_activity:
                [ETBartDataHelper readActivityFromData:value];
                break;
            case BartValueType_temperature:
                [ETBartDataHelper readTemperatureFromData:value];
                break;
            default:
                break;
        }
        
        
        
        return YES;
    }
    
    DDLogError(@"buffer is closed");
    return NO;
}

-(void) openBuffer {
    
    self.paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.isBufferInitialized = NO;
    
    self.startDateTime =roundf([[NSDate date] timeIntervalSince1970]*1000);
    self.isBufferCSV = NO;
    self.filename = [NSString stringWithFormat:@"%@/buffer_ET_%ld%@",[self.paths objectAtIndex:0],(long)self.startDateTime,self.isBufferCSV?@".csv":@".dat"];
    
    int intBuffer;
    //Initializaing the header of the file
    NSMutableData *header;
    if (!self.isBufferCSV) {
        intBuffer = DEVICE_ID;
        header = [[NSMutableData alloc] initWithData:[NSData dataWithBytes:&intBuffer length:1]];
        
        //Adding the sampling frequency to the header
        intBuffer = SAMPLING_FREQUENCY;
        [header appendBytes:&intBuffer length:1];
        
        //Adding timestamp
        long timestamp = self.startDateTime;
        [header appendBytes:&timestamp length:sizeof(timestamp)];
    } else {
        header = [[NSMutableData alloc] initWithData:[@"csvStringHeader" dataUsingEncoding:NSUTF16StringEncoding]];
        
        self.csvDataSeparator = [csvDataSeparatorString dataUsingEncoding:NSUTF16StringEncoding];
    }
    //Create file with current header
    [header writeToFile:self.filename atomically:NO];
    DDLogInfo(@"filename: %@",self.filename);
    

    if (!self.fileHandle || !self.isBufferOpened) {
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.filename];
        DDLogInfo(@"file handler: %@",self.fileHandle.description);
    }
    [self.fileHandle seekToEndOfFile];
    self.isBufferOpened = YES;
}

-(void) closeBuffer {
    //close the file
    [self.fileHandle closeFile];
    self.isBufferOpened = NO;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    //Set Start DateTime of record to meta data dictionary
    [dict setObject:[NSString stringWithFormat:@"%ld", self.startDateTime] forKey:@"startdatetime"];
    
    //Set End DateTime of record to meta data dictionary
    long endDateTime = roundf([[NSDate date] timeIntervalSince1970]*1000);
    [dict setObject:[NSString stringWithFormat:@"%ld", endDateTime] forKey:@"enddatetime"];
    
    //Set Data Type of record to meta data dictionary
    //This record is from a sensor of type "pulsewave"
    [dict setObject:@"etactrecord" forKey:@"datatype"];
    
    //Send the data to the database
    [appDelegate storeDocumentWithMeta:dict andBinaryFilePath:self.filename];
}

-(void) testBinaryBuffer {
    //make sure the buffer is correctly closed before doing anything
    if (self.isBufferOpened) {
        [self.fileHandle closeFile];
    }
    
    //open for reading
    self.fileHandle = [NSFileHandle fileHandleForReadingAtPath:self.filename];
    
    NSData * data = [self.fileHandle readDataOfLength:20];
    
    int deviceId = 0;
    NSRange deviceIdRange= {0, 1};
    [data getBytes:&deviceId range:deviceIdRange];
    
    int frequency = 0;
    NSRange frequecyRange = {1, 1};
    [data getBytes:&frequency range:frequecyRange];
    
    long timestamp = 0;
    NSRange timestampRange = {2, 8};
    [data getBytes:&timestamp range:timestampRange];
    
    int firstValue = 0;
    NSRange firstValueRange ={10, 2};
    [data getBytes:&firstValue range:firstValueRange];
    
    int firstCoeff = 0;
    NSRange firstCoeffRange = {12, 2};
    [data getBytes:&firstCoeff range:firstCoeffRange];
    NSLog(@"Data read from file: %d : %d : %ld : %d : %d",deviceId,frequency, timestamp, firstValue, firstCoeff);
    DDLogWarn(@"Data read from file: %d : %d : %ld : %d : %d",deviceId,frequency, timestamp, firstValue, firstCoeff);
}

-(NSDictionary *) readBinaryBuffer {
    NSMutableDictionary * result = [[NSMutableDictionary alloc] init];
    
    //make sure the buffer is correctly closed before doing anything
    if (self.isBufferOpened) {
        [self.fileHandle closeFile];
        self.isBufferOpened = NO;
    }
    
    //open for reading
    self.fileHandle = [NSFileHandle fileHandleForReadingAtPath:self.filename];
    
    NSData * data = [self.fileHandle readDataToEndOfFile];
    int deviceId = 0;
    NSRange deviceIdRange= {0, 1};
    [data getBytes:&deviceId range:deviceIdRange];
    
    int frequency = 0;
    NSRange frequecyRange = {1, 1};
    [data getBytes:&frequency range:frequecyRange];
    
    long timestamp = 0;
    NSRange timestampRange = {2, 8};
    [data getBytes:&timestamp range:timestampRange];
    
    int currentPointer = 10;
    
    NSMutableArray * rawValues = [[NSMutableArray alloc] init];
    NSMutableArray * coeffs = [[NSMutableArray alloc] init];
    while (currentPointer < [data length]) {
        int valueBuffer = 0;
        NSRange valueRange ={currentPointer, 2};
        [data getBytes:&valueBuffer range:valueRange];
        currentPointer+=2;
        
        NSRange coeffRange ={currentPointer, 2};
        int coeffBuffer = 0;
        [data getBytes:&coeffBuffer range:coeffRange];
        currentPointer+=2;
        
        if(coeffBuffer != 0) {
            [rawValues addObject:@(valueBuffer)];
            [coeffs addObject:@(coeffBuffer)];
        }
    };
    [self.fileHandle closeFile];
    
    [result setObject:@(deviceId) forKey:@"deviceID"];
    [result setObject:@(frequency) forKey:@"frequency"];
    [result setObject:@(timestamp) forKey:@"timestamp"];
    [result setObject:rawValues forKey:@"rawValues"];
    [result setObject:coeffs forKey:@"coeffs"];
    
    return result;
}
@end
