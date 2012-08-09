package com.appirio.mobile.aau;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;

import com.appirio.aau.R;
import com.appirio.mobile.AMSalesforceDroidGapActivity;
import com.salesforce.androidsdk.app.ForceApp;
import com.salesforce.androidsdk.ui.LoginActivity;
import com.salesforce.androidsdk.ui.SalesforceR;
import com.salesforce.samples.vfconnector.SalesforceRImpl;

public class AAUCampusApp extends ForceApp {

	@Override
	public void onCreate() {
		super.onCreate();
		
		SharedPreferences settings = getSharedPreferences(
				LoginActivity.SERVER_URL_PREFS_SETTINGS,
				Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = settings.edit();
		editor.putString(LoginActivity.SERVER_URL_CURRENT_SELECTION,
		  getString(R.string.sf_default_url));

		editor.commit();		
	}
	
	private SalesforceR salesforceR = new SalesforceRImpl();
	
	@Override
	public Class<? extends Activity> getMainActivityClass() {
		return AMSalesforceDroidGapActivity.class;
	}
	
	@Override
	protected String getKey(String name) {
		return null; 
	}

	@Override
	public SalesforceR getSalesforceR() {
		return salesforceR;
	}
}
