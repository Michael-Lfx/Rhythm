//
//  BTNoBandViewController.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTSettingsViewController.h"
#import "BTSetupViewController.h"

@interface BTBandViewController : BTSettingsViewController <UITableViewDelegate, UITableViewDataSource>

@property(strong, nonatomic) BTBandCentral* cm;
@property(strong, nonatomic) BTSetupViewController* setupViewCtrl;

@property (weak, nonatomic) IBOutlet UITableView *bleList;
@property (weak, nonatomic) IBOutlet UIProgressView *dlProgress;

- (IBAction)scan:(UIButton *)sender;


@end
