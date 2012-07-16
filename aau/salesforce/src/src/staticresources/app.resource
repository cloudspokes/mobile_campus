/*

File: apps.js
Description: Application specific functionality

Change Log:

Mauricio Created on 07/05/12

*/

$(document).bind("pageinit", function(event) {
  $("#map_div").css('height', $("body").innerHeight());

  // Initialize objects
  mapManager = new MapManager();
  teletracManager = new TeletracManager();

  // render map
  mapManager.renderMap($("#map_div"));
    
  // Set up vehicle auto refresh
  teletracManager.setAutoRefreshVehiclesPosition(true, mapManager.addVehicles);
    
  // Add bus stops to map
  mapManager.addStops(teletracManager.getBusStops());
  
  //mapManager.triggerResize();

});

$(document).bind("pageshow", function(event) {
  mapManager.triggerResize();
});

