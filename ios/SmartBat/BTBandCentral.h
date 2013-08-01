//
//  BTBandCentral.h
//  SmartBat
//
//  Created by kaka' on 13-6-15.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTConstants.h"
#import "BTBandPeripheral.h"
#import "BTGlobals.h"
#import "BTBleList.h"
#import "BTAppDelegate.h"
#import "BTMetronomeCoreController.h"
#import <mach/mach_time.h>

@interface BTBandCentral : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>{
    NSManagedObjectContext* _context;
    NSArray* _localBleLIst;
}

@property(strong, nonatomic) CBCentralManager* cm;
@property(strong, nonatomic) NSMutableDictionary* p;


@property(strong, nonatomic) BTGlobals* globals;
@property(strong, nonatomic) NSMutableDictionary* allPeripherals;

+(BTBandCentral*)sharedBandCentral;

-(void)write:(NSData*)value withUUID:(CBUUID*)cuuid fromPeripheral:(CBUUID*)puuid;
-(void)writeAll:(NSData*)value withUUID:(CBUUID*)cuuid;

-(void)read:(CBUUID*)cuuid fromPeripheral:(CBUUID*)puuid withBlock:(void (^)(NSData* value, CBCharacteristic* characteristic, CBPeripheral* peripheral))block;
-(void)readAll:(CBUUID*)cuuid withBlock:(void (^)(NSData* value, CBCharacteristic* characteristic, CBPeripheral* peripheral))block;

-(void)scan;

-(void)playAllAt:(double)timestamp;
-(void)pauseAll;

-(NSArray*)bleList:(NSUInteger)index;
-(void)connectSelectedPeripheral:(NSUInteger)index;

@end
 