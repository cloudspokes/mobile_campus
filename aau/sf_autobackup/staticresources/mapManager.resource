/*

File: mapManager.js
Description: Functions to render and manage Google maps

Change Log:

Mauricio Created on 07/05/12

*/

// Object used to manage Google maps
var MapManager = function() {

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
    var currentLocation = new google.maps.LatLng(37.788008, -122.400682);
    
    // The info window
    var infoWindow;
    
    // Define if the user position should be updated automatically
    var trackUserPos;
    
    // Defines interval to update user position in milliseconds
    var trackUserPosInterval = 30000;
    
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
    
    function doRenderMap(element, stopCallback, stopCallbackParam) {
        // Icon associated with the student marker
        var studentMarkerImage = new google.maps.MarkerImage(imgStudentMarker,
				    	null, //new google.maps.Size((72*0.3), (79*0.3)),
				    	null, //new google.maps.Point(0,0),
				    	null, //new google.maps.Point(36,79),
				    	new google.maps.Size(25, 27) //new google.maps.Size((72*0.3),(79*0.3))											
				    	);
    
        var myOptions = {
            center: currentLocation,
            zoom: 15,
            mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        
        map = new google.maps.Map(element[0], myOptions);        
		
        myMarker = new google.maps.Marker({
                     position: currentLocation,
                     title: "Me",
                     animation: google.maps.Animation.DROP,
                     icon: studentMarkerImage 
                  });
        
        myMarker.popupInfo = "This is where you are!";
                  
        google.maps.event.addListener(myMarker, 'click', simpleMarkerListener);
        
        myMarker.setMap(map);
        stopCallback(stopCallbackParam);
        utils.log('add stops called from doRenderMap');
    }
    
    return {
      // Update user's position and optionally pan to that position
      updateUserPos: function(pan, callback, param, stopCallback, stopCallbackParam) {
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
                    callback(param, stopCallback, stopCallbackParam);
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
        
      },
    
      // Centers the map on the student
      centerOnStudent: function() {
        map.panTo(myMarker.getPosition());
      },
      
      // Trigger a resize event on the map so it redraws on the full canvas
      triggerResize: function() {
        if(map)
          google.maps.event.trigger(map, 'resize');
      },
    
      // Renders a map in a specific element on the page, centralizing the map
      // in the specified latitude and longitude
      renderMap: function(element, stopCallback, stopCallbackParam) {
        
        this.updateUserPos(false, doRenderMap, element, stopCallback, stopCallbackParam);
        
      },
      
      // Given a JSON array of objects returned from teletrac, adds markers for those
      // vehicles to the map. If a marker for a vehicle with the same name already exists,
      // this updates the vehicle position rather than adding another vehicle marker.
      addVehicles: function(vehicles) {
      	var busMarker = new google.maps.MarkerImage(imgBusMarker,
				    	null, //new google.maps.Size((72*0.3), (79*0.3)),
				    	null, //new google.maps.Point(0,0),
				    	null, //new google.maps.Point(36,79),
				    	new google.maps.Size(25, 27) //new google.maps.Size((72*0.3),(79*0.3))											
				    	);
        $(vehicles.Vehicle).each(function() {
            var marker = vehicleMarkers[this.VehicleName];
            
            if(!marker) {
              marker = new google.maps.Marker({
                position: new google.maps.LatLng(this.Latitude, this.Longitude),
                title: this.VehicleName,
                animation: google.maps.Animation.DROP,
                icon: busMarker
              });
              
              marker.popupInfo = "Vehicle Name: " + this.VehicleName;
              
              google.maps.event.addListener(marker, 'click', simpleMarkerListener);

              marker.setMap(map);
            } else {
              marker.setPosition(new google.maps.LatLng(this.Latitude, this.Longitude));
            }

            vehicleMarkers[this.VehicleName] = marker;
        });
        utils.log('map from add vehicles' + map);
        
      },
      
      // Adds bus stops markers to the map
      addStops: function(stops) {
      	
        $(stops).each( function() {
        			if(this.active == true){	
    					var marker = new google.maps.Marker({
    						position: new google.maps.LatLng(this.lat, this.long),
    						title: this.stopName,
    						animation: google.maps.Animation.DROP
    					});
 
                        marker.popupInfo = "Stop at: " + this.stopName;
              
                        google.maps.event.addListener(marker, 'click', simpleMarkerListener);
    					marker.setMap(map);
    				}
    	});
      },
      
      // Configures tracking of user position
      setTrackUserPos: function(track) {
        trackUserPos = track;
      
        trackUser();
      }
    };
};

var mapManager;