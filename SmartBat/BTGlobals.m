//
//  BTConfigs.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTGlobals.h"

//定义初始化全局变量
int const kBeatPerMinuteInit = 150;

@implementation BTGlobals

@synthesize beatPerMinute;

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
        
        NSLog(@"%d", globalFromModel.count);
        
        if (globalFromModel.count == 0) {
            //如果发现数据库为空
            _globalsInEntity = [NSEntityDescription insertNewObjectForEntityForName:@"BTEntity" inManagedObjectContext:_context];
            
            //把初始化全局变量写入数据库，同时该实例全局变量初始化
            _globalsInEntity.beatPerMinute = [NSNumber numberWithInt:kBeatPerMinuteInit];
            beatPerMinute = kBeatPerMinuteInit;
            
            //保存数据
            if(![_context save:&error]){
                NSLog(@"%@", [error localizedDescription]);
            }
        }else{
            _globalsInEntity = [globalFromModel objectAtIndex:0];
            
            //从数据库数据来初始化该实例的全局变量
            beatPerMinute = [_globalsInEntity.beatPerMinute intValue];
        }
    }
    return self;
}

-(void)applicationWillResignActive:(NSNotification*) notification{
    _globalsInEntity.beatPerMinute = [NSNumber numberWithInt:beatPerMinute];
    
    NSError* error;
    if(![_context save:&error]){
        NSLog(@"%@", [error localizedDescription]);
    }
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
