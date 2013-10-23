//
//  BTConfigs.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTGlobals.h"

//定义全局变量的初始值
int const kBeatPerMinuteInit = 120;
int const kBeatPerMeasureInit = 4;
float const kNoteType = 0.25;
int const kSubdivision = 1;
double const kSubdivisionDuration = 0.5;

@implementation BTGlobals

-(BTGlobals*)init{
    self = [super init];
    
    if (self) {
        //监听程序终止前的通知
        UIApplication *app = [UIApplication sharedApplication];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:app];
        
        //获取上下文
        BTAppDelegate *delegate = (BTAppDelegate *)[app delegate];
        _context = delegate.managedObjectContext;
        
        //读取BTEntity下的数据
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"BTEntity" inManagedObjectContext:_context];
        
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        
        NSError* error;
        NSArray *globalFromModel = [_context executeFetchRequest:request error:&error];
        
        //看看数据里是不是空的
        if (globalFromModel.count == 0) {
            //如果发现数据库为空
            _globalsInEntity = [NSEntityDescription insertNewObjectForEntityForName:@"BTEntity" inManagedObjectContext:_context];
            
            //从常量初始化全局变量

            _lastCheckVersionDate = (int)[[NSDate date] timeIntervalSince1970];
            _hasAskGrade = 0;
            _installDate = _lastCheckVersionDate;
            _lastSync = 0;      //表示从没同步过
            
            
            //首次写入即可
            _globalsInEntity.installDate = [NSNumber numberWithInt:_lastCheckVersionDate];
            
            //保存数据
            //需要反复写入的
            [self globalsIntoEntity];
            
        }else{
            //数据库里有数据
            _globalsInEntity = [globalFromModel objectAtIndex:0];
            
            //从数据库数据来初始化该实例的全局变量

            _lastCheckVersionDate = [_globalsInEntity.lastCheckVersionDate intValue];
            _hasAskGrade = [_globalsInEntity.hasAskGrade intValue];
            _installDate = [_globalsInEntity.installDate intValue];
            _lastSync = [_globalsInEntity.lastSync intValue];
            
            
            NSLog(@"%@", _globalsInEntity);
        }
        
        //监控变量，变化时写入数据库
        //监控全局变量beatPerMinute的变化
        [self addObserver:self forKeyPath:@"lastCheckVersionDate" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        [self addObserver:self forKeyPath:@"hasAskGrade" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }
    return self;
}

-(void)globalsIntoEntity{
    _globalsInEntity.lastCheckVersionDate = [NSNumber numberWithInt:_lastCheckVersionDate];
    _globalsInEntity.hasAskGrade = [NSNumber numberWithInt:_hasAskGrade];
    _globalsInEntity.lastSync = [NSNumber numberWithInt:_lastSync];
    
    
    NSError* error;
    if(![_context save:&error]){
        NSLog(@"%@", [error localizedDescription]);
    }
}

-(void)applicationWillResignActive:(NSNotification*) notification{
    //退出时写入
    [self globalsIntoEntity];
}

//监控参数，写入本地
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self globalsIntoEntity];
}

+(BTGlobals *)sharedGlobals
{
    static BTGlobals *sharedGlobalsInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedGlobalsInstance = [[self alloc] init];
        });
    return sharedGlobalsInstance;
}

@end
