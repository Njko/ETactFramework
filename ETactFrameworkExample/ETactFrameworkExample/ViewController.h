//
//  ViewController.h
//  ETactFrameworkExample
//
//  Created by Nicolas Linard on 09/12/2015.
//  Copyright © 2015 MEDES. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETDataReaderDelegate.h"
#import "ETConstants.h"
#import "ETBleReaderDelegate.h"

@interface ViewController : UIViewController <ETDataReaderDelegate, ETBleReaderDelegate>


@end

