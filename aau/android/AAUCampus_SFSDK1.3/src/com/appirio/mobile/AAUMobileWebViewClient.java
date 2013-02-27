package com.appirio.mobile;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.apache.cordova.CordovaWebViewClient;
import org.apache.cordova.DroidGap;

import android.webkit.WebView;

public class AAUMobileWebViewClient extends CordovaWebViewClient {

	@Override
	public boolean shouldOverrideUrlLoading(WebView webView, String url) {
		
		return super.shouldOverrideUrlLoading(webView, url);
	}

	/*
	@Override
	public WebResourceResponse shouldInterceptRequest(WebView view, String url) {
		if(url.startsWith("aaumobile://")) {
			String resName = url.substring(12);
			
			try {
				String mimeType = "image/png";
				
				if(resName.toLowerCase().endsWith("css")) {
					mimeType = "text/css";
				}
				if(resName.toLowerCase().endsWith("html")) {
					mimeType = "text/html";
				}
				if(resName.toLowerCase().endsWith("js")) {
					mimeType = "application/javascript";
				}
				
				return new WebResourceResponse(mimeType, null, this.ctx.getAssets().open(resName));
			} catch (IOException e) {
				e.printStackTrace();
				return null;
			}
		} else {
			return super.shouldInterceptRequest(view, url);
		}
	}*/

	
	/* (non-Javadoc)
	 * @see android.webkit.WebViewClient#onLoadResource(android.webkit.WebView, java.lang.String)
	 */
	@Override
	public void onLoadResource(WebView view, String url) {
		
//		if(url.startsWith("aaumobile://")) {
//			//String resName = url.substring(12);			
//			try {
//				String mimeType = "image/png";
//				
//				if(url.toLowerCase().endsWith("html")) {
//					mimeType = "text/html";
//				}
//				if(url.toLowerCase().endsWith("js")) {
//					mimeType = "application/javascript";
//				
//					if(url.endsWith("mob_CombinedLibs_min.js")) {
//						String data = convertStreamToString(this.ctx.getAssets().open("mob_CombinedLibs_min.js"));
//						view.loadDataWithBaseURL("file:///android_asset", data, mimeType, "UTF-8", null);
//						return;
//					}
//					if(url.toLowerCase().endsWith("cordova.js")) {				
//						String data = convertStreamToString(this.ctx.getAssets().open("cordova.js"));
//						view.loadDataWithBaseURL("file:///android_asset", data, mimeType, "UTF-8", null);
//						return;
//					}
//				
//				}
//								
//			} catch (Exception e) {
//				e.printStackTrace();
//				return;
//			}
//		}
		
		super.onLoadResource(view, url);
	}

	public AAUMobileWebViewClient(DroidGap ctx) {
		super(ctx);
	}

	private static String convertStreamToString(InputStream is) throws Exception {
	    BufferedReader reader = new BufferedReader(new InputStreamReader(is));
	    StringBuilder sb = new StringBuilder();
	    String line = null;

	    while ((line = reader.readLine()) != null) {
	        sb.append(line);
	    }

	    is.close();

	    return sb.toString();
	}
	
}
