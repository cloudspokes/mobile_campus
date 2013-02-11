package com.appirio.mobile.aau.nativemap;

import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.appirio.aau.R;
import com.google.android.gms.maps.GoogleMap.InfoWindowAdapter;
import com.google.android.gms.maps.GoogleMap.OnInfoWindowClickListener;
import com.google.android.gms.maps.model.Marker;

public class TransitMapInfoWindowAdapter implements InfoWindowAdapter, OnInfoWindowClickListener {

	private Context ctx;
	
	public TransitMapInfoWindowAdapter(Context ctx) {
		this.ctx = ctx;
	}
	
	@Override
	public View getInfoContents(Marker marker) {
		try {
			JSONObject markerInfo = new JSONObject(marker.getTitle());
			
			if(markerInfo.has("type") && markerInfo.getString("type").equals("stop")) {
				View result = ((Activity)ctx).getLayoutInflater().inflate(R.layout.bus_stop_info_window, null);
				
				((TextView)result.findViewById(R.id.txtRoutes)).setText(markerInfo.getString("routes"));
				((TextView)result.findViewById(R.id.txtStopName)).setText(markerInfo.getString("stopName"));

				View imgvwOpenStopDetails = result.findViewById(R.id.imgvwOpenStopDetails);
				imgvwOpenStopDetails.setClickable(true);
				
				return result;
			} else if (markerInfo.has("type") && markerInfo.getString("type").equals("bus")) {
				View result = ((Activity)ctx).getLayoutInflater().inflate(R.layout.bus_info_window, null);
				
				((TextView)result.findViewById(R.id.txtBusRoute)).setText(markerInfo.getString("route"));
				
				return result;
			}
			
			return null;
			
		} catch (Exception ex) {
			ex.printStackTrace();
			
			return null;
		}
	}

	@Override
	public View getInfoWindow(Marker arg0) {
		return null;
	}

	@Override
	public void onInfoWindowClick(Marker arg0) {
		Builder builder = new AlertDialog.Builder(ctx);
		
		builder.setMessage("Here is where the routes go!");
		
		builder.create().show();
	}

}
