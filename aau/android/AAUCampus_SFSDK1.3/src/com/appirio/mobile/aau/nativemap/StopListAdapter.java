package com.appirio.mobile.aau.nativemap;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.apache.cordova.DroidGap;

import com.appirio.aau.R;

import android.content.Intent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.TextView;

public class StopListAdapter implements OnClickListener {

	private ViewGroup stopListView;
	private DroidGap ctx;
	private List<BusStop> stops;
	private MapManager mapManager;
	
	public StopListAdapter(DroidGap ctx, MapManager mapManager) {
		this.ctx = ctx;
		this.mapManager = mapManager;
		this.stops = mapManager.getBusStops();
		
		Collections.sort(stops, new BusStopOrderComparator());
	}
	
	public ViewGroup getStopListView() {
		if(stopListView == null) {
			stopListView = (ViewGroup) ctx.getLayoutInflater().inflate(R.layout.stop_list, null);
			
			for(BusStop stop : stops) {
				View stopListItem = ctx.getLayoutInflater().inflate(R.layout.stop_list_item, null);
				
				((TextView)stopListItem.findViewById(R.id.txtStopName)).setText(stop.getAddress());
				
				StringBuilder routes = new StringBuilder("Routes: ");
				String separator = "";
				
				for(String route : stop.getRoutes()) {
					routes.append(route);
					routes.append(separator);
					
					separator = ", ";
				}
				
				stopListItem.setOnClickListener(this);
				
				((TextView)stopListItem.findViewById(R.id.txtRoutes)).setText(routes.toString());
				
				((ViewGroup)stopListView.findViewById(R.id.stopsContainer)).addView(stopListItem);
			}
			
		}
		
		return stopListView;
	}

	@Override
	public void onClick(View view) {
		try {
			String stopName = ((TextView)view.findViewById(R.id.txtStopName)).getText().toString();
			
			ArrayList<RouteStopSchedule> schedule = this.mapManager.getSchedule(stopName);

			Intent intent = new Intent(this.ctx, StopScheduleActivity.class);
			
			intent.putExtra("schedule", schedule);
			intent.putExtra("stopName", stopName);
			
			this.ctx.startActivity(intent);
		} catch (AMException e) {
			// TODO handle this exception
			e.printStackTrace();
		}
		
	}
	
}
