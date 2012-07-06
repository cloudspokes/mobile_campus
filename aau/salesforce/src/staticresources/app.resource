/*

File: apps.js
Description: Application specific functionality

Change Log:

Mauricio Created on 07/05/12

*/

$(document).ready(function() {
    // render map
    mapManager.renderMap($("#map_canvas"));
    
    // Set up vehicle auto refresh
    teletracManager.setAutoRefreshVehiclesPosition(true, mapManager.addVehicles);
    
    // Add bus stops to map
    mapManager.addStops(teletracManager.getBusStops());
});