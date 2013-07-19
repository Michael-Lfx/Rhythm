package com.sensormusic.metronomecore;

public enum BTBeatType {

	BTBeatType_F(100), BTBeatType_P(101), BTBeatType_SUBDIVISION(102), BTBeatType_NIL(
			255);

	private int _typeNum;

	private BTBeatType(int num) {
		this._typeNum = num;
	}
	
	public int getTypeNum(){
		return this._typeNum;
	}
}
