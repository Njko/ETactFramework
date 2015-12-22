//
//  ViewController.m
//  e-TactCheck
//
//  Created by Yann Lapeyre on 09/10/2015.
//  Copyright © 2015 Medes-IMPS. All rights reserved.
//

#import "ETDataReaderController.h"
#import "RscMgr.h"
#import "ETReadHandler.h"
#import "ETInstructions.h"
#import "ETCommand.h"
#import "ETBartDataHelper.h"
@import CocoaLumberjack;

#define IDLE_STATUS 0
#define CHECK_STATUS 1
#define OK_STATUS 2
#define ERROR_STATUS 3

#define ACCELERATION_MAX_DATA 34
#define TEMPERATURE_MAX_DATA 40
#define ACTIVITY_MAX_DATA 48

@interface ETDataReaderController ()

@property (nonatomic) BOOL connected;
@property (nonatomic, strong) NSTimer *cmdTimer;
@property (nonatomic, strong) RscMgr *rscMgr;
@property (nonatomic, strong) ETReadHandler *reader;
@property (nonatomic, strong) NSMutableArray *commands;
@property (nonatomic, strong) NSThread *commThread;
@property (nonatomic, strong) ETCommand * lastCommand;

@end

@implementation ETDataReaderController


static const DDLogLevel ddLogLevel = DDLogLevelVerbose;



-(instancetype)init {
    if (self = [super init]) {
        
        self.commands = [[NSMutableArray alloc] init];
        self.connected = FALSE;
        
        [self configureRscMgr];
        
        DDLogInfo(@"Initialized Data Reader Controller");
        
    }
    return self;
}

- (void) resetReader {
    self.reader = [[ETReadHandler alloc] init];
    self.reader.delegate = self;
}


-(void)configureRscMgr {
    if (self.commThread == nil)
    {
        self.commThread = [[NSThread alloc] initWithTarget:self
                                                  selector:@selector(startCommThread:)
                                                    object:nil];
        [self.commThread start];
    }
}

- (void) startCommThread:(id)object
{
    // initialize RscMgr on this thread
    self.rscMgr = [[RscMgr alloc] init];
    self.rscMgr.delegate = self;
    // run the run loop
    [[NSRunLoop currentRunLoop] run];
}


#pragma mark - UI update


#pragma mark - RscMgrDelegate protocol + port configuration

-(void)cableConnected:(NSString *)protocol {
    [self configureSerialPort];
    self.connected = YES;
    self.reader = nil;
    [self resetReader];
    DDLogInfo(@"Cable connected");
    [self performSelectorOnMainThread:@selector(updateCableStatus) withObject:nil waitUntilDone:NO];
}

-(void)cableDisconnected {
    self.connected = NO;
    self.reader = nil;
    DDLogInfo(@"Cable disconnected");
    [self performSelectorOnMainThread:@selector(updateCableStatus) withObject:nil waitUntilDone:NO];
}

-(void) updateCableStatus{
    DDLogInfo(@"Sending cable status to delegate");
    [self.delegate didChangeConnectionStatus:self.connected];
}

-(void)readBytesAvailable:(UInt32)length{
    
    NSData *data = [self.rscMgr getDataFromBytesAvailable];
    if(self.reader){
        [self.reader newBytesRead:data];
    }
}


-(void)configureSerialPort {
    
    [self.rscMgr getDataFromBytesAvailable]; // clear the rx stream
    
    // configure the port
    [self.rscMgr setBaud:19200];
    
    serialPortConfig portCfg;
    [self.rscMgr getPortConfig:&portCfg];
    portCfg.parity = SERIAL_PARITY_NONE;
    portCfg.stopBits = STOPBITS_1;
    portCfg.rxFlowControl = RXFLOW_NONE;
    portCfg.txFlowControl = TXFLOW_NONE;
    portCfg.dataLen = SERIAL_DATABITS_8;
    
    [self.rscMgr setPortConfig:&portCfg requestStatus: NO];
}


-(void)portStatusChanged{
    NSLog(@"Port status changed");
}


#pragma mark - Reader Handler Delegate

-(void)readerStatusChanged:(ETReaderStatus)status :(NSString *)optionalText {
    DDLogInfo(@"%@",optionalText);
    if(status == in_error_status){
        [self performSelectorOnMainThread:@selector(responseError) withObject:nil waitUntilDone:NO];
    }
}

