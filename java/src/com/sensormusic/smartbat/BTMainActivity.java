package com.sensormusic.smartbat;

import android.annotation.TargetApi;
import android.app.ActionBar;
import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ToggleButton;

import com.example.smartbat.R;
import com.sensormusic.metronomecore.BTMetronomeController;

public class BTMainActivity extends FragmentActivity implements
		ActionBar.OnNavigationListener{

	/**
	 * The serialization (saved instance state) Bundle key representing the
	 * current dropdown position.
	 */
	private static final String STATE_SELECTED_NAVIGATION_ITEM = "selected_navigation_item";

	private BTMetronomeController _metronomeController;
	private BTGlobal _global;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		// Set up the action bar to show a dropdown list.
		final ActionBar actionBar = getActionBar();
		actionBar.setDisplayShowTitleEnabled(false);
		actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_LIST);

		// Set up the dropdown list navigation in the action bar.
		actionBar.setListNavigationCallbacks(
		// Specify a SpinnerAdapter to populate the dropdown list.
				new ArrayAdapter<String>(getActionBarThemedContextCompat(),
						android.R.layout.simple_list_item_1,
						android.R.id.text1, new String[] {
								getString(R.string.title_section1),
								getString(R.string.title_section2),
								getString(R.string.title_section3), }), this);

		System.out.println("start!!");
		
		
		this._global = BTGlobal.sharedGlobal();

		this._metronomeController = BTMetronomeController.sharedController();
		this._metronomeController.setBPM((Float)this._global.getValue(BTGlobal.KEY_BPM));
	}

	/**
	 * Backward-compatible version of {@link ActionBar#getThemedContext()} that
	 * simply returns the {@link android.app.Activity} if
	 * <code>getThemedContext</code> is unavailable.
	 */
	@TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
	private Context getActionBarThemedContextCompat() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
			return getActionBar().getThemedContext();
		} else {
			return this;
		}
	}

	@Override
	public void onRestoreInstanceState(Bundle savedInstanceState) {
		// Restore the previously serialized current dropdown position.
		if (savedInstanceState.containsKey(STATE_SELECTED_NAVIGATION_ITEM)) {
			getActionBar().setSelectedNavigationItem(
					savedInstanceState.getInt(STATE_SELECTED_NAVIGATION_ITEM));
		}
	}

	@Override
	public void onSaveInstanceState(Bundle outState) {
		// Serialize the current dropdown position.
		outState.putInt(STATE_SELECTED_NAVIGATION_ITEM, getActionBar()
				.getSelectedNavigationIndex());
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	@Override
	public boolean onNavigationItemSelected(int position, long id) {
		// When the given dropdown item is selected, show its contents in the
		// container view.
		Fragment fragment = new DummySectionFragment();
		Bundle args = new Bundle();
		args.putInt(DummySectionFragment.ARG_SECTION_NUMBER, position + 1);
		fragment.setArguments(args);
		getSupportFragmentManager().beginTransaction()
				.replace(R.id.container, fragment).commit();
		return true;
	}

	/**
	 * A dummy fragment representing a section of the app, but that simply
	 * displays dummy text.
	 */
	public static class DummySectionFragment extends Fragment implements BTGlobalObserver {
		/**
		 * The fragment argument representing the section number for this
		 * fragment.
		 */
		public static final String ARG_SECTION_NUMBER = "section_number";
		final BTMetronomeController metronomeController = BTMetronomeController
				.sharedController();
		final BTGlobal global = BTGlobal.sharedGlobal();

		public DummySectionFragment() {
			global.addObserver(BTGlobal.KEY_PLAY_STATUS, this);
		}

		
		public void updateBPMDisplay(View view){
			EditText bpmText = (EditText) view;
			bpmText.setText((Float)global.getValue(BTGlobal.KEY_BPM) + "");
		}
		
		public void onGlobalValueChange(String key, Object newValue, Object oldValue){

			
			if(key == BTGlobal.KEY_PLAY_STATUS){
				
				int status =(Integer) global.getValue(BTGlobal.KEY_PLAY_STATUS);
				View rootView = this.getView();
				ToggleButton playButton = (ToggleButton) rootView
						.findViewById(R.id.button_play);
				
				
				if(status == 1){
					
					playButton.setChecked(true);
					
				}else{
					
					playButton.setChecked(false);
					
				}
				
			}
			
		}
		
		@Override
		public View onCreateView(LayoutInflater inflater, ViewGroup container,
				Bundle savedInstanceState) {

			View rootView = inflater.inflate(R.layout.fragment_main_dummy,
					container, false);

			final EditText bpmText = (EditText) rootView
					.findViewById(R.id.editText_bpm);
			bpmText.setText((Float)global.getValue(BTGlobal.KEY_BPM) + "");
			bpmText.setOnFocusChangeListener(new View.OnFocusChangeListener() {

				@Override
				public void onFocusChange(View v, boolean hasFocus) {

					if (!hasFocus) {
						EditText bpmText = (EditText) v;
						
						float bpm = Float.parseFloat(bpmText.getText()
								.toString());

						global.setValue(BTGlobal.KEY_BPM, bpm);

						System.out.println("set bpm to " + bpm);
					}

				}
			});

			final ToggleButton playButton = (ToggleButton) rootView
					.findViewById(R.id.button_play);

			playButton.setOnClickListener(new View.OnClickListener() {

				@Override
				public void onClick(View view) {
					
					int playStatus = (Integer)global.getValue(BTGlobal.KEY_PLAY_STATUS);

					if (playStatus == 0) {

						metronomeController.start();

					} else {

						metronomeController.stop();
					}

				}
			});

			final Button decreaseButton = (Button) rootView
					.findViewById(R.id.button_decrease);

			decreaseButton.setOnClickListener(new View.OnClickListener() {

				@Override
				public void onClick(View view) {

					float bpm = (Float)global.getValue(BTGlobal.KEY_BPM);
					global.setValue(BTGlobal.KEY_BPM, bpm-1);
					updateBPMDisplay(bpmText);
					
				}
			});
			
			decreaseButton.setOnLongClickListener(new View.OnLongClickListener() {
				
				@Override
				public boolean onLongClick(View v) {
					// TODO Auto-generated method stub
					float bpm = (Float)global.getValue(BTGlobal.KEY_BPM);
					global.setValue(BTGlobal.KEY_BPM, bpm-10);
					updateBPMDisplay(bpmText);
					
					return true;
				}
			});
			
			
			
			final Button increaseButton = (Button) rootView
					.findViewById(R.id.button_increase);

			increaseButton.setOnClickListener(new View.OnClickListener() {

				@Override
				public void onClick(View view) {

					float bpm = (Float)global.getValue(BTGlobal.KEY_BPM);
					global.setValue(BTGlobal.KEY_BPM, bpm+1);
					updateBPMDisplay(bpmText);
					
				}
			});
			
			increaseButton.setOnLongClickListener(new View.OnLongClickListener() {
				
				@Override
				public boolean onLongClick(View v) {
					// TODO Auto-generated method stub
					float bpm = (Float)global.getValue(BTGlobal.KEY_BPM);
					global.setValue(BTGlobal.KEY_BPM, bpm+10);
					updateBPMDisplay(bpmText);
					
					return true;
				}
			});


			return rootView;
		}
	}

}
