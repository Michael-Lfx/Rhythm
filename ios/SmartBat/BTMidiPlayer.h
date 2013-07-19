//
//  BTMidiPlayer.h
//  SmartBat
//
//  Created by poppy on 13-7-11.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "BTMidiSequence.h"
#import "BTMidiChannelEvent.h"
#import "BTMidiNote.h"
#import "BTMidiTempoEvent.h"
#import "BTMidiClock.h"
#import "BTMidiAudioManager.h"

@interface BTMidiPlayer : NSObject{
    
    BTMidiSequence * _candidateSequence;
    BTMidiSequence * _tempSequence;
    
    BTMidiAudioManager *_audioManager;
    
    BTMidiClock * _midiClock;
    Boolean _isIgnoreOriginalBPM;
    
    
    // Used to delete events which are no longer active
    NSMutableArray * _eventsToDelete;
    
}


//============Read/Write properties=============
//设置是否循环播放
@property(nonatomic) Boolean loop;

//设置bpm
@property(nonatomic) float BPM;


//============Read-only properties=============

//获取开始绝对时间，mach_time
@property(nonatomic, readonly) double startTime;

//获取逝去时间
@property(nonatomic, readonly) double timeElapsed;

//获取逝去的脉冲
@property(nonatomic, readonly) int pulsesElapsed;

//当前midi文件url
@property(nonatomic, readonly) NSURL * URL;

//当前midi文件的BPM
@property(nonatomic, readonly) float originalBPM;

//当前midi文件的ppqn
@property(nonatomic, readonly) int PPQN;


//============实例方法================

//预加载文件。不会干扰当前播放器状态。若播放器正在播放，需要调用play系列方法才能播放新的file。
-(void)loadFile:(NSString *)filename withExtension:(NSString *)extension ignoreOriginalBPM:(Boolean) isIgnoreOriginalBPM;

//在第timeElapsed时间开始播放，以startTime为起点
-(void)playAtTime:(double)timeElapsed;

//在第pulsesElapsed的位置开始播放，以startTime为起点
-(void)playAtPulse:(int)pulsesElapsed;

//暂停播放
-(void) pause;

//停止播放，同时复位
-(void) stop;


//============静态方法================

+(BTMidiPlayer *) sharedPlayer;


@end
