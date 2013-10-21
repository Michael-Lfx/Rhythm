//
//  BTRawData.h
//  Health
//
//  Created by kaka' on 13-10-21.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BTRawData : NSManagedObject

@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * month;
@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * minute;
@property (nonatomic, retain) NSNumber * hour;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * count;

@end
