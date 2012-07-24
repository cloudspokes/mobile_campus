package com.appirio.mobile.plugins;

import java.util.logging.Level;
import java.util.logging.Logger;

import org.json.JSONArray;

import com.phonegap.api.Plugin;
import com.phonegap.api.PluginResult;

public class RESTPlugin extends Plugin {

	@Override
	public PluginResult execute(String arg0, JSONArray arg1, String arg2) {
		Logger.getAnonymousLogger().log(Level.INFO, "Testing!");
		
		return new PluginResult(PluginResult.Status.NO_RESULT);
	}

}
