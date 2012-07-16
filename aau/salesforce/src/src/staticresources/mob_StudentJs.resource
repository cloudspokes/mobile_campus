var aauMobile = aauMobile  || {};
aauMobile.classSchedule = aauMobile.classSchedule || {};
aauMobile.classSchedule.data = aauMobile.classSchedule.data || {};
var catData =  catData || {};

function successCallback (result){
   //console.log("successCallback Result: "+ JSON.stringify(result));
   aauMobile.classSchedule.data = result;
   catData = {
	          enrollments:aauMobile.classSchedule.data.mobStudentsEnrolled,
			  classMeetings:aauMobile.classSchedule.data.classMeetings,
			  startDate:aauMobile.classSchedule.data.startDate,
			  lastDate:aauMobile.classSchedule.data.lastDate
      }
      console.log(":startDate::"+catData.startDate);
      console.log(":lastDate::"+catData.lastDate);
      var stDate =new Date(catData.startDate);
      var enDate =new Date(catData.lastDate);
      
      //console.log(":mobStudentsEnrolled:======= "+JSON.stringify(catData.enrollments));
     //console.log(":classMeetings:======= "+JSON.stringify(catData.classMeetings));
	  var blockTemplate = $("#student-schedule-template");
	  var blockDivider = $("#student-scheduleDivider-template");
	  var detailContent = $("#ulId");
      var isClassMeeting = true;
      for(; stDate < enDate; stDate.setDate(stDate.getDate() + 1)){
        var weekDay = "Sunday";
        if(stDate.getDay() == 0)weekDay = "Sunday";
        else if(stDate.getDay() == 1)weekDay = "Monday";
        else if(stDate.getDay() == 2)weekDay = "Tuesday";
        else if(stDate.getDay() == 3)weekDay = "Wednesday";
        else if(stDate.getDay() == 4)weekDay = "Thursday";
        else if(stDate.getDay() == 5)weekDay ="Friday";
        else if(stDate.getDay() == 6)weekDay = "Saturday";
        if(isClassMeeting){
                var dBlock = blockDivider.tmpl({MeetingDayAndDay:weekDay+' '+stDate});
	            dBlock.appendTo(detailContent);
             }
        isClassMeeting = false;
        $.each(catData.classMeetings, function(index, classMeeting) {
            var meetingSTDate = new Date(classMeeting.startDate);
	        var meetingENDate = new Date(classMeeting.endDate);
	        var daySelected = classMeeting.isMonday;
	        if(stDate >= meetingSTDate && stDate<=meetingENDate){
	           if((stDate.getDay()== 0 && classMeeting.isSunday) || (stDate.getDay()== 1 && classMeeting.isMonday) || (stDate.getDay()== 2 && classMeeting.isTuesday)
	               || (stDate.getDay()== 3 && classMeeting.isWednesday) || (stDate.getDay()== 4 && classMeeting.isThursday) || (stDate.getDay()== 5 && classMeeting.isFriday) || (stDate.getDay()== 6 && classMeeting.isSaturday)){
  				    var className = '';
  				    var classDescription=''; 
			        if(catData.enrollments[classMeeting.classSection]){
			            className = catData.enrollments[classMeeting.classSection].className;
			            classDescription = catData.enrollments[classMeeting.classSection].classDescription;
			        }
			        var mLocation = classMeeting.location;
			        var topicName = classMeeting.specialTopic;
			        var startTime =  classMeeting.startTime;
			        var endTime = classMeeting.endTime;
			        var instructorName = classMeeting.instructorName; 
			        
			        var block = blockTemplate.tmpl({meetingTime:startTime+' - '+endTime,meetingTopic:topicName,meetingInstructor:instructorName,topic:topicName,className:className,meetingLocation:mLocation,stTime:startTime,
			                                        edTime:endTime,classNameDv:className,cDescription:classDescription,mLocation:mLocation});
			        block.appendTo(detailContent);        
			        isClassMeeting = true;       	               
               } 
	        }
         });
        
      }
       $("#ulId").listview("refresh");     
}
	
