package com.appirio.mobile.aau.nativemap;

import java.util.Comparator;

public class WaypointComparator implements Comparator<Waypoint> {

	@Override
	public int compare(Waypoint wp1, Waypoint wp2) {
		return Integer.valueOf(wp1.getOrder()).compareTo(Integer.valueOf(wp2.getOrder()));
	}

}
