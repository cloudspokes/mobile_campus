var ajaxLoading = false;
var jsonResponse;

$(document).ready(function(){
           /*       
        $.post("https://aau--dev5--c.cs12.visual.force.com/services/proxy", 
             {strAccountId: "309411", strUserName: "api_account", strPwd:"9sb^jd8G2"}, 
             {'SalesforceProxy-Endpoint':"https://xmlgateway.teletrac.net/AsciiService.asmx/GetVehicles"},
             function(data,ts,xhr){
                 console.log("success");
        });
                */
                 
        
        if(!ajaxLoading){
                ajaxLoading = true;
                $.ajax({
                    type: "GET",
                    url: "https://aau--dev6--c.cs12.visual.force.com/services/proxy",
                    dataType: "xml",
                    cache: false,
                    success: function(data, ts, xhr){
                        console.log('Success with REST call: ');
                        jsonResponse = $.xml2json(xhr.responseText);
                        console.log('    Respone :   ' + JSON.stringify(jsonResponse));
                        
                        
                        /*console.log('    Response: ' + JSON.stringify(xhr.responseText));
                        var vehicleList = $('Vehicle',xhr.responseText);
                        $(vehicleList).each(function(){
                            console.log('Vehicle Name: '+$('VehicleName',this).html());
                        });*/
                    },
                    error: function(jqXHR, ts, et) {
                        console.log('Error in REST call: ');
                        console.log('    textStatus: ' + ts + '. errorThrown: ' + et);
                        console.log('    errorResponse: ' + JSON.stringify(jqXHR));
                    },
                    headers: {
                        "SalesforceProxy-Endpoint": "https://xmlgateway.teletrac.net/AsciiService.asmx/GetVehicles?strAccountId=309411&strUserName=api_account&strPwd=9sb^jd8G2"
                    }

                });
            }

                    
    });