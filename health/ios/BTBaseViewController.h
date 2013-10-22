//
//  BTBaseViewController.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTConstants.h"
#import "BTGlobals.h"
#import "BTBandCentral.h"
#import "BTAppDelegate.h"

@interface BTBaseViewController : UIViewController{
    
}

@property(strong, nonatomic) BTGlobals* globals;
@property(strong, nonatomic) BTBandCentral* bandCM;
@property(strong, nonatomic) NSManagedObjectContext* context;

-(void)setViewX:(int)x;
-(void)setViewHeight:(int)h;

+(id)buildView;

@end