-(void)responseReceived:(ETBartCommandType)cmd :(NSObject *)result {
    [self.cmdTimer invalidate];
    DDLogInfo(@"Response received ...");
    BOOL canProcessNextCommand = YES;
    switch (cmd) {
        case HardVER:
            [self performSelectorOnMainThread:@selector(updateHardwareVersion:) withObject:result waitUntilDone:NO];
            break;
        case SoftVER:
            [self performSelectorOnMainThread:@selector(updateSoftwareVersion:) withObject:result waitUntilDone:NO];
            break;
        case BartVER:
            [self performSelectorOnMainThread:@selector(updateBartVersion:) withObject:result waitUntilDone:NO];
            break;
        case Reset:
            [self performSelectorOnMainThread:@selector(resetConfirmed:) withObject:result waitUntilDone:NO];
            break;
            
        case NbLINKData:
            [self performSelectorOnMainThread:@selector(processNumberOfValuesToUnload:) withObject:result waitUntilDone:NO];
            //This method will produce a linked list of command to execute and fire its execution.
            //No need to verify if there are new commands to execute for this one
            canProcessNextCommand = NO;
            break;
        case UnloadDATA:
            //unloaddata
            DDLogInfo(@"Response received for Unloaded Data: %@", [result description]);
            [self performSelectorOnMainThread:@selector(processUnloadedData:) withObject:result waitUntilDone:NO];
            break;
        default:
            break;
    }
    if (canProcessNextCommand) {
        [self performSelectorOnMainThread:@selector(processNextCommands) withObject:nil waitUntilDone:NO];
    }
}

-(void) processNextCommands {
    // send next command
    DDLogInfo(@"Last command sent: %@ - Next command is: %@", [self.lastCommand description], [self.lastCommand.nextCommand description]);
    if (self.lastCommand) {
        if (self.lastCommand.nextCommand) {
            DDLogInfo(@"Next command is: %@", [self.lastCommand.nextCommand description]);
            
            self.lastCommand = self.lastCommand.nextCommand;
            [self sendCommand:self.lastCommand];
        } else {
            self.lastCommand = nil;
        }
    }
}

-(void)ackReceivedForCommand:(ETBartCommandType)cmd {
    DDLogInfo(@"ACK received for command %@",[ETBartDataHelper bartCommandTypeToString:cmd]);
    [self.delegate lastCommandAcknoledged:cmd];
}

#pragma mark - Orchestration
-(void)responseError {
    [self.cmdTimer invalidate];
    DDLogInfo(@"Response is in error");
    [self statusChanged:ERROR_STATUS];
}

-(void)responseTimeOut {
    DDLogInfo(@"Response timed out");
    [self statusChanged:ERROR_STATUS];
}

-(void)updateHardwareVersion:(NSNumber *)versionNumber {
    [self.delegate didUpdateHardwareVersionNumber:versionNumber];
}

-(void)updateSoftwareVersion:(NSNumber *)versionNumber {
    [self.delegate didUpdateSoftwareVersionNumber:versionNumber];
}

-(void)updateBartVersion:(NSArray *)values {
    if ([values count] >0) {
        ETBartData * data = [values objectAtIndex:0];
        [self.delegate didUpdateBartVersionNumber:data];
    }
}

