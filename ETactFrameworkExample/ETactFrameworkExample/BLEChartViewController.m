//
//  BLEChartViewController.m
//  ETactFrameworkExample
//
//  Created by Nicolas Linard on 14/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import "BLEChartViewController.h"
#import "ETBleData.h"

@interface BLEChartViewController()

@property (nonatomic) NSUInteger lastXIndexCreated;
@property (nonatomic) NSUInteger lastXIndexDestroyed;
@property (nonatomic) NSUInteger lastIndex;

@property (nonatomic, strong) NSArray * dataSets;

@end

@implementation BLEChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [self initializeData];
}

- (void) initializeData {
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    /*
    for (int i = 0; i < self.maxValues; i++)
    {
        [xVals addObject:[@(i) stringValue]];
    }*/
    
    [xVals addObject:@"0"];
    
    [self prepareDataSets];
    
    self.rawData = [[LineChartData alloc] initWithXVals:xVals dataSets:self.dataSets];
    [self.rawData setValueTextColor:UIColor.blackColor];
    [self.rawData setValueFont:[UIFont systemFontOfSize:9.f]];
    self.lastXIndexCreated = self.rawData.xValCount;
    self.lastIndex = self.lastXIndexCreated;
    self.lastXIndexDestroyed = 0;
    self.lineChartView.data = self.rawData;
    [self.lineChartView setVisibleXRangeWithMinXRange:0 maxXRange:300];
    //[self.lineChartView setVisibleYRangeMaximum:100  axis:AxisDependencyRight];
    self.lineChartView.rightAxis.enabled = NO;
    self.lineChartView.leftAxis.enabled = YES;
    self.lineChartView.descriptionText = @"";
    self.lineChartView.legend.enabled = YES;
}

-(void) prepareDataSets {
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    /*for (int i = 0; i < self.maxValues-1; i++)
    {
        [yVals addObject:[[ChartDataEntry alloc] initWithValue:0.0f xIndex:i]];
    }*/
    [yVals addObject:[[ChartDataEntry alloc] initWithValue:0.0f xIndex:0]];
    //[yVals addObject:[[ChartDataEntry alloc] initWithValue:5.0f xIndex:self.maxValues]];
    
    
    self.temperatureDataSet = [[LineChartDataSet alloc] initWithYVals:yVals label:@"Temperature"];
    self.activityDataSet = [[LineChartDataSet alloc] initWithYVals:yVals label:@"Activity"];
    self.accelerationXAxisDataSet = [[LineChartDataSet alloc] initWithYVals:yVals label:@"Acceleration X Axis"];
    self.accelerationYAxisDataSet = [[LineChartDataSet alloc] initWithYVals:yVals label:@"Acceleration Y Axis"];
    self.accelerationZAxisDataSet = [[LineChartDataSet alloc] initWithYVals:yVals label:@"Acceleration Z Axis"];
    self.accelerationPitchDataSet = [[LineChartDataSet alloc] initWithYVals:yVals label:@"Acceleration Pitch"];
    self.accelerationRollDataSet = [[LineChartDataSet alloc] initWithYVals:yVals label:@"Acceleration Roll"];
    
    self.dataSets = @[self.temperatureDataSet,
                      self.activityDataSet,
                      self.accelerationXAxisDataSet,
                      self.accelerationYAxisDataSet,
                      self.accelerationZAxisDataSet,
                      self.accelerationPitchDataSet,
                      self.accelerationRollDataSet];
    
    
    
    for (int i=0; i<[self.dataSets count]; i++) {
        LineChartDataSet *currentDataSet = [self.dataSets objectAtIndex:i];
        
        currentDataSet.axisDependency = AxisDependencyRight;
        [currentDataSet setColor:[UIColor colorWithRed:(i*10+5)/255.f green:181/255.f blue:229/255.f alpha:1.f]];
        [currentDataSet setCircleColor:[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:0.f]];
        currentDataSet.lineWidth = 4.0;
        currentDataSet.circleRadius = 0.0;
        currentDataSet.fillAlpha = 65/255.0;
        currentDataSet.fillColor = [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.0f];
        currentDataSet.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
        currentDataSet.drawCircleHoleEnabled = NO;
    }
    
    NSLog(@"dataSets ready");
}

- (void) addNewData:(ETBleData *) data {
    
}
/*
- (void) produceNewData:(CGFloat) value{
    
    [self shiftValues];
    
    self.lastXIndexCreated++;
    [self.realTimeLineChartViewController.rawData addXValue:[NSString stringWithFormat:@"%ld",(long)self.lastXIndexCreated]];
    
    [[self.realTimeLineChartViewController.rawData getDataSetByIndex:0] entryForXIndex:maxValues].value = value;
    
    [self.realTimeLineChartViewController.rawData removeEntryByXIndex:0 dataSetIndex:0];
    [self.realTimeLineChartViewController.rawData removeXValue:0];
    
    //Write value to the file buffer
    int intValue = roundf(value*100);
    BOOL didWriteBuffer = [[FileBufferManager sharedInstance] pushValueToBuffer:intValue];
    if (!didWriteBuffer) {
        DDLogError(@"Did not write buffer");
    }
    
    [self.realTimeLineChartViewController.lineChartView notifyDataSetChanged];
}


-(void) shiftValues {
    for (int i=0; i < self.realTimeLineChartViewController.rawData.xValCount; i++) {
        double value = [[[self.realTimeLineChartViewController.rawData getDataSetByIndex:0] entryForXIndex:i+1] value];
        [[self.realTimeLineChartViewController.rawData getDataSetByIndex:0] entryForXIndex:i].value = value;
    }
}
*/

@end
