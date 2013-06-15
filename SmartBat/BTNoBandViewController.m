//
//  BTNoBandViewController.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTNoBandViewController.h"

@interface BTNoBandViewController ()

@end

@implementation BTNoBandViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //设置手环设置页在屏幕左侧隐藏
    _originX = [[UIScreen mainScreen] applicationFrame].size.width;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startCentral:(UIButton *)sender {
    _cm = [[BTBandCentral alloc] init];
}

- (IBAction)centralWrite:(UIButton *)sender {
    [_cm write];
}

- (IBAction)centralRead:(UIButton *)sender {
    [_cm read];
}

- (IBAction)startPeripheral:(UIButton *)sender {
    _pm = [[BTBandPeripheral alloc] init];
}

- (IBAction)peripheralUpdate:(UIButton *)sender {
    [_pm update];
}
@end
