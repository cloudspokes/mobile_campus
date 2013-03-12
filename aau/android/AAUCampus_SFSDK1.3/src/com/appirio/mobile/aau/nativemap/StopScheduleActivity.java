package com.appirio.mobile.aau.nativemap;

import java.util.ArrayList;
import java.util.Collections;

import android.app.Activity;
import android.app.ProgressDialog;
import android.graphics.Color;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.ArcShape;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.Menu;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.TextView;

import com.appirio.aau.R;

public class StopScheduleActivity extends Activity {
	
	public static MapManager mapManager;
	private StopScheduleWorker stopScheduleWorker;
	private ProgressDialog loadScheduleStatusDialog;
	private boolean isInProgress = false;
	private ArrayList<RouteStopSchedule> schedule;
	private String stopName;
	
	// Task handler to update UI view from thread
	private Handler showScheduleResults = new Handler() { 
		
		@Override	
		public void handleMessage(Message msg) {
    	   createRouteStopView(schedule, stopName);
		}
		
    };  
	
	
	@Override
	protected void onStop() {
		active = false;
		super.onStop();
	}

	private static boolean active = false;
	
	public static boolean isActive() {
		return active;
	}

	public static void setActive(boolean _active) {
		active = _active;
	}
	
	public static MapManager getMapManager() {
		return mapManager;
	}

	public static void setMapManager(MapManager mapManager) {
		StopScheduleActivity.mapManager = mapManager;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);

