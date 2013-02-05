package com.appirio.mobile.plugins;

import org.json.JSONArray;

import android.app.Activity;

import com.phonegap.api.Plugin;
import com.phonegap.api.PluginResult;

public class AMCloseActivity extends Plugin {

	@Override
	public PluginResult execute(String arg0, JSONArray arg1, String arg2) {
		((Activity)this.ctx).finish();
		
		return new PluginResult(PluginResult.Status.NO_RESULT);
	}

}
