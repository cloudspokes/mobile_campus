@isTest
private class  mob_BusStop_Schedule_Test {
  
  static testmethod void testStudentRest() {
    User aaUStudent = mob_TestUtil.makeUser('AAU Student - Platform');
    System.runAs(aaUStudent) {
    
           
          Bus_Route__c busRoute = mob_TestUtil.createBusRoute('new Test');
          Double lat =  37.788008;
          Double longitute = -122.400682;
          Bus_Stop__c busStop = mob_TestUtil.createBusStop('First', lat, longitute);
          Bus_Stops_Routes__c busStopRoutes = new Bus_Stops_Routes__c();
          busStopRoutes.Bus_Route__c = busRoute.Id;
          busStopRoutes.Bus_Stop__c = busStop.Id;
          busStopRoutes.Stop_Order__c = 1;
          
          Bus_Stop_Schedule__c schedule = mob_TestUtil.createBusSchedule(busStop.Id, busRoute.Id,2,'10:30PM');
          
          RestRequest req = new RestRequest(); 
          RestResponse res = new RestResponse();
          
          req.addParameter('busStopName', 'First');

          // pass the req and resp objects to the method     
          req.requestURI = 'https://aau--dev6.cs12.my.salesforce.com/services/apexrest/BusStopSchedule/';  
          req.httpMethod = 'GET';
          mob_BusStop_Schedule.getBusStopSchedule(req,res);
    }
  }    
}