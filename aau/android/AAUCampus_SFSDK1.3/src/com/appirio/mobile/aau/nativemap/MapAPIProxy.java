package com.appirio.mobile.aau.nativemap;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;

import org.apache.cordova.DroidGap;
import org.json.JSONArray;

import com.salesforce.androidsdk.app.ForceApp;
import com.salesforce.androidsdk.rest.ClientManager;
import com.salesforce.androidsdk.rest.RestClient;

public class MapAPIProxy {
	
	private DroidGap ctx;
	
	public MapAPIProxy(DroidGap ctx) {
		this.ctx = ctx;
	}
	
	private String makeSFRequest(String uri) throws AMException {
		try {
			ClientManager mgr = new ClientManager(this.ctx.getContext(), ForceApp.APP.getAccountType(), null);
			RestClient cli = mgr.peekRestClient();
			
			String line = null;
			
			URL url = new URL(cli.getClientInfo().instanceUrl + uri);

			URLConnection conn = url.openConnection();
			conn.addRequestProperty("Authorization", "OAuth " + cli.getAuthToken());
			
			StringBuilder responseBody = new StringBuilder();
			
			BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
			
			while((line = reader.readLine()) != null) {
				responseBody.append(line);
			}
			
			return responseBody.toString();
			
		} catch (Exception e) {
			e.printStackTrace();
			
			throw new AMException(e);
		}

	}
	
	public JSONArray getBusStops() throws AMException {
		try {
			return new JSONArray(makeSFRequest("/services/apexrest/BusStops/"));
		} catch (Exception e) {
			e.printStackTrace();
			
			throw new AMException(e);
		}
	}
}
