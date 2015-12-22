//
//  BLEChartViewController.h
//  ETactFrameworkExample
//
//  Created by Nicolas Linard on 14/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Charts;

@interface BLEChartViewController : UIViewController

@property (weak, nonatomic) IBOutlet LineChartView *lineChartView;
@property (strong, nonatomic) LineChartData *rawData;
@property (strong, nonatomic) LineChartDataSet *temperatureDataSet;
@property (strong, nonatomic) LineChartDataSet *activityDataSet;
@property (strong, nonatomic) LineChartDataSet *accelerationXAxisDataSet;
@property (strong, nonatomic) LineChartDataSet *accelerationYAxisDataSet;
@property (strong, nonatomic) LineChartDataSet *accelerationZAxisDataSet;
@property (strong, nonatomic) LineChartDataSet *accelerationPitchDataSet;
@property (strong, nonatomic) LineChartDataSet *accelerationRollDataSet;
@property (nonatomic) NSUInteger maxValues;

@end
