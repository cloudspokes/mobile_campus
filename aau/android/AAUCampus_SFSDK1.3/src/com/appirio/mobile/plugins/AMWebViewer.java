package com.appirio.mobile.plugins;

import org.json.JSONArray;
import org.json.JSONException;

import android.content.Intent;

import com.appirio.mobile.WebViewActivity;
import com.phonegap.api.Plugin;
import com.phonegap.api.PluginResult;

public class AMWebViewer extends Plugin {

	@Override
	public PluginResult execute(String action, JSONArray params, String arg2) {

		try {
			Intent i = new Intent(this.ctx.getContext(), WebViewActivity.class);
			i.putExtra("url", params.getString(0));
			
			ctx.getContext().startActivity(i);
		} catch (JSONException e) {
			e.printStackTrace();
		}

		return new PluginResult(PluginResult.Status.NO_RESULT);
	}

}
