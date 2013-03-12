package com.appirio.mobile.aau.nativemap;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.apache.cordova.DroidGap;

import android.content.Intent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.TextView;

import com.appirio.aau.R;

public class StopListAdapter implements OnClickListener {

	private ViewGroup stopListView;
	private DroidGap ctx;
	private List<BusStop> stops = new ArrayList<BusStop>();
	private MapManager mapManager;
	
	public StopListAdapter(DroidGap ctx, MapManager mapManager) {
		this.ctx = ctx;
		this.mapManager = mapManager;
		
	}
	
	public ViewGroup getStopListView() {
		if(mapManager != null && this.stops == null) {
			this.stops = mapManager.getBusStops();

		}

		if(stops.size() == 0) {
			if(mapManager != null) {
				stopListView = null;
				this.stops = mapManager.getBusStops();
			}
		}
		
		if(this.stops.size() == 0) {
			stopListView = null;
		}
		
		Collections.sort(stops, new BusStopOrderComparator());

		if(stopListView == null) {
			stopListView = (ViewGroup) ctx.getLayoutInflater().inflate(R.layout.stop_list, null);
			
			for(BusStop stop : stops) {
				View stopListItem = ctx.getLayoutInflater().inflate(R.layout.stop_list_item, null);
				
				((TextView)stopListItem.findViewById(R.id.txtStopName)).setText(stop.getAddress());
				
				StringBuilder routes = new StringBuilder("Routes: ");
				String separator = "";
				
				for(String route : stop.getRoutes()) {
					routes.append(separator);
					routes.append(route);
					
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
			if(!StopScheduleActivity.isActive()) {
				
				StopScheduleActivity.setActive(true);
				StopScheduleActivity.setMapManager(this.mapManager);
				
				String stopName = ((TextView)view.findViewById(R.id.txtStopName)).getText().toString();
				
				//ArrayList<RouteStopSchedule> schedule = this.mapManager.getSchedule(stopName);
	
				Intent intent = new Intent(this.ctx, StopScheduleActivity.class);
				
				//intent.putExtra("schedule", schedule);
				intent.putExtra("stopName", stopName);
				
				this.ctx.startActivity(intent);
			}
		} catch (Exception e) {  //(AMException e) {
			// TODO handle this exception
			e.printStackTrace();
		}
		
	}

	public boolean hasStops() {
		return stops.size() > 0;
	}
	
}
