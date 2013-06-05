//
//  BTSwipeViewController.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTBaseViewController.h"
#import "BTSettingsViewController.h"

@interface BTSwipeViewController : BTBaseViewController{
    CGPoint _originPoint;
}

-(void)swipeBegan;
-(void)swipe:(int)dis;
-(void)swipeEnded;

-(IBAction)callCommonSettings:(UIButton*)sender;
-(IBAction)callBandSettings:(UIButton*)sender;

-(void)slideIn:(UIView*)view;

@end
