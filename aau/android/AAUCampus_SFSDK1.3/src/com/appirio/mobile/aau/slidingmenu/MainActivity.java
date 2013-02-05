

package com.appirio.mobile.aau.slidingmenu;

import java.util.ArrayList;

import com.appirio.aau.R;

import android.app.Activity;
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

public class MainActivity extends Activity implements OnClickListener, OnItemClickListener
{
	SlidingMenuLayout rootLayout;
	ListView slidingMenuListView;
	View menuLayout, mainLayout;
	Button showSlidingMenuButton;
	WebView webView;
	SlidingMenuAdapter menuAdapter;
	ArrayList<SlidingMenuItem> slidingMenuList;

	@Override
	protected void onCreate(Bundle savedInstanceState) 
	{
		super.onCreate(savedInstanceState);
		
		/* Create a new SlidingMenuLayout and set Layout parameters. */
		rootLayout = new SlidingMenuLayout(this);
		rootLayout.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, 0.0F));
		
		/* Inflate and add the main view layout and menu layout to root sliding menu layout. Menu layout should be added first.. */
		menuLayout = getLayoutInflater().inflate(R.layout.sliding_menu_layout, null);
		mainLayout = getLayoutInflater().inflate(R.layout.main_layout, null);		
		rootLayout.addView(menuLayout);
		rootLayout.addView(mainLayout);
		
		/* Set activity content as sliding menu layout. */
		setContentView(rootLayout);
		
		/* Initialize list view and buttons to handle showing of menu. */
		slidingMenuListView = (ListView) menuLayout.findViewById(R.id.sliding_menu_list_view);
		showSlidingMenuButton = (Button) mainLayout.findViewById(R.id.show_menu_button);
		
		/* Initialize the main web view for displaying of web content. */
		//webView = (WebView) mainLayout.findViewById(R.id.content_web_view);
		
		/* Initialize the menu adapter and set to list view to load menu from the XML file. */
		menuAdapter = new SlidingMenuAdapter(getLayoutInflater(), this);
		slidingMenuListView.setAdapter(menuAdapter);
		
		/* Handle button and list item clicks. */
		showSlidingMenuButton.setOnClickListener(this);
		slidingMenuListView.setOnItemClickListener(this);
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
}