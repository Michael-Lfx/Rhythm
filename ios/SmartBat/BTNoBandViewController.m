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
    [self.globals addObserver:self forKeyPath:@"bleListCount" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    _bleList.delegate = self;
    _bleList.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//手动查找
- (IBAction)scan:(UIButton *)sender {
    [_cm scan];
}

//监控参数，更新显示
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if([keyPath isEqualToString:@"bleListCount"])
    {
        NSLog(@"ble count: %d", self.globals.bleListCount);
        
        //行数变化时，重新加载列表
        [_bleList reloadData];
    }
}

//列表行数的代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.globals.bleListCount;
}

//渲染每行数据的代理
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray* bleOne = [self.bandCM bleList:indexPath.row];
    NSLog(@"wo ca");
    if (bleOne == NULL) {
        
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OYNO"];
    }
    
    Boolean isConnected = [[bleOne objectAtIndex:IS_CONNECTED_INDEX] intValue];
    
    NSString *CellIdentifier;
    
    if (isConnected) {
        CellIdentifier = @"bleListCellConnected";
    }else{
        CellIdentifier = @"bleListCellScan";
    }
    
    NSLog(@"%@", CellIdentifier);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (isConnected) {
        //连接后显示电量
        UILabel* batteryLevel = (UILabel*)[cell.contentView viewWithTag:BATTERY_LEVEL_TAG];
        batteryLevel.text = [NSString stringWithFormat:@"%@%%", [bleOne objectAtIndex:BATTERY_LEVEL_INDEX]];
        batteryLevel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        
        //手环名称
        UITextField* bandName = (UITextField*)[cell.contentView viewWithTag:BAND_NAME_TAG];
        bandName.text = [bleOne objectAtIndex:BAND_NAME_INDEX];
    }
    
    return cell;
}

//选中某行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [self.bandCM connectSelectedPeripheral:[indexPath row]];
    [self.bandCM willSetup:[indexPath row]];
    
    _setupViewCtrl = nil;
    _setupViewCtrl = [BTSetupViewController buildView];
    _setupViewCtrl.view.tag = SETUP_VIEW_TAG;
    [self.view.superview insertSubview:_setupViewCtrl.view belowSubview:self.view];
    
    [self pickupSettings:nil];
}

@end
