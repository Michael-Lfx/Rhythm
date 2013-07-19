package com.sensormusic.smartbat;

import java.util.ArrayList;
import java.util.HashMap;

public class BTGlobal {
	
	private static BTGlobal uniqueInstance = null;

	public static BTGlobal sharedGlobal() {
		if (uniqueInstance == null) {
			uniqueInstance = new BTGlobal();
		}
		return uniqueInstance;
	}
	
	private HashMap<String, Object> _valuePool;
	private HashMap<String, ArrayList<BTGlobalObserver>> _observerPool;
	
	public static String KEY_BPM = "bpm";
	public static String KEY_PLAY_STATUS = "play_status";
	
	
	public BTGlobal(){
		
		
		this._observerPool = new HashMap<String,ArrayList< BTGlobalObserver>>();
		this._valuePool = new HashMap<String, Object>();
		
		
		setValue(BTGlobal.KEY_BPM, 120f);
		
		//ÄÚºË¹¤×÷×´Ì¬£¬driven by BTMetronomeController
		setValue(BTGlobal.KEY_PLAY_STATUS, 0);
		
		
	}
	
	public void setValue(String key, Object value){
		
		Object oldValue = getValue(key);
		
		this._valuePool.put(key, value);
		
		ArrayList<BTGlobalObserver> observerList = this._observerPool.get(key);
		
		if(observerList != null){
			for( int n=0; n< observerList.size(); n++){
				BTGlobalObserver observer  = observerList.get(n);
				observer.onGlobalValueChange(key, value, oldValue);
			}
		}
		
	}
	
	public Object getValue(String key){
		
		Object value = this._valuePool.get(key);
		return value;
	}
	
	public void addObserver(String key, BTGlobalObserver observer){
		
		if(this._observerPool.get(key)==null){
			this._observerPool.put(key, new ArrayList<BTGlobalObserver>());
		}
		
		ArrayList<BTGlobalObserver> observerList = this._observerPool.get(key);
		observerList.add(observer);

	}
	

}