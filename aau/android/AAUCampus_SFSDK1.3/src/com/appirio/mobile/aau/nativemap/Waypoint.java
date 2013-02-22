package com.appirio.mobile.aau.nativemap;

import org.json.JSONException;
import org.json.JSONObject;

public class Waypoint {

	private double latitude;
	private double longitude;
	private int order;
	
	public Waypoint(JSONObject waypoint) {
		try {
			this.order = waypoint.getInt("stopOrder");
			this.latitude = waypoint.getDouble("latitude");
			this.longitude = waypoint.getDouble("longitude");

		} catch (JSONException e) {
			e.printStackTrace();
		}
	}
	
	public double getLatitude() {
		return latitude;
	}
	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}
	public double getLongitude() {
		return longitude;
	}
	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}
	public int getOrder() {
		return order;
	}
	public void setOrder(int order) {
		this.order = order;
	}
	
	
}
