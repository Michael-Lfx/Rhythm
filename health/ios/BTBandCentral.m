 //
//  BTBandCentral.m
//  SmartBat
//
//  Created by kaka' on 13-6-15.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTBandCentral.h"

@implementation BTBandCentral

-(id)init{
    self = [super init];
    
    if (self) {
        
        //初始化
        self.cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.globals = [BTGlobals sharedGlobals];
        
        self.allPeripherals = [[NSMutableDictionary alloc] init];
        
        self.connectedList = [[NSMutableDictionary alloc] init];
        
        //没连接上设备之前加锁
        self.syncLocker = YES;
        
        //获取上下文
        UIApplication *app = [UIApplication sharedApplication];
        BTAppDelegate *delegate = (BTAppDelegate *)[app delegate];
        _context = delegate.managedObjectContext;
    }
    
    return self;
}

//central改变状态后的回调
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            
            {
                //设置nil查找任何设备
                [self scan];
                
                //读取coredata里的数据
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"BTBleList" inManagedObjectContext:_context];
                
                NSFetchRequest* request = [[NSFetchRequest alloc] init];
                [request setEntity:entity];
                
                NSError* error;
                _localBleLIst = [_context executeFetchRequest:request error:&error];
                
                for (BTBleList* old in _localBleLIst) {
                    
                    //如果coredata里有数据，建一个缓存
                    
                    BTBandPeripheral* new = [[BTBandPeripheral alloc] init];
                    
                    new.name = old.name;
                    new.lastSync = [old.lastSync intValue];
                    new.isConnected = NO;
                    new.batteryLevel = 0;
                    new.isFinded =NO;
                    
                    [_allPeripherals setObject:new forKey:new.name];
                }
                
                self.globals.bleListCount = _allPeripherals.count;
                
                NSLog(@"array: %@", _allPeripherals);

            }
            
            break;
            
        case CBCentralManagerStatePoweredOff:
            
            //关掉蓝牙开关时清零
            self.globals.bleListCount = 0;
            
            [_allPeripherals removeAllObjects];
            
            break;
            
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}

//发现peripheral后的回调
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"Discover Peripheral: %@", peripheral);
    NSLog(@"AD count:%lu", (unsigned long)advertisementData.count);
    
    //排除name=(null)的异常状态
    if (advertisementData.count && peripheral.name != NULL) {
        
        NSLog(@"AD:%@", advertisementData);

        //查找之前是否连接过
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"BTBleList" inManagedObjectContext:_context];
        
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        
        NSError* error;
        _localBleLIst = [_context executeFetchRequest:request error:&error];
        
        //取出现在发现设备的型号
        NSString* findModel = [BTUtils getModel:peripheral.name];
        
        Boolean rightOne = YES;
        
        for (BTBleList* old in _localBleLIst) {
            
            //如果型号一致
            if ([findModel isEqualToString:[BTUtils getModel:old.name]]) {
                
                if ([old.name isEqualToString:peripheral.name]){
                    
                    //sn也一致的话，直接连接
                    
                    [_cm connectPeripheral:peripheral options:nil];
                    NSLog(@"!!!2222222");
                    
                }else{
                    
                    //型号一致，但不是之前连接的那个
                    
                    rightOne = NO;
                    
                    NSLog(@"is wrong one!");
                    
                }
            }
        }
        
        //是之前连接过的那个，或者还未连接过此类设备，对所有设备开放
        
        if (rightOne) {
            
            BTBandPeripheral* find = [_allPeripherals objectForKey:peripheral.name];
            
            //如果不在缓存中，新建一个
            if (!find) {
                find = [[BTBandPeripheral alloc] init];
                
                find.name = peripheral.name;
                find.isConnected = NO;
                find.batteryLevel = 0;
            }
            
            //缓存周边对象，变更查找状态
            [find addPeripheral:peripheral];
            find.isFinded = YES;
            
            //保存在缓存里
            [_allPeripherals setObject:find forKey:find.name];
            
            //连接上一个以后增加
            self.globals.bleListCount = _allPeripherals.count;
        }
        
        
        NSLog(@"%@", _localBleLIst);
        
        NSLog(@"%@", _allPeripherals);
    }
}

