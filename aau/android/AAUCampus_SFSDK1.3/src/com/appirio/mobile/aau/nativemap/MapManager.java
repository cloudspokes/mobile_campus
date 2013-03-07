package com.appirio.mobile.aau.nativemap;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Vector;

import org.apache.cordova.DroidGap;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;

import com.appirio.aau.R;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.gms.maps.model.Polyline;
import com.google.android.gms.maps.model.PolylineOptions;

public class MapManager {

	private Context ctx;
	private LatLng initialPos = new LatLng(37.789238, -122.401407);
	private JSONArray busRoutes;
	private APIProxy mapProxy;
	private GoogleMap map;
	private boolean mapAvailable;
	private BitmapDescriptor stopBitmap;
	private Map<String, BitmapDescriptor> routeIconMap;
	private BitmapDescriptor defaultBusIcon;
	private List<Marker> vehicleMarkers = new Vector<Marker>();
	private MapUpdater mapUpdater;
	private RoutesParser routesParser;
	private TransitMapInfoWindowAdapter infoWindowAdapter;
	private List<Polyline> routesPolylineShown;
	private List<Route> routesShown;
	private List<BusStop> allBusStopsList = new ArrayList<BusStop>();
	private MapManager mapManager;
	private List<MarkerOptions> busStopsMos;
	private boolean isInit = false;

	public ArrayList<RouteStopSchedule> getSchedule(String stopName) throws AMException {
		try {
			JSONObject schedule = mapProxy.getSchedule(stopName);
			ArrayList<RouteStopSchedule> result = new ArrayList<RouteStopSchedule>();
			
			JSONArray routes = schedule.getJSONArray("routes");
			
			for(int i = 0; i < routes.length(); i++) {
				result.add(new RouteStopSchedule((JSONObject) routes.get(i)));
			}
			
			return result;
		} catch (JSONException e) {
			e.printStackTrace();
			
			throw new AMException(e);
		}
	}
	
	public List<Route> getRoutesShown() {
		return routesShown;
	}
	
