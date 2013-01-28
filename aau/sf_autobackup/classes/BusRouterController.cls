public class BusRouterController {

    public transient Map<String, Map<String, List<String>>> crosses = new Map<String, Map<String, List<String>>>();

    // just to keep track of relevant bus stops and routes
    // to reduce query amount
    transient Set<String> stopNames = new Set<String>();
    transient Set<String> routeNames = new Set<String>();

    // pathways are possible travel flows from one route to another route
    public transient Map<String, List<Map<String, String>>> pathways = new Map<String, List<Map<String, String>>>{};

    // well-structured schedules after re-mapping
    transient Map<String, Map<String, List<Double>>> schedules = new Map<String, Map<String, List<Double>>>();
    // arrival schedules for all pathways
    public transient Map<String, Double> arrivalSchedules = new Map<String, Double>();
    
    public transient String startBusStopId;
    public transient String endBusStopId;
    
    transient String startBusStop;
    transient String endBusStop;
    
    public transient Double startTime;
    public transient Double endTime;
    
    public List<Double> bestArrivals = new List<Double>{25, 25, 25};
    public List<String> bestPathways = new String[3];

    public BusRouterController(String dummy) {
    
    }
    
    public BusRouterController() {
        
        if(ApexPages.currentPage().getParameters().get('fromId') != null ) {
           startBusStopId = ApexPages.currentPage().getParameters().get('fromId'); 
        }
       
        
        if(ApexPages.currentPage().getParameters().get('toId') != null ) {
           endBusStopId = ApexPages.currentPage().getParameters().get('toId'); 
        }
        
        if(ApexPages.currentPage().getParameters().get('now') != null ) {
           startTime = Double.valueOf(ApexPages.currentPage().getParameters().get('now')); 
        }  
        
        /////////////
         //startBusStopId = 'a4NV0000000Cdia';
        //endBusStopId = 'a4NV0000000CdhX';
        //startTime = 7.10 ;//DateTime.newInstanceGmt(1980,1,1,7,15,0).;
        /////////////
        //this.crosses = getCrossesFromJSON();
        this.crosses = getCrosses();      
                
        // do the magic! get all pathways
        getAllPathways(2); // limit to 2 transfers   
    }
        
    public String getPathwaysJSON() {
        return JSON.serializePretty(pathways);
    }

    public String getArrivalsJSON() {
        return JSON.serializePretty(arrivalSchedules);
    }
    
    public String getBestPathwaysJSON() {
        
        return JSON.serializePretty(getBestPathwaysMAP());
    }

    public Map<String, List<Map<String, String>>> getBestPathwaysMAP() {
        Map<String, List<Map<String, String>>> bestPathways_map = new Map<String, List<Map<String, String>>>();
        
        for(String key : bestPathways) {
            bestPathways_map.put(key, pathways.get(key));
        }

        return bestPathways_map; 
    }
        
    public void getBestPathways() {
    
        bestArrivals = new List<Double>{25, 25, 25};
        bestPathways = new String[3];

        // doing a bit of sorting to favor direct route
        List<String> pathway_keys = new List<String>();
        pathway_keys.addAll(pathways.keySet());
        pathway_keys.sort();
        
        // loop through all pathways and get the pathway which arrival the earliest
        for(String pathway_key : pathway_keys) {
            List<Map<String, String>> pathway = pathways.get(pathway_key);
            Double arrivalTime = Double.valueOf(pathway[pathway.size() - 1].get('toTime'));
            
            for(Integer i=0; i<bestArrivals.size(); i++) {
                Double bestArrival = bestArrivals[i];
                if(startTime > endTime) { // travel over midnight
                    if(bestArrival <= 3.0) {
                        bestArrival += 24.0;
                    }
                    
                    if(arrivalTime <= 3.0) { 
                        arrivalTime += 24.0;
                    }
                }
    
                // time taken is lesser
                if(arrivalTime <= bestArrival) {
                    // shift back manually, apex list methods are limited
                    if(i == 0) {
                        bestArrivals.set(2, bestArrivals.get(1));
                        bestPathways.set(2, bestPathways.get(1));
                         
                        bestArrivals.set(1, bestArrivals.get(0));
                        bestPathways.set(1, bestPathways.get(0)); 
                    } else if(i == 1) {
                        bestArrivals.set(2, bestArrivals.get(1));
                        bestPathways.set(2, bestPathways.get(1));
                    }
                    
                    bestArrivals.set(i, arrivalTime);
                    bestPathways.set(i, pathway_key);
                    
                    break;
                }
            } // for(Double bestArrival : bestArrivals)
        }
        
        //return bestPathways;
    }        
    
    public List<Map<String, String>> getBestPathway() {
        return pathways.get(bestPathways[0]);
    }

    public List<String> getBestPathwayLines() {
        List<Map<String, String>> pathway = getBestPathway();
        List<String> lines = new List<String>();
        String line = '';
        
        if(pathway != null) {
            for(Map<String, String> p : pathway) {
                if(p.get('from') == 'START') {
                    line = 'start: "'+ p.get('stop') +'" on route: '+ p.get('to') +' at '+ p.get('fromTime');
                } else if(p.get('from') == 'END') {
                    line = 'end: "'+ p.get('stop') +'" on route: '+ p.get('to') +' at '+ p.get('toTime');
                } else {
                    line = 'transfer: "'+ p.get('stop') +'"'+
                        ' from route: '+ p.get('from') +' at '+ p.get('fromTime') +
                        ' to route: '+ p.get('to') +' at '+ p.get('toTime');
                }
                
                line = line.replaceAll('([0-9]+)\\.([0-9]+)', '$1:$2');
                lines.add(line);
            }
            
            return lines; 
        } else {
            lines.add('none');
            
            return lines;
        }
    }
        
    public String getBestPathwayJSON() {
        return JSON.serializePretty(getBestPathway());
    }

    public Map<String, Map<String, List<String>>> getCrossesFromJSON() {
        String crosses_string = '{}';
        
        List<Key_Val__c> vals = [select Val__c from Key_Val__c where Name = 'bus_router_crosses'];
        crosses_string = vals[0].Val__c;
        
        System.Type t = Map<String, Map<String, List<String>>>.class;
        Map<String, Map<String, List<String>>> crosses_local = (Map<String, Map<String, List<String>>>) JSON.deserialize(crosses_string, t);
        
        return crosses_local;
    }
    
    public Map<String, Map<String, List<String>>> getCrosses() {
        Map<String, Map<String, List<String>>> crosses_local = new Map<String, Map<String, List<String>>>();
        
        List<Bus_Stop__c> bus_stops = [select Id, Name, (select Id, Name, Bus_Route__r.Name from Bus_Stops_Routes__r) from Bus_Stop__c where Routes_Count__c > 1];
        
        for(Bus_Route__c route: [select Id, Name from Bus_Route__c]) {
            crosses_local.put(route.Name,  new Map<String, List<String>>());
        }
        
        for(Bus_Stop__c bus_stop : bus_stops) {
            for(Bus_Stops_Routes__c routeA : bus_stop.Bus_Stops_Routes__r) {
                for(Bus_Stops_Routes__c routeB : bus_stop.Bus_Stops_Routes__r) {
                    if(routeA.Bus_Route__r.Name != routeB.Bus_Route__r.Name) {
                        if(crosses_local.get(routeA.Bus_Route__r.Name).containsKey(routeB.Bus_Route__r.Name)) {
                            crosses_local.get(routeA.Bus_Route__r.Name).get(routeB.Bus_Route__r.Name).add(bus_stop.Name);
                        } else {
                            crosses_local.get(routeA.Bus_Route__r.Name).put(routeB.Bus_Route__r.Name, new list<String> { bus_stop.Name });
                        }               
                    }
                }
            }
        }
        
        
        
        
        //System.debug(JSON.serialize(crosses_local));
        return crosses_local; 
    }
           
    // get pathways from many routes to other many routes
    // for instance, stops at which routes crosses
    public void getAllPathways(Integer transfers) {
    
        // limiting travel timeframe to 3 hours to reduce query amount
        endTime = startTime + 3.00;
        
        if(endTime > 24.00) {
            endTime -= 24.00;
        }
 
        stopNames.clear();
        routeNames.clear();
        
        pathways.clear();
        
        schedules.clear();
        arrivalSchedules.clear();

        // query routes at the startBusStop and endBusStop
        List<Bus_Stops_Routes__c> start_and_end_routes = [
            select Id, Name, Bus_Stop__r.Name, Bus_Route__r.Name from Bus_Stops_Routes__c 
            where Bus_Stop__c in (:startBusStopId, :endBusStopId)
        ];
                
        // starting routes to end routes
        // loop and call getPathways as needed
        for(Bus_Stops_Routes__c start_route : start_and_end_routes) {
            // loop the start bus stop's routes first
            if(start_route.Bus_Stop__c == startBusStopId) {             
                for(Bus_Stops_Routes__c end_route : start_and_end_routes) {
                    // then loop the end bus stop's routes
                    if(end_route.Bus_Stop__c == endBusStopId) {                        
                        startBusStop = start_route.Bus_Stop__r.Name;
                        endBusStop = end_route.Bus_Stop__r.Name;

                        getPathways(start_route.Bus_Route__r.Name, end_route.Bus_Route__r.Name, 1, transfers, '0');
                    }
                } 
            }
        }

        // now we have all the pathways
        // build relevant schedules
        getSchedules(stopNames, routeNames, startTime, endTime);
        
        // then then set pathways' schedules - when to get on and off
        // loop through each pathway and call setPathwaySchedules
        for(String pathway_key : pathways.keySet()) {
            List<Map<String, String>> pathway = pathways.get(pathway_key);
            Double arrivalSchedule = setPathwaySchedules(pathway, startTime);
            
            if(arrivalSchedule != null) {
                // add to arrivalSchedules
                arrivalSchedules.put(pathway_key, arrivalSchedule);
            } else {
                // remove this pathway as there is some problem getting schedules for complete pathway
                pathways.remove(pathway_key); 
            }
        }
        
        // then find out the best 3 pathways
        getBestPathways();
    }

    // get pathways from one route to another route
    // shouldn't be called directly, call getAllPathways instead
    public void getPathways(String currentRoute, String endRoute, Integer i, Integer transfers, String key) {
        String key_local = '';
        
        if(key == '0') { // very start
        	key = '(0)'+ currentRoute;
            pathways.put(key, new List<Map<String, String>>());
            
            
            pathways.get(key).add(new Map<String, String>{ 
                'type' => 'START',
                'fromRoute' => currentRoute,
                'toRoute' => currentRoute, 
                
                'from' => 'START', 
                'to' => currentRoute, 
                'stop' => startBusStop, 
                'fromTime' => '', 'toTime' => ''
            });
            
            routeNames.add(currentRoute);
            routeNames.add(endRoute);
            
            stopNames.add(startBusStop);
            stopNames.add(endBusStop);
        }
        
        if(currentRoute == endRoute) { // on the same route
            pathways.put(key +'*', pathways.get(key).clone());

            // this is the end, add end stop too
            pathways.get(key +'*').add(new Map<String, String>{ 
            	 'type' => 'END',
                'fromRoute' => endRoute,
                'toRoute' => endRoute, 
                
                'from' => 'END', 
                'to' => endRoute, 
                'stop' => endBusStop, 
                'fromTime' => '', 'toTime' => ''
            });
            
        } else if(crosses.get(currentRoute).containsKey(endRoute)) { // 2 routes cross each other
            key_local = '~'+ key +' => ('+ i +')'+ endRoute +'*';
            
            for(Integer c = 0; c < crosses.get(currentRoute).get(endRoute).size(); c++) {
            
                if(crosses.get(currentRoute).get(endRoute)[c] == startBusStop) {
                    continue; // ignore if the transfer is at the very start
                }
                
                pathways.put(key_local + c, pathways.get(key).clone());

                pathways.get(key_local + c).add(new Map<String, String>{ 
                	'type' => 'TRANS',
	                'fromRoute' => currentRoute,
	                'toRoute' => endRoute, 
	                
                    'from' => currentRoute, 
                    'to' => endRoute, 
                    'stop' => crosses.get(currentRoute).get(endRoute)[c], 
                    'fromTime' => '', 'toTime' => ''
                });

                stopNames.add(crosses.get(currentRoute).get(endRoute)[c]);
                routeNames.add(currentRoute);
                
                // as this is the end, add end stop too
                pathways.get(key_local + c).add(new Map<String, String>{ 
                	'type' => 'END',
	                'fromRoute' => endRoute,
	                'toRoute' => endRoute, 
	                
                    'from' => 'END', 
                    'to' => endRoute, 
                    'stop' => endBusStop, 
                    'fromTime' => '', 'toTime' => ''
                });
            }
        
        } else { // 2 routes don't cross each other, so the search continue
            if(i < transfers) {
                for(String c_key : crosses.get(currentRoute).keySet()) {
                    key_local = '~'+ key +' => ('+ i +')'+ c_key +'^';

                    for(Integer c = 0; c < crosses.get(currentRoute).get(c_key).size(); c++) {
                    
                        if(crosses.get(currentRoute).get(c_key)[c] == startBusStop) {
                            continue; // ignore if the transfer is at the very start
                        }
                        
                        pathways.put(key_local + c, pathways.get(key).clone());
                        
                        pathways.get(key_local + c).add(new Map<String, String>{ 
                        	'type' => 'TRANS',
			                'fromRoute' => currentRoute,
			                'toRoute' => c_key, 
			                
                            'from' => currentRoute, 
                            'to' => c_key, 
                            'stop' => crosses.get(currentRoute).get(c_key)[c], 
                            'fromTime' => '', 'toTime' => ''
                        });

                        stopNames.add(crosses.get(currentRoute).get(c_key)[c]);
                        routeNames.add(currentRoute);

                        getPathways(c_key, endRoute, i + 1, transfers, key_local + c);
                    }
                }
            } // if(i < transfers)
            
        } // else
        
        pathways.remove(key); // remove it as it is not needed anymore
    } // getPathways


    // get well-structured schedules for relevant bus stops and routes between relevant time schedules
    // for leaner and faster query and processing
    public void getSchedules(Set<String> stopNames, Set<String> routeNames, Double startTime, Double endTime) {
        // not well-structured schedules from soql
        List<Bus_Stop_Schedule__c> scheds = new List<Bus_Stop_Schedule__c>();
        if(startTime < endTime) { // normal "day" travel 
            scheds = [select Time_Value__c, Bus_Route__r.Name, Bus_Stop__r.Name 
                from Bus_Stop_Schedule__c 
                where Bus_Stop__r.Name in :stopNames and Bus_Route__r.Name in :routeNames
                and Time_Value__c >= :startTime and Time_Value__c <= :endTime 
            ];
        } else { // travel duration over the midnight
            scheds = [select Time_Value__c, Bus_Route__r.Name, Bus_Stop__r.Name 
                from Bus_Stop_Schedule__c 
                where Bus_Stop__r.Name in :stopNames and Bus_Route__r.Name in :routeNames
                and Time_Value__c >= :startTime and Time_Value__c <= 24.00 
            ];
            
            scheds.addAll([select Time_Value__c, Bus_Route__r.Name, Bus_Stop__r.Name 
                from Bus_Stop_Schedule__c 
                where Bus_Stop__r.Name in :stopNames and Bus_Route__r.Name in :routeNames
                and Time_Value__c >= 0.00 and Time_Value__c <= :endTime
            ]);            
        }

        // initialize schedules
        for(String stopName : stopNames) {
            schedules.put(stopName, new Map<String, List<Double>>());
        }

        // map out well-structured schedules
        // easier and faster to reference without looping
        for(Bus_Stop_Schedule__c sched : scheds) {
            if(!schedules.get(sched.Bus_Stop__r.Name).containsKey(sched.Bus_Route__r.Name)) {
                schedules.get(sched.Bus_Stop__r.Name).put(sched.Bus_Route__r.Name, new List<Double>());
            }
            schedules.get(sched.Bus_Stop__r.Name).get(sched.Bus_Route__r.Name).add(sched.Time_Value__c);
        }

        System.debug(JSON.serialize(schedules));
    } // getSchedules


    // set the pathway's schedules - i.e: when to get on and off
    public Double setPathwaySchedules(List<Map<String, String>> pathway, Decimal refTime) {        
        for(Map<String, String> sub_pathway : pathway) {
            if(sub_pathway.get('from') != 'START' && sub_pathway.get('from') != 'END') { 
                // only if the sub_pathway are not the start and the end
                // get arrival time from the "from" route
                refTime = getNextStopSchedule(sub_pathway.get('stop'), sub_pathway.get('from'), refTime); 
            }
            
            if(refTime != null) {
                // update arrival time from the "from" route
                sub_pathway.put('fromTime', String.valueOf(refTime));

                // get boarding time for the "to" route
                refTime = getNextStopSchedule(sub_pathway.get('stop'), sub_pathway.get('to'), refTime);

                if(refTime != null) {
                    // update boarding time for the "to" route
                    sub_pathway.put('toTime', String.valueOf(refTime.setScale(2)));
                    
                    if(sub_pathway.get('from') == 'START' || sub_pathway.get('from') == 'END') { 
                        // for start and end pathways, set fromTime the same as toTime
                        sub_pathway.put('fromTime', String.valueOf(refTime.setScale(2)));
                    }
                    
                } else {
                    break;
                    return null;
                }
            } else {
                break; 
                return null;
            }
        }        
        
        return refTime;      
    } // getPathwaySchedule


    // get next stop time at a particular bus stop on a particular route after current time
    public Double getNextStopSchedule(String stopName, String routeName, Decimal currentTime) {

        // the bus might not go during the time frame
        // so do check first
        if(schedules.get(stopName).containsKey(routeName)) {
            List<Double> busStopSchedules = schedules.get(stopName).get(routeName);
            busStopSchedules.sort(); // from earlier to later

            for(Double busStopSchedule : busStopSchedules) {
                if(busStopSchedule >= currentTime) {
                    return busStopSchedule;
                }
            }
            
            // after loop not found the schedule yet
            if(startTime > endTime) { // travel over midnight
                for(Double busStopSchedule : busStopSchedules) {
                    Double busStopSchedule_local = busStopSchedule;
                    
                    if(busStopSchedule_local <= 3.0) {
                        busStopSchedule_local += 24.0;
                    }
                    
                    if(currentTime <= 3.0) { 
                        currentTime += 24.0;
                    }

                    if(busStopSchedule_local >= currentTime) {
                        return busStopSchedule;
                    }
                }            
            }
                         
        }
        
        return null;
    } // getNextStopSchedule

}