package com.example.androidtest;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Set;

import android.support.v7.app.ActionBarActivity;
import android.support.v7.app.ActionBar;
import android.support.v4.app.Fragment;
import android.R.string;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothClass.Device;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.os.Build;

public class MainActivity extends ActionBarActivity {
	
	private static final int REQUEST_ENABLE_BT = 2;  
    TextView txt;  
    TextView txt_see;  
    TextView txt_scan;  
    BluetoothAdapter mBluetoothAdapter;  
    ArrayAdapter mArrayAdapter;  
    Button btn_switch;  
    Button btn_see;  
    Button btn_scan;  
    ListView list;  
    CountDownTimer see_timer;  
    CountDownTimer scan_timer; 
    //Set<BluetoothDevice> pairedDevices;
	ArrayList<BluetoothDevice> bluetoothArray = new ArrayList<>();
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		if (savedInstanceState == null) {
			getSupportFragmentManager().beginTransaction()
					.add(R.id.container, new PlaceholderFragment()).commit();
		}
		
        txt = (TextView)findViewById(R.id.textView1); 
        txt.setText("__TextView1__");
        txt_see = (TextView)findViewById(R.id.textView2);
        txt_see.setText("__TextView2__");  
        txt_scan = (TextView)findViewById(R.id.textView3);
        txt_scan.setText("__TextView3__");  
        list = (ListView) findViewById(R.id.listView1);    
        
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        mArrayAdapter = new ArrayAdapter(this, android.R.layout.simple_expandable_list_item_1);
        if ( mBluetoothAdapter ==null )
        {
        	txt.setText("fail");
        	MainActivity.this.finish();
        	return;
        }
        
        //blind buttons
        btn_switch = (Button)findViewById(R.id.button1);  
        btn_switch.setEnabled(true);
        btn_see = (Button)findViewById(R.id.button2);  
        btn_see.setEnabled(false);     
        btn_scan = (Button)findViewById(R.id.button3);  
        btn_scan.setText("扫描:OFF");  
        btn_scan.setEnabled(false); 
        
