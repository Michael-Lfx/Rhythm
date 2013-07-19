package com.sensormusic.metronomecore;

import java.util.ArrayList;

import com.example.smartbat.R;
import com.sensormusic.smartbat.BTGlobal;
import com.sensormusic.smartbat.BTGlobalObserver;

public class BTMetronomeController implements BTTimeToBeatTransmitterDelegate , BTGlobalObserver{

	public static String KEY_SOUNDFILE_F = "default_f";
	public static String KEY_SOUNDFILE_P = "default_p";
	public static String KEY_SOUNDFILE_SUBDIVISION = "default_subdvision";
	


	private BTTimeToBeatTransmitter _transmitter;
	private BTSoundEngine _soundEngine;
	private BTGlobal _global;
	
	
	

	public static BTMeasure generateBasicMeasureTemplate(
			int noteCountPerMeasure, BTNoteType noteType) {

		ArrayList<BTBeat> tempList = new ArrayList<BTBeat>();

		tempList.add(new BTBeat(BTBeatType.BTBeatType_F));

		for (int n = 1; n < noteCountPerMeasure; n++) {
			tempList.add(new BTBeat(BTBeatType.BTBeatType_P));
		}

		BTMeasure measure = new BTMeasure();
		measure.init(tempList, noteType);

		return measure;

	}

	public static BTSubdivision generateBasicSubdivisionTemplate(
			int subdivisionCount) {

		ArrayList<BTBeat> tempList = new ArrayList<BTBeat>();

		for (int n = 0; n < subdivisionCount; n++) {
			tempList.add(new BTBeat(BTBeatType.BTBeatType_SUBDIVISION));
		}

		BTSubdivision subdivision = new BTSubdivision();
		subdivision.init(tempList);

		return subdivision;

	}

	private static BTMetronomeController uniqueInstance = null;

	public static BTMetronomeController sharedController() {
		if (uniqueInstance == null) {
			uniqueInstance = new BTMetronomeController();
		}
		return uniqueInstance;
	}

	private BTMetronomeController() {
		
		
		this._global = BTGlobal.sharedGlobal();
		this._global.addObserver(BTGlobal.KEY_BPM, this);
		
		
				
		this._soundEngine = new BTSoundEngine();
		this._soundEngine.load(KEY_SOUNDFILE_F, R.raw.default_f);
		this._soundEngine.load(KEY_SOUNDFILE_P, R.raw.default_p);
		this._soundEngine.load(KEY_SOUNDFILE_SUBDIVISION, R.raw.default_subdivision);
		

		this._transmitter = new BTTimeToBeatTransmitter();
		this._transmitter.bindTimeLine(new BTTimeLine());
		this._transmitter.setTransmitterDelegate(this);

		
		setMeasure(BTMetronomeController.generateBasicMeasureTemplate(4,
				BTNoteType.type1_4));
		setSubdivision(BTMetronomeController
				.generateBasicSubdivisionTemplate(2));
		setBPM(120.0f);
		
	}

	public void start() {
		this._transmitter.start();
		this._global.setValue(BTGlobal.KEY_PLAY_STATUS, 1);
	}

	public void stop() {
		this._transmitter.stop();
		this._global.setValue(BTGlobal.KEY_PLAY_STATUS, 0);
	}

	public void setBPM(float BPM) {
		this._transmitter.updateBPM(BPM);
	}

	public void setMeasure(BTMeasure measureTemplate) {

		this._transmitter.updateMeasureTemplate(measureTemplate);

	}

	public void setSubdivision(BTSubdivision subdivisionTemplate) {

		this._transmitter.updateSubdivisionTemplate(subdivisionTemplate);

	}

	public void onNoteHitHandler(BTBeat beat) {

//		System.out.println(beat.beatType.getTypeNum() + ":" + beat.hitTime);
		
		switch(beat.beatType){
		
			case BTBeatType_F:
				_soundEngine.play(KEY_SOUNDFILE_F);
				break;
			case BTBeatType_P:
				_soundEngine.play(KEY_SOUNDFILE_P);
				break;
			default:
				
				break;
		}

	}

	public void onSubdivisionHitHandler(BTBeat beat) {

//		System.out.println(beat.beatType.getTypeNum() + ":" + beat.hitTime);
		
		_soundEngine.play(KEY_SOUNDFILE_SUBDIVISION);

	}
	
	public void onGlobalValueChange(String key, Object newValue, Object oldValue){
		
		if(key == BTGlobal.KEY_BPM){
			
			setBPM((Float)newValue);
			
		}
		
	}

}