//连接peripheral后的回调
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    NSLog(@"Connect Peripheral: %@", peripheral);
    
    BTBandPeripheral* find = [_allPeripherals objectForKey:peripheral.name];
    
    //缓存中变更连接状态
    find.isConnected = YES;
    
    //查找之前是否连接过
    Boolean never = YES;
    
    for (BTBleList* old in _localBleLIst) {
        if ([old.name isEqualToString:find.name]) {
            never = NO;
        }
    }
    
    //从来没有连接过
    if (never) {
        //新建一条记录
        BTBleList* first = [NSEntityDescription insertNewObjectForEntityForName:@"BTBleList" inManagedObjectContext:_context];
        
        first.name = find.name;
        first.lastSync = 0;
        
        //及时保存
        NSError* error;
        if(![_context save:&error]){
            NSLog(@"%@", [error localizedDescription]);
        }
    }

    //代理peripheral
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    
    NSLog(@"hello：%@", _allPeripherals);
}

//发现所有service后的回调
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        NSLog(@"DiscoverServices error: %@", error.localizedDescription);
    }
    
    for (CBService *s in peripheral.services) {
        
        NSLog(@"s:%@", s.UUID);
        
        [peripheral discoverCharacteristics:nil forService:s];
        
    }
    
}

//发现所有characteristic后的回调
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    if (error) {
        NSLog(@"DiscoverCharacteristics error: %@", error.localizedDescription);
    }
    
    NSLog(@"Discover Characteristics sum: %d", service.characteristics.count);
    
    //正常连接操作
    
    BTBandPeripheral* bp = [_allPeripherals objectForKey:peripheral.name];
    
    for (CBCharacteristic* c in service.characteristics) {
        
        NSLog(@"c:%@", c.UUID);
        
        [bp.allCharacteristics setObject:c forKey:c.UUID];
        
        // 设置电量通知
        if ([c.UUID isEqual:[CBUUID UUIDWithString:UUID_BATTERY_LEVEL]]) {
            [peripheral setNotifyValue:YES forCharacteristic:c];
        }
        
        // 设置sync通知
        if ([c.UUID isEqual:[CBUUID UUIDWithString:UUID_HEALTH_SYNC]]) {
            [peripheral setNotifyValue:YES forCharacteristic:c];
        }
        
        // 设置data header通知
        if ([c.UUID isEqual:[CBUUID UUIDWithString:UUID_HEALTH_DATA_HEADER]]) {
            [peripheral setNotifyValue:YES forCharacteristic:c];
        }
        
        // 设置data body通知
        if ([c.UUID isEqual:[CBUUID UUIDWithString:UUID_HEALTH_DATA_BODY]]) {
            [peripheral setNotifyValue:YES forCharacteristic:c];
        }
        
        //连接完成！！
        
        if(bp.allCharacteristics.count == CHARACTERISTICS_COUNT){
            
            NSLog(@"ge zaile ");
            
            //更新手环状态
            self.globals.bleListCount += 0;
            
            //同步锁打开
            _syncLocker = NO;
            
            //取现在距离2000-1-1的秒数
            uint32_t seconds = [BTUtils currentSeconds];
            
            NSLog(@"now:%d", seconds);
            
            //初始化手环的时间
            [self writeAll:[NSData dataWithBytes:&seconds length:sizeof(seconds)] withUUID:[CBUUID UUIDWithString:UUID_HEALTH_CLOCK]];
            
            //新增一个连接设备
            [self.connectedList setObject:[NSNumber numberWithBool:YES] forKey:[BTUtils getModel:peripheral.name]];
            
        }
    }
}

//注册update value后的回调
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        NSLog(@"UpdateNotificationStateForCharacteristic erroe:%@", error.localizedDescription);
    }
    
    if (characteristic.isNotifying) {
        
        NSLog(@"Notification began on %@", characteristic);
        
        // 发现可以注册notify以后，读取一下数据长度
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_HEALTH_DATA_HEADER]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
        
        // 发现可以注册notify以后，读取一下数据长度
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_BATTERY_LEVEL]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }

    } else{
        NSLog(@"Notification stop %@", characteristic);
    }
}

