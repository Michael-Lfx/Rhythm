package com.sensormusic.metronomecore;



public class BTTimeToBeatTransmitter implements BTTimeLineDelegate {

	private double _noteDuration;
	private float _BPM = -1;

	private BTMeasure _measureTemplate;
	private BTSubdivision _subdivisionTemplate;

	private BTTimeLine _timeLine;
	private BTTimeToBeatTransmitterDelegate _transmitterDelegate;

	public BTTimeToBeatTransmitter() {
		
	}

	/**
	 * implement BTTimeLineDelegate
	 */
	public void onTimeInvokeHandler(double time) {

		switch (this._subdivisionTemplate.playIndex) {		
		case 0:
			
			BTBeat beat = this._measureTemplate.getCurrentNote();
			beat.indexOfMeasure = this._measureTemplate.playIndex;
			beat.indexOfSubdivision = this._subdivisionTemplate.playIndex;
			beat.hitTime = time;
			
			if(this._transmitterDelegate!= null){
				this._transmitterDelegate.onNoteHitHandler(beat);
			}
			
			
//			System.out.printf("%d @ %f\n",beat.beatType.getTypeNum(), time);
			this._measureTemplate.playNote();
			this._subdivisionTemplate.playNote();
			break;
			
		default:
			
			BTBeat subdivisionBeat = this._subdivisionTemplate.getCurrentNote();
			subdivisionBeat.indexOfMeasure = this._measureTemplate.playIndex;
			subdivisionBeat.indexOfSubdivision = this._subdivisionTemplate.playIndex;
			subdivisionBeat.hitTime = time;
			
			if(this._transmitterDelegate!= null){
				this._transmitterDelegate.onSubdivisionHitHandler(subdivisionBeat);
			}
			
//			System.out.printf("%d @ %f [s]\n",subdivisionBeat.beatType.getTypeNum(), time);
			this._subdivisionTemplate.playNote();
			break;
		}

	}

	
	
	public void updateBPM(float BPM) {

		this._BPM = BPM;

		this._noteDuration = calculateNoteDuration(this._BPM,
				this._measureTemplate.noteType, this._subdivisionTemplate);

		updateClockDuration();
	}

	
	
	public void updateMeasureTemplate(BTMeasure measureTemplate) {

		

		this._noteDuration = calculateNoteDuration(this._BPM,
				measureTemplate.noteType, this._subdivisionTemplate);
		
		this._measureTemplate = measureTemplate;

		updateClockDuration();
	}

	
	
	public void updateSubdivisionTemplate(BTSubdivision subdivisionTemplate) {
		
		

		this._noteDuration = calculateNoteDuration(this._BPM,
				this._measureTemplate.noteType, subdivisionTemplate);
		
		this._subdivisionTemplate = subdivisionTemplate;

		updateClockDuration();
	}
	

	public void bindTimeLine(BTTimeLine timeLine) {

		this._timeLine = timeLine;
		this._timeLine.setTimeLineDelegate(this);

	}

	public double start(float BPM, BTMeasure measureTemplate,
			BTSubdivision subdivisionTemplate) {

		this._BPM = BPM;
		this._subdivisionTemplate = subdivisionTemplate;
		this._noteDuration = calculateNoteDuration(BPM,
				measureTemplate.noteType, subdivisionTemplate);
		this._measureTemplate = measureTemplate;

		if (this._timeLine != null) {

			updateClockDuration();
			return this._timeLine.startLoopWithDuration(this._noteDuration);
		}

		return -1;
	}

	public double start() {
		
	    if(this._timeLine!= null)
	    {
	        return this._timeLine.startLoopWithDuration(this._noteDuration);
	    }
	    return -1;
	}

	public double stop() {
		
		if(this._timeLine != null){
			this._measureTemplate.reset();
			this._subdivisionTemplate.reset();
			return this._timeLine.stopLoop();
		}
		
		return -1;
		
	}

	private double calculateNoteDuration(float BPM, BTNoteType noteType,
			BTSubdivision subdivisionTemplate) {
		
		if(BPM == -1 || noteType == null || subdivisionTemplate == null){
			return -1;
		}
		
	    double duration = 60.0/(BPM/( noteType.getTypeNum() *4) * subdivisionTemplate.count());
	    return duration;
	    
	}

	private void updateClockDuration()  {

		if(this._noteDuration < 0){
			
			return ;

		}
		this._timeLine.updateClockDuration(this._noteDuration);

	}


	public BTTimeToBeatTransmitterDelegate getTransmitterDelegate() {
		return _transmitterDelegate;
	}


	public void setTransmitterDelegate(BTTimeToBeatTransmitterDelegate _transmitterDelegate) {
		this._transmitterDelegate = _transmitterDelegate;
	}
}
