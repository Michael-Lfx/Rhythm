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

@interface BTBaseViewController : UIViewController{
    int _viewX;
    BTGlobals* _globals;
}

-(void)clearXY;
-(void)setViewX:(int)x who:(UIView*)view;
-(void)setViewX:(int)x;

+(id)buildView;

@end
