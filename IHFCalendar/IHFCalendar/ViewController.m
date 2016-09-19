//
//  ViewController.m
//  IHFCalendar
//
//  Created by chenjiasong on 16/9/9.
//  Copyright © 2016年 Cjson. All rights reserved.
//

#import "ViewController.h"
#import "IHFCalendar.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(didClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didClick:(UIButton *)sender{
    [self showWithInstanceMethod];
}

- (void)showWithClassMethod {
    [IHFCalendar showCalendarWithCurrentDate:[NSDate date]];
}

- (void)showWithInstanceMethod {
    IHFCalendar *calendar = [IHFCalendar calendar];
    calendar.appearence.headerTitleColor = [UIColor redColor];
    [calendar show];
}

@end
