//
//  BTViewController.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTMainViewController.h"

@interface BTMainViewController ()

@end

@implementation BTMainViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.globals addObserver:self forKeyPath:@"dlPercent" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    self.dailyData = [[NSMutableArray alloc] initWithCapacity:24];
    
}

//监控参数，更新显示
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if([keyPath isEqualToString:@"dlPercent"])
    {
        NSLog(@"what");
        
        if (self.globals.dlPercent == 1) {
            
            NSLog(@"oh yeah");
            
            //设置数据类型
            int type = 2;
            
            //分割出年月日小时
            NSDate* date = [NSDate date];
            NSTimeZone *zone = [NSTimeZone systemTimeZone];
            NSInteger interval = [zone secondsFromGMTForDate: date];
            NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
            
            NSLog(@"%@", localeDate);
            
            NSNumber* year = [BTUtils getYear:localeDate];
            NSNumber* month = [BTUtils getMonth:localeDate];
            NSNumber* day = [BTUtils getDay:localeDate];
            NSNumber* hour = [BTUtils getHour:localeDate];
            
            //设置coredata
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"BTRawData" inManagedObjectContext:self.context];
            
            NSFetchRequest* request = [[NSFetchRequest alloc] init];
            [request setEntity:entity];
            
            //设置查询条件
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@ AND month == %@ AND day = %@ AND hour == %@ AND type == %@",year, month, day, hour, [NSNumber numberWithInt:type]];
            
            [request setPredicate:predicate];
            
            //排序
            NSMutableArray *sortDescriptors = [NSMutableArray array];
            [sortDescriptors addObject:[[NSSortDescriptor alloc] initWithKey:@"minute" ascending:YES] ];
            
            [request setSortDescriptors:sortDescriptors];
            
            NSError* error;
            NSArray* raw = [self.context executeFetchRequest:request error:&error];
            
            [_dailyData removeAllObjects]; 
            
            if (raw.count > 0) {
                for (BTRawData* one in raw) {
                    [_dailyData addObject:one.count];
                }
            }
            
            NSLog(@"%@", _dailyData);
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
