//
//  (c) 2013 Appirio
// 
//  
//  Controller for the Bus_Schedule_Editor Page
//
//
//  2/8/2013 - Created : Parth Tamhaney


public without sharing class Bus_Schedule_Editor_Controller { 
 
	public List<Selectoption>opt_Routes{get;set;}
	public List<Selectoption>opt_SubRoutes{get;set;}
	public List<Bus_Stop__c>lst_BusStops{get;set;}
	
	public string selected_Route{get;set;}
	public string selected_SubRoute{get;set;}
	public Bus_Route__c newRoute{get;set;}
	
	public Bus_Schedule_Editor_Controller(){
		opt_Routes =  new List<Selectoption>();  
		opt_SubRoutes =  new List<Selectoption>();
		
		lst_BusStops = new List<Bus_Stop__c>();
		for(Bus_Stop__c stop:[Select id,name from Bus_Stop__c where Active__c = true]){
			lst_BusStops.add(stop);
		}
		
		opt_Routes.add(new Selectoption('','Select'));
		Schedule_Editor_Settings__c settings = Schedule_Editor_Settings__c.getInstance();
		if(settings.Add_Route__c == true){
			opt_Routes.add(new Selectoption('ADD','Add New Route...'));
		}
		
		for(Bus_Route__c route:[Select id, name from Bus_Route__c where Active__c = true]){
			opt_Routes.add(new Selectoption(route.id,route.name));
		}
		
	   opt_SubRoutes.add(new Selectoption('','Select'));	
	   if(settings.Add_Route__c == true){
			opt_SubRoutes.add(new Selectoption('ADD','Add New Sub Route...'));
		}
	   Schema.DescribeFieldResult fieldResult = Bus_Stop_Schedule__c.Sub_Route__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        
	   for( Schema.PicklistEntry f : ple)
	   {
	      opt_SubRoutes.add(new SelectOption( f.getValue(),f.getLabel())); 
	   }  
	     
		
	
	}//End of Constructor
	
	@RemoteAction
	public static  List<BusStopSchedule> get_ScheduleData( string route, string subroute){ 
		
		//Retrieve data from staging table
		//If staging table is empty retrieve data from actual bus schedule table
		map<string,BusStopSchedule> map_Schedule = new map<string,BusStopSchedule>();
	   	list<string> stop_ids = new list<string>();
	   	
		  List<Bus_Stop_Schedule_Staging__c> lst_schedule_staging = [Select Bus_Stop__c, Bus_Stop__r.Name, Bus_Route__c, Bus_Route__r.name, Time__c, Order__c, Sub_Route__c
	   									From Bus_Stop_Schedule_Staging__c where Bus_Stop__r.Active__c = true and Bus_Route__r.Active__c = true 
	   									and Bus_Route__c = :route and Sub_Route__c = :subroute
	   									order by Order__c]     ;
	   	
	   
	   	if(lst_schedule_staging.size() > 0){
	   		for(Bus_Stop_Schedule_Staging__c stop:lst_schedule_staging){
		   		if(!map_Schedule.containskey(stop.Bus_Stop__c)){
		   			stop_ids.add(stop.Bus_Stop__c);
		   			map_Schedule.put(stop.Bus_Stop__c,new BusStopSchedule(stop.Bus_Stop__c, stop.Bus_Stop__r.Name));
		   		}
		   		map_Schedule.get(stop.Bus_Stop__c).time_list.add(stop.Time__c);
		   		map_Schedule.get(stop.Bus_Stop__c).order_list.add(stop.Order__c.intValue());
		   		
		   	}
		   	
	   		
	   	}else{
	   		List<Bus_Stop_Schedule__c> lst_schedule = [Select Bus_Stop__c, Bus_Stop__r.Name, Bus_Route__c, Bus_Route__r.name, Time__c, Order__c, Sub_Route__c
	   									From Bus_Stop_Schedule__c where Bus_Stop__r.Active__c = true and Bus_Route__r.Active__c = true 
	   									and Bus_Route__c = :route and Sub_Route__c = :subroute
	   									order by Order__c]     ;
	   	
		   	for(Bus_Stop_Schedule__c stop:lst_schedule){
		   		if(!map_Schedule.containskey(stop.Bus_Stop__c)){
		   			stop_ids.add(stop.Bus_Stop__c);
		   			map_Schedule.put(stop.Bus_Stop__c,new BusStopSchedule(stop.Bus_Stop__c, stop.Bus_Stop__r.Name));
		   		}
		   		map_Schedule.get(stop.Bus_Stop__c).time_list.add(stop.Time__c);
		   		map_Schedule.get(stop.Bus_Stop__c).order_list.add(stop.Order__c.intValue());
		   	}
	   		
	   	}
	   		
	   	
	   	List<BusStopSchedule>  lst_busSchedules = new List<BusStopSchedule>();
	   	for(string stopid:stop_ids){
	   		lst_busSchedules.add(map_Schedule.get(stopid));
	   		system.debug('____****______****' + map_Schedule.get(stopid));
	   	}
	   	
	   	return lst_busSchedules;
	
	
	}
	
	
	@RemoteAction
	public static  string save_ScheduleData( string route, string subroute,list<string> str_routestops,list<string>str_schedules ){  
		system.debug('______________'+str_routestops);
		system.debug('______________'+str_schedules);
		 list<Bus_Stops_Routes_Staging__c> routestops;// = [select  id,Bus_Route__c,Bus_Stop__c from Bus_Stops_Routes_Staging__c where  Bus_Route__c= :route  ];
		 //delete routestops;
		 
		 
		 
		 list<Bus_Stop_Schedule_Staging__c> schedules = [select  id from Bus_Stop_Schedule_Staging__c where  Bus_Route__c= :route and Sub_Route__c= :subroute ];
		 delete schedules;
		
		routestops = new list<Bus_Stops_Routes_Staging__c> ();
		schedules = new list<Bus_Stop_Schedule_Staging__c>();
		 for(integer i =0; i<str_routestops.size();i++){
		 	str_routestops[i] = str_routestops[i].replaceAll('\\{','{"').replaceAll('=','":"').replaceAll(', ','", "').replaceAll('}','"}').replaceAll(', "type":"Bus_Stops_Routes_Staging__c",',',');
		 	 Bus_Stops_Routes_Staging__c obj_BusStopRoutes = (Bus_Stops_Routes_Staging__c)JSON.deserialize( str_routestops[i],Bus_Stops_Routes_Staging__c.class);
		 	 routestops.add(obj_BusStopRoutes);
		 }
		 
		 for(integer i =0; i<str_schedules.size();i++){
		 	str_schedules[i] = str_schedules[i].replaceAll('\\{','{"').replaceAll('=','":"').replaceAll(', ','", "').replaceAll('}','"}').replaceAll(', "type":"Bus_Stop_Schedule_Staging__c"','');
		 	system.debug('_________*****'+str_schedules[i]);
		 	 Bus_Stop_Schedule_Staging__c obj_schedule = (Bus_Stop_Schedule_Staging__c)JSON.deserialize( str_schedules[i],Bus_Stop_Schedule_Staging__c.class);
		 	 schedules.add(obj_schedule);
		 }
		
		insert routestops; 
		insert schedules;
	   	
	   	return '';
	
	
	}
	
	public class BusStopSchedule {

        public String stop_name{get;set;}
        public String stop_id{get;set;}
        public List<String> time_list{get;set;}
        public List<integer> order_list{get;set;}
        
        public BusStopSchedule(string stopid, string stopname){ 
        	this.stop_name = stopname;
        	this.stop_id = stopid;
        	this.time_list = new List<String>(); 
        	this.order_list = new List<integer>();
        }
        

    }
	
	@RemoteAction
	public static  string publish_ScheduleData( string route, string subroute){  
		//retrieve staging route stops and schedule
		 
		List<Bus_Stop_Schedule_Staging__c> lst_schedule_staging = [Select Bus_Stop__c, Bus_Stop__r.Name, Bus_Route__c, Bus_Route__r.name, Time__c, Order__c, Sub_Route__c
	   									From Bus_Stop_Schedule_Staging__c where  Bus_Route__c= :route and Sub_Route__c= :subroute]     ;//Bus_Stop__r.Active__c = true and Bus_Route__r.Active__c = true and
		
		List<Bus_Stops_Routes_Staging__c> lst_route_staging = [Select Bus_Stop__c, Bus_Stop__r.Name, Bus_Route__c, Bus_Route__r.name,Stop_Order__c
	   									From Bus_Stops_Routes_Staging__c where    Bus_Route__c= :route]     ;//Bus_Stop__r.Active__c = true and Bus_Route__r.Active__c = true and
		
		
		list<Bus_Stops_Routes__c> routestops = new list<Bus_Stops_Routes__c> ();
		list<Bus_Stop_Schedule__c> schedules = new list<Bus_Stop_Schedule__c>();
		map<string, Bus_Stops_Routes__c>  mapRouteStops = new map<string, Bus_Stops_Routes__c>();
		//create new routestop records 
		 for(Bus_Stops_Routes_Staging__c route_Stop : lst_route_staging){
		 	 Bus_Stops_Routes__c obj_BusStopRoutes = new Bus_Stops_Routes__c(Bus_Stop__c = route_Stop.Bus_Stop__c, Bus_Route__c = route_Stop.Bus_Route__c ,Stop_Order__c = route_Stop.Stop_Order__c );
		 	 routestops.add(obj_BusStopRoutes);
		 	 mapRouteStops.put( route_Stop.Bus_Route__c + '-' +route_Stop.Bus_Stop__c,obj_BusStopRoutes );
		 }
		 //create new schedule records 
		 for(Bus_Stop_Schedule_Staging__c sch : lst_schedule_staging){
		 	 Bus_Stop_Schedule__c obj_sch = new Bus_Stop_Schedule__c(Bus_Stop__c = sch.Bus_Stop__c, Bus_Route__c = sch.Bus_Route__c ,
		 	 																	Sub_Route__c= sch.Sub_Route__c, Time__c = sch.Time__c ,Order__c = sch.Order__c );
		 	 schedules.add(obj_sch);
		 }
		
		
		if(routestops.size()>0){
			//retrieve routestops and delete
			 list<Bus_Stops_Routes__c> routestops_del = [select  id,Bus_Stop__c,Bus_Route__c, Stop_Order__c from Bus_Stops_Routes__c where  Bus_Route__c= :route and Bus_Stop__r.High_Fidelity_Waypoint__c = false];
			 for(Bus_Stops_Routes__c stop: routestops_del){
			 	mapRouteStops.remove( stop.Bus_Route__c + '-' +stop.Bus_Stop__c );
			 }
			 
			 //insert new route stops
			insert  mapRouteStops.values();
			 //delete staging data
			 delete lst_route_staging;
		 }
		 
		 if(schedules.size()>0){
		 	//retrieve schedules and delete
			 list<Bus_Stop_Schedule__c> schedules_del = [select  id from Bus_Stop_Schedule__c where  Bus_Route__c= :route and Sub_Route__c= :subroute];
			 delete schedules_del;
			
			//insert new schedules
			 insert schedules;
			 //delete staging data
			 delete lst_schedule_staging;
	   	
		 }
		 //Delete unused RouteStop records
		 set<string> stops = new set<string>();
		 list<Bus_Stop_Schedule__c> schedules_del = [select  id ,Bus_Stop__c,Bus_Route__c from Bus_Stop_Schedule__c where  Bus_Route__c= :route ];
		 for(Bus_Stop_Schedule__c sch:schedules_del){
		 	stops.add(sch.Bus_Stop__c);
		 }
		 
		 list<Bus_Stops_Routes__c> routestops_del = [select  id,Bus_Stop__c,Bus_Route__c, Stop_Order__c from Bus_Stops_Routes__c where  Bus_Route__c= :route and Bus_Stop__r.High_Fidelity_Waypoint__c = false];
		 list<Bus_Stops_Routes__c> delete_routeStop = new list<Bus_Stops_Routes__c>();
		 for(Bus_Stops_Routes__c route_stop:routestops_del){
		 	if(!stops.contains(route_stop.Bus_Stop__c)){
		 		delete_routeStop.add(route_stop);
		 	}
		 }
		 delete delete_routeStop;
	   	
	   	return '';
	
	
	}
	
	@RemoteAction
	public static  string publish_ScheduleData_All( ){  
		//retrieve staging route stops and schedule
		List<Bus_Stop_Schedule_Staging__c> lst_schedule_staging = [Select Bus_Stop__c, Bus_Stop__r.Name, Bus_Route__c, Bus_Route__r.name, Time__c, Order__c, Sub_Route__c
	   									From Bus_Stop_Schedule_Staging__c  ]     ;//where Bus_Stop__r.Active__c = true and Bus_Route__r.Active__c = true
		
		List<Bus_Stops_Routes_Staging__c> lst_route_staging = [Select Bus_Stop__c, Bus_Stop__r.Name, Bus_Route__c, Bus_Route__r.name,Stop_Order__c
	   									From Bus_Stops_Routes_Staging__c ]     ;// where Bus_Stop__r.Active__c = true and Bus_Route__r.Active__c = true
		
		list<Bus_Stops_Routes__c>  routestops = new list<Bus_Stops_Routes__c> ();
		list<Bus_Stop_Schedule__c> schedules = new list<Bus_Stop_Schedule__c>();
		map<string, Bus_Stops_Routes__c>  mapRouteStops = new map<string, Bus_Stops_Routes__c>();
		 //create new routestop records
		 for(Bus_Stops_Routes_Staging__c route_Stop : lst_route_staging){
		 	 Bus_Stops_Routes__c obj_BusStopRoutes = new Bus_Stops_Routes__c(Bus_Stop__c = route_Stop.Bus_Stop__c, Bus_Route__c = route_Stop.Bus_Route__c ,Stop_Order__c = route_Stop.Stop_Order__c );
		 	 routestops.add(obj_BusStopRoutes);
		 	 mapRouteStops.put( route_Stop.Bus_Route__c + '-' +route_Stop.Bus_Stop__c,obj_BusStopRoutes );
		 }
		 
		 Map<String,Set<String>> mapUpdatedroutes = new  Map<String,Set<String>>();
		 //create new staging records
		 for(Bus_Stop_Schedule_Staging__c sch : lst_schedule_staging){
		 	 Bus_Stop_Schedule__c obj_sch = new Bus_Stop_Schedule__c(Bus_Stop__c = sch.Bus_Stop__c, Bus_Route__c = sch.Bus_Route__c ,
		 	 																	Sub_Route__c= sch.Sub_Route__c, Time__c = sch.Time__c ,Order__c = sch.Order__c );
		 	 schedules.add(obj_sch);
		 	 if(!mapUpdatedroutes.containsKey(sch.Bus_Route__c) ){
		 	 	mapUpdatedroutes.put(sch.Bus_Route__c , new Set<string>());
		 	 }
		 	 mapUpdatedroutes.get(sch.Bus_Route__c ).add(sch.Sub_Route__c);
		 }
		
		
		 if(routestops.size()>0){
		 	//retrieve routestops and delete
			list<Bus_Stops_Routes__c> routestops_del = [select  id,Bus_Stop__c,Bus_Route__c, Stop_Order__c from Bus_Stops_Routes__c where   Bus_Route__c in :mapUpdatedroutes.keySet() and Bus_Stop__r.High_Fidelity_Waypoint__c = false];
			  for(Bus_Stops_Routes__c stop: routestops_del){
			 	mapRouteStops.remove( stop.Bus_Route__c + '-' +stop.Bus_Stop__c );
			 }
			 
			 //insert new route stops
			insert  mapRouteStops.values();
			 
			  //delete staging data
			 delete lst_route_staging;
		 }
		 
		 if(schedules.size()>0){
		 	//retrieve schedule and delete
			 list<Bus_Stop_Schedule__c> schedules_del_all = [select  id , Bus_Route__c, Sub_Route__c from Bus_Stop_Schedule__c where   Bus_Route__c in :mapUpdatedroutes.keySet() ];
			 list<Bus_Stop_Schedule__c> schedules_del = new list<Bus_Stop_Schedule__c>();
			 for(Bus_Stop_Schedule__c sch:schedules_del_all){
			 	
			 	if(mapUpdatedroutes.get(sch.Bus_Route__c ).contains(sch.Sub_Route__c)){
			 		schedules_del.add(sch);
			 	}
			 }
			 delete schedules_del;
			
			 //insert new schedule stops
			 insert schedules;
			  //delete schedule data
			 delete lst_schedule_staging;
	   	
		 }

		 //Delete unused RouteStop records
		 set<string> stops = new set<string>();
		 list<Bus_Stop_Schedule__c> schedules_del = [select  id ,Bus_Stop__c,Bus_Route__c from Bus_Stop_Schedule__c where  Bus_Route__c= :mapUpdatedroutes.keySet() ];
		 for(Bus_Stop_Schedule__c sch:schedules_del){
		 	stops.add(sch.Bus_Route__c + '-' +sch.Bus_Stop__c);
		 }
		 list<Bus_Stops_Routes__c> routestops_del = [select  id,Bus_Stop__c,Bus_Route__c, Stop_Order__c from Bus_Stops_Routes__c where  Bus_Route__c= :mapUpdatedroutes.keySet() and Bus_Stop__r.High_Fidelity_Waypoint__c = false];
		  list<Bus_Stops_Routes__c> delete_routeStop = new list<Bus_Stops_Routes__c>();
		 for(Bus_Stops_Routes__c route_stop:routestops_del){
		 	if(!stops.contains(route_stop.Bus_Route__c + '-' + route_stop.Bus_Stop__c)){
		 		delete_routeStop.add(route_stop);
		 	}
		 }
		 delete delete_routeStop;
	   	
	   	return '';
	
	
	}
	
	@RemoteAction
	public static  List<Bus_Route__c>  add_Route( string routeName, string routeColor,string routeMarker,string teletracName,boolean isactive,string externalId){
		Bus_Route__c  newRoute = new Bus_Route__c (Name= routeName, Route_Color__c = routeColor,Route_Marker__c= routeMarker,Teletrac_Name__c= teletracName,Active__c= isactive, External_Id__c = externalId);
		insert newRoute;
		
		List<Bus_Route__c> opt_Routes = [Select id, name from Bus_Route__c where Active__c = true];
		
		return opt_Routes;
	}
	
	@RemoteAction
	public static  List<Bus_Route__c>  delete_Route( string routeId){
		
			set<string> suboutes = new set<string>();
			AggregateResult[] groupedResults = [select  Sub_Route__c, count(id)   from Bus_Stop_Schedule__c where  Bus_Route__c= :routeId GROUP BY Sub_Route__c];
			for (AggregateResult ar : groupedResults)  {
				suboutes.add((string)ar.get('Sub_Route__c'));
			}
			
			for(string subRoute : suboutes){
				delete_SubRoute(  routeId, subRoute);
			}
		Bus_Route__c  oldRoute =[Select id from Bus_Route__c where id=:routeId];
		delete oldRoute;
		
		List<Bus_Route__c> opt_Routes = [Select id, name from Bus_Route__c where Active__c = true];
		
		return opt_Routes;
	}
	
	@RemoteAction
	public static string  delete_SubRoute( string routeId,string subRoute){
		list<Bus_Stop_Schedule__c> schedules_del = [select  id  from Bus_Stop_Schedule__c where  Bus_Route__c= :routeId and Sub_Route__c=:subRoute ];
		delete schedules_del;
		
		list<Bus_Stop_Schedule_Staging__c> schedules_staging_del = [select  id  from Bus_Stop_Schedule_Staging__c where  Bus_Route__c= :routeId and Sub_Route__c=:subRoute ];
		delete schedules_staging_del;
		
		return '';
	}
	
	@RemoteAction
	public static list<string>  get_SubRoutes( string routeId){
		set<string> subroutes = new set<string>();
		
		for(Bus_Stop_Schedule__c schedules :[select  id,Sub_Route__c  from Bus_Stop_Schedule__c where  Bus_Route__c= :routeId order by Sub_Route__c asc]){
			if(!subroutes.contains(schedules.Sub_Route__c)){
				subroutes.add(schedules.Sub_Route__c);
			}
		}
		
		
		for(Bus_Stop_Schedule_Staging__c schedules :[select  id,Sub_Route__c  from Bus_Stop_Schedule_Staging__c where  Bus_Route__c= :routeId order by Sub_Route__c asc]){
			if(!subroutes.contains(schedules.Sub_Route__c)){
				subroutes.add(schedules.Sub_Route__c);
			}
		}
	
		list<string> lst = new list<string>();
		lst.addAll(subroutes);
		lst.sort();
		
		return lst;
	}
	
	
}// End of Class