/*

File: teletracManager.js
Description: Functionality to integrate with Teletrac

Change Log:

Mauricio Created on 07/05/12

*/

// Teletrac manager object, contains functionality to interact with Teletrac
var TeletracManager = function() {
    // Static list of bus stops
    var busStops = [];
    var busStopNames = [];
    var routeNamesAndColors = [];

    // When auto refresh is enabled, this is the interval in miliseconds in which
    // bus markers are refreshed
    var refreshInterval = busRefreshRate || 30000;
    
    // Call back to use for the auto refresh of buses
    var autoRefreshCallback;
    
    // Indicates if auto refresh is enabled
    var autoRefresh = false;
    
    //holder for response converted to json
    var jsonResponse;
    
    // Bus Routes with Stops
    var routes = {};
    
    // Bus stops with all routes that run through it
    var stopNamesWithRoutes = {};
    
    // Private function that performs the auto refresh of vehicles
    function autoRefreshVehiclesPosition() {
        if(autoRefresh) {
          teletracManager.getVehicles(autoRefreshCallback);
          setTimeout(autoRefreshVehiclesPosition, refreshInterval);
        }
    }
    

    // Private function to parse bus stops to plot on gmap from response form SFDC
    // using an array to hold stop names to compare against to prevent dup stops
    // Function also creates an associative array of stopName: [route] in stopNamesWtihRoutes
    function parseStops(results, callback){
    	$(results).each( function(){
    	   
    	   var that = this;
    	   
    		$(this.stops).each( function(){
    		  var routeNameArray = stopNamesWithRoutes[this.stopName];
    		  if(!routeNameArray) {
    		    routeNameArray = [];
    		  }
    		  routeNameArray.push(that.routeName);
    		  stopNamesWithRoutes[this.stopName] = routeNameArray;  
    			
    			if(($.inArray(this.stopName, busStopNames)) == -1 && this.active == true){
    				busStopNames.push(this.stopName);
    				busStops.push(this);
    			}
    		});
    	});
    	
    	callback(busStops);
    }
    
    // Private function to create array with routes and colors together for route
    // drawing. Then create appropriate check box on shuffle popover
    function parseRouteNamesAndColors(results){
      //Stort routes Alphabetically 
  		results.sort(function(a,b){
  			return a.routeName.localeCompare(b.routeName);
  		});
  		
  		// Set starting position of auto refresh switch based on local storage 'autoREfreshSetting
  		if(localStorage.getItem('autoRefreshSetting') == 'on' || !localStorage.getItem('autoRefreshSetting')){
  			var refreshToggle = $("#settings-route-refresh-toggle").tmpl({refreshOn: true});
  		} else {
  			console.log('IM OFF');
  			var refreshToggle = $("#settings-route-refresh-toggle").tmpl({refreshOn: false});
  		}
			refreshToggle.appendTo($('#result-list'));
			$('#auto-refresh-toggle').slider();
    	
    	// Generate check boxes for all routes
    	$(results).each(function () {
    		routeNamesAndColors.push({"routeName": this.routeName, "routeColor": this.stops[0].color});
    		var routeCheckbox = $("#settings-route-checkbox").tmpl({routeName: this.routeName});
    		$(routeCheckbox).find("input[type='checkbox']").checkboxradio({theme: 'a', mini: 'true'});
			routeCheckbox.appendTo($('#result-list'));
    	});
    	if(!aauMobile.isAndroid()){
    		$('.result-scroll-container *').css('-webkit-transform', 'translate3d(0,0,0)');
    	}
    	if($('#result-list').hasClass('ui-listview')){
    		$('#result-list').listview('refresh');
    	}
    }
    
    return {
        // Returns all bus stops
        getBusStops: function() {
            return busStops;
        },
        
        // Returns route object
        getRoutes: function() {
        	return routes;
        },
        
        getRouteNamesAndColors: function() {
        	return routeNamesAndColors;
        },
        
        getStopNamesWithRoutes: function() {
          return stopNamesWithRoutes;
        },
        
        // Configures auto refresh, if first parameter is true will cause
        // the get vehicles function to be called in the pre determined auto refresh interval
        // passing the provided callback function. If false, disables auto refresh
        setAutoRefreshVehiclesPosition: function(enabled, callback) {
            autoRefresh = enabled;
            autoRefreshCallback = callback;
            if(enabled) {
                autoRefreshVehiclesPosition();
            }
        },
        
        // Gets vehicles from teletrac, including their position, parsers the data
        // into json format and passes it to the callback function provided
        getVehicles: function(callback) {
            var restPath = "https://xmlgateway.teletrac.net/AsciiService.asmx/GetVehicles";
            utils.log("made it here");
            RestDataPlugin.getData(function(result){
            							utils.log('Success with REST call: ' + result);
            							jsonResponse = $.xml2json(result);
            							utils.log(JSON.stringify(jsonResponse));
            							
            							if(callback){
            							    utils.log("callback is defined: " + callback);
            								callback(jsonResponse);
            							} else {
            							  utils.log("callback is undefined");
            							}
            						}, 
            						function(result){
            							utils.log('Failure in Teletrac REST call: ' + JSON.stringify(result));
            						}, 
            						restPath, 
            						false, 
            						"GET", 
            						"xml");
            
            console.log('refreshed vehicles from server');
            
     }, //getVehicles
    
    getRoutesFromSFDC: function(callback) {
      	var restPath = "/BusStops/"; 
		RestDataPlugin.getData(function(result){
								utils.log('Success REST service bus routes:');
								parseStops(result, callback);
								parseRouteNamesAndColors(result);
								routes = result;
								return routes;
							   },
							   function(){
							   	utils.log('Failure REST service bus routes:');
							   }, 
							   restPath, 
							   true, 
							   "GET", 
							   "json");
	},
	
	//helper function for toggling auto bus refresh
	toggleRefresh: function(inputField) {
		if(($(inputField).val()) == "on"){
			teletracManager.setAutoRefreshVehiclesPosition(true, mapManager.addVehicles);
			localStorage.setItem('autoRefreshSetting', 'on');
		} else {
			teletracManager.setAutoRefreshVehiclesPosition(false, mapManager.addVehicles);
			localStorage.setItem("autoRefreshSetting", "off");
		}
	}
  };
};

var teletracManager;