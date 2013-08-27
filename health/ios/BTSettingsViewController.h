//
//  BTSettingsViewController.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTBaseViewController.h"

@interface BTSettingsViewController : BTBaseViewController{
    //不同的子类，设置不同的原始x点
    int _originX;
}

-(IBAction)pickupSettings:(id)sender;

-(void)callMeDisplay;

@end
