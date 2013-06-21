//
//  BTTempoViewController.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTSwipeViewController.h"
#import "BTMetronomeCoreController.h"

@interface BTTempoViewController : BTSwipeViewController{
    
}

@property (nonatomic, retain) BTMetronomeCoreController * metronomeCoreController;

@property (weak, nonatomic) IBOutlet UILabel *beatPerMeasureDisplay;
@property (weak, nonatomic) IBOutlet UILabel *noteTypeDisplay;
@property (weak, nonatomic) IBOutlet UIImageView *subdivisionDisplay;

- (IBAction)increaseBeatHandler:(UIButton *)sender;
- (IBAction)decreaseBeatHandler:(UIButton *)sender;
- (IBAction)increaseNoteTypeHandler:(UIButton *)sender;
- (IBAction)decreaseNoteTypeHandler:(UIButton *)sender;
- (IBAction)increaseSubdivisionHandler:(id)sender;
- (IBAction)decreaseSubdivisionHandler:(id)sender;


@end
