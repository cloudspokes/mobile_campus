package com.appirio.mobile;

import java.io.IOException;

import org.apache.cordova.CordovaWebViewClient;
import org.apache.cordova.DroidGap;

//import android.webkit.WebResourceResponse;
import android.webkit.WebView;

public class AAUMobileWebViewClient extends CordovaWebViewClient {

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

	public AAUMobileWebViewClient(DroidGap ctx) {
		super(ctx);
	}

}