package com.sensormusic.metronomecore;

import java.util.ArrayList;

public class BTSubdivision {

	public int playIndex;

	private ArrayList<BTBeat> _noteList;

	public void init(ArrayList<BTBeat> beatDescription) {

		this._noteList = beatDescription;
		this.playIndex = 0;
	}

	public BTBeat getCurrentNote() {
		BTBeat beat = this._noteList.get(this.playIndex);
		return beat;
	}

	public void playNote() {

	    if(this.playIndex == count()-1){
	        
	        this.playIndex = 0;
	    }
	    else
	    {
	        this.playIndex ++;
	    }
	}
	
	public void reset(){
		this.playIndex = 0;
	}
	
	public int count(){
		return this._noteList.size();
	}
}
