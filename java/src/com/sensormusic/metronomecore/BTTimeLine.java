package com.sensormusic.metronomecore;

import android.annotation.SuppressLint;
import android.os.Handler;
import android.os.Message;

@SuppressLint("HandlerLeak")
public class BTTimeLine extends Thread {

	private static float LOCK_TIME = 2;

	private boolean _isStop = true;

	private double _clockDuration;
	private double _clockStartTime = -1;
	private double _clockPreviousTickTime = -1;

	private Thread _thread;

	private BTTimeLineDelegate _timeLineDelegate;

	private int _clockTickCount = 0;

	/**
	 * 
	 * @param duration
	 * @return
	 */
	public double startLoopWithDuration(double duration) {

		if (!_isStop) {
			return _clockStartTime;
		}

		_isStop = false;
		_clockTickCount = 0;
		_clockDuration = duration;

		_thread = new Thread(looper);
		_thread.start();
		_thread.setPriority(10);

		_clockStartTime = getNowTime();

		return _clockStartTime;

	}

	/**
	 * 
	 * @return
	 */
	public double stopLoop() {

		_isStop = true;

		_clockStartTime = -1;
		_clockPreviousTickTime = -1;
		_thread.interrupt();
		_thread = null;

		return getNowTime();

	}

	/**
	 * 
	 * @param duration
	 */
	public void updateClockDuration(double duration) {
		_clockDuration = duration;
		_clockTickCount = 0;
		_clockStartTime = -1;
	}

	private Handler handler = new Handler() {

		@Override
		public void handleMessage(Message msg) {

			if (_timeLineDelegate != null) {
				_timeLineDelegate.onTimeInvokeHandler((Double) msg.obj);
			}
		}

	};

	private Runnable looper = new Runnable() {

		@Override
		public void run() {

			while (!_isStop) {

				_clockPreviousTickTime = getNowTime();

				if (_clockStartTime < 0) {
					_clockStartTime = _clockPreviousTickTime;
				}

				boolean _isLock = true;

				while (_isLock) {
					double _testTime = getNowTime();

					if (_testTime >= _clockStartTime + _clockDuration
							* _clockTickCount) {

						handler.obtainMessage(1, _testTime).sendToTarget();

						_isLock = false;
					} else {

					}
				}

				double _accurateClockDuration = Math
						.floor((_clockDuration + (_clockStartTime
								+ _clockDuration * _clockTickCount - _clockPreviousTickTime)) * 1.0e3) / 1.0e3;

				_clockTickCount++;

				try {
					Thread.sleep((long) (sToMS(_accurateClockDuration) - LOCK_TIME));
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}

		}
	};

	private double sToMS(double _accurateClockDuration) {
		return _accurateClockDuration * 1e3;
	}

	private double getNowTime() {
		return System.nanoTime() * 1e-9;
	}

	public BTTimeLineDelegate getTimeLineDelegate() {
		return _timeLineDelegate;
	}

	public void setTimeLineDelegate(BTTimeLineDelegate _timeLineDelegate) {
		this._timeLineDelegate = _timeLineDelegate;
	}

}
