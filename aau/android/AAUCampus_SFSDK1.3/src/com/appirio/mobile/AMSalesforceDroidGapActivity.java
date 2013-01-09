package com.appirio.mobile;

import java.util.ArrayList;
import java.util.Calendar;

import org.apache.cordova.CordovaWebViewClient;

import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ListView;

import com.appirio.mobile.aau.R;
import com.appirio.mobile.aau.slidingmenu.SlidingMenuAdapter;
import com.appirio.mobile.aau.slidingmenu.SlidingMenuItem;
import com.appirio.mobile.aau.slidingmenu.SlidingMenuLayout;
import com.salesforce.androidsdk.ui.LoginActivity;
import com.salesforce.androidsdk.ui.SalesforceDroidGapActivity;

public class AMSalesforceDroidGapActivity extends SalesforceDroidGapActivity implements OnClickListener, OnItemClickListener {
	
	public SlidingMenuLayout rootLayout;
	ListView slidingMenuListView;
	View menuLayout, mainLayout;
	Button showSlidingMenuButton;
	WebView webView;
	SlidingMenuAdapter menuAdapter;
	ArrayList<SlidingMenuItem> slidingMenuList;
	
	@Override
	protected CordovaWebViewClient createWebViewClient() {
		return new AAUMobileWebViewClient(this);
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);


