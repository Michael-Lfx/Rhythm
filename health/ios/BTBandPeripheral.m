//
//  BTBandPeripheral.m
//  SmartBat
//
//  Created by kaka' on 13-6-15.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTBandPeripheral.h"

@implementation BTBandPeripheral

-(void)addPeripheral:(CBPeripheral*)peripheral{
    
    self.allCharacteristics = [NSMutableDictionary dictionaryWithCapacity:CHARACTERISTICS_COUNT];
    self.allValues = [NSMutableDictionary dictionaryWithCapacity:CHARACTERISTICS_COUNT];
    self.allCallback = [NSMutableDictionary dictionaryWithCapacity:CHARACTERISTICS_COUNT];
    
    self.handle = peripheral;

}

@end