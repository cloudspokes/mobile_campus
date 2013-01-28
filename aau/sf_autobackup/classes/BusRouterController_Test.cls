@isTest
public class BusRouterController_Test {
    
    static testMethod void testAll() {
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
        
        con.crosses = con.getCrosses();
        // now update crosses_json
        crosses_json.Val__c = JSON.serialize(con.crosses);
        update crosses_json;
        
        // test getCrosses
        System.assertEquals(con.crosses.keySet().size(), 4); // 4 routes
        System.assertEquals(con.crosses.get('R1').size(), 1); // cross with 1 route R2
        System.assertEquals(con.crosses.get('R1').get('R2').size(), 1); // R1 & R2 crosses at 1 point
        System.assertEquals(con.crosses.get('R1').get('R3'), null); // R1 & R2 don't cross
        System.assertEquals(con.crosses.get('R3').get('R4').size(), 2); // R3 & R4 crosses at 2 points
        
        // schedule
        transient List<Bus_Stop_Schedule__c> scheds = new List<Bus_Stop_Schedule__c>();
        
        /*
        for(Integer r=0; r<4; r++) {
            for(Integer s=0; s<2; s++) {
                Integer x = s + (2 * r);
                for(Decimal t=8.00; t<9.00; t + 0.20) {
                    scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c=String.valueOf(t).replace('.', ':') + ' AM', Bus_Stop__c=stops[x].Id, Bus_Route__c=routes[r].Id, Order__c=0));
                }
            }   
        }
        
        insert scheds;
        */
        
        scheds.clear();
        scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c='8:10 AM', Bus_Stop__c=stops[0].Id, Bus_Route__c=routes[0].Id, Order__c=0));
        
        scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c='8:20 AM', Bus_Stop__c=stops[1].Id, Bus_Route__c=routes[0].Id, Order__c=0));
        scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c='8:25 AM', Bus_Stop__c=stops[1].Id, Bus_Route__c=routes[0].Id, Order__c=0));
        scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c='8:30 AM', Bus_Stop__c=stops[1].Id, Bus_Route__c=routes[1].Id, Order__c=0));
        
        scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c='8:30 AM', Bus_Stop__c=stops[2].Id, Bus_Route__c=routes[1].Id, Order__c=0));
        scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c='8:35 AM', Bus_Stop__c=stops[2].Id, Bus_Route__c=routes[1].Id, Order__c=0));
        
        scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c='8:40 AM', Bus_Stop__c=stops[3].Id, Bus_Route__c=routes[1].Id, Order__c=0));
        
        insert scheds;
        //List<Bus_Stop_Schedule__c> scheds_test = [select Time_Value__c, Id from Bus_Stop_Schedule__c];
        
        con.startBusStopId = stops[0].Id; // s1-1
        con.endBusStopId = stops[3].Id; // s2-2
        con.startTime = 8.00;
        con.getAllPathways(2); // limit to 2 transfers
        
        System.assertEquals(con.pathways.keySet().size(), 1); // just 1 route
        System.assertEquals(con.pathways.containsKey(con.bestPathways[0]), true);
        System.assertEquals(con.getBestPathway(), con.pathways.get(con.bestPathways[0]));
        System.assertEquals(con.getBestPathwayLines().size(), con.getBestPathway().size());
        System.assertEquals(con.getBestPathwayJSON(), JSON.serializePretty(con.getBestPathway()));
        
        System.assertEquals(con.getPathwaysJSON(), JSON.serializePretty(con.pathways));
        System.assertEquals(con.getArrivalsJSON(), JSON.serializePretty(con.arrivalSchedules));
        System.assertEquals(con.getBestPathwaysJSON(), JSON.serializePretty(con.getBestPathwaysMAP()));
        System.assertEquals(con.getBestPathwaysMAP().containsKey(con.bestPathways[0]), true);
        

        scheds.clear();
        scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c='11:40 PM', Bus_Stop__c=stops[0].Id, Bus_Route__c=routes[0].Id, Order__c=0));
        
        scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c='11:45 PM', Bus_Stop__c=stops[1].Id, Bus_Route__c=routes[0].Id, Order__c=0));
        scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c='11:50 PM', Bus_Stop__c=stops[1].Id, Bus_Route__c=routes[0].Id, Order__c=1));
        // R1 => R2 at s1-2
        scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c='11:55 PM', Bus_Stop__c=stops[1].Id, Bus_Route__c=routes[1].Id, Order__c=2));
        
        // R2 at s2-1
        scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c='11:50 PM', Bus_Stop__c=stops[2].Id, Bus_Route__c=routes[1].Id, Order__c=0));
        scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c='00:25 AM', Bus_Stop__c=stops[2].Id, Bus_Route__c=routes[1].Id, Order__c=1));
        scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c='00:35 AM', Bus_Stop__c=stops[2].Id, Bus_Route__c=routes[1].Id, Order__c=2));
        
        // R2 at s2-2
        scheds.add(new Bus_Stop_Schedule__c(Name='', Time__c='00:40 AM', Bus_Stop__c=stops[3].Id, Bus_Route__c=routes[1].Id, Order__c=0));
        
        insert scheds;
        //List<Bus_Stop_Schedule__c> scheds_test = [select Time_Value__c, Id from Bus_Stop_Schedule__c];
        
        // over midnight
        con.startBusStopId = stops[0].Id; // s1-1
        con.endBusStopId = stops[3].Id; // s2-2
        con.startTime = 23.30;
        con.getAllPathways(3); // limit to 3 transfers

        System.assertEquals(con.pathways.keySet().size(), 1); // just 1 route
        System.assertEquals(con.pathways.containsKey(con.bestPathways[0]), true);
        System.assertEquals(con.getBestPathway(), con.pathways.get(con.bestPathways[0]));
        System.assertEquals(con.getBestPathwayLines().size(), con.getBestPathway().size());
        System.assertEquals(con.getBestPathwayJSON(), JSON.serializePretty(con.getBestPathway()));
        
        // over midnight same schedule but starting time is a bit later
        con.startTime = 23.45;
        con.getAllPathways(3); // limit to 3 transfers
        
        System.assertEquals(con.pathways.keySet().size(), 0); // no route!
                        
        // no pathway possible yet!
        con.endBusStopId = stops[5].Id; // s3-2
        con.getAllPathways(2); // limit to 2 transfers
                
        System.assertEquals(con.getBestPathway(), null);
        System.assertEquals(con.getBestPathwayLines()[0], 'none');

        PageReference ref = new PageReference('/apex/bus_router_debug?fromId=a02d0000007URVD&toId=a02d0000007URV0&now=22'); 
        Test.setCurrentPage(ref);
        
        // test controller from VF
        BusRouterController page_con = new BusRouterController();

        Double startTime = 22.0;
        System.assertEquals(page_con.startTime, startTime);
        System.assertEquals(page_con.startBusStopId, 'a02d0000007URVD');
        System.assertEquals(page_con.endBusStopId, 'a02d0000007URV0');
        
                                     
    }
}