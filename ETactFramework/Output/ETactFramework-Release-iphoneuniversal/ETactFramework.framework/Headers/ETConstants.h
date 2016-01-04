//
//  ETConstants.h
//  ETactFramework
//
//  Created by Nicolas Linard on 08/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#ifndef ETConstants_h
#define ETConstants_h

#define RESPONSE_ACK 165
#define RESPONSE_NACK 166
#define RESPONSE_CUNK 167
#define RESPONSE_DUNK 168
#define RESPONSE_OOB 169

typedef enum {
    idle_status,
    in_result_status,
    in_response_status,
    in_error_status
    
} ETReaderStatus;

typedef enum : UInt8 {
    BartValueType_acceleration = 0x8F,
    BartValueType_activity = 0x82,
    BartValueType_temperature = 0x8D,
    BartValueType_timestamp = 0x80,
    BartValueType_version = 0xFF,
    BartValueType_unavailabe = 0x00
} ETBartType;

typedef enum : UInt8 {
    BartValueSize_acceleration = 3,
    BartValueSize_temperature = 2,
    BartValueSize_activity = 1,
    BartValueSize_timestamp = 4,
    BartValueSize_version = 4
} ETBartValueSize;

typedef enum : UInt8 {
    CompNAME = 0x00,
    ProdNAME = 0x01,
    HardDESC = 0x02,
    SoftDESC = 0x03,
    HardVER = 0x04,
    SoftVER = 0x05,
    BartVER = 0x06,
    LocalID = 0x30,
    StockDATA = 0x41,
    SetStockDATA = 0x42,
    NbLINKData = 0x60,
    Reset = 0xE1,
    Timestamp = 0x11,
    UnloadDATA = 0x63
    
} ETBartCommandType;

typedef enum : UInt8 {
    StockDATA_BATTERY = 0x04,
    StockDATA_MODE_SLEEP = 0xA1,
    StockDATA_CAL_TEMP = 0xC4,
    StockDATA_ACC_THRESH_ACT = 0xB1,
    StockDATA_BARO_RPDS_P = 0xDA,
    StockDATA_MAC_ADDRESS = 0xE0
} ETBartStockDATAType;

typedef enum : UInt8 {
    SetStockDATA_MODE_SLEEP = 0xA1,
    SetStockDATA_CAL_TEMP = 0xC4,
    SetStockDATA_ACC_THRESH_ACT = 0xB1,
    SetStockDATA_BARO_RPDS_P = 0xDA
} ETBartSetStockDATAType;



#endif /* ETConstants_h */
