package com.example.androidtest;

import android.support.v7.app.ActionBarActivity;
import android.support.v7.app.ActionBar;
import android.support.v4.app.Fragment;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.os.Build;

public class BlueToothTestActivity2 extends ActionBarActivity {

	static BlueToothTestActivity2 instance;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_blue_tooth_test_activity2);

		if (savedInstanceState == null) {
			getSupportFragmentManager().beginTransaction()
					.add(R.id.container, new PlaceholderFragment()).commit();
		}
	    // Get the message from the intent
	    Intent intent = getIntent();
	    String message = intent.getStringExtra(MainActivity.GO_MESSAGE);
	    
		
		// Create the text view
	    TextView textView = (TextView)findViewById(R.id.text_view_blue2);
	    if ( textView != null )
	    {
		    textView.setTextSize(40);
		    textView.setText(message);
	    }
	    
	    instance = this;
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {

		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.blue_tooth_test_activity2, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle action bar item clicks here. The action bar will
		// automatically handle clicks on the Home/Up button, so long
		// as you specify a parent activity in AndroidManifest.xml.
		int id = item.getItemId();
		if (id == R.id.action_settings) {
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

	/**
	 * A placeholder fragment containing a simple view.
	 */
	public static class PlaceholderFragment extends Fragment {

		public PlaceholderFragment() {
		}

		@Override
		public View onCreateView(LayoutInflater inflater, ViewGroup container,
				Bundle savedInstanceState) {
			View rootView = inflater.inflate(
					R.layout.fragment_blue_tooth_test_activity2, container,
					false);
//			// Get the message from the intent
//		    Intent intent = BlueToothTestActivity2.instance.getIntent();
//		    //String message = intent.getStringExtra(MainActivity.GO_MESSAGE);
//		    String message = "hi";
//			
//			// Create the text view
//		    TextView textView = (TextView)BlueToothTestActivity2.instance.findViewById(R.id.text_view_blue2);
//		    if ( textView != null )
//		    {
//			    textView.setTextSize(40);
//			    textView.setText(message);
//		    }
			return rootView;
		}
	}

}
