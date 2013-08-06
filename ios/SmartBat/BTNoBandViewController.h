//
//  BTNoBandViewController.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTSettingsViewController.h"
#import "OALSimpleAudio.h"
#import "BTSetupViewController.h"

@interface BTNoBandViewController : BTSettingsViewController <UITableViewDelegate, UITableViewDataSource>

@property(strong, nonatomic) BTBandCentral* cm;
@property(strong, nonatomic) BTSetupViewController* setupViewCtrl;

@property (weak, nonatomic) IBOutlet UITableView *bleList;

- (IBAction)scan:(UIButton *)sender;

@end
