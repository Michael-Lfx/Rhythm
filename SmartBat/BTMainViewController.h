//
//  BTViewController.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTSwipeViewController.h"
#import "BTMetronomeCoreController.h"
#import "BTBandCentral.h"


@interface BTMainViewController : BTSwipeViewController{
    NSTimer* _changeBPMTimer;
    int _intervalCount;
}

@property (weak, nonatomic) IBOutlet UILabel *mainNumber;
@property (weak, nonatomic) IBOutlet UIButton *plus;
@property (weak, nonatomic) IBOutlet UIButton *minus;
@property (weak, nonatomic) IBOutlet UILabel *beatAndNoteDisplay;
@property (weak, nonatomic) IBOutlet UIImageView *subdivisionDisplay;

@property (nonatomic, retain) BTMetronomeCoreController * metronomeCoreController;

@property(strong, nonatomic) NSTimer* bluetoothTimer;
@property(assign, nonatomic) uint8_t play;

- (IBAction)minusPressed:(UIButton *)sender;
- (IBAction)plusPressed:(UIButton *)sender;
- (IBAction)plusEnded:(UIButton *)sender;
- (IBAction)minusEnded:(UIButton *)sender;
- (IBAction)playPressed:(UIButton *)sender;
- (IBAction)tapPressed:(UIButton *)sender;

@end