//收到周边设备的数据更新
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        NSLog(@"UpdateValueForCharacteristic error: %@", error.localizedDescription);
    }
    
    NSLog(@"update:%@", characteristic.UUID);
    
    //根据uuid取到对象
    BTBandPeripheral* bp = [_allPeripherals objectForKey:peripheral.name];
    
    //把数据放到缓存里
    [bp.allValues setObject:characteristic.value forKey:characteristic.UUID];
    
//    NSLog(@"c:%@, v:%@", characteristic.UUID, characteristic.value);
    
    //用来做调试的
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_HEALTH_SYNC]]) {
//        int16_t x,y,z;
//        
//        [characteristic.value getBytes:&x range:NSMakeRange(0, 2)];
//        [characteristic.value getBytes:&y range:NSMakeRange(2, 2)];
//        [characteristic.value getBytes:&z range:NSMakeRange(4, 2)];
        NSLog(@"%@", characteristic.value);
        
        uint32_t hourSencodes;
        [characteristic.value getBytes:&hourSencodes range:NSMakeRange(0, 4)];
        
//        NSLog(@"x:%d y:%d z:%d", x,y,z);
        NSLog(@"hour:%@", [BTUtils dateWithSeconds:(NSTimeInterval)hourSencodes]);
        
    }
    
    //接到电量的通知
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_BATTERY_LEVEL]]) {
        
        NSLog(@"Battery: %@", characteristic.value);
        
        //更新手环状态
        self.globals.bleListCount += 0;
    }
    
    //接到数据总长度的通知
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_HEALTH_DATA_HEADER]]) {

        NSLog(@"%@", characteristic.value);
        
        uint16_t d;
        [characteristic.value getBytes:&d];
        
        bp.dataLength = d;
        
        NSLog(@"length:%d", bp.dataLength);
    }
    
    //接到数据通知
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_HEALTH_DATA_BODY]]) {
        NSLog(@"v:%@",  characteristic.value);
        
        uint32_t seconds;
        uint16_t count;
        uint8_t type;
        
        [characteristic.value getBytes:&seconds range:NSMakeRange(0, 4)];
        [characteristic.value getBytes:&count range:NSMakeRange(4, 2)];
        [characteristic.value getBytes:&type range:NSMakeRange(6, 1)];
        
        NSLog(@"%@, c:%d t:%d", [BTUtils dateWithSeconds:(NSTimeInterval)seconds], count, type);
        
        if (count > 0) {
            //分割出年月日小时
            NSDate* date = [BTUtils dateWithSeconds:(NSTimeInterval)seconds];
            
            NSNumber* year = [BTUtils getYear:date];
            NSNumber* month = [BTUtils getMonth:date];
            NSNumber* day = [BTUtils getDay:date];
            NSNumber* hour = [BTUtils getHour:date];
            NSNumber* minute = [BTUtils getMinutes:date];
            
            //设置coredata
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"BTRawData" inManagedObjectContext:_context];
            
            NSFetchRequest* request = [[NSFetchRequest alloc] init];
            [request setEntity:entity];
            
            //设置查询条件
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@ AND month == %@ AND day = %@ AND hour == %@ AND minute == %@ AND type == %@",year, month, day, hour, minute, [NSNumber numberWithInt:type]];
            
            [request setPredicate:predicate];
            
            NSError* error;
            NSArray* raw = [_context executeFetchRequest:request error:&error];
            
            if (raw.count == 1) {
                
                //已经有条目了
                
                BTRawData* one = [raw objectAtIndex:0];
                
                NSLog(@"ther is %@", one.count);
                
                one.count = [NSNumber numberWithInt:[one.count intValue] + count];
                
            }else if(raw.count == 0){
                
                //木有啊,就新建一条
                
                NSLog(@"there no");
                
                BTRawData* new = [NSEntityDescription insertNewObjectForEntityForName:@"BTRawData" inManagedObjectContext:_context];
                
                new.year = year;
                new.month = month;
                new.day = day;
                new.hour = hour;
                new.minute = minute;
                new.type = [NSNumber numberWithInt:type];
                new.count = [NSNumber numberWithInt:count];
                new.from = peripheral.name;
            }
            
            // 及时保存
            if(![_context save:&error]){
                NSLog(@"%@", [error localizedDescription]);
            }
            
        }
        
        
        bp.currentBlock++;
        
        bp.dlPercent = (float)bp.currentBlock / (float)bp.dataLength;
        
        //同步完成
        if (bp.dlPercent == 1) {
            _syncLocker = NO;
            
            //更新上次同步时间
            bp.lastSync = [[NSDate date] timeIntervalSince1970];
            
            //设置coredata
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"BTBleList" inManagedObjectContext:_context];
            
            NSFetchRequest* request = [[NSFetchRequest alloc] init];
            [request setEntity:entity];
            
            //设置查询条件
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", bp.name];
            
            [request setPredicate:predicate];
            
            NSError* error;
            NSArray* raw = [_context executeFetchRequest:request error:&error];
            
            if (raw.count) {
                BTBleList* one = [raw objectAtIndex:0];
                
                //更新coredata里的最后更新时间
                one.lastSync = [NSNumber numberWithInt:bp.lastSync];
            }
            
            // 及时保存
            if(![_context save:&error]){
                NSLog(@"%@", [error localizedDescription]);
            }

        }
        
    }
    
    //取出缓存中的block并执行
    void (^block)(NSData* value, CBCharacteristic* characteristic, CBPeripheral* peripheral)  = [bp.allCallback objectForKey:characteristic.UUID];
    
    if (block) { 
        block(characteristic.value, characteristic, peripheral);
    }
    
    [bp.allCallback removeObjectForKey:characteristic.UUID];
}

