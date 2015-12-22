//
//  ViewController.m
//  ETactFrameworkExample
//
//  Created by Nicolas Linard on 09/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import "ViewController.h"
#import "ETDataReaderController.h"
#import "ETBleController.h"
#import "ETBartDataHelper.h"
#import "ETBleDataHelper.m"
#import "BLEChartViewController.h"
@import CocoaLumberjack;


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *hardwareVersionNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *softwareVersionNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *bartVersionNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataAvailableCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastACKCommand;
@property (nonatomic, strong) ETDataReaderController * dataReader;
@property (nonatomic, strong) ETBleController * bleReader;
@property (weak, nonatomic) IBOutlet UITextView *bleDataText;
@property (weak, nonatomic) IBOutlet UILabel *bleStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *scanningStatusLabel;

@property (weak, nonatomic) IBOutlet UIButton *getVersionNumberButton;
@property (weak, nonatomic) IBOutlet UIButton *resetLabelsButton;
@property (weak, nonatomic) IBOutlet UIButton *sendResetButton;
@property (weak, nonatomic) IBOutlet UIButton *sendSleepModeOnButton;
@property (weak, nonatomic) IBOutlet UIButton *sendSleepModeOffButton;
@property (weak, nonatomic) IBOutlet UIButton *sendGetDataButton;
@property (weak, nonatomic) IBOutlet UIButton *sendUnloadTemperatureButton;
@property (weak, nonatomic) IBOutlet UIButton *sendUnloadAccelerationDataButton;
@property (weak, nonatomic) IBOutlet UIButton *sendUnloadActivityButton;




@property (strong, nonatomic) BLEChartViewController * bleChartViewController;

@end

@implementation ViewController

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dataReader = [[ETDataReaderController alloc] init];
    self.dataReader.delegate = self;
    self.connectionStatusLabel.text = @"DISCONNECTED";
    self.bleReader = [[ETBleController alloc] init];
    self.bleReader.delegate = self;
    
    self.getVersionNumberButton.enabled = NO;
    self.resetLabelsButton.enabled = NO;
    self.sendGetDataButton.enabled = NO;
    self.sendResetButton.enabled = NO;
    self.sendSleepModeOffButton.enabled = NO;
    self.sendSleepModeOnButton.enabled = NO;
    self.sendUnloadAccelerationDataButton.enabled = NO;
    self.sendUnloadActivityButton.enabled = NO;
    self.sendUnloadTemperatureButton.enabled = NO;
    DDLogInfo(@"Initialiazing ViewController");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate
- (void) didChangeStatus:(ETReaderStatus)status {
    
    switch (status) {
        case idle_status:
            
            break;
        case in_result_status:
            
            break;
            
        case in_response_status:
            
            break;
        case in_error_status:
            break;
        default:
            break;
    }
    
}
- (void) didUpdateHardwareVersionNumber:(NSNumber *)versionNumber {
     DDLogInfo(@"Hardware version number received from reader controller (%@)", versionNumber);
    self.hardwareVersionNumberLabel.text = [NSString stringWithFormat:@"%@",versionNumber];
}
- (void) didUpdateSoftwareVersionNumber:(NSNumber *)versionNumber {
    DDLogInfo(@"Software version number received from reader controller (%@)",versionNumber);
    self.softwareVersionNumberLabel.text = [NSString stringWithFormat:@"%@",versionNumber];
}
- (void) didUpdateBartVersionNumber:(ETBartData *)versionNumber {
    DDLogInfo(@"Bart version number received from reader controller (%@)",[versionNumber.rawData description]);
    self.bartVersionNumberLabel.text = [NSString stringWithFormat:@"%@",[ETBartDataHelper readBartVersionNumberFromData:versionNumber ]];
}
- (void) didReceiveValues:(NSArray *)values ofType:(ETBartType)type{
    DDLogInfo(@"Data received from reader controller");
    //self.dataAvailableCountLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[values count]];
    
    NSMutableString *text = [[NSMutableString alloc] initWithString:self.bleDataText.text];
    [text appendString:[NSString stringWithFormat:@"\n %lu values of %@:\n",[values count],[ETBartDataHelper bartTypeToString:type]]];
    for (int i = 0; i< [values count];i++) {
        [text appendString:[NSString stringWithFormat:@"%@\n",[[values objectAtIndex:i] description]]];
    }
    self.bleDataText.text = text;
}
- (void) didChangeConnectionStatus:(BOOL)connected{
    self.connectionStatusLabel.text = connected?@"CONNECTED":@"DISCONNECTED";
    DDLogInfo(@"Cable status: %@",connected?@"Connected":@"Disconnected");
    if (connected) {
        self.getVersionNumberButton.enabled = YES;
        self.resetLabelsButton.enabled = YES;
        self.sendGetDataButton.enabled = YES;
        self.sendResetButton.enabled = YES;
        self.sendSleepModeOffButton.enabled = YES;
        self.sendSleepModeOnButton.enabled = YES;
        self.sendUnloadAccelerationDataButton.enabled = YES;
        self.sendUnloadActivityButton.enabled = YES;
        self.sendUnloadTemperatureButton.enabled = YES;
    } else {
        self.getVersionNumberButton.enabled = NO;
        self.resetLabelsButton.enabled = NO;
        self.sendGetDataButton.enabled = NO;
        self.sendResetButton.enabled = NO;
        self.sendSleepModeOffButton.enabled = NO;
        self.sendSleepModeOnButton.enabled = NO;
        self.sendUnloadAccelerationDataButton.enabled = NO;
        self.sendUnloadActivityButton.enabled = NO;
        self.sendUnloadTemperatureButton.enabled = NO;
    }
}

