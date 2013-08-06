//
//  BTSetupViewController.m
//  SmartBat
//
//  Created by kaka' on 13-8-2.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTSetupViewController.h"

@interface BTSetupViewController ()

@end

@implementation BTSetupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [_deviceName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(UIButton *)sender {
    UIView* bandView = [self.view.superview viewWithTag:NO_BAND_VIEW_TAG];
    
    NSLog(@"%@", bandView); 
    
    [UIView animateWithDuration:THRESHOLD_2_COMPLETE_DURETION animations:^(void) {
        CGRect f = bandView.frame;
        f.origin.x = 0;
        bandView.frame = f;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        self.view = nil;
    }];
}

- (IBAction)done:(id)sender {
    NSData* data = [_deviceName.text dataUsingEncoding:NSASCIIStringEncoding];
    
    NSLog(@"len:%lu", (unsigned long)data.length);
    
    if (data.length > DEVICE_NAME_MAX_LENGTH) {
        
    }else{
        [[BTBandCentral sharedBandCentral] setup:data withBlock:^(int result) {
            if (result == 0) {
                [self back:nil];
            }
        }];
    }
}
@end
