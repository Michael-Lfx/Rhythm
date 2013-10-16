//
//  BTCommonViewController.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTSettingsViewController.h"

@interface BTCommonViewController : BTSettingsViewController  <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *dataTable;

@end
