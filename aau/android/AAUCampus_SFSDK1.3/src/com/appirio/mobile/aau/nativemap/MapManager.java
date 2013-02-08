package com.appirio.mobile.aau.nativemap;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.cordova.DroidGap;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;

import com.appirio.aau.R;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
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
	private Map<String, BitmapDescriptor> routeIconMap;
	private BitmapDescriptor defaultBusIcon;
	private List<Marker> vehicleMarkers = new ArrayList<Marker>();
	private MapUpdater mapUpdater;
	private List<String> routes;
	
	private class MapUpdater implements Runnable {

		private boolean autoRefreshOn = true;
		private int autoRefreshInterval = 30000;

		private MapUpdater() {
		}
		
		private void refreshBuses() throws AMException {
			List<Vehicle> vehicles = new TeletracInfoParser().parse(mapProxy.getVehicles());
			
			for(Marker m : vehicleMarkers) {
				m.remove();
			}
			
			vehicleMarkers.clear();
			
			for(Vehicle v: vehicles) {
				if(v.getVehicleName() != null && v.getRoute() != null) {
					MarkerOptions mo = new MarkerOptions();
					LatLng pos = new LatLng(v.getLatitude(), v.getLongitude());

					BitmapDescriptor bd = routeIconMap.get(v.getRoute());
					
					if(bd == null) {
						bd = defaultBusIcon;
					}
					
					mo.position(pos);
					mo.icon(bd);
					mo.title("Route: " + v.getRoute());
					
					vehicleMarkers.add(map.addMarker(mo));
				}
			}
			
		}

		@Override
		public void run() {
			try {
				while(this.autoRefreshOn) {
					((Activity)ctx).runOnUiThread(new Runnable() {
						
						@Override
						public void run() {
							try {
								mapUpdater.refreshBuses();
							} catch (AMException e) {
								e.printStackTrace();
							}
						}
					});
					Thread.currentThread().sleep(this.autoRefreshInterval);
				}
			} catch (Exception e) {
				// TODO handle issues refreshing buses
				e.printStackTrace();
			}
		}
		
	}

	public MapManager(Context ctx, GoogleMap map) throws AMException {
		this.ctx = ctx;
		mapProxy = new MapAPIProxy((DroidGap)this.ctx);
		this.map = map;
		this.mapUpdater = new MapUpdater();
		
		// Center and zoom map on initial position
		try {
			MapsInitializer.initialize(ctx);
			
			stopBitmap = BitmapDescriptorFactory.fromResource(R.drawable.marker_busstop);
			
			defaultBusIcon = BitmapDescriptorFactory.fromResource(R.drawable.marker_bus_darkred);

			mapAvailable = true;
			
			// Load bus stop data from Salesforce
			busRoutes = mapProxy.getBusStops();

			try {
				routeIconMap = new HashMap<String, BitmapDescriptor>(); 

				for(int i = 0; i < busRoutes.length(); i++) {
					JSONObject route = (JSONObject) busRoutes.get(i);
					JSONArray routeStops = (JSONArray) route.get("stops");

					for(int j = 0; j < routeStops.length(); j++) {
						JSONObject stop = (JSONObject) routeStops.get(j);
						String routeName = stop.get("routeTeletracName").toString();
						
						if(routeIconMap.get(routeName) == null) {
							String markerName = stop.get("routeMarker").toString();
							
							markerName = markerName.toLowerCase();
							markerName = markerName.substring(0, markerName.length() - 4);
							
							int markerId = this.ctx.getResources().getIdentifier(markerName, "drawable", this.ctx.getPackageName());
							
							if(markerId != 0) {
								routeIconMap.put(routeName, BitmapDescriptorFactory.fromResource(markerId));
							} else {
								routeIconMap.put(routeName, defaultBusIcon);
							}
						}
						
						stopsMap.put(stop.get("id").toString(), stop);
					}
				}

				routes = new ArrayList<String>();
				
				for(String id : stopsMap.keySet()) {
					JSONObject stop = stopsMap.get(id);

					String route = stop.get("routeTeletracName").toString();
					
					if(!routes.contains(route)) {
						routes.add(route);
					}
					
					MarkerOptions mo = new MarkerOptions();
					LatLng pos = new LatLng(stop.getDouble("latitude"), stop.getDouble("longitude"));
					
					mo.icon(stopBitmap);
					mo.position(pos);
					
					map.addMarker(mo);
				}

				new Thread(mapUpdater).start();
			} catch (JSONException e) {
				e.printStackTrace();
				
				throw new AMException(e);
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
	
	public List<String> getRoutes() {
		return routes;
	}
	
	public void showRoutes(List<String> routes) {
		
	}
}
 