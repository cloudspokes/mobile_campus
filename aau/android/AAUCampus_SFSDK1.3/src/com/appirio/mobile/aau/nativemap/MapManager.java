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
	private MapAPIProxy mapProxy;
	private GoogleMap map;
	private boolean mapAvailable;
	private BitmapDescriptor stopBitmap;
	private Map<String, BitmapDescriptor> routeIconMap;
	private BitmapDescriptor defaultBusIcon;
	private List<Marker> vehicleMarkers = new ArrayList<Marker>();
	private MapUpdater mapUpdater;
	private List<String> routes;
	private RoutesParser transitManager;
	private TransitMapInfoWindowAdapter infoWindowAdapter;
	
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
			transitManager = new RoutesParser(busRoutes);
			routeIconMap = new HashMap<String, BitmapDescriptor>();
			infoWindowAdapter = new TransitMapInfoWindowAdapter(this.ctx);
			
			try {
				for(Route route : transitManager.getRoutes()) {
					String markerName = route.getMarkerIcon();
					
					markerName = markerName.toLowerCase().substring(0, markerName.length() - 4);
					
					routeIconMap.put(route.getName(), BitmapDescriptorFactory.fromResource(this.ctx.getResources().getIdentifier(markerName, "drawable", this.ctx.getPackageName())));
				}
				
				for(BusStop stop : transitManager.getStops()) {
					JSONObject markerInfo = new JSONObject();
					
					MarkerOptions mo = new MarkerOptions();
					
					mo.icon(stopBitmap);
					
					markerInfo.put("type", "stop");
					markerInfo.put("stopName", stop.getAddress());
					markerInfo.put("routes", stop.getRoutesString());
					
					mo.title(markerInfo.toString());
					
					mo.position(new LatLng(stop.getLatitude(), stop.getLongitude()));
					
					map.addMarker(mo);
				}
				
				map.setInfoWindowAdapter(infoWindowAdapter);
				map.setOnInfoWindowClickListener(infoWindowAdapter);
				map.setMyLocationEnabled(true);
				
				new Thread(mapUpdater).start();
			} catch (Exception e) {
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
					JSONObject markerInfo = new JSONObject();
					
					MarkerOptions mo = new MarkerOptions();
					LatLng pos = new LatLng(v.getLatitude(), v.getLongitude());

					BitmapDescriptor bd = routeIconMap.get(v.getRoute());
					
					if(bd == null) {
						bd = defaultBusIcon;
					}
					
					mo.position(pos);
					mo.icon(bd);
					
					try {
						markerInfo.put("type", "bus");
						markerInfo.put("route", v.getRoute());
						mo.title(markerInfo.toString());
					} catch (JSONException e) {
						e.printStackTrace();
						
						mo.title(v.getRoute());
					}
					
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
}
 