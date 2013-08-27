//
//  BTEntity.h
//  Health
//
//  Created by kaka' on 13-8-27.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BTEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * hasAskGrade;
@property (nonatomic, retain) NSNumber * installDate;
@property (nonatomic, retain) NSNumber * lastCheckVersionDate;

@end
