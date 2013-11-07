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
#import <mach/mach_time.h>
#import "BTUtils.h"
#import "BTRawData.h"

@interface BTBandCentral : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>{
    NSManagedObjectContext* _context;
    NSArray* _localBleLIst;
    
}

@property(strong, nonatomic) CBCentralManager* cm;
@property(strong, nonatomic) NSMutableDictionary* allPeripherals;
@property(strong, nonatomic) BTGlobals* globals;

@property(strong, nonatomic) NSMutableDictionary* connectedList;

@property(strong, nonatomic) NSTimer* scanTimer;
@property(assign, nonatomic) Boolean syncLocker;

+(BTBandCentral*)sharedBandCentral;

-(void)writeAll:(NSData*)value withUUID:(CBUUID*)cuuid;
-(void)readAll:(CBUUID*)cuuid withBlock:(void (^)(NSData* value, CBCharacteristic* characteristic, CBPeripheral* peripheral))block;

-(void)scan;

-(void)connectSelectedPeripheral:(NSUInteger)index;

-(void)sync:(NSString*)model;
-(NSString*)getLastSyncDesc:(NSString*)model;

-(BTBandPeripheral*)getBpByModel:(NSString*)model;
-(BTBandPeripheral*)getBpByIndex:(NSInteger)row;

-(Boolean)isConnectedByModel:(NSString*)model;

@end
 