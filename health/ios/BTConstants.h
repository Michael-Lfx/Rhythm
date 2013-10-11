//
//  BTConstants.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

//ip5处理时用到
#define IS_IP5                          (([UIScreen mainScreen].applicationFrame.size.height == 548) ? YES : NO)
#define IP4_HEIGHT                      460
#define IP5_Y_FIXED                     40

//和appstoer相关的
#define CHECK_VERSION_DURATION          86400
#define APP_LOOKUP_URL                  @"http://itunes.apple.com/lookup?id=632827808"
#define ASK_GRADE_DURATION              86400*3

//动画效果参数
#define THRESHOLD_2_COMPLETE_DURETION   0.2f

//主要view的tag
#define NEWS_VIEW_TAG                   10
#define MAIN_VIEW_TAG                   11
#define TEMPO_VIEW_TAG                  12
#define COMMON_VIEW_TAG                 13
#define BAND_VIEW_TAG                   14
#define SETUP_VIEW_TAG                  15
#define PAGE_CONTROL_TAG                1
#define COMMON_BUTTON_TAG               2
#define BAND_BUTTON_TAG                 3
#define ROOT_BG_TAG                     4

//设备列表tag
#define BAND_NAME_TAG                   1
#define BATTERY_LEVEL_TAG               2

//设置页tag
#define SPARK_SETTING_LABEL_TAG         20
#define SPARK_SETTING_SWITCH_TAG        21
#define SHOCK_SETTING_LABEL_TAG         10
#define SHOCK_SETTING_SWITCH_TAG        11

//设备列表数组里索引
#define IS_CONNECTED_INDEX              0
#define BAND_NAME_INDEX                 1
#define BATTERY_LEVEL_INDEX             2

//连续设置bpm时的速度参数
#define BPM_CHANGE_INTERVAL             0.2f
#define BPM_CHANGE_INTERVAL_FASTER      0.02f
#define BPM_CHANGE_FASTER_COUNT         5

//bpm范围
#define BPM_MIN                         30
#define BPM_MAX                         220

//bpm调整指令
#define BPM_PLUS                        @"plus"
#define BPM_MINUS                       @"minus"

//noteType范围
#define NOTETYPE_MIN                    0.03125f
#define NOTETYPE_MAX                    0.5f

//蓝牙服务uuid
#define CHARACTERISTICS_COUNT          5

#define UUID_HEALTH_SERVICE             @"2300"

#define UUID_HEALTH_SYNC                @"2301"
#define UUID_HEALTH_CLOCK               @"2302"
#define UUID_HEALTH_DATA_HEADER         @"2303"
#define UUID_HEALTH_DATA_BODY           @"2304"

#define UUID_BATTERY_LEVEL              @"2A19"

//手环名称最大字节数
#define DEVICE_NAME_MAX_LENGTH          16

//蓝牙延时传输间隔
#define BLUETOOTH_DELAY                 0.5

//手环同步设置

#define APP_SOUND_LATENCY               0.030f
#define SYNC_INTERVAL                   0.067
#define SYNC_COUNT                      12

//同步间隔
#define SYNC_AGAIN                      120.0

//定时器锁常量
#define DEFAULT_INTERVAL                0.01
#define LOCK_TIME                       0.002

