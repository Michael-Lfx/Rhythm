package com.sensormusic.metronomecore;

import java.util.HashMap;

import android.content.Context;
import android.media.AudioManager;
import android.media.SoundPool;

import com.sensormusic.util.ContextUtil;

public class BTSoundEngine{
	
	private SoundPool _soundManager;
	private HashMap<String, Integer> _soundMap;
	private Context context;
	
	
	public BTSoundEngine(){
		
		context = ContextUtil.getInstance();
		
		_soundManager = new SoundPool(4, AudioManager.STREAM_MUSIC, 0);
		_soundMap = new HashMap<String, Integer>();
		
	}
	
	public void load(String key, int Rid){

		_soundMap.put(key, _soundManager.load(context, Rid, 1));
		;
	}
	
	public void play(String key){
		
		int soundId = _soundMap.get(key);
		
		_soundManager.play(soundId, 1, 1, 1, 0, 1);
		
		;
	}

}
