package com.appirio.mobile.aau.nativemap;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import org.apache.cordova.DroidGap;
import org.json.JSONArray;
import org.json.JSONObject;

import com.salesforce.androidsdk.app.ForceApp;
import com.salesforce.androidsdk.rest.ClientManager;
import com.salesforce.androidsdk.rest.ClientManager.AccountInfoNotFoundException;
import com.salesforce.androidsdk.rest.RestClient;

public class MapAPIProxy {
	
	private DroidGap ctx;
	private static String authToken = null;
	private static String instanceUrl = null;
	private static String clientId = null;
	private static String refreshToken = null;
	private static String teletracQueryString = null;
	private static final String TELETRAC_INFO_ENDPOINT = "/services/apexrest/teletracInfo/";
	
	private String getTeletracQueryString() throws AMException {
		try {
			ensureToken();

			if(teletracQueryString == null) {
				String teletracResponse = makeSFRequest(instanceUrl + TELETRAC_INFO_ENDPOINT, true);
				JSONObject teletracInfo = new JSONObject(teletracResponse);

				teletracQueryString = String.format(
						"?strAccountId=%s&strUserName=%s&strPwd=%s",
						teletracInfo.getString("Account"),
						teletracInfo.getString("Username"),
						teletracInfo.getString("Password"));
			}
			
			return teletracQueryString;
		} catch (Exception e) {
			e.printStackTrace();
			
			throw new AMException(e);
		}
	}
	
	public MapAPIProxy(DroidGap ctx) {
		this.ctx = ctx;
	}
	
	private void ensureToken() throws AccountInfoNotFoundException {
		if (authToken == null) {
			ClientManager mgr = new ClientManager(this.ctx.getContext(),
					ForceApp.APP.getAccountType(), null);
			RestClient cli = mgr.peekRestClient();

			authToken = cli.getAuthToken();
			refreshToken = cli.getRefreshToken();
			instanceUrl = cli.getClientInfo().instanceUrl.toString();
			clientId = cli.getClientInfo().clientId;
		}
	}
	
	public String makeSFRequest(String uri, boolean retry) throws AMException {
		
		try {
			ensureToken();
			
			boolean error = false;

			String line = null;

			URL url = new URL(uri);

			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.addRequestProperty("Authorization", "OAuth " + authToken); 

			StringBuilder responseBody = new StringBuilder();

			BufferedReader reader = null;

			try {
				reader = new BufferedReader(new InputStreamReader(
						conn.getInputStream()));
			} catch (IOException ex) {
				error = true;
			}
			
			if(conn.getResponseCode() != 200) {
				error = true;
			}
			
			if(!error) {
				while ((line = reader.readLine()) != null) {
					responseBody.append(line);
				}
			}
			
			try {
				JSONObject response = new JSONObject(responseBody.toString());
				
				if(response.has("errorCode")) {
					error = true;
				}
			} catch (Exception e) {
				// not a json return, can ignore
				e.printStackTrace();
			}

			if (error) {
				if (retry) {
					url = new URL(instanceUrl + "/services/oauth2/token");

					conn = (HttpURLConnection) url.openConnection();

					conn.setRequestMethod("POST");
					conn.setRequestProperty("ContentType",
							"application/x-www-form-urlencoded");
					conn.setRequestProperty("Accept", "application/json");

					conn.setDoOutput(true);

					conn.getOutputStream().write(
							("grant_type=refresh_token&client_id=" + clientId
									+ "&refresh_token=" + refreshToken).getBytes());

					reader = new BufferedReader(new InputStreamReader(
							conn.getInputStream()));

					while ((line = reader.readLine()) != null) {
						responseBody.append(line);
					}

					authToken = new JSONObject(responseBody.toString()).getString("access_token"); 
					
					return makeSFRequest(uri, false);

				} else {
					throw new RuntimeException(conn.getResponseMessage());
				}
			} else {
				return responseBody.toString();
			}
		} catch (Exception e) {
			e.printStackTrace();
			throw new AMException(e);
		}

	}
	
	public String makeTeletracRequest(String uri) throws AMException {
		try {
			uri += getTeletracQueryString();
			
			URL url = new URL(uri);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			StringBuilder responseBody = new StringBuilder();
			BufferedReader reader = null;

			reader = new BufferedReader(new InputStreamReader(
						conn.getInputStream()));
			
			String line = null;
			
			while((line = reader.readLine()) != null) {
				responseBody.append(line);
			}
			
			return responseBody.toString();

		} catch (Exception e) {
			e.printStackTrace();
			
			throw new AMException(uri);
		}
	}
	
	public JSONObject getSchedule(String stopName) throws AMException {
		try {
			ensureToken();
			
			return new JSONObject(makeSFRequest(instanceUrl + "/services/apexrest/BusStopSchedule?busStopName=" + URLEncoder.encode(stopName, "UTF-8"), true));
		} catch (Exception e) {
			e.printStackTrace();
			
			throw new AMException(e);
		}
	}
	
	public JSONArray getBusStops() throws AMException {
		try {
			ensureToken();
			
			return new JSONArray(makeSFRequest(instanceUrl + "/services/apexrest/BusStops/", true));
		} catch (Exception e) {
			e.printStackTrace();
			
			throw new AMException(e);
		}
	}
	
	public String getVehicles() throws AMException {
		String buses = makeTeletracRequest("https://xmlgateway.teletrac.net/AsciiService.asmx/GetVehicles");
		
		return buses;		
	}
}
