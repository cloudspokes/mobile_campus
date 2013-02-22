package com.appirio.mobile.aau.nativemap;

import java.util.HashSet;
import java.util.Set;

import org.json.JSONObject;

public class BusStop {
	
	private String address;
	private Set<String> routes = new HashSet<String>();
	private double latitude;
	private double longitude;
	private int order;
	
	public int getOrder() {
		return order;
	}

	public void setOrder(int order) {
		this.order = order;
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

	public BusStop(JSONObject jsonStop) throws AMException {
		try {
			this.address = jsonStop.getString("stopName");
			
			this.latitude = jsonStop.getDouble("latitude");
			this.longitude = jsonStop.getDouble("longitude");
			
			this.order = jsonStop.getInt("stopOrder");
			
		} catch (Exception e) {
			e.printStackTrace();
			
			throw new AMException(e);
		}
	}

	public String getAddress() {
		return address;
	}
	
	public void setAddress(String address) {
		this.address = address;
	}
	
	public Set<String> getRoutes() {
		return routes;
	}
	
	public void setRoutes(Set<String> routes) {
		this.routes = routes;
	}
	
	public void addRoute(String route) {
		routes.add(route);
	}

	public String getRoutesString() {
		StringBuilder result = new StringBuilder();
		String separator = "";
		
		for(String route : routes) {
			result.append(separator);
			result.append(route);
			
			separator = ", ";
		}
		
		return result.toString();
	}

}
