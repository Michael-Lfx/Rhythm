//
//  BTNoBandViewController.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTSettingsViewController.h"
#import "BTBandCentral.h"
#import "BTBandPeripheral.h"
#import "OALSimpleAudio.h"

@interface BTNoBandViewController : BTSettingsViewController

@property(strong, nonatomic) BTBandPeripheral* pm;
@property(strong, nonatomic) BTBandCentral* cm;

@end
