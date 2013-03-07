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
    var useGeolocation = true;
    
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
    var currentLocation = new google.maps.LatLng(37.786174, -122.400141);
    
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
    
    // Counter for info bubbles
    var infoBubbleCount = 0;
    
    // Flag for first resize
    var firstMapResize = false;
    
    /* PARTH: fix issue I-35353 : Map hangs if stops are clicked in quick succession*/
    //Added this var for callback function
    var fireEventCallback = function(){};
    
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
    
    function fireEvent_simpleMarkerListener(marker){
    	appirioUtils.fireEvent(simpleMarkerListener, marker, null);
    }
    
    // Simple popup listener that just shows content from the popupInfo of the associated object
    function simpleMarkerListener(callback,marker) {
    	//alert('simpleMarkerListener-' + marker);
    	console.log(marker);
    	
    	/* PARTH: fix issue I-35353 : Map hangs if stops are clicked in quick succession*/
    	mapManager.fireEventCallback = callback;
    	
      if(aauMobile.getAndroidVersion() < 3.0 && aauMobile.getAndroidVersion() > 0 && marker.name && !marker.isBus){
      	mapManager.getStopDetails(encodeURIComponent(marker.name));
      	//callback();  
      	return;
      } 
      if(infoBubble && (marker.name == currentInfoBubble)) {
        infoBubble.close();
        currentInfoBubble = null;
      } else {
        if(markerListenerIsRunning == false) {
          markerListenerIsRunning = true;
          currentInfoBubble = marker.name;
          infoBubbleCount++;
          
          if(infoBubble) {
            infoBubble.close();
          }
          
          var content = '<div class="infoBubbleContent">' + marker.popupInfo;
          if(!marker.isBus){
          		content += '<span name="' + encodeURIComponent(marker.name) + '" class="infoBubbleLink" id="infoBubble' + infoBubbleCount + '">&nbsp;</span></div>';
          } else{
            content += '</div>';
          }
          
          //var size = 230;150;
          var size = 230;
         /* var s = content.split(/\<.*?\>/);
          
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
          }*/
          
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
              //minHeight: 45,
              minWidth: size
            });
            
            infoBubble.open(map, marker);
         	setTimeout(function() {
                        markerListenerIsRunning = false;
                        if(aauMobile && aauMobile.isIOS()){
				           $('span.infoBubbleLink').on('touchstart', function(e){
				           		console.log('infoBubbleLink clicked');
				            	e.preventDefault();
				            	e.stopPropagation();
				            	mapManager.fireEvent_getStopDetails($(this).attr('name'));
				            });
			            } else{
				           $('span.infoBubbleLink').on('click', function(e){
				            	console.log('infoBubbleLink clicked');
				            	e.preventDefault();
				            	e.stopPropagation();
								mapManager.fireEvent_getStopDetails($(this).attr('name'));
				            });				            																									 
			            }
                     }, 1300);
          /* PARTH: fire callback */
          //callback();          
        }
      }
      /* PARTH: fix issue I-35353 : Map hangs if stops are clicked in quick succession*/
      mapManager.fireEventCallback();
    } 
    
    function doRenderMap(element) {
        appirioUtils.log("rendering the map");
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
		  if(useGeolocation) {
          myMarker = new google.maps.Marker({
                       position: currentLocation,
                       title: "Student Marker",
                       animation: google.maps.Animation.DROP,
                       icon: studentMarkerImage,
                       zindex: 1,
                       clickable: true
                    });
          
          // Commented out, geo location not working in iOS
          //myMarker.setMap(map);
        }
        
        google.maps.event.addListener(map, 'click', function(event) {
                    console.log(event);
          console.log(event.latLng);
          if(infoBubble) {
            infoBubble.close();
            currentInfoBubble = null;
          }
        });
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
      	}
      	
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
   		nearestStop: '',
   		getClosestStop_Callback: function(){},
   		
   		getClosestStop: function(callback){
   			
   			mapManager.getClosestStop_Callback = callback;
   			if(useGeolocation && navigator && navigator.geolocation) {
	            var options = { timeout: 10000, enableHighAccuracy: false };
	            navigator.geolocation.getCurrentPosition(function(position) {
	                var posLat = position.coords.latitude;
	            	var posLong = position.coords.longitude;
	            			
	            	console.log("Current Position: " + posLat + " , " + posLong);
	            	
	            	var R = 6371; // Radius of the earth in km
	            	var M = 0.621371192; //Kilometer per mile
	            	var RAD = Math.PI / 180;
	            	
	            	var dMin = 9999999;
	            	var closestStopId = '0'; 
	            	$(mapManager.busStopDetails).each( function() {
	            	//alert(this.lat);
	            		var dLat = (posLat-this.lat) * RAD;  
						var dLon = (posLong-this.lng) * RAD; 
						var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
						        Math.cos(this.lat * RAD) * Math.cos(posLat * RAD) * 
						        Math.sin(dLon/2) * Math.sin(dLon/2); 
						var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
						var d = R * c * M; // Distance in miles
						
						if(d <= dMin){ 
							dMin = d;
							//alert(this.Id)
							closestStopId = this.stopId;
						}
	            	});
					
					//alert("closest Stop " + closestStopId );
					console.log("closest Stop " + closestStopId );
					mapManager.nearestStop = closestStopId;
					mapManager.getClosestStop_Callback(closestStopId);
	            	//return closestStopId;
	            },
	            function(error) {
	              console.log('Navigator geolocation Error ' + error.message);
	              
	             mapManager.nearestStop = '0';
	             mapManager.getClosestStop_Callback('');
	            });
           }else{ 
           		mapManager.nearestStop = '0';
           		 mapManager.getClosestStop_Callback('');
           	}
   		},	
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
            var options = { timeout: 10000, enableHighAccuracy: false };
            navigator.geolocation.getCurrentPosition(function(position) {
                var defaultLat = 37.789238;
            	var defaultLong = -122.401407;
            	var posLat = position.coords.latitude;
            	var posLong = position.coords.longitude;
            	
            	console.log("Current Position: " + posLat + " , " + posLong);
            	
            	var R = 6371; // Radius of the earth in km
            	var M = 0.621371192; //Kilometer per mile
            	var RAD = Math.PI / 180;
				var dLat = (posLat-defaultLat) * RAD;  
				var dLon = (posLong-defaultLong) * RAD; 
				var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
				        Math.cos(defaultLat * RAD) * Math.cos(posLat * RAD) * 
				        Math.sin(dLon/2) * Math.sin(dLon/2); 
				var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
				var d = R * c * M; // Distance in miles
				
				console.log("Distance from New Montgomery: " + d + " miles");
            	
            	if(d < 6.0){
                	currentLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
                } else{
                	currentLocation = new google.maps.LatLng(defaultLat, defaultLong);
                }
                
              /*  if(myMarker) {
                  myMarker.setMap(null);
                  myMarker.setPosition(currentLocation);
                  myMarker.setMap(map);
                }*/
                
                if(pan) {
                  if(map)
                    map.panTo(currentLocation);
                }
            },
            function(error) {
              console.log('Navigator geolocation Error ' + error.message);
              
              currentLocation = new google.maps.LatLng(37.78628600, -122.39931900);
              if(myMarker) {
                myMarker.setPosition(currentLocation);
              }
              
              if(pan) {
                if(map)
                  map.panTo(currentLocation);
              }
            });
        } else {
            currentLocation = new google.maps.LatLng(37.78628600, -122.39931900);
            if(myMarker) {
              myMarker.setPosition(currentLocation);
            }
            
            if(pan) {
              if(map)
                map.panTo(currentLocation);
            }
        }
        
        /*if(pan) {
          if(map)
            map.panTo(currentLocation);
        }*/
        
      }, //updateUserPos
    
      // Centers the map on the student
      centerOnStudent: function() {
        map.panTo(myMarker.getPosition());
      }, //centeronStudent
      
      // Trigger a resize event on the map so it redraws on the full canvas
      triggerResize: function() {
        if(map) {
          google.maps.event.trigger(map, 'resize');
          if(!firstMapResize) {
            map.panTo(currentLocation);
            firstMapResize = true;
          }
        }
      }, //triggerResize
    
      // Renders a map in a specific element on the page, centralizing the map
      // in the specified latitude and longitude
      renderMap: function(element) {
        this.updateUserPos(true, doRenderMap, element);
        
      }, //renderMap
      
      // Given a JSON array of objects returned from teletrac, adds markers for those
      // vehicles to the map. If a marker for a vehicle with the same name already exists,
      // this updates the vehicle position rather than adding another vehicle marker.
      addVehicles: function(vehicles) {
		//console.log('Test Vehicles! '+JSON.stringify(vehicles));
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
	              
	              marker.name = nameResult.name;
	              marker.isBus = true;
	              //PARTH:Fix I-35493 - remove vehicle name from popup 
	              //marker.popupInfo = "Vehicle: " + nameResult.name + "<br />Route: " + nameResult.route;
	              marker.popupInfo = "Route: " + nameResult.route;
	              
	              //google.maps.event.addListener(marker, 'click', function(){simpleMarkerListener(marker)});
	              google.maps.event.addListener(marker, 'click', function(){fireEvent_simpleMarkerListener(marker)});
	
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
     
     busStopDetails: [],
     
     
	  // Adds bus stops markers to the map
      addStops: function(stops) {
      	//alert('addStops');
        var stpRoutes = teletracManager.getStopNamesWithRoutes();
        var scale = 0.45;
        var listContainer = $('#bus-stop-ul');
        var listTemplate = $("#bus-stop-template");
      //PARTH: Travel Planner items
      	var startSelectContainer = $('#startStop-select');
      	var finishSelectContainer = $('#endStop-select');
        var optionsTemplate = $("#bus-stop-options-template");
        var startDetailContainer = $('#stopdetails');
        var optionsDetailTemplate = $("#bus-stop-detail-template");
        
        var index = 0;
        var jsonList =[];
        $(stops).each( function() {
        			var stopMarker = new google.maps.MarkerImage(imgStopMarker,
												    	null, 
												    	null, 
												    	null, 
												    	new google.maps.Size(38 * scale, 53 * scale) 											
					    								);
        			
					var marker = new google.maps.Marker({
						position: new google.maps.LatLng(this.latitude, this.longitude),
						title: this.stopName,
						animation: google.maps.Animation.DROP,
						icon: stopMarker,
						zindex: 300
					});
 					marker.name = this.stopName;
 					marker.isBus = false;
                    marker.popupInfo = this.stopName + "<br />";
                    var stopRoutes = "";
                    if(stpRoutes[this.stopName].length > 1) {
                      marker.popupInfo += "Routes: "; 
                      stopRoutes = "Routes: ";
                    } else if(stpRoutes[this.stopName].length == 1) {
                      marker.popupInfo += "Route: "; 
                      stopRoutes = "Route: ";
                    }
                    
                    var separator = ""; 
                    
                    $(stpRoutes[this.stopName]).each(function() {
                      marker.popupInfo += separator + this;
                      stopRoutes += separator + this;
                      separator = ", ";
                    });
              
                   //google.maps.event.addListener(marker, 'click', function() { simpleMarkerListener(marker); });
                   google.maps.event.addListener(marker, 'click', function() { fireEvent_simpleMarkerListener(marker); });
					         marker.setMap(map);
					
					busStopMarkers[this.stopName] = marker;
					//PARTH: add to json List
					//alert(JSON.stringify(this));
					//jsonList.push({busStopTitle: this.stopName, busStopRoutes: stopRoutes,stopId: this.stopName.replace(/ /g,"-")});
					jsonList.push({busStopTitle: this.stopName, busStopRoutes: stopRoutes,stopId: this.id,stopName: encodeURIComponent(this.stopName)});
					mapManager.busStopDetails.push({busStopTitle: this.stopName,lat:this.latitude, lng:this.longitude, busStopRoutes: stopRoutes,stopId: this.id,stopName: encodeURIComponent(this.stopName)});
					index++;
				    //listTemplate.tmpl({busStopTitle: this.stopName, busStopRoutes: stopRoutes}).appendTo(listContainer);
				    
    	});
    	//PARTH: run template for json list
    	listTemplate.tmpl(jsonList).appendTo(listContainer);
    	optionsTemplate.tmpl(jsonList).appendTo(startSelectContainer);
    	 /*if($(startSelectContainer).hasClass('ui-listview')){
			$(startSelectContainer).listview('refresh');
		}*/
    	
    	optionsTemplate.tmpl(jsonList).appendTo(finishSelectContainer);
    	/*if($(finishSelectContainer).hasClass('ui-listview')){
			$(finishSelectContainer).listview('refresh');
		}*/
    	optionsDetailTemplate.tmpl(jsonList).appendTo(startDetailContainer);
    	
		
   	    if($(listContainer).hasClass('ui-listview')){
			$(listContainer).listview('refresh');
		}
      }, //addSTops
      
       addBusStops: function(stops) {
      	//alert('addBusStops');
        var stpRoutes = aauMobile.tripPlanner.stopNamesWithRoutes;
        
        //var scale = 0.45;
        //var listContainer = $('#bus-stop-ul');
        //var listTemplate = $("#bus-stop-template");
      //PARTH: Travel Planner items
      	var startSelectContainer = $('#startStop-select');
      	var finishSelectContainer = $('#endStop-select');
        var optionsTemplate = $("#bus-stop-options-template");
        var startDetailContainer = $('#stopdetails');
        var optionsDetailTemplate = $("#bus-stop-detail-template");
        
        var index = 0;
        var jsonList =[];
        $(stops).each( function() {
        			
                    var stopRoutes = "";
                    if(stpRoutes[this.stopName].length > 1) {
                      stopRoutes = "Routes: ";
                    } else if(stpRoutes[this.stopName].length == 1) {
                      stopRoutes = "Route: ";
                    }
                    
                    var separator = ""; 
                    
                    $(stpRoutes[this.stopName]).each(function() {
                      stopRoutes += separator + this;
                      separator = ", ";
                    });
              
                    //PARTH: add to json List
					//alert(JSON.stringify(this));
					//jsonList.push({busStopTitle: this.stopName, busStopRoutes: stopRoutes,stopId: this.stopName.replace(/ /g,"-")});
					jsonList.push({busStopTitle: this.stopName, busStopRoutes: stopRoutes,stopId: this.id,stopName: encodeURIComponent(this.stopName)});
					mapManager.busStopDetails.push({busStopTitle: this.stopName,lat:this.latitude, lng:this.longitude, busStopRoutes: stopRoutes,stopId: this.id,stopName: encodeURIComponent(this.stopName)});
					index++;
				    //listTemplate.tmpl({busStopTitle: this.stopName, busStopRoutes: stopRoutes}).appendTo(listContainer);
				    
    	});
    	//PARTH: run template for json list
    	//listTemplate.tmpl(jsonList).appendTo(listContainer);
    	
    	optionsTemplate.tmpl(jsonList).appendTo(startSelectContainer);
    	
    	optionsTemplate.tmpl(jsonList).appendTo(finishSelectContainer);
    	
    	optionsDetailTemplate.tmpl(jsonList).appendTo(startDetailContainer);
    	
      }, //addBusSTops
      
      fireEvent_getStopDetails: function(busStopName){
      	appirioUtils.fireEvent(mapManager.getStopDetails_Event, busStopName, null);
      },
      
      getStopDetails_Event : function(callback,busStopName){
      		mapManager.fireEventCallback = callback;
      		mapManager.getStopDetails(busStopName);
      },
      
      // Requests schedule data from Salesforce. This is keyed by stop.
      getStopDetails: function(busStopName){
      	var restPath = "/BusStopSchedule?busStopName=" + busStopName;
		$.mobile.showPageLoadingMsg("b", "Loading...", false);
  		$('.ui-loader').css('display', 'block');
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
      	
      	var jsonList = [];
      	$.each(data.routes, function(index, route){
      		var routeName = route.name;
      		var routeSchedule = route.schedule.join();
      		var routeColor = "#BF2200";
      		var routeArrival = "No More Stops Today";
      		route.schedule.sort(aauMobile.scheduleSort);
      		
      		var routeNameAndColor ;
      		if(!hasNativeMap){
      			routeNameAndColor = teletracManager.getRouteNamesAndColors();
      		}else{
      			routeNameAndColor = aauMobile.tripPlanner.routeNamesAndColors;
      		}
      		
      		$.each(routeNameAndColor, function(index, color){
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
      			console.log('stopTime = ' +stopTime);
      			console.log('currentTime = ' +currentTime);
      			console.log('stopTime - currentTime = ' + (stopTime - currentTime));
      			if((!nextTime || nextTime - stopTime > 0) && stopTime - currentTime > 0){
      				nextTime = stopTime;
      				nextSchedule = schedule;
      				nextIndex = index;
      			}
      		});
      		
      		console.log('nextTime = ' +nextTime);
      		console.log('nextSchedule = ' +nextSchedule);
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
      		console.log('nextIndex = ' +nextIndex);
      		var routeSchedule = "No Upcoming Stops.";
      		if(nextIndex){
      			var upcoming = route.schedule.slice(nextIndex);
      			if(upcoming.length > 8){
      				upcoming = upcoming.slice(0,8);
      			}
      			routeSchedule = "Upcoming Stops: " + upcoming.join(", ");
      		}
      		console.log('routeName = ' +routeName);
      		console.log('routeArrival = ' +routeArrival);
      		console.log('routeColor = ' +routeColor);
      		console.log('routeSchedule = ' +routeSchedule);
      		
      		//PARTH: add to json
      		jsonList.push({routeName: routeName, 
						  routeArrival: routeArrival,
						  routeColor: routeColor, 
						  routeSchedule: routeSchedule});
      		/*$("#bus-stop-list").append($("#bus-stop-schedule-template").tmpl({routeName: routeName, 
      																		  routeArrival: routeArrival,
      																		  routeColor: routeColor, 
      																		  routeSchedule: routeSchedule}));*/
      		
      	});
      	//PARTH: run template for json list
      	$("#bus-stop-list").append($("#bus-stop-schedule-template").tmpl(jsonList));
      	
      /* PARTH: fix issue I-35353 : Map hangs if stops are clicked in quick succession*/
      	if(mapManager.fireEventCallback){
      		mapManager.fireEventCallback()
      	}else{
      		$.mobile.hidePageLoadingMsg();
  			$('.ui-loader').css('display', 'none');
      	}
      	
      	if($("#bus-stop-list").hasClass("ui-listview")){
      		$("#bus-stop-list").listview("refresh");
      	}
      	$.mobile.changePage("#bus-detail", {transition: 'slide', changeHash: true});
      	$.mobile.hidePageLoadingMsg();
  		$('.ui-loader').css('display', 'none');
      },
      
      // Renders a data return failure.
      showStopError: function(data){
      	console.log(data);
      	alert(JSON.stringify(data));
      	$.mobile.hidePageLoadingMsg();
      	$('.ui-loader').css('display', 'none');
      	
      	/* PARTH: fix issue I-35353 : Map hangs if stops are clicked in quick succession*/
      	if(mapManager.fireEventCallback){
      		mapManager.fireEventCallback()
      	}else{
      		$.mobile.hidePageLoadingMsg();
  			$('.ui-loader').css('display', 'none');
      	}
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
