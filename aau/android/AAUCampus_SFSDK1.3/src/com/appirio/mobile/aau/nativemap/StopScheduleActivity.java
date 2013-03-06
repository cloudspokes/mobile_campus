package com.appirio.mobile.aau.nativemap;

import java.util.ArrayList;
import java.util.Collections;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.ArcShape;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.TextView;

import com.appirio.aau.R;

public class StopScheduleActivity extends Activity {
	
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
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);

		active = true;
		
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_stop_schedule);
		
		//ViewGroup root = (ViewGroup) this.findViewById(R.id.mainStopScheduleContainer);
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
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		return false;
	}

}
