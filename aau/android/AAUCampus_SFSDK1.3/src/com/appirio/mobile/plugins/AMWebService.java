package com.appirio.mobile.plugins;

import org.apache.cordova.DroidGap;
import org.json.JSONArray;

import com.appirio.mobile.aau.nativemap.APIProxy;
import com.phonegap.api.Plugin;
import com.phonegap.api.PluginResult;

public class AMWebService extends Plugin {

	private APIProxy proxy;

	private APIProxy getProxy() {
		if(proxy == null && this.ctx != null) {
			proxy = new APIProxy((DroidGap)this.ctx);
		}
		
		return proxy;
	}
	
	public AMWebService() {
	}
	
	public PluginResult execute(String arg0, JSONArray arg1, String arg2, boolean retry) {
		try {
			String uri = arg1.get(0).toString();

			if (uri.equals("https://xmlgateway.teletrac.net/AsciiService.asmx/GetVehicles")) {
				return new PluginResult(PluginResult.Status.OK, getProxy().makeTeletracRequest(uri));
			} else {
				return new PluginResult(PluginResult.Status.OK, getProxy().makeSFRequest(uri, true, false));
			}
		} catch (Exception e) {
			e.printStackTrace();
			
			if(retry) {
				return execute(arg0, arg1, arg2, false);
			}

			return new PluginResult(PluginResult.Status.ERROR, e.getMessage());
		}
	}
	
	@Override
	public PluginResult execute(String arg0, JSONArray arg1, String arg2) {
		return execute(arg0, arg1, arg2, true);
	}

}
