//
//  BTViewController.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTSwipeViewController.h"
#import "BTSimpleFileSoundEngine.h"


@interface BTMainViewController : BTSwipeViewController{
    UIView* _tempoView;
    BTGlobals* _globals;
    
    NSTimer* _changeBPMTimer;
    int _intervalCount;
}

@property (weak, nonatomic) IBOutlet UILabel *mainNumber;
@property (weak, nonatomic) IBOutlet UIButton *plus;
@property (weak, nonatomic) IBOutlet UIButton *minus;

- (IBAction)minusPressed:(UIButton *)sender;
- (IBAction)plusPressed:(UIButton *)sender;
- (IBAction)plusEnded:(UIButton *)sender;
- (IBAction)minusEnded:(UIButton *)sender;

-(void)changeBPM:(NSTimer*)timer;
-(void)setBPMDisplay;
-(void)startChangeBPMTimer:(NSString*)operation interval:(float)duration;
-(void)stopChangeBPMTImer;

@end
