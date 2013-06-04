//
//  BTRootViewController.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTBaseViewController.h"
#import "BTMainViewController.h"
#import "BTTempoViewController.h"
#import "BTCommonViewController.h"
#import "BTConstants.h"

@interface BTRootViewController : BTBaseViewController{
    BTTempoViewController* tempViewCtl;
    BTMainViewController* mainViewCtl;
    BTCommonViewController* commonViewCtl;
}

@end
