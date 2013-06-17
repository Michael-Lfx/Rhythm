//
//  BTBandPeripheral.m
//  SmartBat
//
//  Created by kaka' on 13-6-15.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTBandPeripheral.h"

@implementation BTBandPeripheral

-(id)init{
    self = [super init];
    
    if (self) {
        self.pm = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        
        [[OALSimpleAudio sharedInstance] preloadEffect:@"default_p.caf"];
    }
    
    return self;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            
            [self addService];
            
            break;
        default:
            NSLog(@"Peripheral Manager did change state");
            break;
    }
}

-(void)addService{
    
    _mc = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kMetronomeServiceUUID] properties:CBCharacteristicPropertyWrite|CBCharacteristicPropertyNotify|CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
    
    CBMutableService* ms = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:kMetronomePlayUUID] primary:YES];
    
    [ms setCharacteristics:@[_mc]];
    
    // Publishes the service
    [_pm addService:ms];
    
    NSLog(@"Peripheral addService");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service error:(NSError *)error {

    [peripheral startAdvertising:@{CBAdvertisementDataLocalNameKey :@"SmartBat", CBAdvertisementDataServiceUUIDsKey :@[[CBUUID UUIDWithString:kMetronomeServiceUUID]]}];
    
    NSLog(@"Peripheral didAddService");
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    
    _i = 1;
    [peripheral updateValue:[NSData dataWithBytes:&_i length:sizeof(_i)] forCharacteristic:_mc onSubscribedCentrals:nil];
    
    NSLog(@"Peripheral SubscribeToCharacteristic");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"UnsubscribeFromCharacteristic");
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    NSLog(@"%@", request.value);
    [_pm respondToRequest:request withResult:CBATTErrorSuccess];
    
    [[OALSimpleAudio sharedInstance] playEffect:@"default_p.caf"]; 
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    
    for (CBATTRequest* r in requests) {
        NSLog(@"%@", r.value);
        [_pm respondToRequest:r withResult:CBATTErrorSuccess];
        
        [[OALSimpleAudio sharedInstance] playEffect:@"default_p.caf"];
    }
}

-(void)update{
    _i++;
    [_pm updateValue:[NSData dataWithBytes:&_i length:sizeof(_i)] forCharacteristic:_mc onSubscribedCentrals:nil];
    
    [[OALSimpleAudio sharedInstance] playEffect:@"default_p.caf"];
}

@end