		active = true;
		
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_stop_schedule);
				
		this.stopScheduleWorker = new StopScheduleWorker();
		stopName = getIntent().getExtras().getString("stopName");
		// Create default Stop
		createSearchingStateView(stopName);
		// Start worker thread to get Teletrack bus stops schedule
		new Thread(this.stopScheduleWorker).start();
		
		// Start disply of porgress dialog
		this.loadScheduleStatusDialog = ProgressDialog.show(this, "", "Please wait");
		this.isInProgress = true;
		
		/*
		 ViewGroup stopSchedulecontainer = (ViewGroup) this.findViewById(R.id.stopScheduleContainer);

		((TextView)this.findViewById(R.id.txtBusStopName)).setText(getIntent().getExtras().getString("stopName"));
		
		ArrayList<RouteStopSchedule> schedule = (ArrayList<RouteStopSchedule>) getIntent().getExtras().get("schedule");
		
		Collections.sort(schedule, new RouteStopScheduleComparator()); 

				
		for(RouteStopSchedule routeSchedule : schedule) {
			View scheduleView = this.getLayoutInflater().inflate(R.layout.schedule_item, null);
			
			((TextView)scheduleView.findViewById(R.id.txtRouteName)).setText(routeSchedule.getName());
			// ((TextView)scheduleView.findViewById(R.id.txtRouteName)).setBackgroundColor(Color.parseColor(routeSchedule.getColor()));
			
			ShapeDrawable circle = new ShapeDrawable( new ArcShape(0, 360));
			circle.setIntrinsicHeight(150);
			circle.setIntrinsicWidth(100); // this does not effect anything, width set by layout
			circle.getPaint().setColor(Color.parseColor(routeSchedule.getColor()));
			((TextView)scheduleView.findViewById(R.id.txtRouteName)).setBackgroundDrawable(circle);
			
			String upcomingStops = routeSchedule.getTodaysNextStops();
			if(upcomingStops == null) {
				((TextView)scheduleView.findViewById(R.id.txtUpcomingStops)).setText("No Upcoming Stops.");
			} else {
				((TextView)scheduleView.findViewById(R.id.txtUpcomingStops)).setText("Upcoming Stops: " + upcomingStops);
			}
			
			String eta = routeSchedule.getNextBusETA();
			if(eta == null) {
				((TextView)scheduleView.findViewById(R.id.txtNextStopTilte)).setText("No More Stops Today");
				((TextView)scheduleView.findViewById(R.id.txtETA)).setText("");
			} else {
				((TextView)scheduleView.findViewById(R.id.txtETA)).setText(eta);
			}

			stopSchedulecontainer.addView(scheduleView);
		}
*/		
	}

	/**
	 * Create a temporqry default List item to display while Teletrack loading data
	 * and display progress dialog
	 * 
	 * @param stopName
	 */
	private void createSearchingStateView(String stopName){
		ViewGroup stopSchedulecontainer = (ViewGroup) this.findViewById(R.id.stopScheduleContainer);
		stopSchedulecontainer.removeAllViews();
		((TextView)this.findViewById(R.id.txtBusStopName)).setText(stopName);

		View scheduleView = this.getLayoutInflater().inflate(R.layout.schedule_item, null);
		
		((TextView)scheduleView.findViewById(R.id.txtRouteName)).setText("?");
		
		((TextView)scheduleView.findViewById(R.id.txtRouteName)).setBackgroundDrawable(createStopDefaultCircle());
		((TextView)scheduleView.findViewById(R.id.txtUpcomingStops)).setText("Searching...");
		((TextView)scheduleView.findViewById(R.id.txtNextStopTilte)).setText("");
		((TextView)scheduleView.findViewById(R.id.txtETA)).setText("");
		
		stopSchedulecontainer.addView(scheduleView);
	}
	
	/**
	 * Use schedule route data from Tekletrack to fill a list view
	 * 
	 * @param schedule
	 * @param stopName
	 */
	private void createRouteStopView(ArrayList<RouteStopSchedule> schedule, String stopName){

		ViewGroup stopSchedulecontainer = (ViewGroup) this.findViewById(R.id.stopScheduleContainer);
		
		((TextView)this.findViewById(R.id.txtBusStopName)).setText(stopName);

		stopSchedulecontainer.removeAllViews();
		for(RouteStopSchedule routeSchedule : schedule) {
			View scheduleView_List = this.getLayoutInflater().inflate(R.layout.schedule_item, null);
			
			((TextView)scheduleView_List.findViewById(R.id.txtRouteName)).setText(routeSchedule.getName());
			
			((TextView)scheduleView_List.findViewById(R.id.txtRouteName)).setBackgroundDrawable(createStopCircle(routeSchedule.getColor()));
			
			String upcomingStops = routeSchedule.getTodaysNextStops();
			if(upcomingStops == null) {
				((TextView)scheduleView_List.findViewById(R.id.txtUpcomingStops)).setText("No Upcoming Stops.");
			} else {
				((TextView)scheduleView_List.findViewById(R.id.txtUpcomingStops)).setText("Upcoming Stops: " + upcomingStops);
			}
			
			String eta = routeSchedule.getNextBusETA();
			if(eta == null) {
				((TextView)scheduleView_List.findViewById(R.id.txtNextStopTilte)).setText("No More Stops Today");
				((TextView)scheduleView_List.findViewById(R.id.txtETA)).setText("");
			} else {
				((TextView)scheduleView_List.findViewById(R.id.txtETA)).setText(eta);
			}

			stopSchedulecontainer.addView(scheduleView_List);
		}
		// Dismiss dialog after loading all schedules
		this.loadScheduleStatusDialog.dismiss();
		this.isInProgress = false;
		
	}

	/**
	 * Create default Stop circle for List view with BLUE color
	 * 
	 * @return
	 */
	private ShapeDrawable createStopDefaultCircle(){		
		ShapeDrawable circle = new ShapeDrawable( new ArcShape(0, 360));
		circle.setIntrinsicHeight(150);
		circle.setIntrinsicWidth(100); // this does not effect anything, width set by layout
		circle.getPaint().setColor(Color.BLUE);
		return circle;
	}

	/**
	 * Create a Stop circle with defined color form data
	 * 
	 * @param clr
	 * @return
	 */
	private ShapeDrawable createStopCircle(String clr){		
		ShapeDrawable circle = new ShapeDrawable( new ArcShape(0, 360));
		circle.setIntrinsicHeight(150);
		circle.setIntrinsicWidth(100); // this does not effect anything, width set by layout
		circle.getPaint().setColor(Color.parseColor(clr));
		return circle;
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		return false;
	}
	
	@Override
	public void onPause() {
		super.onPause();
		this.loadScheduleStatusDialog.dismiss();
	}

	@Override
	public void onResume() {
		super.onResume();
		if (this.isInProgress && this.loadScheduleStatusDialog != null){
			this.loadScheduleStatusDialog.show();
		}
	}
	
	/**
	 * This inner class handles background thread to read real time
	 * bus stop schedules form teletrack using MapManager proxy method
	 * Send a message to Handler to Set up a list of stops display on view
	 * 
	 * @author iandrosov
	 *
	 */
	private class StopScheduleWorker implements Runnable {

		@Override
		public void run() {
			try{
				
				schedule = StopScheduleActivity.mapManager.getSchedule(stopName);
				Collections.sort(schedule, new RouteStopScheduleComparator()); 
				showScheduleResults.sendEmptyMessage(0);
				
			}catch(Exception e){
				e.printStackTrace();
			}
			
		}
		
		
	}
}
