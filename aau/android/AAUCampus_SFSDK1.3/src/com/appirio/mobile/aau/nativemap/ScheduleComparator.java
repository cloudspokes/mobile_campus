package com.appirio.mobile.aau.nativemap;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Comparator;
import java.util.Date;

public class ScheduleComparator implements Comparator<String> {

	private SimpleDateFormat format = new SimpleDateFormat("h:mm a");
	
	@Override
	public int compare(String lhs, String rhs) {
		try {
			Date date1 = format.parse(lhs);
			Date date2 = format.parse(rhs);
			
			return date1.compareTo(date2);
		} catch (ParseException e) {
			e.printStackTrace();
			
			return lhs.compareTo(rhs);
		}
	}

}
