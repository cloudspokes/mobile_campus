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
            appirioUtils.log("made it here");
            
           // RestDataPlugin.getData(function(result){
           RestDataPlugin.getData_ignoreTimeout(function(result){
					appirioUtils.log('Success with REST call: ' + result);
					jsonResponse = $.xml2json(result);
					appirioUtils.log(JSON.stringify(jsonResponse));
					
					if(callback){
						//appirioUtils.log("callback is defined: " + callback);
						callback(jsonResponse);
					} else {
					  appirioUtils.log("callback is undefined");
					}
				}, 
				function(result){
					appirioUtils.log('Failure in Teletrac REST call: ' + JSON.stringify(result));
				}, 
				restPath, 
				false, 
				"GET", 
				"xml");
            
            console.log('refreshed vehicles from server');
            
     }, //getVehicles

    getRoutesFromSFDC: function(callback) {
    	//alert('getRoutesFromSFDC');
		var myRoutes = localStorage.getItem('routeData'); 
		//PARTH: Check Last refresh date 
		// If time elapsed since last update is more than the time out then refresh the data
		var str_lastRefreshDate = localStorage.getItem('lastRefreshDate');
		
		if(str_lastRefreshDate == null || str_lastRefreshDate == 'null' || str_lastRefreshDate == '' || myRoutes == null || myRoutes == 'null' || myRoutes == ''){
			myRoutes = null;
			localStorage.setItem('routeData', null);
		}else{
			var LastRefresh_milis = Number(str_lastRefreshDate);
			var now_milis = Date.now().valueOf();
			if( (now_milis - LastRefresh_milis) > (str_cacheTimeoutDays * 86400000)){
				//clear local storage
				//alert('ClearData');
				myRoutes = null;
				localStorage.setItem('routeData', null);
				
			}
		}
		
		//console.log('WOOOOOT: '+myRoutes);
		//routes = JSON.parse(myRoutes);
		try{
		  	routes = JSON.parse(routes);
		}
		catch(err){ 
		  routes = null;
		  console.log('Error while parsing data for : routeData' );
	  	}
		
		//alert(routes[0].routeName);
		if(myRoutes == null || myRoutes == 'null'  || routes == null || routes.length < 1 || routes[0].routeName == null || routes[0].routeName == 'null'  || routes[0].routeName == ''){
			var restPath = "/BusStops/"; 
			RestDataPlugin.getData(function(result){
								//appirioUtils.log('Success REST service bus routes:'+JSON.stringify(result));
								//alert('Success REST service bus routes:'+JSON.stringify(result));
								parseStops(result, callback);
								parseRouteNamesAndColors(result);
								routes = result;
								localStorage.setItem('routeData', JSON.stringify(result));
								//PARTH: Set last refresh date 
								localStorage.setItem('lastRefreshDate', Date.now().valueOf());
								return result;
							   },
							   function(){
							   	appirioUtils.log('Failure REST service bus routes:');
							   }, 
							   restPath, 
							   true, 
							   "GET", 
							   "json");
		}else{
			//console.log('WOOT localStorage: '+routes);
			parseStops(routes, callback);
			parseRouteNamesAndColors(routes);
		}
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