		/* Create a new SlidingMenuLayout and set Layout parameters. */
		rootLayout = new SlidingMenuLayout(this);
		rootLayout.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, 0.0F));
		
		/* Inflate and add the main view layout and menu layout to root sliding menu layout. Menu layout should be added first.. */
		menuLayout = getLayoutInflater().inflate(R.layout.sliding_menu_layout, null);
		mainLayout = getLayoutInflater().inflate(R.layout.main_layout, null);		
		rootLayout.addView(menuLayout);
		//rootLayout.addView(mainLayout);
		
		this.root.removeView(this.appView);
		
		rootLayout.addView((View)this.appView);
		
		/* Set activity content as sliding menu layout. */
		this.root.addView(rootLayout);
		
		/* Initialize list view and buttons to handle showing of menu. */
		slidingMenuListView = (ListView) menuLayout.findViewById(R.id.sliding_menu_list_view);
		showSlidingMenuButton = (Button) mainLayout.findViewById(R.id.show_menu_button);
		
		/* Initialize the main web view for displaying of web content. */
		//webView = (WebView) mainLayout.findViewById(R.id.content_web_view);
		webView = this.appView;
		
		/* Initialize the menu adapter and set to list view to load menu from the XML file. */
		menuAdapter = new SlidingMenuAdapter(getLayoutInflater(), this);
		slidingMenuListView.setAdapter(menuAdapter);
		
		/* Handle button and list item clicks. */
		showSlidingMenuButton.setOnClickListener(this);
		slidingMenuListView.setOnItemClickListener(this);
		

		super.setIntegerProperty("splashscreen", com.appirio.mobile.aau.R.drawable.aau_load);

		super.loadUrl("file:///android_asset/www/bootstrap.html",10000); 
		
	}

	private static final String FEEDBACK_PREFS = "feedback_prefs";
	private static final String ASK_FEEDBACK_ON_PREF = "AskFeedbackOn";
	private static final int ASK_FEEDBACK_AFTER_DAYS = 3;
	
	private boolean isConnected() {
	    boolean haveConnectedWifi = false;
	    boolean haveConnectedMobile = false;

	    ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
	    NetworkInfo[] netInfo = cm.getAllNetworkInfo();
	    for (NetworkInfo ni : netInfo) {
	        if (ni.getTypeName().equalsIgnoreCase("WIFI"))
	            if (ni.isConnected())
	                haveConnectedWifi = true;
	        if (ni.getTypeName().equalsIgnoreCase("MOBILE"))
	            if (ni.isConnected())
	                haveConnectedMobile = true;
	    }
	    return haveConnectedWifi || haveConnectedMobile;
	}
	
	@Override
	public void onResume() {
		this.appView.loadUrl("javascript:aauMobile.init.appActivation();");
		
		if(!isConnected()) {
		  	AlertDialog.Builder adb = new AlertDialog.Builder(this);
		  	
		  	adb.setTitle("Error!");
		  	adb.setMessage("This device is not currently connected to the internet, please restart the application when a connection is available");
		  	
		  	new AlertDialog.Builder(this)
  		  	  .setTitle("Error")
   		  	  .setMessage("This device is not currently connected to the internet, please restart the application when a connection is available")
   		  	  .setNeutralButton("Ok", new DialogInterface.OnClickListener() {
   		  		  public void onClick(DialogInterface dialog,
   		  		    int which) {
   				  	endActivity();
   		  		  }
		  	}).show();
		} else {
			
			// If the user has the app installed for more than 3 days, ask for feedback
			SharedPreferences settings = getSharedPreferences(
					FEEDBACK_PREFS,
					Context.MODE_PRIVATE);
			SharedPreferences.Editor editor = settings.edit();
			editor.putString(LoginActivity.SERVER_URL_CURRENT_SELECTION,
			  getString(com.appirio.mobile.aau.R.string.sf_default_url));
			
			long askFeedbackOn = settings.getLong(ASK_FEEDBACK_ON_PREF, 0);
			Calendar calendar = Calendar.getInstance();
			calendar.add(Calendar.DAY_OF_MONTH, ASK_FEEDBACK_AFTER_DAYS);

			if(askFeedbackOn == 0) {
				editor.putLong(ASK_FEEDBACK_ON_PREF, calendar.getTimeInMillis());
			} else if(askFeedbackOn != -1) {
				if(askFeedbackOn < System.currentTimeMillis()) {
					Builder dialogBuilder = new Builder(this);
					
					dialogBuilder.setMessage("Would you like to provide feedback on this app?");
					dialogBuilder.setTitle("Feedback");
					
					FeedbackDialogListener listener = new FeedbackDialogListener(this, editor);
					
					dialogBuilder.setNegativeButton("Don't ask again", listener);
					dialogBuilder.setNeutralButton("Not now", listener);
					dialogBuilder.setPositiveButton("Yes!", listener);
					
					dialogBuilder.show();
				}
			}
			
			editor.commit();
		}
		
		
		super.onStart();
	}
	
	class FeedbackDialogListener implements DialogInterface.OnClickListener {

		private Context ctx;
		private SharedPreferences.Editor editor;
		
		public FeedbackDialogListener(Context ctx, SharedPreferences.Editor editor) {
			this.ctx = ctx;
			this.editor = editor;
		}
		
		public void onClick(DialogInterface dialog, int which) {
			Calendar calendar = Calendar.getInstance();
			calendar.add(Calendar.DAY_OF_MONTH, ASK_FEEDBACK_AFTER_DAYS);
			
			if(which == DialogInterface.BUTTON_NEGATIVE) {
				editor.putLong(ASK_FEEDBACK_ON_PREF, -1);
			} else if(which == DialogInterface.BUTTON_NEUTRAL) {
				editor.putLong(ASK_FEEDBACK_ON_PREF, calendar.getTimeInMillis());
			} else if (which == DialogInterface.BUTTON_POSITIVE) {
				editor.putLong(ASK_FEEDBACK_ON_PREF, -1);
				
				 startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + ctx.getPackageName())));
			}
			
			editor.commit();
		}
		
	}
	
	@Override
	public void onItemClick(AdapterView<?> adapterView, View view, int position, long id)
	{
		rootLayout.closeMenu();
		String url = (String) menuAdapter.getItem(position);
		webView.loadUrl(url);
	}

	@Override
	public void onClick(View view) 
	{
		if (view == showSlidingMenuButton)
		{
			if (rootLayout.isOpen())
			{
				rootLayout.closeMenu();
			}
			else 
			{
				rootLayout.openMenu();
			}			
		}		
	}
	
	public void showMenu() {
		menuLayout.requestLayout();
	}
}
