@RestResource(urlMapping='/tripplanner/*')
global with sharing class  mob_TripPlanner {

	public static Map<String, Map<String, List<String>>> crosses = new Map<String, Map<String, List<String>>>();

    // just to keep track of relevant bus stops and routes
    // to reduce query amount
     static Set<String> stopNames = new Set<String>();
     static Set<String> routeNames = new Set<String>(); 

    // pathways are possible travel flows from one route to another route
    public  static  Map<String, List<Map<String, String>>> pathways = new Map<String, List<Map<String, String>>>{};

    // well-structured schedules after re-mapping
    //static Map<String, Map<String, List<Double>>> schedules = new Map<String, Map<String, List<Double>>>();
    static Map<String, Map<String, List<Bus_Stop_Schedule__c>>> schedules = new Map<String, Map<String, List<Bus_Stop_Schedule__c>>>();
    // arrival schedules for all pathways
    public static Map<String, Double> arrivalSchedules = new Map<String, Double>();
    
    public static String startBusStopId;
    public static String endBusStopId;
    
    static String startBusStop;
    static String endBusStop;
    
    public static Double startTime;
    public static Double endTime;
    
    public static List<Double> bestArrivals = new List<Double>{25, 25, 25};
    public static List<String> bestPathways = new String[3];
    
    global class BestRoutes{
    	public  Map<String, List<Map<String, String>>> routes {get;set;}
    	public  List<List<Map<String, String>>> lstRoutes {get;set;}
    
    }
    
    public static integer TIMEFRAME = 4;
    public static integer MAX_TRANS = 3;
    
    @HttpGet
    global static BestRoutes getBestRoutes(RestRequest req, RestResponse res) {
        
        startBusStopId = req.params.get('fromId'); 
        endBusStopId = req.params.get('toId'); 
        startTime = Double.valueOf(req.params.get('startTime')); 
        
        generateRoutes(); 
        
       return  getBestRoutes();
    }
    
    

    
    
    public static void generateRoutes() {
        crosses = getCrosses();      
                
        // do the magic! get all pathways
        getAllPathways(MAX_TRANS); // limit to 2 transfers   
    }
        
    /*public String getPathwaysJSON() {
        return JSON.serializePretty(pathways);
    }

    public String getArrivalsJSON() {
        return JSON.serializePretty(arrivalSchedules);
    }
    
    public String getBestPathwaysJSON() {
        
        return JSON.serializePretty(getBestPathwaysMAP());
    }*/
    public static BestRoutes getBestRoutes() {
        
        BestRoutes br = new BestRoutes();
        br.routes = getBestPathwaysMAP();
        
        system.debug('__________________br.routes________'+ br.routes.keySet());
        
        //br.lstRoutes = br.routes.values();
        //br.lstRoutes = new List<List<Map<String, String>>>();
        for(Integer i=0; i<br.routes.size(); i++) {
       		 //br.lstRoutes.add(br.routes.get(i.toString()));
        }
        
        return br;
    }
    

    public static Map<String, List<Map<String, String>>> getBestPathwaysMAP() {
        Map<String, List<Map<String, String>>> bestPathways_map = new Map<String, List<Map<String, String>>>();
        
        for(String key : bestPathways) {
            bestPathways_map.put(key, pathways.get(key));
			system.debug('WOOT5 Best Path: '+key+', '+pathways.get(key));
        }

        return bestPathways_map; 
    }
        
    public static void getBestPathways() {
    
        bestArrivals = new List<Double>{25, 25, 25};
        bestPathways = new String[3];

        // doing a bit of sorting to favor direct route
        List<String> pathway_keys = new List<String>();
        pathway_keys.addAll(pathways.keySet());
        System.debug('^^^^^^^^^^^^^^^^^'+ json.serializePretty(pathway_keys));
        pathway_keys.sort();
        System.debug('^^^^^^^^^^^^^^^^SORTED^^^^'+ json.serializePretty(pathway_keys));
        
        // loop through all pathways and get the pathway which arrival the earliest
        for(String pathway_key : pathway_keys) {
            List<Map<String, String>> pathway = pathways.get(pathway_key);
            Double arrivalTime = Double.valueOf(pathway[pathway.size() - 1].get('toTime'));
            

			System.debug('WOOT4 arrivalTime: '+arrivalTime+', Best: '+bestArrivals[0]);
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
    
    public static List<Map<String, String>> getBestPathway() {
        return pathways.get(bestPathways[0]);
    }

    public static List<String> getBestPathwayLines() {
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
        
    /*public String getBestPathwayJSON() {
        return JSON.serializePretty(getBestPathway());
    }

    public Map<String, Map<String, List<String>>> getCrossesFromJSON() {
        String crosses_string = '{}';
        
        List<Key_Val__c> vals = [select Val__c from Key_Val__c where Name = 'bus_router_crosses'];
        crosses_string = vals[0].Val__c;
        
        System.Type t = Map<String, Map<String, List<String>>>.class;
        Map<String, Map<String, List<String>>> crosses_local = (Map<String, Map<String, List<String>>>) JSON.deserialize(crosses_string, t);
        
        return crosses_local;
    }*/
    
    public static Map<String, Map<String, List<String>>> getCrosses() {
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
    public static void getAllPathways(Integer transfers) {
    
        // limiting travel timeframe to 3 hours to reduce query amount
        endTime = startTime + TIMEFRAME;//3.00;
        
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
        system.debug('-------------------------'+ JSON.serializePretty(pathways));
        // now we have all the pathways
        // build relevant schedules
        getSchedules(stopNames, routeNames, startTime, endTime);
        
        // then then set pathways' schedules - when to get on and off
        // loop through each pathway and call setPathwaySchedules
        for(String pathway_key : pathways.keySet()) {
            List<Map<String, String>> pathway = pathways.get(pathway_key);
            Double arrivalSchedule = setPathwaySchedules(pathway, startTime);
            // system.debug('-@@@@@@--------------arrivalSchedule----------'+ arrivalSchedule);
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
    public static  void getPathways(String currentRoute, String endRoute, Integer i, Integer transfers, String key) {
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
                'fromSubroute' => '',
                'toSubroute' => '', 
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
                'fromSubroute' => '',
                'toSubroute' => '', 
                'fromTime' => '', 'toTime' => ''
            });
            
        } else if(crosses.get(currentRoute).containsKey(endRoute)) { // 2 routes cross each other
            key_local = '~'+ key +' => ('+ i +')'+ endRoute +'*';
            
            for(Integer c = 0; c < crosses.get(currentRoute).get(endRoute).size(); c++) {
            
                if(crosses.get(currentRoute).get(endRoute)[c] == startBusStop) {
                    continue; // ignore if the transfer is at the very start
                }
                
                //PARTH: if the End and Trans are same add only END node
				if(crosses.get(currentRoute).get(endRoute)[c] != endBusStop){
                	pathways.put(key_local + c, pathways.get(key).clone());
				
				
	                pathways.get(key_local + c).add(new Map<String, String>{ 
	                	'type' => 'TRANS',
		                'fromRoute' => currentRoute,
		                'toRoute' => endRoute, 
		                
	                    'from' => currentRoute, 
	                    'to' => endRoute, 
	                    'stop' => crosses.get(currentRoute).get(endRoute)[c], 
						'fromSubroute' => '',
						'toSubroute' => '', 
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
						'fromSubroute' => '',
						'toSubroute' => '', 
	                    'fromTime' => '', 'toTime' => ''
	                });
	                
				}
					

               
                
               
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
							'fromSubroute' => '',
							'toSubroute' => '', 
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
    public static void getSchedules(Set<String> stop_Names, Set<String> route_Names, Double start_time, Double end_time) {
        // not well-structured schedules from soql
        List<Bus_Stop_Schedule__c> scheds = new List<Bus_Stop_Schedule__c>();
        if(start_time < end_time) { // normal "day" travel 
            scheds = [select Time_Value__c, Bus_Route__r.Name, Bus_Stop__r.Name, Sub_Route__c 
                from Bus_Stop_Schedule__c 
                where Bus_Stop__r.Name in :stop_Names and Bus_Route__r.Name in :route_Names
                and Time_Value__c >= :start_time and Time_Value__c <= :end_time ORDER BY Time_Value__c ASC
            ];
        } else { // travel duration over the midnight
            scheds = [select Time_Value__c, Bus_Route__r.Name, Bus_Stop__r.Name, Sub_Route__c  
                from Bus_Stop_Schedule__c 
                where Bus_Stop__r.Name in :stop_Names and Bus_Route__r.Name in :route_Names
                and Time_Value__c >= :start_time and Time_Value__c <= 24.00 ORDER BY Time_Value__c ASC
            ];
            
            scheds.addAll([select Time_Value__c, Bus_Route__r.Name, Bus_Stop__r.Name, Sub_Route__c  
                from Bus_Stop_Schedule__c 
                where Bus_Stop__r.Name in :stop_Names and Bus_Route__r.Name in :route_Names
                and Time_Value__c >= 0.00 and Time_Value__c <= :end_time ORDER BY Time_Value__c ASC
            ]);            
        }

        // initialize schedules
        for(String stopName : stop_Names) {
            //schedules.put(stopName, new Map<String, List<Double>>());
            schedules.put(stopName, new Map<String, List<Bus_Stop_Schedule__c>>());
        }

        // map out well-structured schedules
        // easier and faster to reference without looping
        for(Bus_Stop_Schedule__c sched : scheds) {
            if(!schedules.get(sched.Bus_Stop__r.Name).containsKey(sched.Bus_Route__r.Name)) {
                //schedules.get(sched.Bus_Stop__r.Name).put(sched.Bus_Route__r.Name, new List<Double>());
                schedules.get(sched.Bus_Stop__r.Name).put(sched.Bus_Route__r.Name, new List<Bus_Stop_Schedule__c>());
            }
            //schedules.get(sched.Bus_Stop__r.Name).get(sched.Bus_Route__r.Name).add(sched.Time_Value__c);
            schedules.get(sched.Bus_Stop__r.Name).get(sched.Bus_Route__r.Name).add(sched);
        }

       // System.debug('***************' + JSON.serializePretty(schedules));
    } // getSchedules


    // set the pathway's schedules - i.e: when to get on and off
    public static Double setPathwaySchedules(List<Map<String, String>> pathway, Decimal refTime) {        
		Map<String, String> previous_pathway = null;
        for(Map<String, String> sub_pathway : pathway) {
        	System.debug('*************** sub_pathway****' + JSON.serializePretty(sub_pathway));
			Bus_Stop_Schedule__c sched = new Bus_Stop_Schedule__c();
			
			//Account for the sub routes (could be 2 buses at diff places of route at a time) when finding stop schedules!
			//TODO - update to use from and to
			if(previous_pathway != null){
				sub_pathway.put('fromSubroute', previous_pathway.get('toSubroute'));
			}
	
            if(sub_pathway.get('from') != 'START' && sub_pathway.get('from') != 'END') { 
            	system.debug('**************1');
                // only if the sub_pathway are not the start and the end
                // get arrival time from the "from" route

				//TODO: Get subroute from somewhere!!
                sched = getNextStopSchedule(sub_pathway.get('stop'), sub_pathway.get('from'), sub_pathway.get('fromSubroute'), refTime); 
				refTime = null;
				if(sched != null){
					refTime = sched.Time_Value__c;
					sub_pathway.put('toSubroute', sched.Sub_Route__c);
				}
            }
            
            if(refTime != null) {
            	system.debug('**************2');
                // update arrival time from the "from" route
                sub_pathway.put('fromTime', String.valueOf(refTime));

                // get boarding time for he "to" route
                sched = getNextStopSchedule(sub_pathway.get('stop'), sub_pathway.get('to'), sub_pathway.get('fromSubroute'), refTime);
				refTime = null;
				if(sched != null){
					refTime = sched.Time_Value__c;
					sub_pathway.put('toSubroute', sched.Sub_Route__c);
				}

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
			previous_pathway = sub_pathway;
        }        
        
        return refTime;      
    } // getPathwaySchedule


    // get next stop time at a particular bus stop on a particular route after current time
    public static Bus_Stop_Schedule__c getNextStopSchedule(String stopName, String routeName, String subRoute, Decimal currentTime) {
		system.debug('WOOT - getSchedule: sub route: '+subRoute);
		if(subRoute == '2'){
			system.debug('WOOT2 - getSchedule: sub route: '+subRoute);
		}

        // the bus might not go during the time frame
        // so do check first
        if(schedules.get(stopName).containsKey(routeName)) {
            //List<Double> busStopSchedules = schedules.get(stopName).get(routeName);
            List<Bus_Stop_Schedule__c> busStopSchedules = schedules.get(stopName).get(routeName);
            //busStopSchedules.sort(a.Time_Value__c,b.Time_Value__c); // from earlier to later

			//already sorted in the query!
            for(Bus_Stop_Schedule__c busStopSchedule : busStopSchedules) {
				system.debug('WOOT - Compare sub routes: '+busStopSchedule.Sub_Route__c+' '+subRoute);

				if(subRoute == '2'){
					system.debug('WOOT2 - Compare: sub route: '+busStopSchedule.Sub_Route__c);
				}

                if(busStopSchedule.Time_Value__c >= currentTime && (busStopSchedule.Sub_Route__c == subRoute || subRoute == '')) {
                    //return busStopSchedule.Time_Value__c;
					system.debug('WOOT3 - Valid Connection: '+busStopSchedule.Sub_Route__c+subRoute);
                    return busStopSchedule;
                }
            }
            
           // after loop not found the schedule yet
            if(startTime > endTime) { // travel over midnight
                for(Bus_Stop_Schedule__c busStopSchedule : busStopSchedules) {
                    Double busStopSchedule_local = busStopSchedule.Time_Value__c;
                    
                    if(busStopSchedule_local <= 3.0) {
                        busStopSchedule_local += 24.0;
                    }
                    
                    if(currentTime <= 3.0) { 
                        currentTime += 24.0;
                    }

                    if(busStopSchedule_local >= currentTime && (busStopSchedule.Sub_Route__c == subRoute || subRoute == '')) {
                        //return busStopSchedule.Time_Value__c;
                        return busStopSchedule;
                    }
                }            
            }
                         
        }
        
        return null;
    } // getNextStopSchedule
}