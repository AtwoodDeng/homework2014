package com.example.androidtest;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.UUID;

import android.support.v7.app.ActionBarActivity;
import android.support.v7.app.ActionBar;
import android.support.v4.app.Fragment;
import android.R.string;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.os.Build;

public class BlueToothTestActivity extends ActionBarActivity {

	Button btn_send;
	EditText editText;
	TextView textView;
	
//	String deviceName;
//	String deviceAddress;
	BluetoothDevice mDevice;
	BluetoothSocket mSocket;
	UUID uuid = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		System.out.println("on create");
		super.onCreate(savedInstanceState);
		setContentView(R.layout.blue_tooth_test);

		if (savedInstanceState == null) {
			getSupportFragmentManager().beginTransaction()
					.add(R.id.container, new PlaceholderFragment()).commit();
		}
		
	    //blind
		 textView = (TextView)findViewById(R.id.textViewBlue);
		 editText = (EditText)findViewById(R.id.editTextBlue);
		 btn_send = (Button)findViewById(R.id.buttonBlue);
		 
		 //get device name and address
		 Intent intent = getIntent();
		 //deviceName = intent.getStringExtra(MainActivity.BLUETOOTH_NAME);
		 //deviceAddress = intent.getStringExtra(MainActivity.BLUETOOTH_ADDRESS);
		 ArrayList<BluetoothDevice> arrayList = intent.getParcelableArrayListExtra(MainActivity.BLUETOOTH_DEVICE);
		 int index = intent.getIntExtra(MainActivity.BLUETOOTH_SELECT_INDEX, -1);
		 if ( index < 0 )
		 {
			 textView.setText("cannot find the device");
		 }else {
			mDevice = arrayList.get(index);
			 textView.setText("Device: " + mDevice.getName() + "--" + mDevice.getAddress() );
		}
		 
		 addMessage("====== Start Connect ======");
		 
		 setupConnection();
		
		 
	}
	
	public void addMessage( String msg )
	{
		textView.setText(textView.getText() + "\r\n"+ msg );
	}
	
	
	public void setupConnection()
	{
		try {
			mSocket = mDevice.createRfcommSocketToServiceRecord(uuid);  
		} catch (Exception e) {
			addMessage(e.toString());
		}
		try {
			mSocket.connect();
		} catch (Exception e) {
			addMessage(e.toString());
		}
		addMessage("[Connect]success!");
	}
	

	public void onSend(View view) {
		
		String msg = editText.getText().toString();
		addMessage("[SendMsg]"+msg);
		OutputStream outStream;
		try {
			outStream = mSocket.getOutputStream();
			outStream.write(msg.getBytes());
		} catch (IOException e) {
			addMessage(e.toString());
		}
		addMessage("[SendMsg]success!");
		InputStream inStream;
		try {
			inStream = mSocket.getInputStream();
			int i = 0 ;
			while ( i < 20 ) {
				Thread.sleep(50);
				if (inStream.available() > 0 )
				{
					byte[] inMsg = new byte[100];
					inStream.read(inMsg);
					addMessage(inMsg.toString());
					break;
				}
				i++;
			}
		} catch (Exception e) {
			addMessage(e.toString());
		}
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {

		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.blue_tooth_test, menu);
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
			View rootView = inflater.inflate(R.layout.fragment_blue_tooth_test,
					container, false);
			return rootView;
		}
	}

}
