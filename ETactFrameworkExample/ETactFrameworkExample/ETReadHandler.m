//
//  EtactReader.m
//  BodyCapSerial
//
//  Created by Yann Lapeyre on 29/07/2015.
//  Copyright (c) 2015 Medes-IMPS. All rights reserved.
//

#import "ETReadHandler.h"
#import "ETInstructions.h"
#import "ETByteUtils.h"
#import "ETBartData.h"
@import CocoaLumberjack;

const UInt8 STRING_READER_MODE = 1;
const UInt8 UINT_READER_MODE = 2;
const UInt8 DATA_READER_MODE = 3;
const UInt8 NO_RESULT_READER_MODE = 4;

const int RESULT_SIZE = 4;

@interface ETReadHandler()

@property (nonatomic) ETReaderStatus status;

@property (nonatomic, strong) NSMutableData *receivedBytes;

@property (nonatomic) UInt8 currentCommand;

@property (nonatomic, strong) NSData *currentResponse;

@property (nonatomic) int expectedResponseSize;

@end

@implementation ETReadHandler

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

-(instancetype) init {
    self = [super init];
    if(self){
        [self reset];
    }
    return self;
}

-(void) reset {
    self.currentCommand = 0;
    self.expectedResponseSize = 0;
    self.status = idle_status;
    self.receivedBytes = [[NSMutableData alloc] init];
    self.mode = STRING_READER_MODE;
}

-(void)newBytesRead:(NSData *)read {
    [self.receivedBytes appendData:read];
    DDLogInfo(@"Reading new bytes: %@ with status %u and mode %hhu", [read description], self.status, self.mode);
    switch(self.status){
        case idle_status:
            if(read.length>2){
                [self handleResult];
            }
            break;
        case in_result_status:
            [self handleResponse];
            break;
        case in_response_status:
            [self handleResponse];
            break;
        case in_error_status:
            break;
    }
    
}

-(void)handleResult {
     // ACK - NACK packet reception
    UInt8 command = [ETByteUtils readOneByteFrom:self.receivedBytes atIndex:0];
    UInt8 size = [ETByteUtils readOneByteFrom:self.receivedBytes atIndex:1];
    UInt8 result = [ETByteUtils readOneByteFrom:self.receivedBytes atIndex:2];
    UInt8 crc = [ETByteUtils readOneByteFrom:self.receivedBytes atIndex:3];
    
    //
    self.currentCommand = command;
    
    // Check CRC
    UInt8 buffer[3];
    buffer[0] = command;
    buffer[1] = size;
    buffer[2] = result;
    
    UInt8 confirm = [ETInstructions computeCrc:[[NSData alloc] initWithBytes:buffer length:3]];
    
    // Status progress
    if(crc == confirm){
        self.status = in_result_status;
        [self.delegate readerStatusChanged:self.status :@"Result received ..."];
        switch (result) {
            case RESPONSE_ACK:
                // Handle response
                DDLogInfo(@"Result ACK for mode %hhu", self.mode);
                [self.delegate ackReceivedForCommand:command];
                if (self.mode != 4) {
                    [self handleResponse];
                } else {
                    [self handleNoDataResponse];
                }
                break;
            case RESPONSE_NACK:
                DDLogError(@"Result NACK");
                break;
            case RESPONSE_CUNK:
                DDLogError(@"Result CUNK");
                break;
            case RESPONSE_DUNK:
                DDLogError(@"Result DUNK");
                break;
            case RESPONSE_OOB:
                DDLogError(@"Result OOB");
                break;
            default:
                break;
        }
        
    }else{
        self.status = in_error_status;
        [self.delegate readerStatusChanged:self.status :@"Result CRC invalid."];
    }
}

