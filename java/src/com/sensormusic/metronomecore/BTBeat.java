package com.sensormusic.metronomecore;




public class BTBeat {

	public int indexOfMeasure;
	public int indexOfSubdivision;
	public double hitTime;
	public BTBeatType beatType;
	
	public BTBeat(BTBeatType beatType){
		this.beatType = beatType;
	}
	
}
