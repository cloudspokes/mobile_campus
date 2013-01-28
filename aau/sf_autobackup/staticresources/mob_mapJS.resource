/*

File: apps.js
Description: Application specific functionality

Change Log:

Mauricio Created on 07/05/12

*/

function mapInit() {
	//alert('mapinit');
	if(!hasNativeMap){
	//alert('No native map');
      // Initialize objects
      mapManager = new MapManager();
      teletracManager = new TeletracManager();
	  console.log('mapManager and teletracManager');
	  
	  //alert('a');
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
   }
}

function TripPlannerInit() {
	//alert('TripPlannerInit');
	if(hasNativeMap){
	
      // Initialize objects
       if(!mapManager) {
      	mapManager = new MapManager();
      }
     
	  //variable to add stops function
	  var addStopFunction = mapManager.addBusStops;
	  
	  // Pass mapManager add stop function as callback to getRoutes,
	  // to then be passed to parseStops in teletracManager so stops get plotted
	  aauMobile.tripPlanner.getBusStopsFromSFDC(addStopFunction);
	 }
}

function mapLoad(callback, data){
	//alert('mapload');
	 // Setting height of the map div, otherwise it will collapse to 0px
  	$("#map_div").css('height', $("body").innerHeight());
    console.log('running mapLoad');
  
    // If mapManager is null this is the first time the map is being rendered, so initialize and prepare everything
    if(!mapManager) {
      console.log('mapManager does not exist!');
	  mapInit();
    }
    
      // Set up user position tracking
      mapManager.setTrackUserPos(true);
      
      // Update user position and center to it
      if( data.prevPage.attr('id') != 'bus-detail'){
      	mapManager.updateUserPos(true);
      }else{
      	mapManager.updateUserPos(false);
      }
      
    $('#map_div a').live('click', function(event){
	  	event.preventDefault();
	  	var pageLink = $(this).attr('href');
		if(pageLink.length <= 1){
			//jQuery Mobile has hijacked our link to prevent the address bar from showing.
			pageLink = $(this).data('href');
		}
		WebViewer.showWebView(pageLink);
	  });
	  
  	var autoRefreshSetting = localStorage.getItem('autoRefreshSetting');
  	
  	if(autoRefreshSetting == 'on' || !autoRefreshSetting){
	    // Set up vehicle auto refresh
		console.log('TELETRAC: Attempt to set Vehicles');
	    teletracManager.setAutoRefreshVehiclesPosition(true, mapManager.addVehicles);
		console.log('TELETRAC: Vehicles retrieved.');
    } else {
    	teletracManager.setAutoRefreshVehiclesPosition(false, mapManager.addVehicles);
    }
    
    callback();
    
  
}

$(document).bind("pageshow", function(event, data) {
/*//function mapLoad(event, data){
  // Setting height of the map div, otherwise it will collapse to 0px
  $("#map_div").css('height', $("body").innerHeight());

  // If the transit-map page is being show, the map is visible, so update it
  if(event.target.id == "transit-map") {
    // If mapManager is null this is the first time the map is being rendered, so initialize and prepare everything
    if(!mapManager) {
      console.log('mapManager does not exist!');
	  mapInit();
    }
    
      // Set up user position tracking
      mapManager.setTrackUserPos(true);
      
      // Update user position and center to it
      if( data.prevPage.attr('id') != 'bus-detail'){
      	mapManager.updateUserPos(true);
      }else{
      	mapManager.updateUserPos(false);
      }
      
    $('#map_div a').live('click', function(event){
	  	event.preventDefault();
	  	var pageLink = $(this).attr('href');
		if(pageLink.length <= 1){
			//jQuery Mobile has hijacked our link to prevent the address bar from showing.
			pageLink = $(this).data('href');
		}
		WebViewer.showWebView(pageLink);
	  });
	  
  	var autoRefreshSetting = localStorage.getItem('autoRefreshSetting');
  	
  	if(autoRefreshSetting == 'on' || !autoRefreshSetting){
	    // Set up vehicle auto refresh
		console.log('TELETRAC: Attempt to set Vehicles');
	    teletracManager.setAutoRefreshVehiclesPosition(true, mapManager.addVehicles);
		console.log('TELETRAC: Vehicles retrieved.');
    } else {
    	teletracManager.setAutoRefreshVehiclesPosition(false, mapManager.addVehicles);
    }
    
    // Set up user position tracking
   // mapManager.setTrackUserPos(true);
    
    // Update user position and center to it
    //mapManager.updateUserPos(true);
    
    
    //setTimeout(mapManager.centerOnStudent(), 2000);
	$.mobile.hidePageLoadingMsg();
    
  } else {
    // In this case map page is not being viewed, so if teletracManager exists, stop auto refresh 
    if(teletracManager) {
      teletracManager.setAutoRefreshVehiclesPosition(false);
    }
    
    // In the case the map is not being viewed, stop tracking user position on the map
    if(mapManager) {
      mapManager.setTrackUserPos(false);
    }
  }*/
  if(event.target.id == "transit-map") {
    	console.log('fireEvent: mapLoad');
	  appirioUtils.fireEvent(mapLoad, data, null);
    
  }else{
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

