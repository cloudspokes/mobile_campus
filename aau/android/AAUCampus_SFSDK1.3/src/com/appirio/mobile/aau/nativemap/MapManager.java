package com.appirio.mobile.aau.nativemap;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.cordova.DroidGap;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;

import com.appirio.aau.R;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;

public class MapManager {

	private Context ctx;
	private LatLng initialPos = new LatLng(37.789238, -122.401407);
	private JSONArray busRoutes;
	private Map<String, JSONObject> stopsMap = new HashMap<String, JSONObject>();
	private MapAPIProxy mapProxy;
	private GoogleMap map;
	private boolean mapAvailable;
	private BitmapDescriptor stopBitmap; 
	

	public MapManager(Context ctx, GoogleMap map) throws AMException {
		this.ctx = ctx;
		mapProxy = new MapAPIProxy((DroidGap)this.ctx);
		this.map = map;
		
		// Center and zoom map on initial position
		try {
			MapsInitializer.initialize(ctx);
			
			stopBitmap = BitmapDescriptorFactory.fromResource(R.drawable.marker_busstop);

			mapAvailable = true;
			
			// Load bus stop data from Salesforce
			busRoutes = mapProxy.getBusStops();

			try {
				for(int i = 0; i < busRoutes.length(); i++) {
					JSONObject route = (JSONObject) busRoutes.get(i);
					JSONArray routeStops = (JSONArray) route.get("stops");
					
					for(int j = 0; j < routeStops.length(); j++) {
						JSONObject stop = (JSONObject) routeStops.get(j);
						
						stopsMap.put(stop.get("id").toString(), stop);
					}
				}

				for(String id : stopsMap.keySet()) {
					JSONObject stop = stopsMap.get(id);
					
					MarkerOptions mo = new MarkerOptions();
					LatLng pos = new LatLng(stop.getDouble("latitude"), stop.getDouble("longitude"));
					
					mo.icon(stopBitmap);
					mo.position(pos);
					
					map.addMarker(mo);
				}

			} catch (JSONException e) {
				e.printStackTrace();
				
				throw new AMException(e);
			}
			
			
			List<Vehicle> vehicles = new TeletracInfoParser().parse(mapProxy.getVehicles());
			
			for(Vehicle v: vehicles) {
				MarkerOptions mo = new MarkerOptions();
				LatLng pos = new LatLng(v.getLatitude(), v.getLongitude());
				BitmapDescriptor bd = BitmapDescriptorFactory.fromResource(R.drawable.aaulogo);
				
				mo.position(pos);
				mo.icon(bd);
				
				map.addMarker(mo);
			}
		} catch (GooglePlayServicesNotAvailableException e) {
			// TODO handle map is not available situation
			e.printStackTrace();
			
			mapAvailable = false;
		}
		
		
	}
	
	public void showMap() {
		if(mapAvailable) {
			map.animateCamera(CameraUpdateFactory.newLatLngZoom(initialPos, 14.0f));
			
		}
		
	}
}