//写数据完成后的回调
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"WriteValueForCharacteristic error: %@", error.localizedDescription);
    }
    NSLog(@"write value: %@", characteristic.value);
    
}

//某个peripheral断开连接
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    NSLog(@"dis:%@ err:%@", peripheral, error);

    //从缓存中移除
    [_allPeripherals removeObjectForKey:peripheral.name];
    
    
    //读取coredata里的数据
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BTBleList" inManagedObjectContext:_context];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError* err;
    _localBleLIst = [_context executeFetchRequest:request error:&err];
    
    for (BTBleList* old in _localBleLIst) {
        
        if ([old.name isEqual:peripheral.name]) {
            
            //如果在coredata中，则在缓存中重建
            
            BTBandPeripheral* new = [[BTBandPeripheral alloc] init];
            
            new.name = peripheral.name;
            new.lastSync = 0;
            new.isConnected = NO;
            new.batteryLevel = 0;
            new.isFinded =NO;
            
            [_allPeripherals setObject:new forKey:new.name];

        }
    }

    //设备总数减少
    self.globals.bleListCount = _allPeripherals.count;
    
    //断开一个设备
    [_connectedList setObject:[NSNumber numberWithBool:NO] forKey:[BTUtils getModel:peripheral.name]];
    
    //断开连接后自动重新搜索
    
    [central stopScan];
    
    _scanTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(doScan:) userInfo:nil repeats:NO];
}


/*
    对外接口
 */


-(void)doScan:(NSTimer *)theTimer{
    [self scan];
}

//向所有peripheral写数据
-(void)writeAll:(NSData*)value withUUID:(CBUUID*)cuuid{
    
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    
    for (BTBandPeripheral* bp in enumeratorValue) {
        CBCharacteristic* tmp = [bp.allCharacteristics objectForKey:cuuid];
        
        if (tmp && bp.handle.isConnected) {
            [bp.handle writeValue:value forCharacteristic:tmp type:CBCharacteristicWriteWithResponse];
        }
    }
}


//读取所有peripheral里某个characteristic
-(void)readAll:(CBUUID*)cuuid withBlock:(void (^)(NSData* value, CBCharacteristic* characteristic, CBPeripheral* peripheral))block{
    
    //遍历所有的peripheral
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    
    for (BTBandPeripheral* bp in enumeratorValue) {
        
        //根据uuid找到具体的characteristic
        CBCharacteristic* tmp = [bp.allCharacteristics objectForKey:cuuid];
        
        if (tmp && bp.handle.isConnected) {
            //把block句柄放到缓存里
            //注意：没有加锁，可能有问题
            if (block) {
                [bp.allCallback setObject:block forKey:cuuid];
            }
            
            //发送read请求
            [bp.handle readValueForCharacteristic:tmp];
        }
    }
}


//把丫做成单例
+(BTBandCentral *)sharedBandCentral
{
    static BTBandCentral *sharedBandCentralInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedBandCentralInstance = [[self alloc] init];
    });
    return sharedBandCentralInstance;
}