        //list view
        list.setOnItemClickListener(new OnItemClickListener() {
        	
        	@Override
        	public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
        			long arg3)
        	{
        		txt.setText("the " + arg2 + " device is " + bluetoothArray.get(arg2).getName()
        				+ " " + bluetoothArray.get(arg2).getAddress());
        		goToBluetoothDevice(arg2);
        		
        	}
		});
        
        //judge if the blue tooth is on
        if (mBluetoothAdapter.isEnabled())
        {
        	btn_switch.setText("ON");
        	btn_see.setEnabled(true);
        	btn_scan.setEnabled(true);
        }
        
        //timer
        see_timer = new CountDownTimer(12000,1000)  
        {  
            @Override  
            public void onTick( long millisUntilFinished)   
            {  
                txt_see.setText( "剩余可见时间" + millisUntilFinished / 1000 + "秒");  
            }            
            @Override  
            public void onFinish()   
            {  
                //判断蓝牙是否已经被打开   
                if (mBluetoothAdapter.isEnabled())  
                {  
                    btn_see.setEnabled(true);  
                    txt_see.setText( "设备不可见");  
                }  
            }  
        };  
        
        scan_timer = new CountDownTimer(12000,1000)   
        {  
            @Override  
            public void onTick( long millisUntilFinished)   
            {  
                txt_scan.setText( "剩余扫描时间" + millisUntilFinished/1000 + "秒");  
            }

			@Override
			public void onFinish() {
				// TODO Auto-generated method stub
				//判断蓝牙是否已经被打开   
                if (mBluetoothAdapter.isEnabled())  
                {  
                    btn_scan.setEnabled(true);  
                    //关闭扫描   
                    mBluetoothAdapter.cancelDiscovery();  
                    btn_scan.setText("扫描:OFF");  
                    txt_scan.setText( "停止扫描");  
                }   
			}
        };
            
	}
	
	public static String BLUETOOTH_NAME = "BLUETOOTH_NAME";
	public static String BLUETOOTH_ADDRESS = "BLUETOOTH_ADDRESS";
	public static String BLUETOOTH_DEVICE = "BLUETOOTH_DEVICE";
	public static String BLUETOOTH_SELECT_INDEX = "BLUETOOTH_SELECT_INDEX";
	public void goToBluetoothDevice( int index )
	{
		Intent intent = new Intent( this , BlueToothTestActivity.class );
//		Bundle bundle = new Bundle();
//		bundle.putString(BLUETOOTH_NAME, device.getName());
//		bundle.putString(BLUETOOTH_ADDRESS, device.getAddress());
//		intent.putExtras(bundle);
		intent.putParcelableArrayListExtra(BLUETOOTH_DEVICE, bluetoothArray);
		intent.putExtra(BLUETOOTH_SELECT_INDEX, index);
		startActivity(intent);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {

		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
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
			View rootView = inflater.inflate(R.layout.fragment_main, container,
					false);
			return rootView;
		}
	}
	public final static String GO_MESSAGE = "com.example.androidtest.MESSAGE";
	public final static String MESSAGE = "go";
	
	
	public void onButton1(View view){
		String str = btn_switch.getText().toString();
		if ( "OFF".equals(str))
		{
			if ( !mBluetoothAdapter.isEnabled())
			{
				Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
				startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
				txt.setText("s1");
				btn_see.setEnabled(true);
				btn_scan.setText("扫描:OFF");
				btn_scan.setEnabled(true);
			}
		}else {

            //关闭蓝牙   
            mBluetoothAdapter.disable();  
            btn_switch.setText("OFF");  
            mArrayAdapter.clear();  
            list.setAdapter(mArrayAdapter);  
            btn_see.setEnabled(false);    
            btn_scan.setEnabled(false);   
		}
		
	}
	
	public void onButton2(View view){

        //开启可见   
        Intent enableBtIntent_See = new Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE);  
        startActivityForResult(enableBtIntent_See, 3);  
        txt.setText("s1");  
        btn_see.setEnabled(false);   
        see_timer.start();   
	}
	public void onButton3(View view){
		 String str = btn_scan.getText().toString();  
         if (str == "扫描:OFF")  
         {  
             txt.setText("s5");  
             if (mBluetoothAdapter.isEnabled())   
             {  
                 //开始扫描   
                 mBluetoothAdapter.startDiscovery();  
                 txt.setText("s6");  
                 btn_scan.setText("扫描:ON");  
                   
                 // Create a BroadcastReceiver for ACTION_FOUND   
                 final BroadcastReceiver mReceiver = new BroadcastReceiver()   
                 {  
                     @Override  
                     public void onReceive(Context context, Intent intent)   
                     {  
                         // TODO Auto-generated method stub   
                         String action = intent.getAction();  
                         // When discovery finds a device   
                         mArrayAdapter.clear();  
                         if (BluetoothDevice.ACTION_FOUND.equals(action))   
                         {  
                             // Get the BluetoothDevice object from the Intent   
                             BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);  
                             // Add the name and address to an array adapter to show in a ListView   
                             mArrayAdapter.add(device.getName() + ":" + device.getAddress());  
                         }  
                         list.setAdapter(mArrayAdapter);  
                     }  
                 };  
                 // Register the BroadcastReceiver   
                 IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);  
                 registerReceiver(mReceiver, filter); // Don't forget to unregister during onDestroy   
                   
                 scan_timer.start();  
             }  
         }  
         else  
         {  
             //关闭扫描   
             mBluetoothAdapter.cancelDiscovery();  
             btn_scan.setText("扫描:OFF");  
             scan_timer.cancel();  
             txt_scan.setText( "停止扫描");  
         }   
	}
	
	public void onActivityResult(int requestCode, int resultCode, Intent data)   
    {    
		
        switch (requestCode)   
        {    
        case REQUEST_ENABLE_BT:    
            // When the request to enable Bluetooth returns     
            if (resultCode == Activity.RESULT_OK)   
            {    
                // Bluetooth is now enabled, so set up a chat session     
                btn_switch.setText("ON");  
                txt.setText("s4");  
                  
                //获取蓝牙列表   
                Set<BluetoothDevice> pairedDevices = mBluetoothAdapter.getBondedDevices();  
                mArrayAdapter.clear();  
                // If there are paired devices   
                if (pairedDevices.size() > 0)   
                { 
                	
                	txt.setText("s3");   
                      
                    // Loop through paired devices   
                    for (BluetoothDevice device : pairedDevices)   
                    {  
                        // Add the name and address to an array adapter to show in a ListView   
                        mArrayAdapter.add(device.getName() + ":" + device.getAddress());  
                        bluetoothArray.add(device);
                    }  
                    list.setAdapter(mArrayAdapter);  
                 }  
            } else   
            {    
                finish();    
            }    
        }    
    }     
	

}
