//
//  BTBaseViewController.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTConstants.h"

@interface BTBaseViewController : UIViewController{
    int _viewX;
}

-(void)clearXY;
-(void)setViewX:(int)x who:(UIView*)view;
-(void)setViewX:(int)x;

+(id)buildView;

@end
