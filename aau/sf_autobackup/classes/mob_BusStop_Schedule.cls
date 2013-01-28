@RestResource(urlMapping='/BusStopSchedule/*')
global with sharing class  mob_BusStop_Schedule {

    @HttpGet
    global static BusStopSchedule getBusStopSchedule(RestRequest req, RestResponse res) {
        String busStopName = EncodingUtil.urlDecode(req.params.get('busStopName'), 'UTF-8');
        BusStopSchedule schedule = new BusStopSchedule();
        system.debug('stop: ' + busStopName);
        Map <String, BusRoute>routes = new Map <String, BusRoute>();
        for(Bus_Stop_Schedule__c busStopSchedule:[Select Time__c, Bus_Stop__r.Name, Bus_Stop__c, Bus_Route__r.Name, Bus_Route__r.Route_Color__c, Bus_Route__c From Bus_Stop_Schedule__c where Bus_Stop__r.Name=:busStopName]){
            
            system.debug('_______' + busStopSchedule.Bus_Stop__r.Name);
            BusRoute currentRoute = routes.get(busStopSchedule.Bus_Route__r.Name);
            system.debug('current route: ' + busStopSchedule.Bus_Route__r.Name);
            if (currentRoute == null){
                currentRoute = new BusRoute();
                currentRoute.name = busStopSchedule.Bus_Route__r.Name;
                currentRoute.color = busStopSchedule.Bus_Route__r.Route_Color__c;
                currentRoute.schedule = new List<String>();
                
                routes.put(busStopSchedule.Bus_Route__r.Name, currentRoute);
            }
            
            currentRoute.schedule.add(busStopSchedule.Time__c);
            
        }
        system.debug('current busStopName: ' + busStopName);
        schedule.stop = busStopName;
        schedule.routes = routes.values();
        return schedule;
    }

    
    
    global class BusStopSchedule {

        global String stop{get;set;}
        global List<BusRoute> routes{get;set;}
        

    }
    
    global class BusRoute {

        global String name{get;set;}
        global String color{get;set;}
        global List <String> schedule{get;set;}
        
        
    }
    
}