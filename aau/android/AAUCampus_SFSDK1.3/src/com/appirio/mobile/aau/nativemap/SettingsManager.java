package com.appirio.mobile.aau.nativemap;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.drawable.BitmapDrawable;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.CheckBox;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.Toast;
import android.widget.ToggleButton;

import com.appirio.aau.R;
import com.appirio.mobile.AMSalesforceDroidGapActivity;

public class SettingsManager {

	//private Context ctx;
	private AMSalesforceDroidGapActivity view;
	private MapManager mapManager;
	private PopupWindow popup;
	
	public SettingsManager(Context ctx, AMSalesforceDroidGapActivity parent_view, MapManager map_mgr) {
		//this.ctx = ctx;
		this.mapManager = map_mgr;
	}

	// The method that displays the popup.
	public void showPopup(final Activity context, Point p) {
		
		DisplayMetrics metrics = context.getResources().getDisplayMetrics();
		int width = metrics.widthPixels;
		int height = metrics.heightPixels;
		
		int popupWidth = width - 40; // 460;
		int popupHeight = height - 100; //650;

		// Inflate the popup_layout.xml
		LinearLayout viewGroup = (LinearLayout) context.findViewById(R.id.popup);
		LayoutInflater layoutInflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View layout = layoutInflater.inflate(R.layout.popup_settings_layout, viewGroup);

		// Creating the PopupWindow
		popup = new PopupWindow(context);
		popup.setContentView(layout);
		popup.setWidth(popupWidth);
		popup.setHeight(popupHeight);
		popup.setFocusable(true);

		// Some offset to align the popup a bit to the right, and a bit down, relative to button's position.
		int OFFSET_X = 20;
		int OFFSET_Y = 60;

		//Initialize the Point with x, and y positions
		Point pbtn = p; //getSettingAnchorPoint();
		
		// Clear the default translucent background
		popup.setBackgroundDrawable(new BitmapDrawable());

		// Log.d("NATIVE MAP Activity", "Setting POINT: "+ pbtn.x + OFFSET_X + " " + pbtn.y + OFFSET_Y);
		// Displaying the popup at the specified location, + offsets.
		popup.showAtLocation(layout, Gravity.NO_GRAVITY, pbtn.x + OFFSET_X, pbtn.y + OFFSET_Y);

		
		// Dynamically add bttons here
		//routeList = mapManager.getRoutesShown();
		addRoutesTable(popup);

		// Set Autoupdate flag from map Manager
		
		ToggleButton liveUpdBtn = (ToggleButton)popup.getContentView().findViewById(R.id.toggleLiveUpdatesButton);
		if (liveUpdBtn != null){
			liveUpdBtn.setChecked(mapManager.getAutoUpdate());
		}
		
	}

	private void addRoutesTable(PopupWindow popup){
		
		TableLayout tl = (TableLayout)popup.getContentView().findViewById(R.id.tableLayout1);
		int cnt = 1;
		TableRow tr = null;
		CheckBox cb = null;
		boolean isOdd = false;
		List<String> rtList = stubRoutsList();
		    for (String s : rtList) {
		         cb = createCheckBox(cnt, s);
		         
		         
		         if (( cnt & 1) == 0 ) { 
		        	 // even... 
			         tl.addView(tr, new TableLayout.LayoutParams(TableLayout.LayoutParams.WRAP_CONTENT, TableLayout.LayoutParams.WRAP_CONTENT));
			 		 // Get Line sep view
			         addLineSeparator(tl);
			         isOdd = false;	
		         } else { 
			         // Odd
		        	 tr = new TableRow(view);
			         tr.setLayoutParams(new TableRow.LayoutParams(TableRow.LayoutParams.WRAP_CONTENT, TableRow.LayoutParams.WRAP_CONTENT));
			         tr.setPadding(5, 0, 5, 0);		
			         isOdd = true;
		         }
		         
		         
		         tr.addView(cb);

		         cnt++;
		    }
		    
	         // Check if its last element
	         if (isOdd){
		         tl.addView(tr, new TableLayout.LayoutParams(TableLayout.LayoutParams.WRAP_CONTENT, TableLayout.LayoutParams.WRAP_CONTENT));
		         //tr.addView(cb);
		         // Get Line sep view
		         addLineSeparator(tl);
	         }

	}
	
	private CheckBox createCheckBox(int id, String s){
        CheckBox cb = new CheckBox(view);
        cb.setId(id);
        cb.setText(s);
      
        TableRow.LayoutParams lp2 = new TableRow.LayoutParams(
       		 TableRow.LayoutParams.WRAP_CONTENT,
       		 TableRow.LayoutParams.WRAP_CONTENT
       		 );
        
        cb.setLayoutParams(lp2);  
        cb.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
           	 testCheckHandler(v);	
           	 // TODO Auto-generated method stub
            }
        });     
		
        return cb;
	}
	
	
	public void addLineSeparator(TableLayout tl){
		 // Get Line sep view
		 View v = new View(view);
		 v.setLayoutParams(new TableRow.LayoutParams(TableRow.LayoutParams.FILL_PARENT, 1));
		 v.setBackgroundColor(Color.rgb(51, 51, 51));
       
       tl.addView(v);		
	}
	
	// Set up test route list
	public List<String> stubRoutsList(){
		List<String> al = new ArrayList<String>();
		String rt1 = "D";
		String rt2 = "H";
		String rt3 = "C";
		String rt4 = "Polk";
		String rt5 = "Campus Tour";
		String rt6 = "Warf9";
		String rt7 = "A";
		al.add(rt1);
		al.add(rt2);
		al.add(rt3);
		al.add(rt4);
		al.add(rt5);
		al.add(rt6);
		al.add(rt7);
		
		//return mapManager.getRoutes();
		return al;
	}

	// Method to open WebView and display a static map image
	public void onStaticMapBtnClicked(View v){
	    if(v.getId() == R.id.staticMap){
	        
	    	MessageBox("Show static map");

	        //this.webView.loadUrl("http://www.google.com");
			//rootLayout.removeView(this.appView);
			//rootLayout.addView(this.webView);
	    }

	}
	
	// Method to handle Toggle button to set flag for Live Bus updates from Teletrack
	public void onLiveUpdatesClicked(View v){
	    if(v.getId() == R.id.toggleLiveUpdatesButton){
	    	
	    	boolean on = ((ToggleButton) v).isChecked();
	        
	        if (on) {
	            // Enable Bus live updates
	        	MessageBox("Enable Bus Live Updates");
	        } else {
	            // Disable Bus Live updates
	        	MessageBox("Disable Bus Live Updates");
	        }	        
	    	
	    }
	}
	
	
	public void onRouteSelectorClicked(View view) {
		testCheckHandler(view);
	}	
	
	private void testCheckHandler(View view){
	    // Is the view now checked?
	    boolean checked = ((CheckBox) view).isChecked();
	    if (checked){
	    	MessageBox("Selected: "+view.getId());
	    }
	    if (!checked){
	    	MessageBox("NOT Selected: "+view.getId());
	    }
		
	}

    public void MessageBox(String message)
    {
       Toast.makeText(view, message, Toast.LENGTH_SHORT).show();
    }   

}
