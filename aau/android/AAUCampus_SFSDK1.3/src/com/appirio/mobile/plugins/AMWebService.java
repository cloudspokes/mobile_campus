package com.appirio.mobile.plugins;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.phonegap.api.Plugin;
import com.phonegap.api.PluginResult;
import com.salesforce.androidsdk.app.ForceApp;
import com.salesforce.androidsdk.rest.ClientManager;
import com.salesforce.androidsdk.rest.RestClient;

public class AMWebService extends Plugin {

	private static String teletracQueryString = null;
	private static final String TELETRAC_INFO_ENDPOINT = "/services/apexrest/teletracInfo/";

	private static String authToken = null;
	private static String refreshToken = null;
	private static String instanceUrl = null;
	private static String clientId = null;

	private String doGet(String uri, boolean retry) throws IOException, JSONException {
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
				
				return doGet(uri, false);

			} else {
				throw new RuntimeException(conn.getResponseMessage());
			}
		} else {
			return responseBody.toString();
		}

	}

	@Override
	public PluginResult execute(String arg0, JSONArray arg1, String arg2) {
		try {

			ClientManager mgr = new ClientManager(this.ctx.getContext(),
					ForceApp.APP.getAccountType(), null);
			RestClient cli = mgr.peekRestClient();

			if (authToken == null) {
				authToken = cli.getAuthToken();
				refreshToken = cli.getRefreshToken();
				instanceUrl = cli.getClientInfo().instanceUrl.toString();
				clientId = cli.getClientInfo().clientId;
			}

			String uri = arg1.get(0).toString();

			if (uri.equals("https://xmlgateway.teletrac.net/AsciiService.asmx/GetVehicles")) {
				if (teletracQueryString == null) {
					String teletracResponse = doGet(
							cli.getClientInfo().instanceUrl
									+ TELETRAC_INFO_ENDPOINT, false);
					JSONObject teletracInfo = new JSONObject(teletracResponse);

					teletracQueryString = String.format(
							"?strAccountId=%s&strUserName=%s&strPwd=%s",
							teletracInfo.getString("Account"),
							teletracInfo.getString("Username"),
							teletracInfo.getString("Password"));
				}

				uri += teletracQueryString;
			}

			return new PluginResult(PluginResult.Status.OK, doGet(uri, true));
		} catch (Exception e) {
			e.printStackTrace();
			return new PluginResult(PluginResult.Status.ERROR, e.getMessage());
		}
	}

}
