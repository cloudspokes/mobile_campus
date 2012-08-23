/*

File: apps.js
Description: Application specific functionality

Change Log:

Mauricio Created on 07/05/12

*/

function mapInit() {
      // Initialize objects
      mapManager = new MapManager();
      teletracManager = new TeletracManager();
	  console.log('mapManager and teletracManager');
	  
	  setTimeout(function() {
	     // render map
      // send addStops function and param to render map, to be passed to updateUserPos
      // and then to doRenderMap to ensure that the stop are always added after the map is rendered
      mapManager.renderMap(document.getElementById('map_div'));
      console.log('rendering the map');
    
      //variable to add stops function
      var addStopFunction = mapManager.addStops;
      console.log('mapManager stops added');
      
      // Pass mapManager add stop function as callback to getRoutes,
      // to then be passed to parseStops in teletracManager so stops get plotted
      teletracManager.getRoutesFromSFDC(addStopFunction);
      console.log('teletracManager getting routes from SFDC');
    
  	  // Set up user position tracking
      mapManager.setTrackUserPos(true);
      
      // Update user position and center to it
      mapManager.updateUserPos(true);
      }, 10000); 
}

$(document).bind("pageshow", function(event) {
  // Setting height of the map div, otherwise it will collapse to 0px
  $("#map_div").css('height', $("body").innerHeight());

  // If the transit-map page is being show, the map is visible, so update it
  if(event.target.id == "transit-map") {
    // If mapManager is null this is the first time the map is being rendered, so initialize and prepare everything
    if(!mapManager) {
      console.log('mapManager does not exist!');
	  mapInit();
    }
    
  	var autoRefreshSetting = localStorage.getItem('autoRefreshSetting');
  	
  	if(autoRefreshSetting == 'on' || !autoRefreshSetting){
	    // Set up vehicle auto refresh
	    teletracManager.setAutoRefreshVehiclesPosition(true, mapManager.addVehicles);
    } else {
    	teletracManager.setAutoRefreshVehiclesPosition(false, mapManager.addVehicles);
    }
    
    // Set up user position tracking
   // mapManager.setTrackUserPos(true);
    
    // Update user position and center to it
    //mapManager.updateUserPos(true);
    
    
    
  } else {
    // In this case map page is not being viewed, so if teletracManager exists, stop auto refresh 
    if(teletracManager) {
      teletracManager.setAutoRefreshVehiclesPosition(false);
    }
    
    // In the case the map is not being viewed, stop tracking user position on the map
    if(mapManager) {
      mapManager.setTrackUserPos(false);
    }
  }
  
});

