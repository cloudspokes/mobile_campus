package com.appirio.mobile.plugins;

import org.apache.cordova.DroidGap;
import org.json.JSONArray;

import com.appirio.mobile.aau.nativemap.MapAPIProxy;
import com.phonegap.api.Plugin;
import com.phonegap.api.PluginResult;

public class AMWebService extends Plugin {

	private MapAPIProxy proxy;
	
	public AMWebService() {
		proxy = new MapAPIProxy((DroidGap)this.ctx);
	}
	
	@Override
	public PluginResult execute(String arg0, JSONArray arg1, String arg2) {
		try {


			String uri = arg1.get(0).toString();

			if (uri.equals("https://xmlgateway.teletrac.net/AsciiService.asmx/GetVehicles")) {
				return new PluginResult(PluginResult.Status.OK, proxy.makeTeletracRequest(uri));
			} else {
				return new PluginResult(PluginResult.Status.OK, proxy.makeSFRequest(uri, true));
			}
		} catch (Exception e) {
			e.printStackTrace();
			return new PluginResult(PluginResult.Status.ERROR, e.getMessage());
		}
	}

}