function failureCallback(result){
   console.log("failureCallback Result: "+ JSON.stringify(result));
}

function readCookie (name) {
	 var nameEQ = name + "=";
	// var ca = top.content.document.cookie.split(';');
	 var ca = document.cookie.split(';');
	 for(var i=0;i < ca.length;i++) {
	  var c = ca[i];
	  while (c.charAt(0)==' ') c = c.substring(1,c.length);
	  if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	 }
	 return null;
};

aauMobile.classSchedule = {
    
	init: function(){
	  //var contactId = '003V0000009kTMpIAM';
	  //var contactId = '003V0000009kTMv';
	  //var contactId = '003V0000009ko5y';
	  var contactId = '003V0000009kTN1';
	  
	  var webUrl = 'https://aau--dev6--c.cs12.visual.force.com/services/proxy'; 
	  var client = '3MVG9Oe7T3Ol0ea4rCgfMtZo3n40wB4t890nElRZIKn5z2cjSuFdf13Yrw6bgcwA5vlotolfrrrHGqaimsfyM';
	  var restPath = "https://na14.salesforce.com/services/apexrest/classSchedule/"+contactId;
	  aauMobile.classSchedule.categoryData = '';
	  if(RestDataPlugin.isPhonegap()){
	    console.log('::Phone Gap Availbale ::');
	       //================== Call to Phonegap to get the data ===================
			console.log('Attempt Phonegap WS call');
			ContentDataPlugin.getContent(function(data){
				console.log('Phonegap WS Success!! ' + $.parseJSON(data));
				console.log('Phonegap WS Success!! ' + JSON.stringify($.parseJSON(data)));
				loadContentData($.parseJSON(data)); //process the data
			},
			function(error){
				console.log('Phonegap WS Error: '+JSON.stringify(error));
			},restPath);
	    
	  }else{
	    console.log('::on Browser Phone Gap not  Availbale ::');
	   // Using Force.Com ToolKit
	   RestDataPlugin.getAjaxDataByForceTK(successCallback, failureCallback, '/classSchedule/'+contactId, "GET", "json",webUrl,client);
	   //make call to Phonegap REST call
	  }
	},
	
    showClassDetails: function(meetTime,topic,instructor,classNameDv,cDescription,mLocation) {
      $.mobile.changePage("#student-detail");
      $('#ulDlId').empty();
      $('#classNameDv').empty();
      $('#classDescrDv').empty();
      
      $("<h2>"+classNameDv+"</h2>").appendTo('#classNameDv');
      $("<h3>"+cDescription+"</h3>").appendTo('#classDescrDv');
       console.log(":Show Details ::  meetingTime :: "+meetTime);
       console.log(":Show Details ::  topic ::"+topic);
       console.log(":Show Details ::  instructor ::"+instructor);
       var blockTemplate = $("#student-classDetail-template");
	   var detailContent = $("#ulDlId");
	   if(instructor == '')
	     instructor = 'SFDC Admin'; 
	   if(topic == '')
	     topic = 'Topic';  
	   
	   var detailBlock = blockTemplate.tmpl({meetingTime:meetTime,meetingTopic:topic,meetingInstruction:instructor,mLocation:mLocation});
	   detailBlock.appendTo(detailContent);
	   $("#ulDlId").listview("refresh");      
    },
    
	loadStudentSchedule: function(){
	}
};

var ContentDataPlugin = {
	getContent: function(successCallback, failureCallback,restPath) {
		console.log('In ContentDataPlugin.  Calling Phonegap...');
		PhoneGap.exec(successCallback, failureCallback, "com.appirio.mobile.webservice", "getContent", restPath);
		console.log('In ContentDataPlugin.  Returned from Phonegap...');
	},
};


$("#student-home").live("pageinit", function(event) {
    // init Class Schedule data
	aauMobile.classSchedule.init();
	//aauMobile.classSchedule.loadStudentSchedule();
});

$("#student-home").live("pagebeforeshow", function(event) {
	aauMobile.classSchedule.loadStudentSchedule();
});




