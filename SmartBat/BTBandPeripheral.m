//
//  BTBandPeripheral.m
//  SmartBat
//
//  Created by kaka' on 13-6-15.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTBandPeripheral.h"

@implementation BTBandPeripheral

-(BTBandPeripheral*)initWithPeripheral:(CBPeripheral*)peripheral{
    self = [super init];
    
    if (self) {
        
        self.allCharacteristics = [NSMutableDictionary dictionaryWithCapacity:kCharacteristicsCount];
        self.allValues = [NSMutableDictionary dictionaryWithCapacity:kCharacteristicsCount];
        self.allCallback = [NSMutableDictionary dictionaryWithCapacity:kCharacteristicsCount];
        
        self.handle = peripheral;
        
        self.play = 0;
//        self.waitForRestart = NO;
    }
    
    return self;
}

@end