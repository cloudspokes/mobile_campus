package com.appirio.mobile.aau.nativemap;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import org.apache.commons.codec.binary.Hex;
import org.json.JSONArray;
import org.json.JSONObject;

import android.graphics.Color;

public class Route {

	private String name;
	private String markerIcon;
	private List<BusStop> busStop;
	private Set<Waypoint> waypoints;
	private int routeColor;
	
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
				JSONObject stop = stops.getJSONObject(0);
				
				this.routeColor = Color.parseColor(stop.getString("color"));
				
				markerIcon = (stop).get("routeMarker").toString();
			}
			
			for(int i = 0; i < stops.length(); i++) {
				busStop.add(new BusStop(stops.getJSONObject(i)));
			}
			
			waypoints = new TreeSet<Waypoint>(new WaypointComparator());
						
			if(jsonRoute.has("highFidelity")) {
				JSONArray highFidelity = jsonRoute.getJSONArray("highFidelity");
				
				for(int i = 0; i < highFidelity.length(); i++) {
					waypoints.add(new Waypoint((JSONObject) highFidelity.get(i))); 
				}
			}
			
		} catch (Exception e) {
			e.printStackTrace();
			
			throw new AMException(e);
		}
		
		
	}

	public Set<Waypoint> getWaypoints() {
		return waypoints;
	}

	public void setWaypoints(Set<Waypoint> waypoints) {
		this.waypoints = waypoints;
	}

	public int getRouteColor() {
		return routeColor;
	}

	public void setRouteColor(int routeColor) {
		this.routeColor = routeColor;
	}

}
