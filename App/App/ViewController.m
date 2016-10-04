//
//  ViewController.m
//  App
//
//  Created by Dan Kalinin on 21/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "ViewController.h"
#import <Helpers/Helpers.h>



@interface ViewController ()

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"ff0000"];
    
    NSDate *date = [NSDate date];
    
    NSDateFormatter *df = [NSDateFormatter fixedDateFormatterWithDateFormat:DateFormatRFC1123];
    NSString *dateString = [df stringFromDate:date];
    NSLog(@"RFC 1123 - %@", dateString);
    
    df = [NSDateFormatter fixedDateFormatterWithDateFormat:DateFormatRFC850];
    dateString = [df stringFromDate:date];
    NSLog(@"RFC 850 - %@", dateString);
    
    df = [NSDateFormatter fixedDateFormatterWithDateFormat:DateFormatAsctime];
    dateString = [df stringFromDate:date];
    NSLog(@"asctime() - %@", dateString);
}


@end
