package com.appirio.mobile;

import java.io.IOException;

import org.apache.cordova.CordovaWebViewClient;
import org.apache.cordova.DroidGap;

import android.webkit.WebView;
//import android.webkit.WebResourceResponse;

public class AAUMobileWebViewClient extends CordovaWebViewClient {

	@Override
	public boolean shouldOverrideUrlLoading(WebView webView, String url) {
		return super.shouldOverrideUrlLoading(webView, url);
	}

//	@Override
//	public WebResourceResponse shouldInterceptRequest(WebView view, String url) {
//		if(url.startsWith("aaumobile://")) {
//			String resName = url.substring(12);
//			
//			try {
//				String mimeType = "image/png";
//				
//				if(resName.toLowerCase().endsWith("css")) {
//					mimeType = "text/css";
//				}
//				if(resName.toLowerCase().endsWith("html")) {
//					mimeType = "text/html";
//				}
//				if(resName.toLowerCase().endsWith("js")) {
//					mimeType = "application/javascript";
//				}
//				
//				return new WebResourceResponse(mimeType, null, this.ctx.getAssets().open(resName));
//			} catch (IOException e) {
//				e.printStackTrace();
//				return null;
//			}
//		} else {
//			return super.shouldInterceptRequest(view, url);
//		}
//	}

	@Override
	public void onLoadResource(WebView view, String url) {
		super.onLoadResource(view, url);
	}

	public AAUMobileWebViewClient(DroidGap ctx) {
		super(ctx);
	}

}
