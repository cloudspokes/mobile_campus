package com.appirio.mobile;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import com.salesforce.androidsdk.ui.SalesforceDroidGapActivity;

public class AMSalesforceDroidGapActivity extends SalesforceDroidGapActivity {
	
	private boolean isConnected() {
	    boolean haveConnectedWifi = false;
	    boolean haveConnectedMobile = false;

	    ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
	    NetworkInfo[] netInfo = cm.getAllNetworkInfo();
	    for (NetworkInfo ni : netInfo) {
	        if (ni.getTypeName().equalsIgnoreCase("WIFI"))
	            if (ni.isConnected())
	                haveConnectedWifi = true;
	        if (ni.getTypeName().equalsIgnoreCase("MOBILE"))
	            if (ni.isConnected())
	                haveConnectedMobile = true;
	    }
	    return haveConnectedWifi || haveConnectedMobile;
	}
	
	@Override
	public void onResume() {
		if(!isConnected()) {
		  	AlertDialog.Builder adb = new AlertDialog.Builder(this);
		  	
		  	adb.setTitle("Error!");
		  	adb.setMessage("This device is not currently connected to the internet, please restart the application when a connection is available");
		  	
		  	new AlertDialog.Builder(this)
  		  	  .setTitle("Error")
   		  	  .setMessage("This device is not currently connected to the internet, please restart the application when a connection is available")
   		  	  .setNeutralButton("Ok", new DialogInterface.OnClickListener() {
   		  		  public void onClick(DialogInterface dialog,
   		  		    int which) {
   				  	endActivity();
   		  		  }
		  	}).show();
		  	
		} 
		super.onStart();
	}

}
