package com.appirio.mobile.aau.nativemap;

import java.util.Comparator;

public class RouteStopScheduleComparator implements
		Comparator<RouteStopSchedule> {

	@Override
	public int compare(RouteStopSchedule lhs, RouteStopSchedule rhs) {
		return Long.valueOf(lhs.getNextBusETAInMillisSort()).compareTo(Long.valueOf(rhs.getNextBusETAInMillisSort()));
	}

}