// handle the response received
-(void)handleResponse {
    DDLogInfo(@"Handling response with status value: %d",self.status);
    // response header
    if(self.status == in_result_status){
        DDLogInfo(@"Handling response with status in result");
        //UInt8 command = [ByteUtils readOneByteFrom:self.receivedBytes atIndex:RESULT_SIZE];
        self.expectedResponseSize = [ETByteUtils readOneByteFrom:self.receivedBytes atIndex:RESULT_SIZE+1];
        self.status = in_response_status;
    }
    
    // response body
    if(self.status == in_response_status && self.receivedBytes.length >= RESULT_SIZE+self.expectedResponseSize){
        DDLogInfo(@"Handling response with status in response");
        
        //Check CRC
        UInt8 crc = [ETByteUtils readOneByteFrom:self.receivedBytes atIndex:(int)self.receivedBytes.length-1];
        UInt8 responseBytes[self.expectedResponseSize+2];
        [self.receivedBytes getBytes:&responseBytes range:NSMakeRange(RESULT_SIZE, self.expectedResponseSize+2)];
        UInt8 confirm = [ETInstructions computeCrc:[[NSData alloc] initWithBytes:responseBytes length:self.expectedResponseSize+2]];
        
        if(crc == confirm){
            
            DDLogInfo(@"Handling response , CRC confirmed");
            
            UInt8 payload[self.expectedResponseSize];
            [self.receivedBytes getBytes:&payload range:NSMakeRange(RESULT_SIZE+2, self.expectedResponseSize)];
            
            // handle the response payload
            if(self.mode == STRING_READER_MODE){
                DDLogInfo(@"Handling response , payload is string");
                [self handleStringPayload:[NSData dataWithBytes:payload length:self.expectedResponseSize]];
            }else if(self.mode == UINT_READER_MODE){
                DDLogInfo(@"Handling response , payload is number");
                [self handleUIntPayload:[NSData dataWithBytes:payload length:self.expectedResponseSize]];
            }else if(self.mode == DATA_READER_MODE) {
                DDLogInfo(@"Handling response , payload is data. Received bytes: %@", [self.receivedBytes description]);
                NSData *payloadData = [NSData dataWithBytes:payload length:self.expectedResponseSize];
                int minRange;
                if (self.expectedDataType == BartValueType_version) {
                    minRange = 0;
                } else {
                    //removing ack, datatype and timestamp from payload received
                    minRange = 5;
                }
                [self handleDataPayload:[payloadData subdataWithRange:NSMakeRange(minRange, [payloadData length]-minRange)] withExpectedType:self.expectedDataType];
            }
        }else{
            self.status = in_error_status;
            [self.delegate readerStatusChanged:self.status :[NSString stringWithFormat:@"Invalid crc: %d",confirm]];
        }
    }
}

// handle a response paylaod of type 'String'
-(void)handleStringPayload:(NSData *)payload {
    NSString *response = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
    [self.delegate readerStatusChanged:self.status :[NSString stringWithFormat:@"Response received, %@",response]];
    [self.delegate responseReceived:self.currentCommand :response];
}

// handle a response payload of type 'unsigned int'
-(void)handleUIntPayload:(NSData *)payload{
    UInt32 response =[ETByteUtils dataToUInt32:payload];
    [self.delegate readerStatusChanged:self.status :[NSString stringWithFormat:@"Response received, %d",(unsigned int)response]];
    [self.delegate responseReceived:self.currentCommand :[NSNumber numberWithInt:response]];
}

-(void)handleDataPayload:(NSData *)payload withExpectedType:(ETBartType) type{
    
    int payloadSize;
    
    switch (type) {
        case BartValueType_acceleration:
            payloadSize = BartValueSize_timestamp + BartValueSize_acceleration;
            break;
        case BartValueType_temperature:
            payloadSize = BartValueSize_timestamp + BartValueSize_temperature;
            break;
        case BartValueType_activity:
            payloadSize = BartValueSize_timestamp + BartValueSize_activity;
            break;
        case BartValueType_version:
            payloadSize = BartValueSize_version;
            break;
        case BartValueType_timestamp:
        case BartValueType_unavailabe:
        default:
            break;
    }
    
    long numberOfValues = [payload length]/payloadSize;
    NSMutableArray * values = [[NSMutableArray alloc] init];
    DDLogInfo(@"Handling data payload , payload: %@", [payload description]);
    DDLogInfo(@"Handling data payload , number of values: %ld", numberOfValues);
    
    int index = 0;
    //Slicing the payload into chunks of ETBartData
    while(numberOfValues) {
        ETBartData * data =[[ETBartData alloc] initWithData:[payload subdataWithRange:NSMakeRange(index, payloadSize)]
                                                    andType:type];
        if (data.isValid) {
            [values addObject:data];
        }
        index+= payloadSize;
        numberOfValues--;
    }
    DDLogInfo(@"Handling data paylaod , number of values: %@", [values description]);
    [self.delegate readerStatusChanged:self.status :[NSString stringWithFormat:@"Response received value count, %lu",(unsigned long)[values count]]];
    
    [self.delegate responseReceived:self.currentCommand :values];
}

-(void)handleNoDataResponse{
    [self.delegate readerStatusChanged:self.status :[NSString stringWithFormat:@"No Data response"]];
    [self.delegate responseReceived:self.currentCommand :@"No Data response"];
}


@end
