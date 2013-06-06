//
//  BTConstants.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTConstants.h"

float const SWIPE_2_MOVE_TIMES = 1.2f;
float const THRESHOLD_2_COMPLETE = 0.3f;
float const THRESHOLD_2_COMPLETE_DURETION = 0.2f;

int const MAIN_VIEW_TAG = 11;
int const TEMPO_VIEW_TAG = 12;
int const COMMON_VIEW_TAG = 13;
int const NO_BAND_VIEW_TAG = 14;
int const PAGE_CONTROL_TAG = 1;
int const COMMON_BUTTON_TAG = 2;
int const BAND_BUTTON_TAG = 3;

float const BPM_CHANGE_INTERVAL = 0.2f;
float const BPM_CHANGE_INTERVAL_FASTER = 0.05f;
int const BPM_CHANGE_FASTER_COUNT = 5;

int const BPM_MIN = 5;
int const BPM_MAX = 5;

NSString* const BPM_PLUS = @"plus";
NSString* const BPM_MINUS = @"minus";

@implementation BTConstants

@end
