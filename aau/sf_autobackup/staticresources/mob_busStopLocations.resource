/*
latitude and longitude of bus stops for AAU,
To add another stop:
and a , after the last } on the last line
format for stop should be {"stopName": "stop name here", "lat" latitude, "long" longitutde }

geocode data pulled from http://gmaps-samples.googlecode.com/svn/trunk/geocoder/singlegeocode.html/

*/

var busStops = [{"stopName": "1849 Washington ST", "lat": 37.792932, "long": -122.423767, "active": true}, //0
			{"stopName": "625 Polk", "lat": 37.782452, "long": -122.419172, "active": true},               //1
			{"stopName": "620 Sutter", "lat": 37.789241, "long": -122.41073, "active": true},              //2
			{"stopName": "680 Sutter", "lat": 37.78907, "long": -122.411577, "active": true},              //3
			{"stopName": "860 Sutter", "lat": 37.78857, "long": -122.414602, "active": true},              //4
			{"stopName": "701 Chestnut", "lat": 37.80363, "long": -122.414903, "active": true},         //5
			{"stopName": "2801 Leavenworth", "lat": 37.806945, "long": -122.41889, "active": true},        //6
			{"stopName": "2300 Stockton", "lat": 37.806979, "long": -122.410479, "active": true},          //7
			{"stopName": "180 New Montgomery", "lat": 37.786286, "long": -122.399319, "active": true},  //8
			{"stopName": "466 Townsend", "lat": 37.774134, "long": -122.39927, "active": true},            //9
			{"stopName": "601 Brannan", "lat": 37.774917, "long": -122.400842, "active": true},         //10
			{"stopName": "60 Federal", "lat": 37.782808, "long": -122.392923, "active": true},             //11
			{"stopName": "2206 Van Ness", "lat": 37.796106, "long": -122.423943, "active": true},          //12
			{"stopName": "1916 Octavia", "lat": 37.790374, "long": -122.42704, "active": false},            //13
			{"stopName": "491 Post", "lat": 37.78784, "long": -122.409698, "active": true},                //14
			{"stopName": "1727 Lombard", "lat": 37.800207, "long": -122.43021, "active": true}];            //15
			
//{"stopName": "150 Hayes", "lat": 37.777511, "long": -122.418851},    


busRoutes = {routes: [{"routeName": "D", stops:[{"stopName": "620 Sutter", "lat": 37.789241, "long": -122.41073},
					  							{"stopName": "680 Sutter", "lat": 37.78907, "long": -122.411577},
					  							{"stopName": "860 Sutter", "lat": 37.78857, "long": -122.414602},
											    {"stopName": "701 Chestnut", "lat": 37.80363, "long": -122.414903},
											    {"stopName": "2300 Stockton", "lat": 37.806979, "long": -122.410479},
											    {"stopName": "2801 Leavenworth", "lat": 37.806945, "long": -122.41889},
											    {"stopName": "2206 Van Ness", "lat": 37.796106, "long": -122.423943},
											    {"stopName": "1849 Washington ST", "lat": 37.792932, "long": -122.423767}]}, 
					  {"routeName": "E", stops:[{"stopName": "180 New Montgomery", "lat": 37.786286, "long": -122.399319},
					  							{"stopName": "701 Chestnut", "lat": 37.80363, "long": -122.414903},
					  							{"stopName": "2801 Leavenworth", "lat": 37.806945, "long": -122.41889},
					  							{"stopName": "2300 Stockton", "lat": 37.806979, "long": -122.410479}]}, 
					  {"routeName": "G", stops:[{"stopName": "860 Sutter", "lat": 37.78857, "long": -122.414602},
					  							{"stopName": "680 Sutter", "lat": 37.78907, "long": -122.411577},
					  							{"stopName": "620 Sutter", "lat": 37.789241, "long": -122.41073},
					  							{"stopName": "60 Federal", "lat": 37.782808, "long": -122.392923},
					  							{"stopName": "180 New Montgomery", "lat": 37.786286, "long": -122.399319}]},
					  {"routeName": "H", stops:[{"stopName": "860 Sutter", "lat": 37.78857, "long": -122.414602},
					  							{"stopName": "680 Sutter", "lat": 37.78907, "long": -122.411577},
					  							{"stopName": "620 Sutter", "lat": 37.789241, "long": -122.41073},
					  							{"stopName": "491 Post", "lat": 37.78784, "long": -122.409698},
					  							{"stopName": "180 New Montgomery", "lat": 37.786286, "long": -122.399319},
					  							{"stopName": "601 Brannan", "lat": 37.774917, "long": -122.400842},
					  							{"stopName": "466 Townsend", "lat": 37.774134, "long": -122.39927}]}, 
					  {"routeName": "I", stops:[{"stopName": "180 New Montgomery", "lat": 37.786286, "long": -122.399319},
					  							{"stopName": "620 Sutter", "lat": 37.789241, "long": -122.41073},
					  							{"stopName": "680 Sutter", "lat": 37.78907, "long": -122.411577},
					  							{"stopName": "860 Sutter", "lat": 37.78857, "long": -122.414602},
					  							{"stopName": "466 Townsend", "lat": 37.774134, "long": -122.39927},
					  							{"stopName": "601 Brannan", "lat": 37.774917, "long": -122.400842}]}, 
					  {"routeName": "J", stops:[{"stopName": "180 New Montgomery", "lat": 37.786286, "long": -122.399319},
					  							{"stopName": "60 Federal", "lat": 37.782808, "long": -122.392923},
					  							{"stopName": "601 Brannan", "lat": 37.774917, "long": -122.400842},
					  							{"stopName": "466 Townsend", "lat": 37.774134, "long": -122.39927}]},
					  {"routeName": "M", stops:[{"stopName": "860 Sutter", "lat": 37.78857, "long": -122.414602},
					  							{"stopName": "680 Sutter", "lat": 37.78907, "long": -122.411577},
					  							{"stopName": "620 Sutter", "lat": 37.789241, "long": -122.41073},
					  							{"stopName": "1727 Lombard", "lat": 37.800207, "long": -122.43021},
					  							{"stopName": "2206 Van Ness", "lat": 37.796106, "long": -122.423943},
					  							{"stopName": "1849 Washington ST", "lat": 37.792932, "long": -122.423767}]},
					  {"routeName": "T", stops:[{"stopName": "625 Polk", "lat": 37.782452, "long": -122.419172},
					  							{"stopName": "860 Sutter", "lat": 37.78857, "long": -122.414602},
					  							{"stopName": "680 Sutter", "lat": 37.78907, "long": -122.411577},
					  							{"stopName": "620 Sutter", "lat": 37.789241, "long": -122.41073}]} ]};




/*var aauMobileMap = aauMobileMap || {
 
busStopLocations: {
	data: {},
	init: function(){

		var restPath = "/BusStops/"; 
		RestDataPlugin.getData(aauMobileMap.busStopLocations.buildSchedule, aauMobileMap.busStopLocations.initFailure, restPath, true, "GET", "json");
	},
	buildSchedule: function(result){
		console.log("Map successCallback Result: "+ JSON.stringify(result));
		aauMobileMap.busStopLocations.data = result;
	},
	initFailure: function(result) {
		console.log("failureCallback Result: "+ JSON.stringify(result));
	}
 }
};

$("#transit-map").live("pageinit", function(event) {
    // init Class busStopLocations data
	aauMobileMap.busStopLocations.init();
});*/




          