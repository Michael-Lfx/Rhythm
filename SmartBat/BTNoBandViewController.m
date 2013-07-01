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
    _cm = [BTBandCentral sharedBandCentral];
    
    //监控全局变量beatPerMinute的变化
    [self.globals addObserver:self forKeyPath:@"bleConnected" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.globals addObserver:self forKeyPath:@"bleListCount" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    _bleList.delegate = self;
    _bleList.dataSource = self;
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
    [_cm readAll:[CBUUID UUIDWithString:kMetronomeNameUUID] withBlock:^(NSData *value, CBCharacteristic *characteristic, CBPeripheral *peripheral) {
        NSLog(@"cb: %@", [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding]);
    }];
    
}

- (IBAction)write:(UIButton *)sender {
    NSString* name = @"卡卡音乐手环";
    
    [_cm writeAll:[name dataUsingEncoding:NSUTF8StringEncoding] withUUID:[CBUUID UUIDWithString:kMetronomeNameUUID]];
    
    NSLog(@"%lu", (unsigned long)name.length);
}

//监控参数，更新显示
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"bleConnected"])
    {
        if (self.globals.bleConnected) {
            [_cm readAll:[CBUUID UUIDWithString:kMetronomeNameUUID] withBlock:^(NSData *value, CBCharacteristic *characteristic, CBPeripheral *peripheral) {
                NSString* name = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                NSLog(@"cb: %@", name);
            }];
            
            [_cm readAll:[CBUUID UUIDWithString:kBatteryLevelUUID] withBlock:^(NSData *value, CBCharacteristic *characteristic, CBPeripheral *peripheral) {
                
                uint8_t bl;
                [value getBytes:&bl];
                
                NSLog(@"cb: %d", bl);
                
            }];
        }
    }
    
    if([keyPath isEqualToString:@"bleListCount"])
    {
        [_bleList reloadData];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.globals.bleListCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"oj yeah %@", indexPath);
    static NSString *CellIdentifier = @"bleListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel* batteryLevel = (UILabel*)[cell.contentView viewWithTag:1];
    batteryLevel.text = @"wo ca lei";
    
    return cell;
}
@end
