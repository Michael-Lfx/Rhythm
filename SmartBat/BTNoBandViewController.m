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
    
    //启动蓝牙并扫描连接
    _cm = [[BTBandCentral alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scan:(UIButton *)sender {
    [_cm scan];
}

- (IBAction)setShock:(UISwitch *)sender {
    UInt16 i = (sender.on)?1:0;
    
    [_cm writeAll:[NSData dataWithBytes:&i length:sizeof(i)] withUUID:[CBUUID UUIDWithString:kMetronomeShockUUID]];
    NSLog(@"%lu", sizeof(i));
}
- (IBAction)setSpark:(UISwitch *)sender {
}

- (IBAction)read:(UIButton *)sender {
    [_cm readAll:[CBUUID UUIDWithString:kMetronomeDurationUUID] withBlock:^(NSData *value, CBCharacteristic *characteristic, CBPeripheral *peripheral) {
        NSLog(@"%@", value);
    }];
    
}

- (IBAction)write:(UIButton *)sender {
    UInt16 i = 500;
    
    [_cm writeAll:[NSData dataWithBytes:&i length:sizeof(i)] withUUID:[CBUUID UUIDWithString:kMetronomeDurationUUID]];
    
    NSLog(@"%lu", sizeof(i));
}
@end
