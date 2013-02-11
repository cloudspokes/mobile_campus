package com.appirio.mobile.aau.nativemap;

import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.appirio.aau.R;
import com.google.android.gms.maps.GoogleMap.InfoWindowAdapter;
import com.google.android.gms.maps.model.Marker;

public class TransitMapInfoWindowAdapter implements InfoWindowAdapter {

	private Context ctx;
	
	public TransitMapInfoWindowAdapter(Context ctx) {
		this.ctx = ctx;
	}
	
	@Override
	public View getInfoContents(Marker arg0) {
		View result = ((Activity)ctx).getLayoutInflater().inflate(R.layout.bus_stop_info_window, null);
		
		//((TextView)result.findViewById(R.id.txtStopName)).setText("Testing!!!");
		
		return result;
	}

	@Override
	public View getInfoWindow(Marker arg0) {
		return null;
	}

}