-(void) processNumberOfValuesToUnload:(NSNumber *)valueCount {
    [self.delegate didUpdateNumberOfValuesToUnload:valueCount];
    
    if ([valueCount intValue] > 0) {
        int valuesToUnload = [valueCount intValue];
        int startIndexForAcceleration = 1;
        int startIndexForTemperature = 1;
        int startIndexForActivity = 1;
        //unload full data
        ETCommand * currentCommand;
        self.commands = [[NSMutableArray alloc] init];
        while (startIndexForAcceleration < valuesToUnload) {
            if (valuesToUnload > (startIndexForAcceleration + ACCELERATION_MAX_DATA)) {
                currentCommand = [self dataResultCommand:[ETInstructions unloadData:BartValueType_acceleration fromIndex:startIndexForAcceleration toIndex:(ACCELERATION_MAX_DATA+startIndexForAcceleration-1)]
                                     AndExpectedDataType:BartValueType_acceleration];
            } else {
                currentCommand = [self dataResultCommand:[ETInstructions unloadData:BartValueType_acceleration fromIndex:startIndexForAcceleration toIndex:valuesToUnload]
                                     AndExpectedDataType:BartValueType_acceleration];
            }
            
            if ([self.commands count] > 0) {
                ((ETCommand *)[self.commands lastObject]).nextCommand = currentCommand;
            }
            [self.commands addObject:currentCommand];
            
            startIndexForAcceleration += ACCELERATION_MAX_DATA;
        }
        
        while (startIndexForTemperature < valuesToUnload) {
            if (valuesToUnload > (startIndexForTemperature + TEMPERATURE_MAX_DATA)) {
                currentCommand = [self dataResultCommand:[ETInstructions unloadData:BartValueType_temperature fromIndex:startIndexForTemperature toIndex:(TEMPERATURE_MAX_DATA+startIndexForTemperature-1)]
                                     AndExpectedDataType:BartValueType_temperature];
            } else {
                currentCommand = [self dataResultCommand:[ETInstructions unloadData:BartValueType_temperature fromIndex:startIndexForTemperature toIndex:valuesToUnload]
                                     AndExpectedDataType:BartValueType_temperature];
            }
            
            ((ETCommand *)[self.commands lastObject]).nextCommand = currentCommand;
            [self.commands addObject:currentCommand];
            
            startIndexForTemperature += TEMPERATURE_MAX_DATA;
        }
        
        while (startIndexForActivity < valuesToUnload) {
            if (valuesToUnload > (startIndexForActivity + ACTIVITY_MAX_DATA)) {
                currentCommand = [self dataResultCommand:[ETInstructions unloadData:BartValueType_activity fromIndex:startIndexForActivity toIndex:(ACTIVITY_MAX_DATA+startIndexForActivity-1)]
                                     AndExpectedDataType:BartValueType_activity];
            } else {
                currentCommand = [self dataResultCommand:[ETInstructions unloadData:BartValueType_activity fromIndex:startIndexForActivity toIndex:valuesToUnload]
                                     AndExpectedDataType:BartValueType_activity];
            }
            
            ((ETCommand *)[self.commands lastObject]).nextCommand = currentCommand;
            [self.commands addObject:currentCommand];
            
            startIndexForActivity += ACTIVITY_MAX_DATA;
        }
        DDLogInfo(@"Commands created: %@", [self.commands description]);
        [self sendCommand:[self.commands objectAtIndex:0]];
        [self statusChanged:CHECK_STATUS];
    }
    
}

-(void) resetConfirmed:(NSString *)message {
    DDLogInfo(@"reset confirmed");
}

-(void) processUnloadedData:(NSArray *)values {
    DDLogInfo(@"Sending data to delegate");
    if ([values count] > 0) {
        ETBartType dataType = ((ETBartData*) values[0]).dataType;
        [self.delegate didReceiveValues:values ofType:dataType];
    }
}


-(void)statusChanged:(NSInteger)status {
    switch (status) {
            // Do nothing
        case IDLE_STATUS:
            [self inIdleStatus];
            break;
            
            // Application is sending commands to the devices
        case CHECK_STATUS:
            [self inCheckStatus];
            break;
            
            // Data successfully read from the device
        case OK_STATUS:
            [self inOKStatus];
            break;
            
            // Unable to read data from the device
        case ERROR_STATUS:
            [self inErrorStatus];
            break;
            
        default:
            break;
    }
}


-(void)inErrorStatus
{
    [self.delegate didChangeStatus:in_error_status];
}

-(void)inOKStatus
{
    [self.delegate didChangeStatus:in_response_status];
}

-(void)inCheckStatus
{
    [self.delegate didChangeStatus:in_result_status];
}

-(void)inIdleStatus
{
    [self.delegate didChangeStatus:idle_status];
}


#pragma mark - Public methods

- (void)resetDeviceStatus {
    [self statusChanged:IDLE_STATUS];
}

#pragma mark - Device commands

- (void)askDeviceForVersionNumbers{
    if(self.connected){
        ETCommand * bartVersion = [self dataResultCommand:[ETInstructions bartVersion] AndExpectedDataType:BartValueType_version];
        ETCommand * softVersion =[self integerResultCommand:[ETInstructions softwareVersion]];
        ETCommand * hardVersion = [self integerResultCommand:[ETInstructions hardwareVersion]];
        //chaining commands
        hardVersion.nextCommand = softVersion;
        softVersion.nextCommand = bartVersion;
        //execute first command
        [self sendCommand:hardVersion];
        [self statusChanged:CHECK_STATUS];
    }
}

- (void)askDeviceForValuesStoredAvailable {
    if(self.connected){
        DDLogInfo(@"Getting number of values...");
        [self sendCommand:[self integerResultCommand:[ETInstructions dataCount]]];
        [self statusChanged:CHECK_STATUS];
        DDLogInfo(@"Done asking for number of values...");
    }
}

