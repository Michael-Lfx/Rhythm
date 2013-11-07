//
//  BTNoBandViewController.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTBandViewController.h"

@interface BTBandViewController ()

@end

@implementation BTBandViewController

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

//监控参数，更新显示
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if([keyPath isEqualToString:@"bleListCount"])
    {
        NSLog(@"ble count: %d", self.globals.bleListCount);
        
        //行数变化时，重新加载列表
        [_bleList reloadData];
        

        if ([self.bandCM isConnectedByModel:MAM_BAND_MODEL]){
            NSLog(@"oh oh fuck");
            
            [[self.bandCM getBpByModel:MAM_BAND_MODEL] addObserver:self forKeyPath:@"dlPercent" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        }
    }
    
    if([keyPath isEqualToString:@"dlPercent"])
    {
        BTBandPeripheral* bp = [self.bandCM getBpByModel:MAM_BAND_MODEL];
        
        NSLog(@"dl: %f", bp.dlPercent);
        
        [UIView animateWithDuration:THRESHOLD_2_COMPLETE_DURETION animations:^(void) {
            [_dlProgress setProgress:bp.dlPercent];
        } completion:^(BOOL finished) {
            
        }];
        
        [_dlProgress setProgress:bp.dlPercent];
        
        if (bp.dlPercent == 1.0) {
            [_dlProgress setHidden:YES];
        }

    }
}

//列表行数的代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.globals.bleListCount;
}

//渲染每行数据的代理
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //根据index找到对应的peripheral
    BTBandPeripheral*bp  = [self.bandCM getBpByIndex:indexPath.row];
    
    //0 是否连接
    Boolean isFinded = bp.isFinded;
    //0 是否连接
    Boolean isConnected = bp.isConnected;
    //1 设备名称
    NSString* name = bp.name;
    //2 电池电量
    uint8_t d = 0;
    
    NSData *battRaw = [bp.allValues objectForKey:[CBUUID UUIDWithString:UUID_BATTERY_LEVEL]];
    
    if (battRaw) {
        [battRaw getBytes:&d];
    }
    
    NSNumber *bl = [NSNumber numberWithInt:d];
    
    NSLog(@"%hhu, %hhu, %@, %@", isFinded, isConnected, name, bl);
    
    if (bp == NULL) {
        
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OYNO"];
    }
    
    NSString *CellIdentifier;
    
    if (isConnected) {
        
        CellIdentifier = @"bleListCellConnected";
        
    }else if(!isFinded){
        
        CellIdentifier = @"bleListCellFinded";
        
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
        batteryLevel.text = [NSString stringWithFormat:@"%@%%", bl];
        batteryLevel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    }
    
    if (isConnected || [CellIdentifier isEqual:@"bleListCellScan"]) {
        //手环名称
        UILabel* bandName = (UILabel*)[cell.contentView viewWithTag:BAND_NAME_TAG];
        bandName.text = name;
    }
    
    return cell;
}

//选中某行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
    NSString* cellId = [tableView cellForRowAtIndexPath:indexPath].reuseIdentifier;
    
    NSLog(@"%@", cellId);
    
    if ([cellId isEqual:@"bleListCellConnected"] || [cellId isEqual:@"bleListCellScan"]) {
        
        [self.bandCM connectSelectedPeripheral:[indexPath row]];
        
    }
}

- (IBAction)sync:(UIButton *)sender {
    
    [self.bandCM sync:MAM_BAND_MODEL];
    
    [_dlProgress setHidden:NO];
}

@end