//主动重新搜索
-(void)scan{
    
    [_cm scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:UUID_HEALTH_SERVICE]] options:nil];
    
    NSLog(@"scan ForPeripherals");
}

//连接选中的peripheral
-(void)connectSelectedPeripheral:(NSUInteger)index{
    
    //根据index找到对应的peripheral
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    BTBandPeripheral* bp = [[enumeratorValue allObjects] objectAtIndex:index];
    
    if (!bp.handle.isConnected) {
        
        [_cm connectPeripheral:bp.handle options:nil];
        NSLog(@"!!!connect");
        
    }else{
        
        //删除coredata里的这条数据
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"BTBleList" inManagedObjectContext:_context];
        
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        
        NSError* error;
        _localBleLIst = [_context executeFetchRequest:request error:&error];
        
        for (BTBleList* old in _localBleLIst) {
            if ([old.name isEqualToString:bp.handle.name]){
                [_context deleteObject:old];
                NSLog(@"!!!2222222");
            }
        }
        
        //断开连接
        [_cm cancelPeripheralConnection:bp.handle];
        NSLog(@"cancel connected");
    }
    
}

-(void)sync:(NSString*)model{
    
    if (!_syncLocker) {
        
        _syncLocker = YES;
        
        NSLog(@"wo ca");
        
        BTBandPeripheral* bp = [self getBpByModel:model];
        
        if (bp) {
            
            //开始同步
            
            bp.currentBlock = 0;
            
            CBCharacteristic* c = [bp.allCharacteristics objectForKey:[CBUUID UUIDWithString:UUID_HEALTH_SYNC]];
            
            uint16_t dd = SYNC_CODE;
            
            [bp.handle writeValue:[NSData dataWithBytes:&dd length:sizeof(dd)] forCharacteristic:c type:CBCharacteristicWriteWithResponse];
            
        }
        
    }
    
}

-(NSString*)getLastSyncDesc:(NSString*)model{
    
    NSString* syncWords;
    
    BTBandPeripheral* bp = [self getBpByModel:model];
        
    if (bp) {
        
        if (bp.lastSync) {
            
            NSString* last;
            
            int interval = [[NSDate date] timeIntervalSince1970] - bp.lastSync;
            
            
            if (interval < 10) {
                
                // 10秒以内，刚刚
                last = @"刚刚";
                
            }else if (interval < 60) {
                
                // 1分钟以内，xx秒前
                last = [NSString stringWithFormat:@"%d0秒前", interval/10];
                
            }else if(interval < 3600){
                
                // 1小时以内，xx分钟前
                last = [NSString stringWithFormat:@"%d分钟前", interval/60];
                
            }else if(interval < 86400){
                
                // 1天以内，xx小时前
                last = [NSString stringWithFormat:@"%d小时前", interval/3600];
                
            }else if(interval < 345600){
                
                // 4天以内，x天前
                last = [NSString stringWithFormat:@"%d天前", interval/86400];
                
            }else{
                
                // 用全日期
                NSDateFormatter* df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"yyyy-MM-dd"];
                [df setTimeZone:[NSTimeZone localTimeZone]];
                
                last = [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:bp.lastSync]];
            }
            
            syncWords = [NSString stringWithFormat:@"上次同步:%@", last];
            
        }else{
            
            //从没同步过
            syncWords = @"从未同步";
            
        }
        
        NSLog(@"%@", syncWords);
        
    }
    
    return syncWords;
    
}

-(BTBandPeripheral*)getBpByModel:(NSString*)model{
    
    //遍历所有的peripheral
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    
    for (BTBandPeripheral* bp in enumeratorValue) {
        
        if ([model isEqual:[BTUtils getModel:bp.name]]) {
            
            return bp;
        }
        
    }
    
    return Nil;
}

-(BTBandPeripheral*)getBpByIndex:(NSInteger)row{
    NSArray * ev = [[_allPeripherals objectEnumerator] allObjects];
    return [ev objectAtIndex:row];
}

-(Boolean)isConnectedByModel:(NSString*)model{
    
    NSNumber* b = [_connectedList objectForKey:model];
    
    if (b && b.boolValue) {
        return YES;
    }else{
        return NO;
    }
}

@end
