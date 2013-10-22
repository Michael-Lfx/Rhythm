//
//  BTViewController.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTMainViewController.h"

@interface BTMainViewController ()

@property (strong, nonatomic) CircularProgressView *circularProgressView;

@end

@implementation BTMainViewController

@synthesize graphView = _graphView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.globals addObserver:self forKeyPath:@"dlPercent" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    graphView = [[GraphView alloc]initWithFrame:CGRectMake(10, 377, self.view.frame.size.width-20, 100)];
    [graphView setBackgroundColor:[UIColor clearColor]];
    [graphView setSpacing:10];
    [graphView setFill:YES];
    [graphView setStrokeColor:[UIColor redColor]];
    [graphView setZeroLineStrokeColor:[UIColor greenColor]];
    [graphView setFillColor:[UIColor orangeColor]];
    [graphView setLineWidth:0];
    [graphView setCurvedLines:YES];
    [self.view addSubview:graphView];
    
    
    //set backcolor & progresscolor
    UIColor *backColor = [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0];
    UIColor *progressColor = [UIColor colorWithRed:82.0/255.0 green:135.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    //alloc CircularProgressView instance
    self.circularProgressView = [[CircularProgressView alloc] initWithFrame:CGRectMake(41, 57, 238, 238) backColor:backColor progressColor:progressColor lineWidth:10];
    
    //add CircularProgressView
    [self.view addSubview:self.circularProgressView];
    
    [self.circularProgressView updateProgressCircle:1000 withTotal:12000];


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
            
            //初始化数据
            _dailyData = [NSMutableArray arrayWithCapacity:60];
            
            for (int i = 0; i < 60; i++) {
                // 显示好看，空的设1
                [_dailyData addObject:[NSNumber numberWithInt:1]];
            }
            
            _stepCount = 0;
            
            //如果有数据

            for (BTRawData* one in raw) {
                NSNumber* m = one.minute;
                [_dailyData insertObject:one.count atIndex:[m integerValue]];
                
                _stepCount += [one.count intValue];
            }
            
            //[self.circularProgressView updateProgressCircle:stepCount withTotal:12000];
            

            NSLog(@"stepCount: %d", _stepCount);

            
            [graphView setArray:_dailyData];

        }
    }
    
}

-(void) updateValue: (float) value
{
    

    self.sportNum.text = [NSString stringWithFormat:@"%f.0",value];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
