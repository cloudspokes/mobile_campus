/*

File: teletracManager.js
Description: Functionality to integrate with Teletrac

Change Log:

Mauricio Created on 07/05/12

*/

// Mock up data to be used for testing when teletrac is not available
var mockData = JSON.parse('{"Vehicle":[{"StreetAddress":"84 UPTON ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94124","VehicleName":"402 _A_","StatusAbbr":"ON","EventDateTime":"7/5/2012 5:56:45 PM","Latitude":"37.743657","Longitude":"-122.402057"},{"StreetAddress":"665 SUTTER ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94102","VehicleName":"2400 _G_","StatusAbbr":"DC","EventDateTime":"7/5/2012 5:56:25 PM","Latitude":"37.788857","Longitude":"-122.411247"},{"StreetAddress":"487 TOWNSEND ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94107","VehicleName":"4207 _H_","StatusAbbr":"DO","EventDateTime":"7/5/2012 5:56:17 PM","Latitude":"37.773892","Longitude":"-122.399067"},{"StreetAddress":"702 TAYLOR ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94108","VehicleName":"_I_","StatusAbbr":"ON","EventDateTime":"7/5/2012 5:56:02 PM","Latitude":"37.788937","Longitude":"-122.411785"},{"StreetAddress":"2331 STOCKTON ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94133","VehicleName":"408 _M_","StatusAbbr":"ON","EventDateTime":"7/5/2012 5:55:56 PM","Latitude":"37.807283","Longitude":"-122.410743"},{"StreetAddress":"2213 JERROLD AVE","City":"SAN FRANCISCO","State":"CA","ZipCode":"94124","VehicleName":"404 _D_","StatusAbbr":"OF","EventDateTime":"7/5/2012 5:55:29 PM","Latitude":"37.745075","Longitude":"-122.40071"},{"StreetAddress":"711 MISSION ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94103","VehicleName":"803 _E_","StatusAbbr":"DC","EventDateTime":"7/5/2012 5:55:10 PM","Latitude":"37.79","Longitude":"-122.402255"},{"StreetAddress":"632 SUTTER ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94102","VehicleName":"4203 K1","StatusAbbr":"ON","EventDateTime":"7/5/2012 5:54:43 PM","Latitude":"37.789057","Longitude":"-122.4108"},{"StreetAddress":"199 2ND ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94105","VehicleName":"1101 Hayes","StatusAbbr":"DC","EventDateTime":"7/5/2012 5:54:21 PM","Latitude":"37.786895","Longitude":"-122.398325"},{"StreetAddress":"568 3RD ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94107","VehicleName":"3101 G","StatusAbbr":"ON","EventDateTime":"7/5/2012 5:53:32 PM","Latitude":"37.780482","Longitude":"-122.394795"},{"StreetAddress":"654 TURK ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94102","VehicleName":"3300 A","StatusAbbr":"DC","EventDateTime":"7/5/2012 5:52:23 PM","Latitude":"37.782073","Longitude":"-122.419872"},{"StreetAddress":"463 MISSION ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94105","VehicleName":"700","StatusAbbr":"ON","EventDateTime":"7/5/2012 5:52:00 PM","Latitude":"37.790025","Longitude":"-122.39717"},{"StreetAddress":"379 MASON ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94102","VehicleName":"3302 I1","StatusAbbr":"ON","EventDateTime":"7/5/2012 5:51:49 PM","Latitude":"37.786968","Longitude":"-122.409902"},{"StreetAddress":"2396 STOCKTON ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94133","VehicleName":"3700 K2","StatusAbbr":"ON","EventDateTime":"7/5/2012 5:51:23 PM","Latitude":"37.807817","Longitude":"-122.410618"},{"StreetAddress":"900 SUTTER ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94109","VehicleName":"4205 H2","StatusAbbr":"DC","EventDateTime":"7/5/2012 5:51:02 PM","Latitude":"37.788432","Longitude":"-122.41532"},{"StreetAddress":"631 HOWARD ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94105","VehicleName":"903 Jerrold Express","StatusAbbr":"DC","EventDateTime":"7/5/2012 5:50:49 PM","Latitude":"37.78624","Longitude":"-122.398963"},{"StreetAddress":"85 LARKIN ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94102","VehicleName":"902 Hayes","StatusAbbr":"DC","EventDateTime":"7/5/2012 5:50:16 PM","Latitude":"37.778463","Longitude":"-122.416662"},{"StreetAddress":"128 JESSIE ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94105","VehicleName":"2403 Campus Tour No1 and Biz Ops","StatusAbbr":"OF","EventDateTime":"7/5/2012 5:49:35 PM","Latitude":"37.788157","Longitude":"-122.400978"},{"StreetAddress":"1401 SAN MATEO AVE","City":"SOUTH SAN FRANCISCO","State":"CA","ZipCode":"94080","VehicleName":"1100","StatusAbbr":"ON","EventDateTime":"7/5/2012 5:49:20 PM","Latitude":"37.646068","Longitude":"-122.410203"},{"StreetAddress":"52 2ND ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94105","VehicleName":"2401 Campus Tour No2","StatusAbbr":"OF","EventDateTime":"7/5/2012 5:47:46 PM","Latitude":"37.788513","Longitude":"-122.400703"},{"StreetAddress":"131 WISCONSIN ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94107","VehicleName":"2402 J","StatusAbbr":"OF","EventDateTime":"7/5/2012 5:45:15 PM","Latitude":"37.765847","Longitude":"-122.399333"},{"StreetAddress":"ORO WAY","City":"MOUNTAIN VIEW","State":"CA","ZipCode":"94043","VehicleName":"M10 FREIGHTLINER","StatusAbbr":"OF","EventDateTime":"7/5/2012 5:45:02 PM","Latitude":"37.417938","Longitude":"-122.07329"},{"StreetAddress":"168 BLUXOME ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94107","VehicleName":"M9","StatusAbbr":"OF","EventDateTime":"7/5/2012 5:44:59 PM","Latitude":"37.774898","Longitude":"-122.399593"},{"StreetAddress":"702 TAYLOR ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94108","VehicleName":"M8","StatusAbbr":"OF","EventDateTime":"7/5/2012 5:39:57 PM","Latitude":"37.788938","Longitude":"-122.411758"},{"StreetAddress":"1755 LOMBARD ST/US-101","City":"SAN FRANCISCO","State":"CA","ZipCode":"94123","VehicleName":"800 Sp Event","StatusAbbr":"DC","EventDateTime":"7/5/2012 5:39:25 PM","Latitude":"37.800225","Longitude":"-122.430278"},{"StreetAddress":"8057 S COLISEUM WAY","City":"OAKLAND","State":"CA","ZipCode":"94621","VehicleName":"3301","StatusAbbr":"OF","EventDateTime":"7/5/2012 5:34:36 PM","Latitude":"37.744795","Longitude":"-122.198382"},{"StreetAddress":"109 JESSIE ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94105","VehicleName":"A44 Biz Ops and Sp Show","StatusAbbr":"OF","EventDateTime":"7/5/2012 5:34:02 PM","Latitude":"37.788167","Longitude":"-122.400452"},{"StreetAddress":"470 TOWNSEND ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94107","VehicleName":"A43 Biz Ops","StatusAbbr":"DC","EventDateTime":"7/5/2012 5:32:45 PM","Latitude":"37.774208","Longitude":"-122.398768"},{"StreetAddress":"46 ARKANSAS ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94107","VehicleName":"801","StatusAbbr":"DC","EventDateTime":"7/5/2012 5:30:42 PM","Latitude":"37.765728","Longitude":"-122.39902"},{"StreetAddress":"713 TAYLOR ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94108","VehicleName":"M2","StatusAbbr":"OF","EventDateTime":"7/5/2012 5:19:35 PM","Latitude":"37.788988","Longitude":"-122.412048"},{"StreetAddress":"48 ARKANSAS ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94107","VehicleName":"802","StatusAbbr":"DC","EventDateTime":"7/5/2012 5:19:35 PM","Latitude":"37.765703","Longitude":"-122.399063"},{"StreetAddress":"2185 VAN NESS AVE/US-101","City":"SAN FRANCISCO","State":"CA","ZipCode":"94109","VehicleName":"M13","StatusAbbr":"OF","EventDateTime":"7/5/2012 5:18:37 PM","Latitude":"37.79552","Longitude":"-122.423595"},{"StreetAddress":"125 WISCONSIN ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94107","VehicleName":"4204 I2","StatusAbbr":"OF","EventDateTime":"7/5/2012 5:16:52 PM","Latitude":"37.765918","Longitude":"-122.399338"},{"StreetAddress":"464 TOWNSEND ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94107","VehicleName":"M12","StatusAbbr":"OF","EventDateTime":"7/5/2012 5:13:02 PM","Latitude":"37.774298","Longitude":"-122.398698"},{"StreetAddress":"141 WISCONSIN ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94107","VehicleName":"4200 Sp Event","StatusAbbr":"OF","EventDateTime":"7/5/2012 5:07:04 PM","Latitude":"37.765732","Longitude":"-122.399622"},{"StreetAddress":"133 WISCONSIN ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94107","VehicleName":"1400","StatusAbbr":"OF","EventDateTime":"7/5/2012 4:34:55 PM","Latitude":"37.765822","Longitude":"-122.399587"},{"StreetAddress":"2783 FRANKLIN ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94123","VehicleName":"MCOMM","StatusAbbr":"PA","EventDateTime":"7/5/2012 4:24:46 PM","Latitude":"37.799995","Longitude":"-122.425992"},{"StreetAddress":"1077 PINE ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94109","VehicleName":"M6","StatusAbbr":"OF","EventDateTime":"7/5/2012 4:22:53 PM","Latitude":"37.79017","Longitude":"-122.41337"},{"StreetAddress":"88 UPTON ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94124","VehicleName":"3202 K1","StatusAbbr":"OF","EventDateTime":"7/5/2012 2:19:49 PM","Latitude":"37.74349","Longitude":"-122.401913"},{"StreetAddress":"26 UPTON ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94124","VehicleName":"M4 IZUZU","StatusAbbr":"SM","EventDateTime":"7/5/2012 2:00:00 PM","Latitude":"37.744733","Longitude":"-122.401165"},{"StreetAddress":"1389 LOWRIE AVE","City":"SOUTH SAN FRANCISCO","State":"CA","ZipCode":"94080","VehicleName":"4201","StatusAbbr":"SM","EventDateTime":"7/5/2012 2:00:00 PM","Latitude":"37.648928","Longitude":"-122.410643"},{"StreetAddress":"975 O FARRELL ST/OFARRELL ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94109","VehicleName":"406","StatusAbbr":"SM","EventDateTime":"7/5/2012 2:00:00 PM","Latitude":"37.784607","Longitude":"-122.42061"},{"StreetAddress":"20 UPTON ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94124","VehicleName":"M7","StatusAbbr":"SM","EventDateTime":"7/5/2012 2:00:00 PM","Latitude":"37.74478","Longitude":"-122.400972"},{"StreetAddress":"42 ARKANSAS ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94107","VehicleName":"904 Hayes No1","StatusAbbr":"SM","EventDateTime":"7/5/2012 2:00:00 PM","Latitude":"37.765748","Longitude":"-122.399092"},{"StreetAddress":"2314 MCKINNON AVE","City":"SAN FRANCISCO","State":"CA","ZipCode":"94124","VehicleName":"3404","StatusAbbr":"OF","EventDateTime":"7/4/2012 3:19:09 AM","Latitude":"37.743443","Longitude":"-122.402077"},{"StreetAddress":"2320 MCKINNON AVE","City":"SAN FRANCISCO","State":"CA","ZipCode":"94124","VehicleName":"3100","StatusAbbr":"DO","EventDateTime":"7/3/2012 9:39:28 PM","Latitude":"37.743458","Longitude":"-122.402158"},{"StreetAddress":"2318 MCKINNON AVE","City":"SAN FRANCISCO","State":"CA","ZipCode":"94124","VehicleName":"3400","StatusAbbr":"DC","EventDateTime":"7/3/2012 2:30:28 PM","Latitude":"37.743442","Longitude":"-122.402142"},{"StreetAddress":"2322 MCKINNON AVE","City":"SAN FRANCISCO","State":"CA","ZipCode":"94124","VehicleName":"3401","StatusAbbr":"DC","EventDateTime":"7/3/2012 2:29:10 PM","Latitude":"37.743463","Longitude":"-122.40218"},{"StreetAddress":"92 UPTON ST","City":"SAN FRANCISCO","State":"CA","ZipCode":"94124","VehicleName":"3102","StatusAbbr":"ON","EventDateTime":"7/3/2012 2:28:10 PM","Latitude":"37.743448","Longitude":"-122.402012"},{"StreetAddress":"1475 SAN MATEO AVE","City":"SOUTH SAN FRANCISCO","State":"CA","ZipCode":"94080","VehicleName":"4206 I2","StatusAbbr":"OF","EventDateTime":"7/2/2012 6:40:26 PM","Latitude":"37.64909","Longitude":"-122.410103"}],"xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance","xmlns:xsd":"http://www.w3.org/2001/XMLSchema","xmlns":"http://xmlgateway.teletrac.net/"}');

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
			routeCheckbox.appendTo($('#result-list'));
    	});
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
            							utils.log('Failure in Teletrac REST call: ' + result);
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
							   	utils.log('Failfure REST service bus routes:');
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