	public void init() {
		if(!isInit) {
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					try {
						
						busRoutes = mapProxy.getBusStops();
						routesParser = new RoutesParser(busRoutes);

						MapsInitializer.initialize(ctx);
						
						stopBitmap = BitmapDescriptorFactory.fromResource(R.drawable.marker_busstop);
						defaultBusIcon = BitmapDescriptorFactory.fromResource(R.drawable.marker_busstop_black_suware);
						mapAvailable = true;
						
						// Load bus stop data from Salesforce
						routeIconMap = new HashMap<String, BitmapDescriptor>();
						infoWindowAdapter = new TransitMapInfoWindowAdapter(ctx, mapManager);
						routesPolylineShown = new Vector<Polyline>();
						routesShown = new Vector<Route>();
						
						try {
							for(Route route : routesParser.getRoutes()) {
								String markerName = route.getMarkerIcon();
								
								if(markerName != null && markerName.length() > 5) {
									markerName = markerName.toLowerCase().substring(0, markerName.length() - 4);
								}
								
								routeIconMap.put(route.getName(), BitmapDescriptorFactory.fromResource(ctx.getResources().getIdentifier(markerName, "drawable", ctx.getPackageName())));
							}
							allBusStopsList.clear();
							for(BusStop stop : routesParser.getStops()) {
								
								allBusStopsList.add(stop);
								
								MarkerOptions mo = new MarkerOptions();
								mo.icon(stopBitmap);
								JSONObject markerInfo = getMarkerJSON(stop);
								mo.title(markerInfo.toString());
								mo.position(new LatLng(stop.getLatitude(), stop.getLongitude()));
								
								busStopsMos.add(mo);
							}
							
							((Activity)ctx).runOnUiThread(new Runnable() {
								
								@Override
								public void run() {
									
									for(MarkerOptions mo : busStopsMos) {
										map.addMarker(mo);
									}
									
									map.setInfoWindowAdapter(infoWindowAdapter);
									map.setOnInfoWindowClickListener(infoWindowAdapter);
									map.setMyLocationEnabled(true);
									
									map.animateCamera(CameraUpdateFactory.newLatLngZoom(initialPos, 14.0f));

								}
							});
							
							new Thread(mapUpdater).start();
							
							isInit = true;
						} catch (Exception e) {
							e.printStackTrace();
							
							//throw new AMException(e);
						}				
				} catch (Exception e) {
					// TODO handle map is not available situation
					e.printStackTrace();
					
				}
			}
			}).start();			
		}
	}
	
	public MapManager(Context _ctx, GoogleMap _map) throws AMException {
		this.ctx = _ctx;
		mapProxy = new APIProxy((DroidGap)this.ctx);
		this.map = _map;
		this.mapUpdater = new MapUpdater();
		mapManager = this;
		busStopsMos = new Vector<MarkerOptions>();
		
		init();
	}
	
	public void showMap() {
		if(mapAvailable) {
			if(!isInit) {
				this.init();
			}
			map.animateCamera(CameraUpdateFactory.newLatLngZoom(initialPos, 14.0f));
		}
	}
	
	public List<Route> getRoutes() {
		return routesParser.getRoutes();
	}
	
	public void showRoutes(Set<String> routeNames) throws AMException, JSONException {
		for(Polyline route : routesPolylineShown) {
			route.remove();
		}
		
		routesPolylineShown.clear();
		routesShown.clear();
		map.clear();

		routesShown = routesParser.getRoutes(routeNames);
		
		
		for(Route r : routesShown) {
			PolylineOptions route = new PolylineOptions();
			
			route.color(r.getRouteColor());
			
			for(Waypoint stop : r.getWaypoints()) {
				LatLng point = new LatLng(stop.getLatitude(), stop.getLongitude());
				
				route.add(point);
			}
			
			if(r.getWaypoints().size() > 0) {
				Waypoint stop = r.getWaypoints().iterator().next();
				
				LatLng point = new LatLng(stop.getLatitude(), stop.getLongitude());
				
				route.add(point);
			}
			
			routesPolylineShown.add(map.addPolyline(route));
			
			// Set stops for route
			displayBusStopForGivenRoute(r);
			
		}
		
		// If no routes select show all stops
		if (routesShown.size() == 0){
			showAllBusStops();
		}
		mapUpdater.refreshBusesUI();
	}
	
	private void displayBusStopForGivenRoute(Route r) throws JSONException {
		for (BusStop stop : r.getBusStops()){
			MarkerOptions mo = new MarkerOptions();
			
			mo.icon(stopBitmap);
			
			JSONObject markerInfo = getMarkerJSON(stop);			
			mo.title(markerInfo.toString());
			
			mo.position(new LatLng(stop.getLatitude(), stop.getLongitude()));
			
			busStopsMos.add(mo);
			map.addMarker(mo);
		}
		
	}
	
	/**
	 * Display all bus stops on the map
	 * @throws JSONException
	 */
	private void showAllBusStops() throws JSONException{
		busStopsMos.clear();
		for(BusStop stop : allBusStopsList) {

			MarkerOptions mo = new MarkerOptions();

			mo.icon(stopBitmap);

			JSONObject markerInfo = getMarkerJSON(stop);
			mo.title(markerInfo.toString());

			mo.position(new LatLng(stop.getLatitude(), stop.getLongitude()));

			busStopsMos.add(mo);
			map.addMarker(mo);
		}					
	}
	
	private JSONObject getMarkerJSON(BusStop stop) throws JSONException {
		JSONObject markerInfo = new JSONObject();

		markerInfo.put("type", "stop");
		markerInfo.put("stopName", stop.getAddress());
		markerInfo.put("routes", stop.getRoutesString());

		return markerInfo;
	}
	
	public void startAutoUpdate() {
		mapUpdater.autoRefreshOn = true;
		
		new Thread(mapUpdater).start();
	}
	
	public void stopAutoUpdate() {
		mapUpdater.autoRefreshOn = false;
	}

	public boolean getAutoUpdate() {
		return mapUpdater.autoRefreshOn;
	}
	
	public List<BusStop> getBusStops() {
		if(routesParser != null) {
			return routesParser.getStops();
		} else {
			return new ArrayList<BusStop>();
		}
	}
	
	private class MapUpdater implements Runnable {

		private boolean autoRefreshOn = true;
		private int autoRefreshInterval = 30000;
		private List<Vehicle> vehicles;

		private MapUpdater() {
		}
		
		private void refreshBuses() throws AMException {
			vehicles = new TeletracInfoParser().parse(mapProxy.getVehicles());
		}

		private void refreshBusesUI() throws AMException {
			for(Marker m : vehicleMarkers) {
				m.remove();
			}
			
			vehicleMarkers.clear();
			
			if(vehicles != null) {
				for(Vehicle v: vehicles) {
					if(v.getVehicleName() != null && v.getRoute() != null) {
	
						if(shouldShowBus(v)) {
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
			}
		}

		private boolean shouldShowBus(Vehicle v) {
			if(routesShown.isEmpty()) {
				return true;
			} 
			
			for(Route route: routesShown) {
				if(route.getName().equals(v.getRoute())) {
					return true;
				}
			}
		
			return false;
		}

		@Override
		public void run() {
			try {
				while(this.autoRefreshOn) {
					this.refreshBuses();
					((Activity)ctx).runOnUiThread(new Runnable() {
						
						@Override
						public void run() {
							try {
								mapUpdater.refreshBusesUI();
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
 