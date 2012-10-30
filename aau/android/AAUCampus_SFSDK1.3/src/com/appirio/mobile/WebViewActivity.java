package com.appirio.mobile;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.view.Window;
import android.webkit.WebView;

import com.appirio.mobile.aau.R;
import com.appirio.mobile.plugins.AppirioWebViewClient;

public class WebViewActivity extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_web_view);
        
        WebView v = (WebView)findViewById(R.id.webView); 
        
        v.setWebViewClient(new AppirioWebViewClient());
        
        v.getSettings().setSupportZoom(true);
        
        v.loadUrl(getIntent().getStringExtra("url"));
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_web_view, menu);
        return false;
    }

    
}