- (void) didUpdateNumberOfValuesToUnload:(NSNumber *)valueCount {
    self.dataAvailableCountLabel.text = [NSString stringWithFormat:@"%@",valueCount];
}

- (void)lastCommandAcknoledged:(ETBartCommandType)cmd {
    self.lastACKCommand.text = [ETBartDataHelper bartCommandTypeToString:cmd];
}

#pragma mark - Ble Reader Delegate
- (void) didUpdateState:(CBCentralManagerState)state {
    
    switch (state) {
        case CBCentralManagerStatePoweredOff:
            self.bleStatusLabel.text = @"BT off";
            break;
            
        case CBCentralManagerStatePoweredOn:
            self.bleStatusLabel.text = @"BT on";
            break;
            
        case CBCentralManagerStateUnauthorized:
            self.bleStatusLabel.text = @"BT unauthorized";
            break;
            
        case CBCentralManagerStateUnsupported:
            self.bleStatusLabel.text = @"BT unsupported";
            break;
            
        case CBCentralManagerStateUnknown:
            self.bleStatusLabel.text = @"BT unknown";
            break;
            
        case CBCentralManagerStateResetting:
            self.bleStatusLabel.text = @"BT ressetting";
            break;
            
        default:
            self.bleStatusLabel.text = @"Unavailable";
        break;
    }
}

- (void) didReceiveValue:(ETBleData *)value {
    NSDictionary * dict = [ETBleDataHelper dataToBleDataValues:value];
    NSMutableString * text = [[NSMutableString alloc] init];
    [text appendString:[NSString stringWithFormat:@"company Id: %@\n",[dict objectForKey:@"companyID"]]];
    [text appendString:[NSString stringWithFormat:@"softwareVersion: %@\n",[dict objectForKey:@"softVersion"]]];
    [text appendString:[NSString stringWithFormat:@"batteryLevel: %@\n",[dict objectForKey:@"batteryLevel"]]];
    [text appendString:[NSString stringWithFormat:@"temperature: %@\n",[dict objectForKey:@"temperature"]]];
    [text appendString:[NSString stringWithFormat:@"activity: %@\n",[dict objectForKey:@"activity"]]];
    NSDictionary * acceleration = [dict objectForKey:@"acceleration"];
    [text appendString:[NSString stringWithFormat:@"acceleration x: %@\n",[acceleration objectForKey:@"xAxis"]]];
    [text appendString:[NSString stringWithFormat:@"acceleration y: %@\n",[acceleration objectForKey:@"yAxis"]]];
    [text appendString:[NSString stringWithFormat:@"acceleration z: %@\n",[acceleration objectForKey:@"zAxis"]]];
    [text appendString:[NSString stringWithFormat:@"acceleration pitch: %@\n",[acceleration objectForKey:@"pitch"]]];
    [text appendString:[NSString stringWithFormat:@"acceleration roll: %@\n",[acceleration objectForKey:@"roll"]]];
    
    self.bleDataText.text = text;
}

#pragma mark - Actions

- (IBAction)resetLabels:(id)sender {
    self.hardwareVersionNumberLabel.text = @"...";
    self.softwareVersionNumberLabel.text = @"...";
    self.bartVersionNumberLabel.text = @"...";
    self.dataAvailableCountLabel.text = @"...";
    self.bleDataText.text = @"";
}
- (IBAction)getDeviceVersionNumbers:(id)sender {
    [self.dataReader askDeviceForVersionNumbers];
}

- (IBAction)getNumberOfValues:(id)sender {
    [self.dataReader askDeviceForValuesStoredAvailable];
}

- (IBAction)resetDevice:(id)sender {
    [self.dataReader askDeviceToReset];
}

- (IBAction)setDeviceToSleepMode:(id)sender {
    [self.dataReader askDeviceToSetSleepMode:YES];
}

- (IBAction)wakeUpDevice:(id)sender {
    [self.dataReader askDeviceToSetSleepMode:NO];
}

- (IBAction)unloadAcceleration:(id)sender {
    [self.dataReader askDeviceForAccelerationData];
}

- (IBAction)unloadTemperature:(id)sender {
    [self.dataReader askDeviceForTemperaturData];
}

- (IBAction)unloadActivity:(id)sender {
    [self.dataReader askDeviceForActivityData];
}

- (IBAction) startBleScan:(id)sender {
    [self.bleReader startScanning];
    self.scanningStatusLabel.text = self.bleReader.isScanning?@"YES":@"NO";
}

- (IBAction) stopBleScan:(id)sender {
    [self.bleReader stopScanning];
    self.scanningStatusLabel.text = self.bleReader.isScanning?@"YES":@"NO";
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"realTimeGraph"]) {
        self.bleChartViewController = segue.destinationViewController;
        self.bleChartViewController.maxValues = 400;
        
    }
}

@end
