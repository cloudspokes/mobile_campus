package com.appirio.mobile.aau.nativemap;

import java.util.ArrayList;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.TextView;

import com.appirio.aau.R;

public class StopScheduleActivity extends Activity {
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);

		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_stop_schedule);
		
		ViewGroup root = (ViewGroup) this.findViewById(R.id.mainStopScheduleContainer);
		ViewGroup stopSchedulecontainer = (ViewGroup) this.findViewById(R.id.stopScheduleContainer);

		((TextView)this.findViewById(R.id.txtBusStopName)).setText(getIntent().getExtras().getString("stopName"));
		
		ArrayList<RouteStopSchedule> schedule = (ArrayList<RouteStopSchedule>) getIntent().getExtras().get("schedule");
		
		for(RouteStopSchedule routeSchedule : schedule) {
			View scheduleView = this.getLayoutInflater().inflate(R.layout.schedule_item, null);
			
			((TextView)scheduleView.findViewById(R.id.txtRouteName)).setText(routeSchedule.getName());
			((TextView)scheduleView.findViewById(R.id.txtRouteName)).setBackgroundColor(Color.parseColor(routeSchedule.getColor()));
			
			((TextView)scheduleView.findViewById(R.id.txtETA)).setText(routeSchedule.getNextBusETA());
			
			((TextView)scheduleView.findViewById(R.id.txtUpcomingStops)).setText(routeSchedule.getTodaysNextStops());

			stopSchedulecontainer.addView(scheduleView);
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		return false;
	}

}
