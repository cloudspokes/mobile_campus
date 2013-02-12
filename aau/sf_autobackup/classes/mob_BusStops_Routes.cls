@RestResource(urlMapping='/BusStops/')
global with sharing class  mob_BusStops_Routes {

    @HttpGet
    global static List<BusRoutes> getBusRoutes(RestRequest req, RestResponse res) {
        List<BusRoutes> busRoutes = new List<BusRoutes>();
        String rootName = null;
        Map<String,List<BusStop>> busStopMap = new Map<String,List<BusStop>> (); 
        Map<String,List<BusStop>> busStopHiFi = new Map<String,List<BusStop>>();
        for(Bus_Stops_Routes__c busStopRoutes:[Select  Bus_Stop__r.Long__c, Bus_Stop__r.Lat__c, Bus_Stop__r.High_Fidelity_Waypoint__c,
                                               Bus_Stop__r.Name, Bus_Stop__r.Active__c, Bus_Stop__r.Id, Bus_Stop__r.Order__c,
                                               Bus_Route__r.Name, Bus_Route__r.Route_Color__c, Bus_Route__r.Teletrac_Name__c,
                                               Bus_Route__r.Route_Marker__c, Bus_Route__r.Id
                                               From Bus_Stops_Routes__c where Bus_Route__r.Active__c = true and (Bus_Stop__r.Active__c = true OR Bus_Stop__r.High_Fidelity_Waypoint__c = true) order by Stop_Order__c ]){
            BusStop  stop = new BusStop();
            stop.id = busStopRoutes.Bus_Stop__r.Id;
            stop.stopName =  busStopRoutes.Bus_Stop__r.Name;
            stop.longitude = busStopRoutes.Bus_Stop__r.Long__c;
            stop.latitude =  busStopRoutes.Bus_Stop__r.Lat__c; 
            stop.active = busStopRoutes.Bus_Stop__r.Active__c;
            stop.color = busStopRoutes.Bus_Route__r.Route_Color__c; 
            stop.stopOrder = (Integer)busStopRoutes.Bus_Stop__r.Order__c; 
            stop.routeTeletracName = busStopRoutes.Bus_Route__r.Teletrac_Name__c;
            stop.routeMarker = busStopRoutes.Bus_Route__r.Route_Marker__c;
            BusRoutes routes = new BusRoutes();
            routes.stops = new List<BusStop>(); 
            if(busStopRoutes.Bus_Stop__r.High_Fidelity_Waypoint__c){
	            if(busStopHiFi.containsKey(busStopRoutes.Bus_Route__r.Name)){
	               busStopHiFi.get(busStopRoutes.Bus_Route__r.Name).add(stop);
	            }else{
	               routes.stops = new List<BusStop>();
	               routes.stops.add(stop);
	               busStopHiFi.put(busStopRoutes.Bus_Route__r.Name,routes.stops);    
	            }
            } else{
            	if(busStopMap.containsKey(busStopRoutes.Bus_Route__r.Name)){
	               busStopMap.get(busStopRoutes.Bus_Route__r.Name).add(stop);
	            }else{
	               routes.stops = new List<BusStop>();
	               routes.stops.add(stop);
	               busStopMap.put(busStopRoutes.Bus_Route__r.Name,routes.stops);    
	            }
            }
        }
        if(!busStopMap.isEmpty()){
            for(String key:busStopMap.keySet()){
              BusRoutes routes = new BusRoutes();
              routes.stops = new List<BusStop>();
              routes.highFidelity = new List<BusStop>();
              routes.routeName = key;
              routes.stops = busStopMap.get(key);
              if(busStopHiFi.containsKey(key)){
              	routes.highFidelity = busStopHiFi.get(key);
              }
              busRoutes.add(routes);        
            }
        }
        return busRoutes;
    }
    
    global  class BusRoutes{
        public String routeName{get;set;}
        public List<BusStop> stops{get;set;}
        public List<BusStop> highFidelity{get;set;}
    }
    
    public  class BusStop{
        public String stopName{get;set;}
        public double latitude{get;set;}
        public double longitude{get;set;}
        public Integer stopOrder{get;set;}
        public boolean active{get;set;}
        public String color{get;set;}
        public string id{get;set;}
        public String routeTeletracName{get;set;}
        public String routeMarker{get;set;}
    }
}