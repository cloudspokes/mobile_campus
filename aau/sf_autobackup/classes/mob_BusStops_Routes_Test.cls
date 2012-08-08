@isTest
private class  mob_BusStops_Routes_Test {
	
	static testmethod void testStudentRest() {
		User aaUStudent = TestUtil.makeUser('AAU Student - Platform');
		System.runAs(aaUStudent) {
			    Bus_Route__c busRoute = TestUtil.createBusRoute('new Test');
			    Double lat =  37.788008;
			    Double longitute = -122.400682;
			    Bus_Stop__c busStop = TestUtil.createBusStop('First', lat, longitute);
			    Bus_Stops_Routes__c busStopRoutes = new Bus_Stops_Routes__c();
			    busStopRoutes.Bus_Route__c = busRoute.Id;
			    busStopRoutes.Bus_Stop__c = busStop.Id;
			    busStopRoutes.Stop_Order__c = 1;
				
				RestRequest req = new RestRequest(); 
    			RestResponse res = new RestResponse();

                // pass the req and resp objects to the method		 
                req.requestURI = 'https://aau--dev6.cs12.my.salesforce.com/services/apexrest/BusStops/';  
                req.httpMethod = 'GET';
    			mob_BusStops_Routes.getBusRoutes(req,res);
		}
	}		
}