- (void)askDeviceToReset {
    if(self.connected){
        DDLogInfo(@"Asking to reset device...");
        //[self.commands addObject:instruction];
        ETCommand * resetMemory = [self noResultCommand:[ETInstructions resetDevice]];
        ETCommand * resetTimestamp = [self noResultCommand:[ETInstructions resetTimestamp]];
        
        resetMemory.nextCommand = resetTimestamp;
        
        [self sendCommand:resetMemory];
        [self statusChanged:CHECK_STATUS];
        DDLogInfo(@"Done asking to reset device...");
    }
}

- (void) askDeviceToSetSleepMode:(BOOL)isOn {
    if(self.connected){
        DDLogInfo(@"Asking device to %@ ...",isOn?@"Sleep":@"Wake up");
        NSData * data = isOn?[ETInstructions activateSleepMode]: [ETInstructions deactivateSleepMode];
        DDLogInfo(@"Data to send to set sleep mode is:%@ ",[data description]);
        [self sendCommand:[self noResultCommand:data]];
        [self statusChanged:CHECK_STATUS];
        DDLogInfo(@"Done device to %@...",isOn?@"Sleep":@"Wake up");
    }
}
- (void) askDeviceForAccelerationData {
    
    if(self.connected){
        DDLogInfo(@"Asking device for acceleration data");
        [self.commands removeAllObjects];
        NSData * data = [ETInstructions unloadData:BartValueType_acceleration fromIndex:1 toIndex:30];
        DDLogInfo(@"Data to send for acceleration data:%@ ",[data description]);
        [self sendCommand:[self dataResultCommand:data AndExpectedDataType:BartValueType_acceleration]];
        [self statusChanged:CHECK_STATUS];
        DDLogInfo(@"Done asking device for acceleration data");
    }
}
- (void) askDeviceForTemperaturData {
    if(self.connected){
        DDLogInfo(@"Asking device for temperature data");
        [self.commands removeAllObjects];
        NSData * data = [ETInstructions unloadData:BartValueType_temperature fromIndex:1 toIndex:30];
        DDLogInfo(@"Data for temperature data:%@ ",[data description]);
        [self sendCommand:[self dataResultCommand:data AndExpectedDataType:BartValueType_temperature]];
        [self statusChanged:CHECK_STATUS];
        DDLogInfo(@"Done asking device for temperature data");
    }
}
- (void) askDeviceForActivityData {
    if(self.connected){
        DDLogInfo(@"Asking device for activity data");
        [self.commands removeAllObjects];
        NSData * data = [ETInstructions unloadData:BartValueType_activity fromIndex:1 toIndex:30];
        DDLogInfo(@"Data to send for activity data:%@ ",[data description]);
        [self sendCommand:[self dataResultCommand:data AndExpectedDataType:BartValueType_activity]];
        [self statusChanged:CHECK_STATUS];
        DDLogInfo(@"Done asking device for activity data");
    }
}

#pragma mark - Private methods
-(void)sendCommand:(ETCommand *)cmd {
    DDLogInfo(@"Sending command : %@",[cmd description]);
    self.lastCommand = cmd;
    [self.reader reset];
    self.reader.mode = cmd.mode;
    self.reader.expectedDataType = cmd.expectedDataType;
    [self.rscMgr writeData: cmd.rawData];
    self.cmdTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self
                                                   selector:@selector(responseTimeOut)
                                                   userInfo:nil
                                                    repeats:NO];
}

#pragma mark - Utils
-(ETCommand *)stringResultCommand:(NSData *)cmdData {
    ETCommand *cmd = [[ETCommand alloc]initWithData:cmdData
                                            andMode:1];
    return cmd;
}

-(ETCommand *)integerResultCommand:(NSData *)data {
    ETCommand *cmd = [[ETCommand alloc] initWithData:data
                                             andMode:2];
    return cmd;
}

-(ETCommand *)dataResultCommand:(NSData *)data AndExpectedDataType:(ETBartType)type{
    ETCommand *cmd = [[ETCommand alloc] initWithData:data
                                                mode:3
                                 andExpectedDataType:type];
    return cmd;
}

-(ETCommand *)noResultCommand:(NSData *)data {
    ETCommand *cmd = [[ETCommand alloc] initWithData:data
                                             andMode:4];
    return cmd;
}

@end
