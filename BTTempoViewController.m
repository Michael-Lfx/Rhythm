//
//  BTTempoViewController.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTTempoViewController.h"

@interface BTTempoViewController ()

@end

@implementation BTTempoViewController

@synthesize metronomeCoreController;

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
    
    self.metronomeCoreController = [BTMetronomeCoreController getController];
    
    [self updateBeatPerMeasureDisplay];
    [self updateNoteTypeDisplay];
    
    [_globals addObserver:self forKeyPath:@"beatPerMeasure" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [_globals addObserver:self forKeyPath:@"noteType" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [_globals addObserver:self forKeyPath:@"subdivision" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [_globals addObserver:self forKeyPath:@"currentMeasure" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [_globals addObserver:self forKeyPath:@"beatIndexOfMeasure" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    

    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)increaseBeatHandler:(UIButton *)sender {
    
    if(_globals.beatPerMeasure < 16)
    {
        _globals.beatPerMeasure ++;
    }
    
}

- (IBAction)decreaseBeatHandler:(UIButton *)sender {

    if(_globals.beatPerMeasure > 1)
    {
        _globals.beatPerMeasure --;
    }
}

- (IBAction)increaseNoteTypeHandler:(UIButton *)sender
{
    if(_globals.noteType > NOTETYPE_MIN)
    {
        _globals.noteType = _globals.noteType/2;
        
        NSNumber *n = [[NSNumber alloc]initWithFloat:1.0/_globals.noteType ];
        _globals.beatPerMeasure = n.intValue;
        _globals.subdivision = 1;
    }
}

- (IBAction)decreaseNoteTypeHandler:(UIButton *)sender
{
    if(_globals.noteType < NOTETYPE_MAX)
    {
        _globals.noteType = _globals.noteType*2;
        
         NSNumber *n = [[NSNumber alloc]initWithFloat:1.0/_globals.noteType ];
        _globals.beatPerMeasure = n.intValue;
        _globals.subdivision = 1;
    }
}

- (IBAction)increaseSubdivisionHandler:(id)sender {
    
    if(_globals.noteType / _globals.subdivision > NOTETYPE_MIN && _globals.subdivision<4)
    {
        _globals.subdivision ++;
    }
    
}

- (IBAction)decreaseSubdivisionHandler:(id)sender {

    if(_globals.subdivision > 1)
    {
        _globals.subdivision--;
    }
    
}

-(void)updateBeatPerMeasureDisplay
{
    self.beatPerMeasureDisplay.text = [NSString stringWithFormat:@"%d", _globals.beatPerMeasure];
}


-(void)updateNoteTypeDisplay
{
    NSNumber *n = [[NSNumber alloc]initWithFloat:1.0/_globals.noteType ];
    self.noteTypeDisplay.text = [NSString stringWithFormat:@"%d",  n.intValue ];
}

-(void)updateSubdivisionDisplay
{

    NSNumber *n = [[NSNumber alloc]initWithFloat: 1 / (_globals.noteType / _globals.subdivision) ];
    NSString *filePath = nil;
    
    switch(n.intValue)
    {
        case 2:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteBig_01" ofType:@"png"];
            break;
        case 4:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteBig_02" ofType:@"png"];
            break;
        case 6:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteBig_33" ofType:@"png"];
            break;
        case 8:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteBig_30" ofType:@"png"];
            break;
        case 12:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteBig_34" ofType:@"png"];
            break;
        case 16:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteBig_40" ofType:@"png"];
            break;
        case 24:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteBig_35" ofType:@"png"];
            break;
        case 32:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteBig_41" ofType:@"png"];
            break;
    }
    NSData *data=[NSData dataWithContentsOfFile:filePath];
    UIImage *image=[UIImage imageWithData:data];
    [self.subdivisionDisplay setImage:image];
}

//global observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if([keyPath isEqualToString:@"beatPerMeasure"])
    {
        [self updateBeatPerMeasureDisplay];
    }
    
    if([keyPath isEqualToString:@"noteType"])
    {
        [self updateNoteTypeDisplay];
    }
    
    if([keyPath isEqualToString:@"subdivision"])
    {
        [self updateSubdivisionDisplay];
    }
    
    if([keyPath isEqualToString:@"currentMeasure"])
    {
        NSLog(@"%@", _globals.currentMeasure.description);
    }
    
    if([keyPath isEqualToString:@"beatIndexOfMeasure"])
    {
        NSLog(@"%d", _globals.beatIndexOfMeasure);
    }
}

@end
