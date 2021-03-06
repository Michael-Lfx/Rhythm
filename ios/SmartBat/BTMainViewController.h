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
#import "BTTapController.h"
#import "BTBandCentral.h"
#import "BTSoundController.h"


@interface BTMainViewController : BTSwipeViewController{
    NSTimer* _changeBPMTimer;
    int _intervalCount;
}

@property (weak, nonatomic) IBOutlet UILabel *mainNumber;
@property (weak, nonatomic) IBOutlet UIButton *plus;
@property (weak, nonatomic) IBOutlet UIButton *minus;
@property (weak, nonatomic) IBOutlet UILabel *beatAndNoteDisplay;
@property (weak, nonatomic) IBOutlet UIImageView *subdivisionDisplay;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *tapDisplay;

@property (nonatomic, retain) BTMetronomeCoreController * metronomeCoreController;
@property (nonatomic, retain) BTTapController * tapController;
@property (nonatomic, retain) BTSoundController * soundController;

@property(strong, nonatomic) NSTimer* bleTimer;

- (IBAction)minusPressed:(UIButton *)sender;
- (IBAction)plusPressed:(UIButton *)sender;
- (IBAction)plusEnded:(UIButton *)sender;
- (IBAction)minusEnded:(UIButton *)sender;
- (IBAction)playPressed:(UIButton *)sender;
- (IBAction)tapPressed:(UIButton *)sender;

@end
