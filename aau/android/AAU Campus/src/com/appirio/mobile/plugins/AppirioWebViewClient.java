package com.appirio.mobile.plugins;

import android.webkit.WebView;
import android.webkit.WebViewClient;

public class AppirioWebViewClient extends WebViewClient {
	@Override
	public boolean shouldOverrideUrlLoading(WebView view, String url) {
		view.loadUrl(url);
		return true;
	}
}
