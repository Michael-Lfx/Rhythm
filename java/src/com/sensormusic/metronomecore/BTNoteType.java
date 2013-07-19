package com.sensormusic.metronomecore;

public enum BTNoteType {

	type1_4(0.25f), type1_8(0.125f), type1_16(0.0625f), type1_32(0.03125f);

	private float _typeNum;

	private BTNoteType(float num) {
		this._typeNum = num;
	}

	public float getTypeNum(){
		return this._typeNum;
	}

}
