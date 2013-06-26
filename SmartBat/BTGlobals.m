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
            _beatPerMinute = kBeatPerMinuteInit;
            _beatPerMeasure = kBeatPerMeasureInit;
            _noteType = kNoteType;
            _subdivision = kSubdivision;
            _lastCheckVersionDate = (int)[[NSDate date] timeIntervalSince1970];
            _hasAskGrade = 0;
            _installDate = _lastCheckVersionDate;
            _currentSubdivisionDuration = kSubdivisionDuration;
            _systemStatus = [[NSDictionary alloc]init];
            [_systemStatus setValue:NO forKey:@"playStatus"];
            
            //需要反复写入的
            [self globalsIntoEntity];
            
            //首次写入即可
            _globalsInEntity.installDate = [NSNumber numberWithInt:_lastCheckVersionDate];
            
            //保存数据
            if(![_context save:&error]){
                NSLog(@"%@", [error localizedDescription]);
            }
        }else{
            //数据库里有数据
            _globalsInEntity = [globalFromModel objectAtIndex:0];
            
            //从数据库数据来初始化该实例的全局变量
            _beatPerMinute = [_globalsInEntity.beatPerMinute intValue];
            _beatPerMeasure = [_globalsInEntity.beatPerMeasure intValue];
            _noteType = [_globalsInEntity.noteType floatValue];
            _subdivision = [_globalsInEntity.subdivision intValue];
            _lastCheckVersionDate = [_globalsInEntity.lastCheckVersionDate intValue];
            _hasAskGrade = [_globalsInEntity.hasAskGrade intValue];
            _installDate = [_globalsInEntity.installDate intValue];
            
            
            NSLog(@"%@", _globalsInEntity);
        }
    }
    return self;
}

-(void)globalsIntoEntity{
    _globalsInEntity.beatPerMinute = [NSNumber numberWithInt:_beatPerMinute];
    _globalsInEntity.beatPerMeasure = [NSNumber numberWithInt:_beatPerMeasure];
    _globalsInEntity.noteType = [NSNumber numberWithFloat:_noteType];
    _globalsInEntity.subdivision= [NSNumber numberWithInt:_subdivision];
    _globalsInEntity.lastCheckVersionDate = [NSNumber numberWithInt:_lastCheckVersionDate];
    _globalsInEntity.hasAskGrade = [NSNumber numberWithInt:_hasAskGrade];
}

-(void)applicationWillResignActive:(NSNotification*) notification{
    //退出时写入
    [self globalsIntoEntity];
    
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
