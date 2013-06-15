//
//  BTBandPeripheral.h
//  SmartBat
//
//  Created by kaka' on 13-6-15.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTConstants.h"
#import "OALSimpleAudio.h"

@interface BTBandPeripheral : NSObject <CBPeripheralManagerDelegate>

@property(strong, nonatomic) CBPeripheralManager* pm;
@property(strong, nonatomic) CBMutableCharacteristic* mc;
@property(assign, nonatomic) int i;

-(void)update;

@end
