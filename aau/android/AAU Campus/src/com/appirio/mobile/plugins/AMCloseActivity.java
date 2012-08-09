package com.appirio.mobile.plugins;

import org.json.JSONArray;

import com.phonegap.api.Plugin;
import com.phonegap.api.PluginResult;

public class AMCloseActivity extends Plugin {

	@Override
	public PluginResult execute(String arg0, JSONArray arg1, String arg2) {
		this.ctx.finish();
		
		return new PluginResult(PluginResult.Status.NO_RESULT);
	}

}
