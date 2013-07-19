package com.sensormusic.metronomecore;

public interface BTTimeToBeatTransmitterDelegate {

	public void onNoteHitHandler(BTBeat beat);
	
	public void onSubdivisionHitHandler(BTBeat beat);
	
}
