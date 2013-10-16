//
//  BTCommonViewController.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTCommonViewController.h"

@interface BTCommonViewController ()

@end

@implementation BTCommonViewController

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
    
    //设置common设置页屏幕右侧隐藏
    _originX = -[[UIScreen mainScreen] applicationFrame].size.width;
    
    [self.globals addObserver:self forKeyPath:@"dataListCount" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    _dataTable.delegate = self;
    _dataTable.dataSource = self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"dataListCount"])
    {
        [_dataTable reloadData];
    }
}

//列表行数的代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.globals.dataListCount;
}

//渲染每行数据的代理
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *CellIdentifier = @"oneData";
    
    
    NSLog(@"%@", CellIdentifier);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSData* one = [self.globals.dataList objectAtIndex:indexPath.row];
    
    uint32_t seconds;
    uint16_t count;
    
    [one getBytes:&seconds range:NSMakeRange(0, 4)];
    [one getBytes:&count range:NSMakeRange(4, 2)];
    
    NSLog(@"%@, c:%d", [BTUtils dateWithSeconds:(NSTimeInterval)seconds], count);
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy/MM/dd HH:mm"];
    // 初始化手环时间时已经转成当地时间
    // 这里设置成格林威治时间
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    
    
    
    //连接后显示电量
    UILabel* date = (UILabel*)[cell.contentView viewWithTag:1];
    date.text =  [df stringFromDate:[BTUtils dateWithSeconds:(NSTimeInterval)seconds]];
    date.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    
    
    //手环名称
    UILabel* countNum = (UILabel*)[cell.contentView viewWithTag:2];
    countNum.text = [NSString stringWithFormat:@"%d", count];
    
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
