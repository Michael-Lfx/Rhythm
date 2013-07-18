//
//  BTEntity.h
//  SmartBat
//
//  Created by kaka' on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BTEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * beatPerMinute;
@property (nonatomic, retain) NSNumber * beatPerMeasure;
@property (nonatomic, retain) NSNumber * noteType;
@property (nonatomic, retain) NSNumber * subdivision;
@property (nonatomic, retain) NSNumber * lastCheckVersionDate;
@property (nonatomic, retain) NSNumber * installDate;
@property (nonatomic, retain) NSNumber * hasAskGrade;

@end
