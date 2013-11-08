//
//  BTSetupViewController.h
//  SmartBat
//
//  Created by kaka' on 13-8-2.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTBaseViewController.h"
#import "BTBandCentral.h"

@interface BTSetupViewController : BTBaseViewController

@property (weak, nonatomic) IBOutlet UITextField *deviceName;

- (IBAction)back:(UIButton *)sender;

@end
