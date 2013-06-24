//
//  BTConstants.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>

//ip5处理时用到
#define IS_IP5 (([UIScreen mainScreen].applicationFrame.size.height == 548) ? YES : NO)
#define IP4_HEIGHT 460
#define IP5_Y_FIXED 40

//和appstoer相关的
#define CHECK_VERSION_DURATION 86400
#define APP_LOOKUP_URL @"http://itunes.apple.com/lookup?id=632827808"
#define ASK_GRADE_DURATION 86400*3

//动画效果参数
#define THRESHOLD_2_COMPLETE_DURETION 0.2f

//主要view的tag
#define MAIN_VIEW_TAG 11
#define TEMPO_VIEW_TAG  12
#define COMMON_VIEW_TAG  13
#define NO_BAND_VIEW_TAG  14
#define PAGE_CONTROL_TAG  1
#define COMMON_BUTTON_TAG  2
#define BAND_BUTTON_TAG  3
#define ROOT_BG_TAG  4

//连续设置bpm时的速度参数
#define BPM_CHANGE_INTERVAL  0.2f
#define BPM_CHANGE_INTERVAL_FASTER  0.02f
#define BPM_CHANGE_FASTER_COUNT  5

//bpm范围
#define BPM_MIN  30
#define BPM_MAX  220

//bpm调整指令
#define BPM_PLUS  @"plus"
#define BPM_MINUS  @"minus"

//noteType范围
#define NOTETYPE_MIN 0.03125f
#define NOTETYPE_MAX 0.5f

//蓝牙服务uuid
#define kCharacteristicsCount           8

#define kGapServiceUUID                 @"1800"

#define kMetronomeServiceUUID           @"2300"
#define kMetronomeNameUUID              @"2301"
#define kMetronomeShockUUID             @"2302"
#define kMetronomeSparkUUID             @"2303"

#define kMetronomePlayUUID              @"2311"
#define kMetronomeDurationUUID          @"2312"
#define kMetronomeMeasureUUID           @"2313"
#define kMetronomeIndexUUID             @"2314"

#define kBatteryServiceUUID             @"2400"
#define kBatteryLevelUUID               @"2401"

@interface BTConstants : NSObject

@end
