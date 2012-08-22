/*

File: mapManager.js
Description: Functions to render and manage Google maps

Change Log:

Mauricio Created on 07/05/12

*/

// Object used to manage Google maps
var MapManager = function() {
	
	// The info bubble
	var infoBubble;
 	
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
    var directionsDisplayMap = {};
    
    // Google direction service
    var directionsService = new google.maps.DirectionsService();
    
    //routes Currently being drawn on map
    var routesOnScreen;
    
    //cache for vehicles
    var vehicleCache;
    
    // Holder for current popup on screen
    var currentInfoBubble;
    
    // Flag to keep track of running of simpleMarkerListener
    var markerListenerIsRunning = false;
    
    
    
    // Function to parse vehicle name, returns a json object with name and route properties, if the vehicle
    // has no route associated with the name it route will be undefined. Route names must be in {}
    function parseVehicleName(vehicleName) {
      var result = {}

      result.route = vehicleName.match(/_[ a-zA-Z0-9\.\[\,\?\;\:\(\)\-\_\+\=\!\@\#\$\%\^\&\*\'\"\`]*_/);

      result.name = vehicleName;

      if(result.route) {
        result.route = result.route[0];

        result.name = result.name.replace(result.route, "");

        result.route = result.route.replace(/_/g, "");
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
    function simpleMarkerListener(marker) {
      
      if(infoBubble && (marker.stopName == currentInfoBubble)) {
        infoBubble.close();
      } else {
        if(markerListenerIsRunning == false) {
          markerListenerIsRunning = true;
          currentInfoBubble = marker.stopName;
          
          if(infoBubble) {
            infoBubble.close();
          }
          
          var content = '<div class="infoBubbleContent">' + marker.popupInfo;
          if(marker.stopName){
          	content += '<span onclick="mapManager.getStopDetails(\'' + encodeURIComponent(marker.stopName) + '\');" class="infoBubbleLink">&nbsp;</span></div>';
          } else{
            content += '</div>';
          }
          
          var size = 150;
          var s = content.split(/\<.*?\>/);
          
          if(s) {
            size = 0;
            $(s).each(function() {
              if(size < this.length) {
                size = this.length;
              }
            });
            
            size = size * 11;
          }
          if(size < 150){
          	size = 150;
          }
          
          $("#popupMeasureDiv").html(content);
         
            infoBubble = new InfoBubble({
              map: map,
              content: content,
              arrowStyle: 2,
              arrowPosition: 30,
              hideCloseButton: true,  
              shadowStyle: 1,
              padding: 0,
              backgroundColor: 'rgba(0,0,0,0.55)',
              borderRadius: 4,
              arrowSize: 10,
              borderWidth: 1,
              borderColor: '#000',
              minHeight: 45,
              minWidth: size
            });
            
            infoBubble.open(map, marker);
            setTimeout(function() {
                        markerListenerIsRunning = false;
                        }, 2000);
        }
      }
    } 
    
    function doRenderMap(element) {
        utils.log("rendering the map");
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
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            panControl: false,
            mapTypeControl: false
        };
        
        var el = element[0] ? element[0] : element;
        map = new google.maps.Map(el, myOptions);        
		
        myMarker = new google.maps.Marker({
                     position: currentLocation,
                     title: "Student Marker",
                     animation: google.maps.Animation.DROP,
                     icon: studentMarkerImage,
                     zindex: 1
                  });
        
        myMarker.popupInfo = "This is where you are!";
                  
        google.maps.event.addListener(myMarker, 'click', simpleMarkerListener);
        
        google.maps.event.addListener(map, 'click', function(event) {
        
          if(infoBubble) {
            infoBubble.close();
          }
        });
        
        // Commented out, geo location not working in iOS
        //myMarker.setMap(map);
    }
    
    // Private function to draw route on map
    // param: route object from routes ex {"routeName": "D", stops:[{stopname: abc, lat:123, long:123}, {stopname: def, lat: 123, long:123}]
    function drawRoute(route){
      if(!directionsDisplayMap[route.routeName]) {
      	var routeColor = route.stops[0].color || "#BF2200";
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
      	directionsDisplayMap[route.routeName] = directionsDisplay;
      } else {
        directionsDisplayMap[route.routeName].setMap(map);
      }
    }
    
    // Private Function to clear route form map
    // param: string of route name to clear  
    function clearRoute(routeName){
    	directionsDisplayMap[routeName].setMap(null);
    }
    
    return {
      // Update user's position and optionally pan to that position
      updateUserPos: function(pan, callback, param) {
              if(callback) {
                if(param) {
                  callback(param);
                } else { 
                  callback();
                }   
              }
        // finds location
        if(useGeolocation && navigator && navigator.geolocation) {
            var options = { timeout: 5000, enableHighAccuracy: true };
            navigator.geolocation.getCurrentPosition(function(position) {
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
            },
            function(error) {
              console.log('Navigator geolocation Error ' + error.message);
              alert(error.message);
              
              currentLocation = new google.maps.LatLng(37.786174, -122.400141);
              if(myMarker) {
                myMarker.setPosition(currentLocation);
              }
              
              if(pan) {
                if(map)
                  map.panTo(currentLocation);
              }
            }, options);
        } else {
            currentLocation = new google.maps.LatLng(37.786174, -122.400141);
            if(myMarker) {
              myMarker.setPosition(currentLocation);
            }
            
            if(pan) {
              if(map)
                map.panTo(currentLocation);
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
        console.log('*** element for map ' + element);
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
            	if(nameResult.route && busMarkers[nameResult.route]){
              	  var busMarker = new google.maps.MarkerImage(busMarkers[nameResult.route],
												    	null, 
												    	null, 
												    	null, 
												    	new google.maps.Size(25, 29) 											
					    								);
					    								
	              var marker = new google.maps.Marker({
	                            position: new google.maps.LatLng(this.Latitude, this.Longitude),
	                     		animation: google.maps.Animation.DROP,
	                     		icon: busMarker,
	                     		zindex: 2
	                          });
	              
	              marker.popupInfo = "Vehicle: " + nameResult.name + "<br />Route: " + nameResult.route;
	              
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
      
      //Sorts times so that latenight times are always at the end of the array.
      scheduleSort: function(a,b){
			//Turn the string into an array. t[0] hour, t[1] minutes, t[2] AM/PM
			var temp = a.split(':');
			var ta = temp[1].split(" ");
			ta.unshift(temp[0]);
			
			temp = b.split(':');
			var tb = temp[1].split(" ");
			tb.unshift(temp[0]);
			
			//Convert to integers.
			ta[0] = parseInt(ta[0]);
			tb[0] = parseInt(tb[0]);
			ta[1] = parseInt(ta[1]);
			tb[1] = parseInt(tb[1]);
			
			//Add additional hours if PM.
			ta[0] = (ta[2] == "PM" && ta[0] != 12)? ta[0] + 12 : ta[0];
			tb[0] = (tb[2] == "PM" && tb[0] != 12)? tb[0] + 12 : tb[0];	
			
			//Midnight is the 0 hour.
			if(ta[2] == "AM" && ta[0] == 12){
				ta[0] = 24;
			}
			if(tb[2] == "AM" && tb[0] == 12){
				tb[0] = 24;
			}
			
			//Return sort value.
			if(ta[0] == tb[0]){
				return ta[1] - tb[1];
			}else{
				return ta[0] - tb[0];
			}
		}, //scheduleSort
      		
      // Adds bus stops markers to the map
      addStops: function(stops) {
        var stpRoutes = teletracManager.getStopNamesWithRoutes();
        var scale = 0.45;
        $(stops).each( function() {
        			var stopMarker = new google.maps.MarkerImage(imgStopMarker,
												    	null, 
												    	null, 
												    	null, 
												    	new google.maps.Size(67 * scale, 67 * scale) 											
					    								);
        			
					var marker = new google.maps.Marker({
						position: new google.maps.LatLng(this.latitude, this.longitude),
						title: this.stopName,
						animation: google.maps.Animation.DROP,
						icon: stopMarker,
						zindex: 5
					});
 					marker.stopName = this.stopName;
 					
                    marker.popupInfo = this.stopName + "<br />";
                    
                    if(stpRoutes[this.stopName].length > 1) {
                      marker.popupInfo += "Routes: "; 
                    } else if(stpRoutes[this.stopName].length == 1) {
                      marker.popupInfo += "Route: "; 
                    }
                    
                    var separator = "";
                    
                    $(stpRoutes[this.stopName]).each(function() {
                      marker.popupInfo += separator + this;
                      separator = ", ";
                    });
              
                   google.maps.event.addListener(marker, 'click', function() { simpleMarkerListener(marker); });
					         marker.setMap(map);
					
					busStopMarkers[this.stopName] = marker;
    	});
    	console.log('Stop Markers ' + busStopMarkers);
      }, //addSTops
      
      // Requests schedule data from Salesforce. This is keyed by stop.
      getStopDetails: function(busStopName){
      	var restPath = "/BusStopSchedule?busStopName=" + busStopName;
		$.mobile.showPageLoadingMsg();
		RestDataPlugin.getData(mapManager.showStopDetails, mapManager.showStopError, restPath, true, "GET", "json");
      },
      
      // Renders the data returned from Salesforce.
      showStopDetails: function(data){
      	console.log(data);
      	if(data.stop){
      		$('#bus-stop-name').html(data.stop);
      	} else{
      		$('#bus-stop-name').html('Stop Schedule');
      	}
      	$('#bus-stop-list').empty();
      	$.each(data.routes, function(index, route){
      		var routeName = route.name;
      		var routeSchedule = route.schedule.join();
      		var routeColor = "#BF2200";
      		var routeArrival = "No More Stops Today";
      		route.schedule.sort(mapManager.scheduleSort);
      		
      		$.each(teletracManager.getRouteNamesAndColors(), function(index, color){
      			if(color.routeName == routeName){
      				routeColor = color.routeColor;
      			}
      		});
      		
      		var nextTime;
      		var nextSchedule;
      		var nextIndex;
      		var currentTime = new Date();
      		$.each(route.schedule, function(index, schedule){
      			var temp = schedule.split(':');
      			var t = temp[1].split(" ");
      			t.unshift(temp[0]);
      			
      			t[0] = parseInt(t[0]);
      			t[1] = parseInt(t[1]);
      			
      			//Add additional hours if PM.
      			t[0] = (t[2] == "PM" && t[0] != 12)? t[0] + 12 : t[0];
      			
      			//Midnight is the 0 hour.
      			if(t[2] == "AM" && t[0] == 12){
      				t[0] = 0;
      			}
      			
      			//If the current time is after 3AM, treat any midnight-3AM stop as tomorrow.
      			if(currentTime.getHours() > 3 && t[0] < 3){
      				t[0] += 24;
      			}
      			
      			
      			var stopTime = new Date();
      			stopTime.setHours(t[0], t[1], 0);
      			
      			if((!nextTime || nextTime - stopTime > 0) && stopTime - currentTime > 0){
      				nextTime = stopTime;
      				nextSchedule = schedule;
      				nextIndex = index;
      			}
      		});
      		if(nextTime){
      			var minutesUntil = Math.ceil((nextTime - currentTime) / 1000 / 60);
      			if(minutesUntil == 1){
      				routeArrival = "Next Bus in: <span class='bus-stop-arrival-time'>1 Minute</span>";
      			}else if(minutesUntil < 60){
      				routeArrival = "Next Bus in: <span class='bus-stop-arrival-time'>" + minutesUntil + " Minutes</span>";
      			}else{
      				routeArrival = "Next Bus at: <span class='bus-stop-arrival-time'>" + nextSchedule + "</span>";
      			}
      		}
      		var routeSchedule = "No Upcoming Stops.";
      		if(nextIndex){
      			var upcoming = route.schedule.slice(nextIndex);
      			if(upcoming.length > 8){
      				upcoming = upcoming.slice(0,8);
      			}
      			routeSchedule = "Upcoming Stops: " + upcoming.join(", ");
      		}
      		
      		$("#bus-stop-list").append($("#bus-stop-schedule-template").tmpl({routeName: routeName, 
      																		  routeArrival: routeArrival,
      																		  routeColor: routeColor, 
      																		  routeSchedule: routeSchedule}));
      		
      	});
      	if($("#bus-stop-list").hasClass("ui-listview")){
      		$("#bus-stop-list").listview("refresh");
      	}
      	$.mobile.changePage("#bus-detail", {transition: 'slide', changeHash: true});
      	$.mobile.hidePageLoadingMsg();
      },
      
      // Renders a data return failure.
      showStopError: function(data){
      	console.log(data);
      },
      
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
      	$(inputField).toggleClass('checked-on');
      	if($(inputField).hasClass('checked-on')){
      		mapManager.setRouteToDraw(routeName);
      	} else {
      		mapManager.setRouteToClear(routeName);
      	}
      }
    };
};

var mapManager;
