//
//  (c) 2012 Appirio
//
//  
//  Trigger for after insert of Planned Store Object
//  that is created when a portal user submits a request
//
//
//  8/8/2012 - Created



public with sharing class mob_NextStopLocator {
	
	private list<Bus_Stop__c>          allStops          {get;set;}        // List of all Stops in SFDC
	private list<Bus_Stops_Routes__c>  nextStops         {get;set;}        // List of next Stops
	private list<Bus_Stops_Routes__c>  allStopsRoutes    {get;set;}        // List of all Bus_Stops_Routes__c
	private map<String, Bus_Stops_Routes__c> routeMap    {get;set;}        // Map connecting string of Route Name (ex 'A') to Bus_Stop_Routes__c objects
	
	
	
	// Constructor
	public mob_NextStopLocator() {
		allStopsRoutes = [SELECT Bus_Stop__r.Name, Bus_Stop__r.Active__c, Bus_Route__r.Name From Bus_Stops_Routes__c ORDER BY Bus_Stops_Routes__c.Name];
		system.debug('***' + allStopsRoutes[0].Bus_Stop__r.Name);
	}
	
	public list<Bus_Stop__c> getAllBusStops() {
		return allStops;
	}
	
	public list<Bus_Stops_Routes__c> getNextStops(String stopName) {
		return nextStops;
	}

}