/*

File: mapManager.js
Description: Functions to render and manage Google maps

Change Log:

Mauricio Created on 07/05/12

*/

// Object used to manage Google maps
var MapManager = function() {
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
                     icon: {
                       path: google.maps.SymbolPath.BACKWARD_CLOSED_ARROW,
                       scale: 3
                     } 
                  });
        
        myMarker.popupInfo = "This is where you are!";
                  
        google.maps.event.addListener(myMarker, 'click', simpleMarkerListener);
        
        myMarker.setMap(map);
    }
    
    return {
      // Renders a map in a specific element on the page, centralizing the map
      // in the specified latitude and longitude
      renderMap: function(element) {
        
        // finds location
        if(navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(position) {
                utils.log(position);
                currentLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
                doRenderMap(element);
            });
        } else {
            doRenderMap(element);
        }
      },
      
      // Given a JSON array of objects returned from teletrac, adds markers for those
      // vehicles to the map. If a marker for a vehicle with the same name already exists,
      // this updates the vehicle position rather than adding another vehicle marker.
      addVehicles: function(vehicles) {
        $(vehicles.Vehicle).each(function() {
            var marker = vehicleMarkers[this.VehicleName];
            
            if(!marker) {
              marker = new google.maps.Marker({
                position: new google.maps.LatLng(this.Latitude, this.Longitude),
                title: this.VehicleName,
                animation: google.maps.Animation.DROP
              });
              
              marker.popupInfo = "Vehicle Name: " + this.VehicleName;
              
              google.maps.event.addListener(marker, 'click', simpleMarkerListener);

              marker.setMap(map);
            } else {
              marker.setPosition(new google.maps.LatLng(this.Latitude, this.Longitude));
            }

            vehicleMarkers[this.VehicleName] = marker;
        });
        
      },
      
      // Adds bus stops markers to the map, if a stop already exists with the same name, this
      // updates the marker position rather than adding a new stop marker
      addStops: function(stops) {
        $(stops).each(function() {
            var substr = this.address.split(',');
            var stopName = substr[0];
            var marker = busStopMarkers[stopName];
            var address = this.address;
            
    	    geocoder.geocode({'address': this.address}, function(results, status){
                if(status == google.maps.GeocoderStatus.OK){
                    if(marker) {
                        marker.setPosition(result[0].geometry.location);
                    } else {
                        marker = new google.maps.Marker({
                            position: results[0].geometry.location,
                            title: substr[0],
                            animation: google.maps.Animation.DROP,
                            icon: {
                                path: google.maps.SymbolPath.CIRCLE,
                                scale: 6
                            }
                        });
                        
                        marker.popupInfo = "Bus stop at: " + address;
                        
                        google.maps.event.addListener(marker, 'click', simpleMarkerListener);
                        
                        marker.setMap(map);
                        busStopMarkers[substr[0]] = marker;
                    }
    		}else{
                    utils.log("Geocode was not successful for the following reason: " + status);
    		}
    	    });    		
        });
      }
    };
};

var mapManager = new MapManager();