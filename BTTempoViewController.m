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
    
    [self.globals addObserver:self forKeyPath:@"beatPerMeasure" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.globals addObserver:self forKeyPath:@"noteType" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.globals addObserver:self forKeyPath:@"subdivision" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.globals addObserver:self forKeyPath:@"currentMeasure" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.globals addObserver:self forKeyPath:@"beatInfo" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    

    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)increaseBeatHandler:(UIButton *)sender {
    
    if(self.globals.beatPerMeasure < 16)
    {
        self.globals.beatPerMeasure ++;
    }
    
}

- (IBAction)decreaseBeatHandler:(UIButton *)sender {

    if(self.globals.beatPerMeasure > 1)
    {
        self.globals.beatPerMeasure --;
    }
}

- (IBAction)increaseNoteTypeHandler:(UIButton *)sender
{
    if(self.globals.noteType > NOTETYPE_MIN)
    {
        self.globals.noteType = self.globals.noteType/2;
        
        NSNumber *n = [[NSNumber alloc]initWithFloat:1.0/self.globals.noteType ];
        self.globals.beatPerMeasure = n.intValue;
        self.globals.subdivision = 1;
    }
}

- (IBAction)decreaseNoteTypeHandler:(UIButton *)sender
{
    if(self.globals.noteType < NOTETYPE_MAX)
    {
        self.globals.noteType = self.globals.noteType*2;
        
         NSNumber *n = [[NSNumber alloc]initWithFloat:1.0/self.globals.noteType ];
        self.globals.beatPerMeasure = n.intValue;
        self.globals.subdivision = 1;
    }
}

- (IBAction)increaseSubdivisionHandler:(id)sender {
    
    if(self.globals.noteType / self.globals.subdivision > NOTETYPE_MIN && self.globals.subdivision<4)
    {
        self.globals.subdivision ++;
    }
    
}

- (IBAction)decreaseSubdivisionHandler:(id)sender {

    if(self.globals.subdivision > 1)
    {
        self.globals.subdivision--;
    }
    
}

-(void)updateBeatPerMeasureDisplay
{
    self.beatPerMeasureDisplay.text = [NSString stringWithFormat:@"%d", self.globals.beatPerMeasure];
}


-(void)updateNoteTypeDisplay
{
    NSNumber *n = [[NSNumber alloc]initWithFloat:1.0/self.globals.noteType ];
    self.noteTypeDisplay.text = [NSString stringWithFormat:@"%d",  n.intValue ];
}

-(void)updateSubdivisionDisplay
{

    NSNumber *n = [[NSNumber alloc]initWithFloat: 1 / (self.globals.noteType / self.globals.subdivision) ];
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
        NSLog(@"%@", self.globals.currentMeasure.description);
    }
    
    if([keyPath isEqualToString:@"beatInfo"])
    {
        NSLog(@"beatInfo : %@", self.globals.beatInfo.description);
    }
}

@end
