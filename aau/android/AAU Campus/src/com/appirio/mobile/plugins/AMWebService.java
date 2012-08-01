package com.appirio.mobile.plugins;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;

import org.json.JSONArray;

import com.phonegap.api.Plugin;
import com.phonegap.api.PluginResult;
import com.salesforce.androidsdk.app.ForceApp;
import com.salesforce.androidsdk.rest.ClientManager;
import com.salesforce.androidsdk.rest.RestClient;

public class AMWebService extends Plugin {

	@Override
	public PluginResult execute(String arg0, JSONArray arg1, String arg2) {
		try {
			
			ClientManager mgr = new ClientManager(this.ctx, ForceApp.APP.getAccountType(), null);
			
			RestClient cli = mgr.peekRestClient();
			
			URL url = new URL(arg1.get(0).toString());
	
			URLConnection conn = url.openConnection();
			
			conn.addRequestProperty("Authorization", "OAuth " + cli.getAuthToken());
			
			BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
			
			String line;
			
			StringBuilder body = new StringBuilder();
			
			while((line = reader.readLine()) != null) {
				body.append(line);
			}
			
			return new PluginResult(PluginResult.Status.OK, body.toString());
		} catch (Exception e) {
			e.printStackTrace();
			return new PluginResult(PluginResult.Status.ERROR, e.getMessage());
		} 
	}

}
