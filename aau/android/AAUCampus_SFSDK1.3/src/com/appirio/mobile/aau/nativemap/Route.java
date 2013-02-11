package com.appirio.mobile.aau.nativemap;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;

public class Route {

	private String name;
	private String markerIcon;
	private List<BusStop> busStop;
	private List<Waypoint> waypoints;
	
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getMarkerIcon() {
		return markerIcon;
	}

	public void setMarkerIcon(String markerIcon) {
		this.markerIcon = markerIcon;
	}

	public List<BusStop> getBusStops() {
		return busStop;
	}

	public void setBusStop(List<BusStop> busStop) {
		this.busStop = busStop;
	}

	public Route(JSONObject jsonRoute) throws AMException {
		try {
			busStop = new ArrayList<BusStop>();
			this.name = (String) jsonRoute.get("routeName");
			
			JSONArray stops = jsonRoute.getJSONArray("stops");
			
			if(stops.length() > 0) {
				markerIcon = (stops.getJSONObject(0)).get("routeMarker").toString();
			}
			
			for(int i = 0; i < stops.length(); i++) {
				busStop.add(new BusStop(stops.getJSONObject(i)));
			}
		} catch (Exception e) {
			e.printStackTrace();
			
			throw new AMException(e);
		}
		
		
	}

}
