package com.appirio.mobile.aau.nativemap;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;

import com.appirio.mobile.aau.R;

public class NativeMapAcivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_native_map_acivity);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_native_map_acivity, menu);
		return true;
	}

}
