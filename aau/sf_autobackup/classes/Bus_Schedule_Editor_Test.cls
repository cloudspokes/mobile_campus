@isTest
private class Bus_Schedule_Editor_Test {

   public static  User sysAdmin;
	public static  Bus_Route__c route;
	public static  Bus_Stop__c stop1;
	public static  Bus_Stop__c stop2;
	public static  Bus_Stops_Routes__c stop1route;
	public static  Bus_Stops_Routes__c stop2route;
	public static  Bus_Stop_Schedule__c stop1Schedule;
	public static  Bus_Stop_Schedule__c stop2Schedule; 
	static{
		sysAdmin = mob_TestUtil.makeUser('System Administrator');
	}
	static testmethod void testScheduleEditor(){
		System.runAs(sysAdmin){
			
			route = mob_TestUtil.createBusRoute('NorthTest');
			stop1 = mob_TestUtil.createBusStop('Stop A', (37.78218800).doubleValue(), (-122.41895900).doubleValue());
			stop2 = mob_TestUtil.createBusStop('Stop B', (37.78238800).doubleValue(), (-122.41895900).doubleValue());
			stop1route = mob_TestUtil.createBusStopRoute(stop1.id, route.id, 0);
			stop2route = mob_TestUtil.createBusStopRoute(stop2.id, route.id, 1);
			stop1Schedule = mob_TestUtil.createBusSchedule(stop1.id, route.id, 0, '1:15PM');
			stop2Schedule = mob_TestUtil.createBusSchedule(stop2.id, route.id, 1, '1:30 PM');
			
				Bus_Schedule_Editor_Controller con = new Bus_Schedule_Editor_Controller();
				List<Bus_Schedule_Editor_Controller.BusStopSchedule> lstSch = Bus_Schedule_Editor_Controller.get_ScheduleData(route.Id,  '0');
				 system.assert(lstSch.size()>0);
				 
				 List<string> str_routestops = new List<string>(); 
		 	 	 str_routestops.add( '{Stop_Order__c=0, Bus_Route__c=' + route.id + ', type=Bus_Stops_Routes_Staging__c, Bus_Stop__c=' + stop1.id + '}');
		 	 	 str_routestops.add( '{Stop_Order__c=1, Bus_Route__c=' + route.id + ', type=Bus_Stops_Routes_Staging__c, Bus_Stop__c=' + stop2.id + '}');

				List<string> str_sch = new List<string>();
				str_sch.add('{Bus_Route__c=' + route.id + ', Time__c=7:10 AM, Sub_Route__c=0, Order__c=0, type=Bus_Stop_Schedule_Staging__c, Bus_Stop__c=' + stop1.id + '}'); 
				str_sch.add('{Bus_Route__c=' + route.id + ', Time__c=7:15 AM, Sub_Route__c=0, Order__c=1, type=Bus_Stop_Schedule_Staging__c, Bus_Stop__c=' + stop2.id + '}');

		 	 	 string res = Bus_Schedule_Editor_Controller.save_ScheduleData( route.id,  '0', str_routestops,str_sch );
		 	 	 system.assert(res=='');
		 	 	 
		 	 	 lstSch = Bus_Schedule_Editor_Controller.get_ScheduleData(route.Id,  '0');
		 	 	system.assert(lstSch.size()>0);
		 	 	
		 	 	 res = Bus_Schedule_Editor_Controller.publish_ScheduleData(route.id, '0');
		 	 	   system.assert(res=='');
		 	 	 
		 	 	  str_routestops = new List<string>();
		 	 	 str_routestops.add( '{Stop_Order__c=0, Bus_Route__c=' + route.id + ', type=Bus_Stops_Routes_Staging__c, Bus_Stop__c=' + stop1.id + '}');
		 	 	 str_routestops.add( '{Stop_Order__c=1, Bus_Route__c=' + route.id + ', type=Bus_Stops_Routes_Staging__c, Bus_Stop__c=' + stop2.id + '}');

				 str_sch = new List<string>();
				str_sch.add('{Bus_Route__c=' + route.id + ', Time__c=7:10 AM, Sub_Route__c=0, Order__c=0, type=Bus_Stop_Schedule_Staging__c, Bus_Stop__c=' + stop1.id + '}'); 
				str_sch.add('{Bus_Route__c=' + route.id + ', Time__c=7:15 AM, Sub_Route__c=0, Order__c=1, type=Bus_Stop_Schedule_Staging__c, Bus_Stop__c=' + stop2.id + '}');
				
		 	 	  res = Bus_Schedule_Editor_Controller.save_ScheduleData( route.id,  '0', str_routestops,str_sch );
		 	 	 system.assert(res=='');
		 	 	  res = Bus_Schedule_Editor_Controller.publish_ScheduleData_All();
		 	 	   system.assert(res=='');
		 	 	
				 List<Bus_Route__c> lst = Bus_Schedule_Editor_Controller.add_Route(  'newTestRoute',  'red', 'red', 'newTestRoute', true, '');
				 system.assert(lst.size()>1);
				 
			
		}
	}
}