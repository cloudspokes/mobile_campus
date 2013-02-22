package com.appirio.mobile.aau.nativemap;

import java.util.Comparator;

public class BusStopOrderComparator implements Comparator<BusStop> {

	@Override
	public int compare(BusStop stop1, BusStop stop2) {
		return Integer.valueOf(stop1.getOrder()).compareTo(Integer.valueOf(stop2.getOrder()));
	}

}
