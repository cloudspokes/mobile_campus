/*

File: mapManager.js
Description: Functions to render and manage Google maps

Change Log:

Mauricio Created on 07/05/12

*/

// Object used to manage Google maps
var MapManager = function() {

	// if should use geolocation to pin point user's position, if false, defaults users position to SF
    var useGeolocation = false;
    
    // Stores the rendered map
    var map;
    
    // List of vehicle markers, necessary to update their position
    var vehicleMarkers = {};
    
    // List of bus stop markers
    var busStopMarkers = {};
    
    // Used to calculate coordinates based on addresses
    var geocoder = new google.maps.Geocoder();
    
    // A marker that indicates the position of the user
    var myMarker;
    
    // Current location of the user, defaults to the initial location if location tracking is not enabled in the browser
    var currentLocation = new google.maps.LatLng(37.788008, -122.400682);
    
    // The info window
    var infoWindow;
    
    // Define if the user position should be updated automatically
    var trackUserPos;
    
    // Defines interval to update user position in milliseconds
    var trackUserPosInterval = 30000;
    
    // Holder array for routes currently draw on screen
    var directionsDisplayMap = [];
    
    // Google direction service
    var directionsService = new google.maps.DirectionsService();
    
    //hash of marker to route
    var markerToRouteHash = {};
    
    //routes Currently being drawn on map
    var routesOnScreen;
    
    //cache for vehicles
    var vehicleCache;
    
    // Function to parse vehicle name, returns a json object with name and route properties, if the vehicle
    // has no route associated with the name it route will be undefined. Route names must be in {}
    function parseVehicleName(vehicleName) {
      var result = {}

      result.route = vehicleName.match("\{[\.\,\?\;\:\(\)\-\_\+\=\!\@\#\$\%\^\&\*\'\"\`\ a-zA-Z0-9]*\}");

      result.name = vehicleName;

      if(result.route) {
        result.route = result.route[0];

        result.name = result.name.replace(result.route, "");

        result.route = result.route.replace("\{", "");
        result.route = result.route.replace("\}", "");
      }
      return result;     
    }    
    
    // Used for updating the user position in regular interval
    function trackUser() {
      if(trackUserPos) {
        mapManager.updateUserPos(false);
        
        setTimeout(trackUser, trackUserPosInterval);
      }
    }
    
    // Simple popup listener that just shows content from the popupInfo of the associated object
    function simpleMarkerListener() {
      if(infoWindow) {
        infoWindow.close();
      }
    
      infoWindow = new google.maps.InfoWindow({
         content: "<div style='margin-top:10px'>" + this.popupInfo + "</div>"
      });
      infoWindow.open(map, this);
    } 
    
    function doRenderMap(element) {
        // Icon associated with the student marker
        var studentMarkerImage = new google.maps.MarkerImage(imgStudentMarker,
				    	null, 
				    	null, 
				    	null, 
				    	new google.maps.Size(25, 29)											
				    	);
    
        var myOptions = {
            center: currentLocation,
            zoom: 15,
            mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        
        map = new google.maps.Map(element[0], myOptions);        
		
        myMarker = new google.maps.Marker({
                     position: currentLocation,
                     title: "Student Marker",
                     animation: google.maps.Animation.DROP,
                     icon: studentMarkerImage
                  });
        
        myMarker.popupInfo = "This is where you are!";
                  
        google.maps.event.addListener(myMarker, 'click', simpleMarkerListener);
        
        myMarker.setMap(map);
    }
    
    // Private function to draw route on map
    // param: route object from routes ex {"routeName": "D", stops:[{stopname: abc, lat:123, long:123}, {stopname: def, lat: 123, long:123}]
    function drawRoute(route){
    	console.log('Map from draw route: ' + map);
    	console.log('route from draw route: ' + route);
    	var routeColor = route.stops[0].color || "#BF2200";
    	console.log(routeColor);
      	var polylineOptions = {
    		strokeColor: routeColor,
    		strokeOpacity: .6,
    		strokeWeight: 5,
    		clickable: false
    	};
    	var rendererOptions = {
    		map: map,
    		hideRouteList: true,
    		draggable: false,
    		polylineOptions: polylineOptions,
    		suppressMarkers: true
    	};
    	var directionsDisplay = new google.maps.DirectionsRenderer(rendererOptions);
    	
    	var routeWayPoints = [];
    	for(var i = 1; i < route.stops.length; i++){
    		routeWayPoints.push({location: new google.maps.LatLng(route.stops[i].latitude, route.stops[i].longitude), stopover: true});
    		console.log(route.stops[i].stopName);
    	}
    	console.log(routeWayPoints);
    	
    	var directionRequest = {
    		origin: new google.maps.LatLng(route.stops[0].latitude, route.stops[0].longitude),
    		destination: new google.maps.LatLng(route.stops[0].latitude, route.stops[0].longitude),
    		waypoints: routeWayPoints,
    		travelMode: google.maps.DirectionsTravelMode.DRIVING
    	};
    	directionsService.route(directionRequest, function(response, status){
    		console.log(response);
    		console.log(status);
    		directionsDisplay.setDirections(response);
    	});
    	directionsDisplayMap.push({"routeName": route.routeName, "directions": directionsDisplay});
      }
    
    // Private Function to clear route form map
    // param: string of route name to clear  
    function clearRoute(routeName){
    	$(directionsDisplayMap).each( function(index){
    		if(routeName == this.routeName){
    			this.directions.setMap(null);
    			directionsDisplayMap.splice(index,1);
    		}
    	});
    }
    
    return {
      // Update user's position and optionally pan to that position
      updateUserPos: function(pan, callback, param) {
        // finds location
        if(useGeolocation && navigator && navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(position) {
                utils.log(position);
                currentLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
                
                if(myMarker) {
                  myMarker.setMap(null);
                  myMarker.setPosition(currentLocation);
                  myMarker.setMap(map);
                }
                
                if(pan) {
                  if(map)
                    map.panTo(currentLocation);
                }
                
                if(callback) {
                  if(param) {
                    callback(param);
                  } else { 
                    callback();
                  }   
                }
                
            });
        } else {
            currentLocation = new google.maps.LatLng(37.781983, -122.407577);
            if(myMarker) {
              myMarker.setPosition(currentLocation);
            }
            
            if(pan) {
              if(map)
                map.panTo(currentLocation);
            }
            
            if(callback) {
              if(param) {
                callback(param);
              } else { 
                callback();
              }   
            }
        }
        
      }, //updateUserPos
    
      // Centers the map on the student
      centerOnStudent: function() {
        map.panTo(myMarker.getPosition());
      }, //centeronStudent
      
      // Trigger a resize event on the map so it redraws on the full canvas
      triggerResize: function() {
        if(map)
          google.maps.event.trigger(map, 'resize');
      }, //triggerResize
    
      // Renders a map in a specific element on the page, centralizing the map
      // in the specified latitude and longitude
      renderMap: function(element) {
        
        this.updateUserPos(false, doRenderMap, element);
        
      }, //renderMap
      
      // Given a JSON array of objects returned from teletrac, adds markers for those
      // vehicles to the map. If a marker for a vehicle with the same name already exists,
      // this updates the vehicle position rather than adding another vehicle marker.
      addVehicles: function(vehicles) {
      	var nameResult;
      	vehicleCache = vehicles;		    								
        $(vehicles.Vehicle).each(function() {
        	var nameResult = parseVehicleName(this.VehicleName);
        	
            var marker = vehicleMarkers[nameResult.name];
            
            
            if(!marker) {
            	if(nameResult.route){
              	  var busMarker = new google.maps.MarkerImage(busMarkers[nameResult.route],
												    	null, 
												    	null, 
												    	null, 
												    	new google.maps.Size(25, 29) 											
					    								);
					    								
	              var marker = new google.maps.Marker({
	                            position: new google.maps.LatLng(this.Latitude, this.Longitude),
	                     		animation: google.maps.Animation.DROP,
	                     		icon: busMarker
	                          });
	              
	              marker.popupInfo = "Vehicle Name: " + nameResult.name;
	              
	              google.maps.event.addListener(marker, 'click', simpleMarkerListener);
	
	              marker.setMap(map);
	              vehicleMarkers[nameResult.name] = marker;
              	}
              
            } else {
            	if($.inArray(nameResult.route, routesOnScreen) > -1 || !routesOnScreen){
            		if(!marker.getMap()){
            			marker.setMap(map);
            		}
              		marker.setPosition(new google.maps.LatLng(this.Latitude, this.Longitude));
              		vehicleMarkers[nameResult.name] = marker;
              	} else {
              	vehicleMarkers[nameResult.name].setMap(null);
              	}
            }
       });
      }, //addVehicles
      
      // Adds bus stops markers to the map
      addStops: function(stops) {
        $(stops).each( function() {
        			var stopMarker = new google.maps.MarkerImage(imgStopMarker,
												    	null, 
												    	null, 
												    	null, 
												    	new google.maps.Size(25, 25) 											
					    								);
        			
					var marker = new google.maps.Marker({
						position: new google.maps.LatLng(this.latitude, this.longitude),
						title: this.stopName,
						animation: google.maps.Animation.DROP,
						icon: stopMarker
					});
 
                    marker.popupInfo = this.stopName;
              
                    google.maps.event.addListener(marker, 'click', simpleMarkerListener);
					marker.setMap(map);
    	});
    	
      }, //addSTops
      
      // Configures tracking of user position
      setTrackUserPos: function(track) {
        trackUserPos = track;
      
        trackUser();
      }, //setTrackUserPos
      
      //Draw route form user input
     setRouteToDraw: function(routeNameParam){
      	$(teletracManager.getRoutes()).each(function(){
      		if(this.routeName == routeNameParam){
      			if(!routesOnScreen){
      				routesOnScreen = [];
      			}
      			routesOnScreen.push(routeNameParam);
      			drawRoute(this);
      		}
      	});
      	mapManager.addVehicles(vehicleCache);
      },
      
      // Clear Route from User input
      setRouteToClear: function(routeName){
      	clearRoute(routeName);
      	if(routesOnScreen){
      		for(var i = 0; i < routesOnScreen.length; i++){
      			if(routesOnScreen[i] == routeName){
      				routesOnScreen.splice(i,1);
      			}
      		}
      		if(routesOnScreen.length == 0){
      			routesOnScreen = null;
      		}
      	}
      	mapManager.addVehicles(vehicleCache);
      },
      
      //toggle route
      toggleRoute: function(inputField, routeName){
      	console.log(' input field ' + inputField);
      	if($(inputField).is(':checked')){
      		mapManager.setRouteToDraw(routeName);
      	} else {
      		mapManager.setRouteToClear(routeName);
      	}
      }
    };
};

var mapManager;