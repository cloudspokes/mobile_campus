package com.appirio.mobile.plugins;

import org.apache.cordova.api.PluginResult;
import org.json.JSONArray;

import com.appirio.mobile.AMSalesforceDroidGapActivity;
import com.phonegap.api.Plugin;

public class ShowNativeMenuPlugin extends Plugin {

	@Override
	public PluginResult execute(String arg0, JSONArray arg1, String arg2) {
		AMSalesforceDroidGapActivity activity = ((AMSalesforceDroidGapActivity)this.ctx);
		
		if(arg0.equals("showMap")) {
			activity.showMap();
		} else if (arg0.equals("hideMap")) {
			activity.showWebView();
		}
		
		return new PluginResult(PluginResult.Status.NO_RESULT);
	}

}
