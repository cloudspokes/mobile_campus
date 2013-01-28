@isTest
public class mob_NextStopLocator_Test {
	
	static testMethod void testNextStopLocator() {
        List<Bus_Route__c> routes = new List<Bus_Route__c>();
        List<Bus_Stop__c> stops = new List<Bus_Stop__c>();
        List<Bus_Stops_Routes__c> stops_routes = new List<Bus_Stops_Routes__c>();
        
        BusRouterController con = new BusRouterController('dummy');
        
        for(Integer r=1; r<5; r++) {
            routes.add(new Bus_Route__c(Name='R'+ r));
            
            for(Integer s=1; s<3; s++) {
                stops.add(new Bus_Stop__c(Name='S'+ r +'-'+ s));
            }
        }
        
        insert routes;
        insert stops;
        
        for(Integer r=0; r<4; r++) {
            for(Integer s=0; s<2; s++) {
                Integer x = s + (2 * r);
                stops_routes.add(new Bus_Stops_Routes__c(Name='', Bus_Stop__c=stops[x].Id, Bus_Route__c=routes[r].Id, Stop_Order__c=s));
            }
        }
        
        insert stops_routes;
        
        con.crosses = con.getCrosses();
        // test basic getCrosses (without any crosses yet)
        System.assertEquals(con.crosses.keySet().size(), 4); // 4 routes
        System.assertEquals(con.crosses.get('R1').size(), 0); // 0 crosses
        
        // insert crosses_json
        Key_Val__c crosses_json = new Key_Val__c(Name='bus_router_crosses', Val__c=JSON.serialize(con.getCrosses()));
        insert crosses_json;
        
        // test basic getCrossesFromJSON (without any crosses yet)
        System.assertEquals(con.getCrossesFromJSON().keySet(), con.crosses.keySet());
        
        // now with crossings (the 2nd stop on each route, end at next route)
        stops_routes.clear();
        stops_routes.add(new Bus_Stops_Routes__c(Name='X', Bus_Stop__c=stops[1].Id, Bus_Route__c=routes[1].Id, Stop_Order__c=2));
        stops_routes.add(new Bus_Stops_Routes__c(Name='X', Bus_Stop__c=stops[3].Id, Bus_Route__c=routes[2].Id, Stop_Order__c=2));
        stops_routes.add(new Bus_Stops_Routes__c(Name='X', Bus_Stop__c=stops[5].Id, Bus_Route__c=routes[3].Id, Stop_Order__c=2));
        
        // R3 and R4 crosses 1 more time
        stops_routes.add(new Bus_Stops_Routes__c(Name='X', Bus_Stop__c=stops[4].Id, Bus_Route__c=routes[3].Id, Stop_Order__c=1));
        
        insert stops_routes;
        
        mob_NextStopLocator nextStopLocator = new mob_NextStopLocator();
        
        list<Bus_Stop__c> lst = nextStopLocator.getAllBusStops();
        nextStopLocator.getNextStops('X');
        
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        req.addParameter('fromId','R1');
        req.addParameter('toId','SR1-S');
        req.addParameter('startTime','10.00');
        
        // pass the req and resp objects to the method		 
        req.requestURI = 'https://aau--dev6.cs12.my.salesforce.com/services/apexrest/tripplanner/getBestRoutes';  
        req.httpMethod = 'GET';
       
    	mob_TripPlanner.getBestPathway(); 
    	mob_TripPlanner.getBestPathwayLines();
    	
    	mob_TripPlanner.getBestRoutes(req,res);   
	 }

}