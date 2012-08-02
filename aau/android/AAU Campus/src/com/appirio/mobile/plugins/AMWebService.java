package com.appirio.mobile.plugins;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;

import org.json.JSONArray;
import org.json.JSONObject;

import com.phonegap.api.Plugin;
import com.phonegap.api.PluginResult;
import com.salesforce.androidsdk.app.ForceApp;
import com.salesforce.androidsdk.rest.ClientManager;
import com.salesforce.androidsdk.rest.RestClient;

public class AMWebService extends Plugin {
	
	private static String teletracQueryString = null;
	private static final String TELETRAC_INFO_ENDPOINT = "/services/apexrest/teletracInfo/"; 

	private String doGet(String uri, String authToken) throws IOException {
		String line = null;
		
		URL url = new URL(uri);

		URLConnection conn = url.openConnection();
		conn.addRequestProperty("Authorization", "OAuth " + authToken);
		
		StringBuilder responseBody = new StringBuilder();
		
		BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
		
		while((line = reader.readLine()) != null) {
			responseBody.append(line);
		}
		
		return responseBody.toString();
		
	}
	
	@Override
	public PluginResult execute(String arg0, JSONArray arg1, String arg2) {
		try {
			
			ClientManager mgr = new ClientManager(this.ctx, ForceApp.APP.getAccountType(), null);
			RestClient cli = mgr.peekRestClient();
			
			String uri = arg1.get(0).toString();

			if(uri.equals("https://xmlgateway.teletrac.net/AsciiService.asmx/GetVehicles")) {
				if(teletracQueryString == null) {
					String teletracResponse = doGet(cli.getClientInfo().instanceUrl + TELETRAC_INFO_ENDPOINT, cli.getAuthToken());
					JSONObject teletracInfo = new JSONObject(teletracResponse);
					
					teletracQueryString = String.format("?strAccountId=%s&strUserName=%s&strPwd=%s", teletracInfo.getString("Account"), 
							teletracInfo.getString("Username"), teletracInfo.getString("Password"));
				}
				
				uri += teletracQueryString;
			}
			

			return new PluginResult(PluginResult.Status.OK, doGet(uri, cli.getAuthToken()));
		} catch (Exception e) {
			e.printStackTrace();
			return new PluginResult(PluginResult.Status.ERROR, e.getMessage());
		} 
	}

}
