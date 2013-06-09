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
    BTGlobals* _globals;
}

-(void)setViewX:(int)x;
-(void)setViewHeight:(int)h;

+(id)buildView;

@end
