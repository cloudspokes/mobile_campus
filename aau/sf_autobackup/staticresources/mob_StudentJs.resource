
var aauMobile = aauMobile || {

studentId: currentUserId,

clickEvent: 'touchstart',

nativeAdapter: null,

/* PARTH: Get method for local storage*/
getLocalStorage: function(key){
	
	if (typeof(localStorage) != 'undefined' ) {
		
		var localData = localStorage.getItem(key) ;
		if(localData == null){
			return null;
		}else{
			var data = null;
			try{
			  data = JSON.parse(localData);
			}
			catch(err){ 
			  data = null;
			  console.log('Error while parsing data for ' + key);
		  	}
		  	return data;
		}
	}
},
/* PARTH: set method for local storage*/
setLocalStorage: function(key,data){
	if (typeof(localStorage) != 'undefined' ) {
		localStorage.setItem(key,data) ;
	}
}, 
 /* PARTH: This method clears the browser local storage */
clearLocalStorage: function(key){
	if (typeof(localStorage) != 'undefined' ) {
		localStorage.setItem(key,null) ;
	}
},

classSchedule: {
	data: [],
	//data: {},
    dataKey : 'StudentData', /* PARTH: Key to identify this data in localStorage*/
	
	/* PARTH: This method clears the browser local storage  */   
    clearLocalStorage: function(){
		aauMobile.clearLocalStorage(aauMobile.classSchedule.dataKey);
	},
	
	isRefreshEvent: false,
	
	onComplete: function(){},
	
	init: function(callback){
	    aauMobile.classSchedule.onComplete = callback; 
		aauMobile.classSchedule.data = [];
		/* PARTH:  
		 * Get Data from local storage
		 * If local Data exists, use it else get fresh data */
		var localData = aauMobile.getLocalStorage(aauMobile.classSchedule.dataKey);
	
		if(aauMobile.classSchedule.isRefreshEvent || localData == null || localData.length < 1 || localData.startDate == null){
			//Load Fresh Data
			console.log('classSchedule: NO LOCAL DATA FOUND - FETCHING FRESH DATA');
			var restPath = "/classSchedule?id=" + aauMobile.studentId;
			
			RestDataPlugin.getData(aauMobile.classSchedule.processFreshData, aauMobile.classSchedule.initFailure, restPath, true, "GET", "json");
		}
		else{
			//Load existing data
			console.log('FOUND LOCAL DATA FOUND - LOADING EXISTING DATA');
			aauMobile.classSchedule.buildSchedule(localData);
			//aauMobile.classSchedule.onComplete();
			
		}
		
	},
	/* PARTH: This method saves the fresh results to database and then builds the DOM */
	processFreshData : function(result){
		console.log('full Feed : '+ JSON.stringify(result));
		aauMobile.setLocalStorage(aauMobile.classSchedule.dataKey,JSON.stringify(result));
		aauMobile.classSchedule.isRefreshEvent = false;
		aauMobile.classSchedule.buildSchedule(result);
		//aauMobile.classSchedule.onComplete();
		
	}, 
	
	buildSchedule: function(result){
		
		//alert("ClassSchedule Result: "+ JSON.stringify(result));
		aauMobile.classSchedule.data = result;
		var classData = {
			enrollments:result.mobStudentsEnrolled,
			classMeetings:result.classMeetings,
			startDate:result.startDate,
			lastDate:result.lastDate
		}
		//console.log('full ClassMeetings : '+JSON.stringify(classData.classMeetings));
		//alert(classData.startDate);

		var stDate =new Date(classData.startDate.replace(/-/g,'/'));
		var enDate =new Date(classData.lastDate.replace(/-/g,'/'));
		
		var blockTemplate = $("#student-schedule-each-template");
		//var blockDivider = $("#student-scheduleDivider-template");
		var classContainer = $("#ulId").empty();
		
		var onlineBlockTemplate = $("#student-onLineschedule-each-template");
		var onlineClassContainer = $("#onlineulId").empty();
		
		var listItems = [];
		var onlineListItems = [];
		
		/***************************************************************************
		* Prepare Online Class List.. Should not depend on Class Meeting attachments   
		*/
		var isDivider = true;
		var index =0;	
		$.each(classData.enrollments, function(index, enrollment) {
		   if(enrollment.onlineClass == 'Yes'){
			   onlineListItems.push({
								className:enrollment.className,
								courseTitle:enrollment.courseTitle,
								classSectionId:enrollment.classSectionId,
								isDivider:isDivider
				});
			 if(isDivider)	
			  isDivider = false;	
			}
			
			
		});
		
		//onlineClassContainer.empty();
		if(onlineListItems[0] == null){
			$('#student-schedule-none-found').tmpl({noneFound:'none-found'}).appendTo(classContainer);
		}else{
			
			$(onlineBlockTemplate).tmpl(onlineListItems).appendTo(onlineClassContainer);
			 
			
		}

		if(onlineClassContainer.hasClass('ui-listview')){
			onlineClassContainer.listview('refresh'); 
		}  
		//onlineClassContainer.css("margin","0px");
		/***************************************************************************/
		
		
		classData.classes = [];
		$.each(classData.classMeetings, function(index, classMeeting){
		   // console.log(':: classMeeting ::'+JSON.stringify(classMeeting));
		    classData.classes.push(classMeeting);
		});
		classData.classes.sort(function(a,b){
			return aauMobile.scheduleSort(a.startTime, b.startTime);
		});
		//console.time('scheduleAppend');
		//alert('woot');
		
		for(var dayCount = 0; stDate < enDate && dayCount < 7; stDate.setDate(stDate.getDate() + 1)){
					var hasClassMeetings = false;
			$.each(classData.classes, function(index, classMeeting) {
				//console.log(JSON.stringify(classMeeting));

				var meetingSTDate = new Date(classMeeting.startDate.replace(/-/g,'/'));
				var meetingENDate = new Date(classMeeting.endDate.replace(/-/g,'/'));
				//console.log('looping through class meeting records.:: meetingSTDate::'+meetingSTDate+' ::meetingENDate::'+meetingENDate);

				if(stDate >= meetingSTDate && stDate<=meetingENDate){
					//console.log('meeting fits timeframe.');

					if((stDate.getDay()== 0 && classMeeting.isSunday) || 
						(stDate.getDay()== 1 && classMeeting.isMonday) || 
						(stDate.getDay()== 2 && classMeeting.isTuesday) || 
						(stDate.getDay()== 3 && classMeeting.isWednesday) || 
						(stDate.getDay()== 4 && classMeeting.isThursday) || 
						(stDate.getDay()== 5 && classMeeting.isFriday) || 
						(stDate.getDay()== 6 && classMeeting.isSaturday)){
						
						if(!hasClassMeetings){
							var localeDate = appirioUtils.formatDate(stDate);
							//var localeDate = stDate.toLocaleDateString();
							//localeDate = localeDate.substring(0,localeDate.length-6);

							listItems.push({isDivider: true, MeetingDayAndDay: localeDate});
							//var dBlock = blockDivider.tmpl({MeetingDayAndDay:localeDate});
							//dBlock.appendTo(detailContent);
							hasClassMeetings = true;
						}
						
						//console.log('creating schedule record');

						var className = '';
						if(classData.enrollments[classMeeting.classSection]){
							className = classData.enrollments[classMeeting.classSection].className;
						}
						
						var mLocation = classMeeting.location;
						var topicName = classMeeting.specialTopic;
						var startTime =  classMeeting.startTime;
						var endTime = classMeeting.endTime;
						var mId = classMeeting.classMeetingId;
						listItems.push({
						        isDivider: false,
							topic:topicName,
							className:className,
							meetingLocation:mLocation,
							stTime:startTime,
							edTime:endTime,
							meetingId:mId
						});
						//var block = blockTemplate.tmpl({
						//	topic:topicName,
						//	className:className,
						//	meetingLocation:mLocation,
						//	stTime:startTime,
						//	edTime:endTime,
						//	meetingId:mId
						//});

						//block.appendTo(detailContent);               	               
					} 
				}
			});
			if(hasClassMeetings){
				dayCount++;
			}
		}
		
		//console.log(listItems);
		//alert('Total List Items: ' + listItems.length); 
		classContainer.empty();
		if(listItems[0] == null && onlineListItems[0] == null){
			
			$('#student-schedule-none-found').tmpl({noneFound:'none-found'}).appendTo(classContainer); 
			
		}else if(listItems[0] != null){
			//alert('appending classes');
			//classContainer.empty();
			$(blockTemplate).tmpl(listItems).appendTo(classContainer);
			
		}
		
		//aauMobile.classSchedule.onComplete();
		if(classContainer.hasClass('ui-listview')){
			classContainer.listview('refresh');
		}  
		
		//console.timeEnd('scheduleAppend');
		if($($.mobile.activePage).attr('id') == 'student-home'){
			//Hide loading message.
			//$('.ui-loader').css('display', 'none');
			//$.mobile.hidePageLoadingMsg();
			//Resize the container so the device can scroll.
			if(aauMobile.isAndroid()){
				$(window).trigger('orientationchange');
			}
		}
		onlineClassContainer.css("margin","0px");
		classContainer.css("margin","0px");
		
		/*PARTH: Hide Spinner*/
		//hideProgress();
		//dataInitComplete('student-home');
		
		aauMobile.classSchedule.onComplete();
		
	},

	initFailure: function(result) {
		console.log("failureCallback Result: "+ JSON.stringify(result));
		/*PARTH: Hide Spinner*/
		//hideProgress();
		//dataInitComplete('student-home');
		aauMobile.classSchedule.isRefreshEvent = false;
		aauMobile.classSchedule.onComplete();
		//alert(result);
		if(result==""){ return;}
		if(result.indexOf("Unable to resolve host")>=0){
			//commented this because it might have been erroring on initial load
			alert("Due to slow or no connection, this action has been canceled. Please try again later.");
		}else{
			alert('We have encountered an error.  Please try again later.');
		}
	},
    
    showOnlineClassDetails: function(classSectionId) {
   		
        onlineClassDetail = aauMobile.classSchedule.data.mobStudentsEnrolled[classSectionId];
		//console.log('onlineClassDetail: '+JSON.stringify(onlineClassDetail));
     	
		//Change the Page to Show the details of Selected Class meeting
		$.mobile.changePage("#student-detail", {transition: 'slide', changeHash: true});
		
		//Make empty to the components to add selected contents 
		$('#ulDlId').empty();
		$('#classNameDv').empty();
		$('#classDescrDv').empty();

		$("<span class='section-details'>"+onlineClassDetail.classSubject+"&nbsp;"+onlineClassDetail.classCatalogNbr+"."+onlineClassDetail.classSection+"</span>").appendTo('#classNameDv');
		$("<h2>"+onlineClassDetail.className+"</h2>").appendTo('#classNameDv');
		$("<h3>"+onlineClassDetail.classDescription+"</h3>").appendTo('#classDescrDv');
        
		var blockTemplate = $("#student-classDetail-template");
		var detailContent = $("#ulDlId");
        
        meetTime = '--';
        instructor = '';
        mLocation = 'Online Class';
        
		if(instructor == '' ||instructor ==null ) instructor = '--'; 

		var detailBlock = blockTemplate.tmpl({
			meetingTime:meetTime,
			meetingInstruction:instructor,
			mLocation:mLocation
		});

		detailBlock.appendTo(detailContent);  
		if($('#ulDlId').hasClass('ui-listview')){
			$("#ulDlId").listview('refresh');
		}
		//Resize the container so the device can scroll.
		if(aauMobile.isAndroid() && $($.mobile.activePage).attr('id') == 'student-detail'){
			$(window).trigger('orientationchange');
		}
		$("#ulDlId").css("margin","0px");
    },
    showClassDetails: function(meetingId) {
        //get Class detail and Enrollment Details for the selected Class Meeting
        classMeetingDetail = aauMobile.classSchedule.data.classMeetings[meetingId];
		//console.log('ClassMeetingDetail: '+JSON.stringify(classMeetingDetail));
        enrolledClass = aauMobile.classSchedule.data.mobStudentsEnrolled[classMeetingDetail.classSection];
        
		var blockTemplate = $("#student-classDetail-template");
		var detailContent = $("#ulDlId");
     
		//Change the Page to Show the details of Selected Class meeting
		$.mobile.changePage("#student-detail", {transition: 'slide', changeHash: true});
		//Make empty to the components to add selected contents 
		$('#ulDlId').empty();
		$('#classNameDv').empty();
		$('#classDescrDv').empty();

		$("<span class='section-details'>"+enrolledClass.classSubject+"&nbsp;"+enrolledClass.classCatalogNbr+"."+enrolledClass.classSection+"</span>").appendTo('#classNameDv');
		$("<h2>"+enrolledClass.className+"</h2>").appendTo('#classNameDv');
		$("<h3>"+enrolledClass.classDescription+"</h3>").appendTo('#classDescrDv');
        
		   
        meetTime = classMeetingDetail.startTime+' to '+classMeetingDetail.endTime;
        //topic =  classMeetingDetail.specialTopic;
        instructor = classMeetingDetail.instructorName;
        mLocation = classMeetingDetail.location;
        
		if(instructor == '' ||instructor ==null ) instructor = '--'; 
		//if(topic == '' || topic ==null)	topic = 'Topic';  

		var detailBlock = blockTemplate.tmpl({
			meetingTime:meetTime,
			//meetingTopic:topic ,
			meetingInstruction:instructor,
			mLocation:mLocation
		});

		detailBlock.appendTo(detailContent);  
		
		if($('#ulDlId').hasClass('ui-listview')){
			$("#ulDlId").listview('refresh');
		}
		
		//Resize the container so the device can scroll.
		if(aauMobile.isAndroid() && $($.mobile.activePage).attr('id') == 'student-detail'){
			$(window).trigger('orientationchange');
		}
		$("#ulDlId").css("margin","0px");
    }
},

/******************** CLASS HISTORY START *************************/
classHistory: {
	data: [],
	//data: {},
    dataKey : 'classHistoryData', /* PARTH: Key to identify this data in localStorage*/
	
	/* PARTH: This method clears the browser local storage  */   
    clearLocalStorage: function(){
		aauMobile.clearLocalStorage(aauMobile.classHistory.dataKey);
	},
	
	isRefreshEvent: false,
	
	onComplete: function(){},
	
	init: function(callback){
	    aauMobile.classHistory.onComplete = callback; 
		aauMobile.classHistory.data = [];
		/* PARTH:  
		 * Get Data from local storage
		 * If local Data exists, use it else get fresh data */
		var localData = aauMobile.getLocalStorage(aauMobile.classHistory.dataKey);
	
		if(aauMobile.classHistory.isRefreshEvent || localData == null || localData.length < 1 || localData.startDate == null){
			//Load Fresh Data
			console.log('classHistory: NO LOCAL DATA FOUND - FETCHING FRESH DATA');
			var restPath = "/classHistory";
				RestDataPlugin.getData(aauMobile.classHistory.processFreshData, aauMobile.classHistory.initFailure, restPath, true, "GET", "json");
		}
		else{
			//Load existing data
			console.log('FOUND LOCAL DATA FOUND - LOADING EXISTING DATA');
			aauMobile.classHistory.buildHistory(localData);
			//aauMobile.classHistory.onComplete();
			
		}
		
	},
	/* PARTH: This method saves the fresh results to database and then builds the DOM */
	processFreshData : function(result){
		//console.log('First History Record: '+ JSON.stringify(result));
		aauMobile.setLocalStorage(aauMobile.classHistory.dataKey,JSON.stringify(result));
		aauMobile.classHistory.isRefreshEvent = false;
		aauMobile.classHistory.buildHistory(result);
		//aauMobile.classHistory.onComplete();
		
	}, 
	
	buildHistory: function(result){
		aauMobile.classHistory.data = result;

		var classContainer = $("#history-list").empty();
		//var blockTemplate = $("#student-onLineschedule-each-template");
		var blockTemplate = $("#class-history-each-template");
		var listItems = [];
		var preSortList = [];
		var classes = [];
        console.log(':: buildHistory========================================::');
        var isDiv = false;
        var termName ='';
		
		$.each(result.classMeetings, function(index, classMeeting){
			preSortList.push({
				specialTopic: classMeeting.specialTopic,
				classMeeting: classMeeting.classMeetingId,
				classSection: classMeeting.classSection,
				termEndDate: classMeeting.termEndDate,
				meetingId:classMeeting.classMeetingId
			});

			console.log('Term End Date: '+classMeeting.termEndDate);
		});

		preSortList.sort(function(a,b){
			return aauMobile.dateSort(a.termEndDate, b.termEndDate);
		});

		$.each(preSortList, function(index, classMeeting){
		   console.log('Term End Date: '+classMeeting.termEndDate);
		   console.log(':: classMeeting ::'+JSON.stringify(classMeeting));
		   //classes.push(classMeeting);
			var cls = {
				specialTopic: classMeeting.specialTopic,
				classMeeting: classMeeting.classMeeting,
				className: '',
				classSectionId: '',
				termName: '',
				meetingId: classMeeting.classMeeting
			}
             
			if(result.mobStudentsEnrolled[classMeeting.classSection]){
				console.log('Related Enrollment: '+JSON.stringify(result.mobStudentsEnrolled[classMeeting.classSection]));
				cls.className = result.mobStudentsEnrolled[classMeeting.classSection].className;
				cls.classSectionId = result.mobStudentsEnrolled[classMeeting.classSection].classSectionId;
				cls.termName = result.mobStudentsEnrolled[classMeeting.classSection].termName;
			}
			
			//determine if subheader for Term should be shown
			if(termName != cls.termName){
			   isDiv = true;
			   termName = cls.termName;
			}     

           	var mId = classMeeting.classMeetingId;
			listItems.push({
				isDivider: isDiv,
				//topic: cls.specialTopic,
				className: cls.className,
				classSectionId: cls.classSectionId,
				termName: cls.termName,
				meetingId:cls.meetingId
			});
			isDiv = false;
		});

		if(listItems[0] == null){
			$('#student-schedule-none-found').tmpl({noneFound:'none-found'}).appendTo(classContainer); 
		}else{
			if($(blockTemplate) != null){
				$(blockTemplate).tmpl(listItems).appendTo(classContainer);
			}
			
		}
		
		if(classContainer.hasClass('ui-listview')){
			classContainer.listview('refresh');
		}  
		
		//console.timeEnd('scheduleAppend');
		if($($.mobile.activePage).attr('id') == 'class-history'){
			//Resize the container so the device can scroll.
			if(aauMobile.isAndroid()){
				$(window).trigger('orientationchange');
			}
		}
		classContainer.css("margin","0px");
		
		aauMobile.classHistory.onComplete();						
		
		/*try{
		}catch(e){
			appirioUtils.handleError(e);
		}*/

	},

	initFailure: function(result) {
		console.log("failureCallback Result: "+ JSON.stringify(result));
		aauMobile.classHistory.isRefreshEvent = false;
		aauMobile.classHistory.onComplete();

		if(result==""){ return;}
		if(result.indexOf("Unable to resolve host")>=0){
			alert("Due to slow or no connection, this action has been canceled. Please try again later.");
		}else{
			alert('We have encountered an error.  Please try again later.');
		}
	},
    showClassDetails: function(meetingId) {
        //get Class detail and Enrollment Details for the selected Class Meeting
        console.log('meetingId::: '+meetingId);
        console.log('============================================================================================================');
        console.log('::Class Meeting :::'+JSON.stringify(aauMobile.classHistory.data.classMeetings));
        console.log('============================================================================================================');
        classMeetingDetail = aauMobile.classHistory.data.classMeetings[meetingId];
		console.log('ClassMeetingDetail: '+JSON.stringify(classMeetingDetail));
        enrolledClass = aauMobile.classHistory.data.mobStudentsEnrolled[classMeetingDetail.classSection];
		console.log('EnrollmentDetail: '+JSON.stringify(enrolledClass));
        
		
		//Change the Page to Show the details of Selected Class meeting
		$.mobile.changePage("#history-detail", {transition: 'slide', changeHash: true});
		//Make empty to the components to add selected contents 

		var nameDiv = $('#history-name').empty();
		var descDiv = $('#history-desc').empty();
		var detailContent = $('#history-detail-list').empty();
		var blockTemplate = $("#student-classDetail-template");
		var hasGrade = false;

		$("<span class='section-details'>"+enrolledClass.classSubject+"&nbsp;"+enrolledClass.classCatalogNbr+"."+enrolledClass.classSection+"</span>").appendTo(nameDiv);
		$("<h2>"+enrolledClass.className+"</h2>").appendTo(nameDiv);
		$("<h3>"+enrolledClass.classDescription+"</h3>").appendTo(descDiv);
        
		//var detailContent = $("#ulDlId");
        
        meetTime = classMeetingDetail.startTime+' to '+classMeetingDetail.endTime;
        //topic =  classMeetingDetail.specialTopic;
        instructor = classMeetingDetail.instructorName;
        mLocation = classMeetingDetail.location;
        
		if(instructor == '' || instructor == null ) instructor = '--'; 
		//if(topic == '' || topic ==null)	topic = 'Topic';  

		if(enrolledClass.grade != '' && enrolledClass.grade != null) hasGrade = true;

		var detailBlock = blockTemplate.tmpl({
			meetingTime: meetTime,
			//meetingTopic:topic ,
			meetingInstruction: instructor,
			mLocation: mLocation,
			hasGrade: hasGrade,
			grade: enrolledClass.grade
		});

		detailBlock.appendTo(detailContent);  
		if(detailContent.hasClass('ui-listview')){
			detailContent.listview('refresh');
		}
		//Resize the container so the device can scroll.
		if(aauMobile.isAndroid() && $($.mobile.activePage).attr('id') == 'student-detail'){
			$(window).trigger('orientationchange');
		}
		detailContent.css("margin","0px");
    }
},    

/******************** CLASS HISTORY END ***************************/
campusEvents: {
	feedData: [],
	
	feedCount: 0,
	/*PARTH: Define Keys for local data*/
	///recreationDataKey: 'RecreationEventsData',
	///academicDataKey: 'AcademicEventsData',
	///studentActivitiesDataKey: 'StudenActivitiesEventsData',
	eventDataKey: 'CampusEventsData',
	isRefreshEvent : false,

	/* PARTH: This method clears the localstorage*/
	clearLocalStorage: function(){
		///aauMobile.clearLocalStorage(aauMobile.campusEvents.recreationDataKey);
		///aauMobile.clearLocalStorage(aauMobile.campusEvents.academicDataKey);
		///aauMobile.clearLocalStorage(aauMobile.campusEvents.studentActivitiesDataKey);
		aauMobile.clearLocalStorage(aauMobile.campusEvents.eventDataKey);
	},
	
	onComplete: function(){},
	init: function(callback) {
	//Get Data from local storage
		///aauMobile.campusEvents.feedCount = 0;
		aauMobile.campusEvents.feedData = [];
		var rssUrl ='';
		
		aauMobile.campusEvents.onComplete = callback;
		
		/* PARTH: Fetch Data from LocalStorage
		 * IF Data exists in Local storage, use it.
		 * Else Fetch Fresh data */
		
		var eventData = aauMobile.getLocalStorage(aauMobile.campusEvents.eventDataKey);
		if(aauMobile.campusEvents.isRefreshEvent || eventData == null || eventData.length < 1){ // || eventData[0].title == null){
			console.log('SF Events : NO LOCAL EVENT DATA - LOADING FRESH DATA');
			rssUrl = '/MobileEvents';
			RestDataPlugin.getData(aauMobile.campusEvents.processFreshData, aauMobile.campusEvents.initFailure, rssUrl, true, "GET", "json");
		}else{
			aauMobile.campusEvents.buildFeed(eventData);
		}

		/* PARTH : Fetch Student Activities Data 
		var stuActData = aauMobile.getLocalStorage(aauMobile.campusEvents.studentActivitiesDataKey);
		//alert(stuActData.channel.title);
		if(stuActData == null || stuActData.length < 1 || stuActData.channel.title == null){
			console.log('campusEvents : NO LOCAL STUDENT ACT DATA - LOADING FRESH DATA');
			rssUrl = 'https://spreadsheets.google.com/feeds/list/0AvROhDzo3UybdDQ5aEFzVDZqSzFDdVVENTRxTXdXcHc/od6/public/basic?alt=rss';
			RestDataPlugin.getData(aauMobile.campusEvents.processFreshStudentActData, aauMobile.campusEvents.initFailure, rssUrl, false, "GET", "xml");
		}else{
			//Load existing data
			console.log('campusEvents : FOUND LOCAL STUDENT ACT DATA - LOADING EXISTING DATA');
			aauMobile.campusEvents.buildFeed(stuActData);
			
			
		}
		/* PARTH : Fetch Academic Activities Data 
		var academicData = aauMobile.getLocalStorage(aauMobile.campusEvents.academicDataKey);
		if(academicData == null || academicData.length < 1 || academicData.channel.title == null){
			console.log('campusEvents : NO LOCAL ACADEMIC ACT DATA - LOADING FRESH DATA');
			rssUrl = 'https://spreadsheets.google.com/feeds/list/0AvROhDzo3UybdHVSWFVwczdOekJlWjNVRmtpLU5scWc/od6/public/basic?alt=rss';
			RestDataPlugin.getData(aauMobile.campusEvents.processFreshAcademicData, aauMobile.campusEvents.initFailure, rssUrl, false, "GET", "xml");
		}else{
			//Load existing data
			console.log('campusEvents : FOUND LOCAL Academic Event DATA - LOADING EXISTING DATA');
			aauMobile.campusEvents.buildFeed(academicData);
		}	
		
		/* PARTH : Fetch Recreation Data 
		var recreationData = aauMobile.getLocalStorage(aauMobile.campusEvents.recreationDataKey);
		if(recreationData == null || recreationData.length < 1 || recreationData.channel.title == null){	
			console.log('campusEvents : NO LOCAL RECREATION DATA - LOADING FRESH DATA');
			rssUrl = 'https://spreadsheets.google.com/feeds/list/0AvROhDzo3UybdHF3Q3FiZnNibk1qV2xpRVFMTUM2NXc/od6/public/basic?alt=rss';
			RestDataPlugin.getData(aauMobile.campusEvents.processFreshRecreationData, aauMobile.campusEvents.initFailure, rssUrl, false, "GET", "xml");
		}
		else{
			//Load existing data
			console.log('campusEvents : FOUND LOCAL RECREATION  Event DATA - LOADING EXISTING DATA');
			aauMobile.campusEvents.buildFeed(recreationData);
			aauMobile.campusEvents.onComplete();
			
		}*/
		

	},
	
	processFreshData: function(result){
		//result = $.xml2json(result);
		aauMobile.setLocalStorage(aauMobile.campusEvents.eventDataKey,JSON.stringify(result));
		aauMobile.campusEvents.isRefreshEvent = false;
		aauMobile.campusEvents.buildFeed(result);
		
	},
	/* PARTH: This method Saves Fresh Student Activities results to local storage
	 * and Builds Feeds 
	processFreshStudentActData: function(result){
		result = $.xml2json(result);
		aauMobile.setLocalStorage(aauMobile.campusEvents.studentActivitiesDataKey,JSON.stringify(result));
		aauMobile.campusEvents.buildFeed(result);
		
	},
	/* PARTH: This method Saves Fresh Academic activities results to local storage
	 * and Builds Feeds 
	processFreshAcademicData: function(result){
		result = $.xml2json(result);
		aauMobile.setLocalStorage(aauMobile.campusEvents.academicDataKey,JSON.stringify(result));
		aauMobile.campusEvents.buildFeed(result);
		
	},
	/* PARTH: This method Saves Fresh Recreation Activities results to local storage
	 * and Builds Feeds 
	processFreshRecreationData: function(result){
		result = $.xml2json(result);
		aauMobile.setLocalStorage(aauMobile.campusEvents.recreationDataKey,JSON.stringify(result));
		aauMobile.campusEvents.buildFeed(result);
		aauMobile.campusEvents.onComplete();
		
	},*/
	
		
	buildFeed: function(result) {

		/*console.log('Result:: '+result);
		console.log('Date '+$(result).find('eventdate').get(0));
		console.log('Date '+eval(result));
		console.log('Date '+result.toString());
		console.log('Date '+$(result).html());
		console.log('Date '+$(result).text());*/
		
		/*PARTH: COmmented this out
		 * this convertion happens in the Process fresh data methods */
		//result = $.xml2json(result);


		console.log('Event Feed Success! ');
		//console.log('Result: ' + JSON.stringify(result));
/*
		var currentDate = new Date();
		console.log('currentDate' + currentDate.toString());
		currentDate = new Date((currentDate.getMonth()+1)+'/'+currentDate.getDate()+'/'+currentDate.getFullYear());
		console.log('currentDate' + currentDate.toString());
*/
		console.log('WOOT | EventResult: '+JSON.stringify(result));

		$.each(result, function(index, item){
			//TODO: you may want to move where this is happening (before the conversion to JSON maybe...)
			//item = aauMobile.campusEvents.processItem(item);
			console.log('WOOT | EventItem: '+JSON.stringify(item));
			//item.origin = item.category;
			//item.eventdate = new Date(item.startdate); //.toDateString();
			//item.shortdate = (item.eventdate.getMonth()+1)+'/'+item.eventdate.getDate()+'/'+item.eventdate.getFullYear();
			//item.longdate = (item.shortdate+' '+item.eventdate.getHours()+':'+item.eventdate.getMinutes();

			//If the time isn't set by the user, make it empty string to display nicely  
			if(item.starttime == '12:00 AM' || item.starttime == null){ item.starttime = ''; }
			if(item.endtime == '12:00 AM' || item.endtime == null){ item.endtime = ''; }
			if(item.enddate == null){ item.enddate = ''; }
			if(item.startdate == null){ item.startdate = ''; }
			
			//format the datetime string to display to user on detail screen
			item.fulldatetime = item.startdate+' '+item.starttime;
			if(item.enddate != item.startdate){
				item.fulldatetime += ' - '+item.enddate+' '+item.endtime;
			}else{
				item.fulldatetime += ' - '+item.endtime;
			}

			//format category and subcategory to display in list and detail page nicely
			if(item.category != ''){
				item.fullcategory = item.category; 
				if(item.subcategory != ''){
					item.fullcategory += ' - ' + item.subcategory; 
				}
			}


			aauMobile.campusEvents.feedData.push(item);
/*
			//console.log('Description ::: '+item.description);
			if(item.description && item.description.split(",")!= null){
			
				var eventItem = item.description.split(",");
				item.raweventdate = new Date(eventItem[0].replace("eventdate:",""));
				//make sure its a real date entered into the field
				if (item.raweventdate.toString() == "NaN" || item.raweventdate.toLocaleString() == "Invalid Date") {
					console.log('Date Error in Feed: ' + item.description);
					item.raweventdate = null;
				} else {
					item.eventdate = item.raweventdate.toDateString();
					item.shortdate = (item.raweventdate.getMonth()+1)+'/'+item.raweventdate.getDate()+'/'+item.raweventdate.getFullYear();
				}
				item.eventdescription = '';
				
				for(count =1 ;count<eventItem.length-1;count++){
				   if(count ==1 ){
				      item.eventdescription = eventItem[count].replace("eventdescription:","");
				   }else{   
				      item.eventdescription += ','+ eventItem[count];
				   }   
				}
				 
				
			}
			//console.log('Campus Event Item: '+JSON.stringify(item));
            //We should also not show any records that are in the past
            if(item.raweventdate >= currentDate){ 
			  aauMobile.campusEvents.feedData.push(item);
			}
*/
		});
/*	
		aauMobile.campusEvents.feedData.sort(function(a,b){
			//return a.raweventdate.localeCompare(b.raweventdate);
			//return a.eventdate.localeCompare(b.raweventdate);
			//console.log('::: Event Date::'+ a.raweventdate);
			return a.raweventdate-b.raweventdate;
		});
*/
		
		//Increment the feed count
//		aauMobile.campusEvents.feedCount++;

		//If all feeds have returned or failed, display.
//		if(aauMobile.campusEvents.feedCount >2 ){
			if(aauMobile.campusEvents.feedData.length > 0){
				aauMobile.campusEvents.showFeed();
			} else{
				aauMobile.campusEvents.showEmptyFeed();
			}
//		}
		/*PARTH: Hide Spinner */
		//hideProgress();
		//dataInitComplete('campus-event-list');
		aauMobile.campusEvents.onComplete();


	},

	processItem: function(item){
		//TODO: put all the logic here
        //console.log('Process Item  >> '+JSON.stringify(item.description.split(",")));
		return item;
	},

	initFailure: function(result) {
		console.log('RSS Feed Failure. ' + result);
		aauMobile.campusEvents.isRefreshEvent = false;
		//Increment so we can still display what didn't fail.
		aauMobile.campusEvents.feedCount++;
		
		//If all feeds have returned or failed, display.
		if(aauMobile.campusEvents.feedCount >2 ){
			if(aauMobile.campusEvents.feedData.length > 0){
				aauMobile.campusEvents.showFeed();
			} else{
				aauMobile.campusEvents.showEmptyFeed();
			}
		}
		/* PARTH: Hide Spinner*/
		//hideProgress();
		//dataInitComplete('campus-event-list');
		aauMobile.campusEvents.onComplete();
		if(result==""){ return;}
		if(result.indexOf("Unable to resolve host")>=0){
			alert("Due to slow or no connection, this action has been canceled. Please try again later.");
		}else{
			alert('We have encountered an error.  Please try again later.');
		}
	},
	
	showEmptyFeed: function(){
		var feedContainer = $("#campus-event-ul");
		$(feedContainer).empty();
		$('#no-campus-events-template').tmpl().appendTo(feedContainer);
		//If jQuery has initialized it, refresh.
		if($(feedContainer).hasClass('ui-listview')){
			$(feedContainer).listview('refresh');
		}
		if($($.mobile.activePage).attr('id') == 'event-list'){
			//Hide loading message.
			//$.mobile.hidePageLoadingMsg();
			//$('.ui-loader').css('display', 'none');
			//Resize the container so the device can scroll.
			if(aauMobile.isAndroid()){
				$(window).trigger('orientationchange');
			}
		}
		$(feedContainer).css('margin','0px');
		/*PARTH: Hide Spinner */
		//hideProgress();
		//dataInitComplete('campus-event-list');
		aauMobile.campusEvents.onComplete();
	},
	
	showFeed: function(){
		var feedTemplate = $("#campus-events-template");
		var feedContainer = $("#campus-event-ul");
		
		$(feedContainer).empty();
		
		// PARTH: refactor code to first create json array and the run template
		var jsonList= [];
		var item  ;
		for(var index = 0 ; index < 20 && index < aauMobile.campusEvents.feedData.length; index++ ){
			item = aauMobile.campusEvents.feedData[index];
			jsonList.push({feedTitle: item.title, feedDate: item.startdate, feedOrigin: item.fullcategory, feedId: item.id});
		}
		
		feedTemplate.tmpl(jsonList).appendTo(feedContainer);
		
		//PARTH: commented previous code
		/*$.each(aauMobile.campusEvents.feedData, function(index, item){
			if(index < 20){
				feedTemplate.tmpl({feedTitle: item.title, feedDate: item.shortdate, feedOrigin: item.category, feedId: item.guid}).appendTo(feedContainer);			
			}else{
				return;
			}
		});*/
		
		//If jQuery has initialized it, refresh.
		if($(feedContainer).hasClass('ui-listview')){
			$(feedContainer).listview('refresh');
		}
		if($($.mobile.activePage).attr('id') == 'campus-event-list'){
			//Hide loading message.
			//$.mobile.hidePageLoadingMsg();
			//$('.ui-loader').css('display', 'none');
			//Resize the container so the device can scroll.
			if(aauMobile.isAndroid()){
				$(window).trigger('orientationchange');
			}
		}
		$(feedContainer).css('margin','0px');
		/*PARTH: Hide Spinner */
		//hideProgress();
		//dataInitComplete('campus-event-list');
		aauMobile.campusEvents.onComplete();
	},

	showFeedDetails: function(feedId) {
		//rssUrl = 'https://www.academyart.edu//news/school/making-a-difference-through-photography.html';
		//RestDataPlugin.getData(aauMobile.campusEvents.buildFeedDetail, aauMobile.campusEvents.initFailure, rssUrl, false, "GET", "text");

		//find Feed in the feedData
		
		var item  ;
		for(var index = 0 ; index < aauMobile.campusEvents.feedData.length; index++ ){
			item = aauMobile.campusEvents.feedData[index];
			if(item.id == feedId){
				//console.log('Opening Feed: ' + JSON.stringify(item));
				//create instance of template for campus Details
				var feedTemplate = $('#campus-detail-template');
				var feedContainer = $('#campus-detail-container').empty();

				feedTemplate.tmpl({feedTitle:item.title, feedOrigin:item.category, feedSuborigin:item.subcategory, feedEventDate:item.fulldatetime, feedEventLocation:item.locationstop+' '+item.location, feedDescription:item.description, feedLinkText:item.linktext, feedLink:item.link}).appendTo(feedContainer);
				break ;
			}
		
		}
		
		/* PARTH : commented previous code
		$.each(aauMobile.campusEvents.feedData, function(index, item){
			//alert('Show Details ' + index);
			if(item.guid == feedId){
				//console.log('Opening Feed: ' + JSON.stringify(item));
				//create instance of template for campus Details
				var feedTemplate = $('#campus-detail-template');
				var feedContainer = $('#campus-detail-container').empty();
				feedTemplate.tmpl({feedTitle: item.title, feedOrigin: item.category, feedEventDate:item.eventdate, feedDescription: item.eventdescription}).appendTo(feedContainer);
			}
		});
		*/
		//do page transition to detail screen
		$.mobile.changePage('#campus-event-detail', {transition: 'slide', changeHash: true});
	},

	//This method is obsolete
	buildFeedDetail: function(result) {
		
		var feedCtnr = $('#feed-detail-container');
		var feedArt = $('.news_article_col', result);
		$('a', feedArt).each(function(index, item){
			//item.href = 'https://www.academyart.edu'+item.href;
			item.href = 'https://www.academyart.edu' + $.mobile.path.parseUrl(item.href).pathname;
		});

		$(feedArt).appendTo(feedCtnr);
		return;

	}
},

//this is the real RSS Feed! TODO: change the names, so this loads under Campus News
campusFeed: {
	feedData: [],
	//feedData: 0,
	/* PARTH: Key to identify data in local storage*/
	dataKey : 'campusFeedData',
	/* PARTH: This method clears the local storage*/
	clearLocalStorage: function(){
		aauMobile.clearLocalStorage(aauMobile.campusFeed.dataKey);
		
	},
	isRefreshEvent : false,
	
	onComplete: function(){},
	init: function(callback) {
		aauMobile.campusFeed.onComplete = callback;
		aauMobile.campusFeed.feedData = [];
		
		/* PARTH: If local Data exists, use it 
		 * else get fresh data */
		var campusData = aauMobile.getLocalStorage(aauMobile.campusFeed.dataKey);
		
		if(aauMobile.campusFeed.isRefreshEvent || campusData == null || campusData.length < 1 || campusData.channel.title == null){
			console.log('campusFeed : NO LOCAL DATA - LOADING FRESH DATA');
			
			var rssUrl = 'https://www.academyart.edu/news.rss';
			RestDataPlugin.getData(aauMobile.campusFeed.processFreshData, aauMobile.campusFeed.initFailure, rssUrl, false, "GET", "xml");
		}else{
			//Load existing data
			console.log('campusFeed : FOUND LOCAL  DATA - LOADING EXISTING DATA');
			aauMobile.campusFeed.buildFeed(campusData);
			
		}
		
	},
	/* PARTH: this method saves fresh resukts to local storage 
	 * and then builds the Feed */
	processFreshData : function(result){
		result = $.xml2json(result);
		aauMobile.setLocalStorage(aauMobile.campusFeed.dataKey,JSON.stringify(result));
		aauMobile.campusFeed.isRefreshEvent = false;
		aauMobile.campusFeed.buildFeed(result);
		
	}, 
	
	initFailure: function(result){
		console.log('RSS Feed Failure. ' + result);
		var feedContainer = $("#feed-ul");
		aauMobile.campusFeed.isRefreshEvent = false;
		var campusData = aauMobile.getLocalStorage(aauMobile.campusFeed.dataKey);
		if(campusData == null || campusData.length < 1 || campusData.channel.title == null){
			$(feedContainer).empty();
			$('#no-rss-feed-template').tmpl().appendTo(feedContainer);
			//If jQuery has initialized it, refresh.
			if($(feedContainer).hasClass('ui-listview')){
				$(feedContainer).listview('refresh');
			}
		}else{
			aauMobile.campusFeed.buildFeed(campusData);
		}
		if($($.mobile.activePage).attr('id') == 'event-list'){
			//Hide loading message.
			//$.mobile.hidePageLoadingMsg();
			//$('.ui-loader').css('display', 'none');
			//Resize the container so the device can scroll.
			if(aauMobile.isAndroid()){
				$(window).trigger('orientationchange');
			}
		}
		$(feedContainer).css('margin','0px');
		/* PARTH: hide Spinner */
		//hideProgress();
		//dataInitComplete('feed-list');
		aauMobile.campusFeed.onComplete();
		if(result==""){ return;}
		if(result.indexOf("Unable to resolve host")>=0){
			alert("Due to slow or no connection, this action has been canceled. Please try again later.");
		}else{
			alert('We have encountered an error.  Please try again later.');
		}
	},
	buildFeed: function(result) {
		/* PARTH : Commented this as we do this conversion in the Process fresh data method */
		//result = $.xml2json(result);
		//aauMobile.campusFeed.feedData = result;

		console.log('RSS Feed Success! ' + result.channel.title);
		//console.log('Result: ' + JSON.stringify(result));
		
		var jsonList = [];
		
		$.each(result.channel.item, function(index, item){

			item.origin = result.channel.title;
			//console.log('Campus News Item: '+JSON.stringify(item));

			var raweventdate = new Date(item.pubDate);
			item.eventdate = raweventdate.toLocaleDateString();

			aauMobile.campusFeed.feedData.push(item);
			//PARTH: CREATE JSON LIST
			if(index < 20) {
				jsonList.push({feedTitle: item.title, feedDate: item.eventdate, feedId: item.guid});
			}
		});
		
		/*aauMobile.campusFeed.feedData.sort(function(a,b){
			return a.title.localeCompare(b.title);
		});*/
		
		var feedTemplate = $("#rss-feed-template");
		var feedContainer = $("#feed-ul");
		$(feedContainer).empty();
		if(aauMobile.campusFeed.feedData[0].title != null){
			//PARTH: refactor code to build template from list
			feedTemplate.tmpl(jsonList).appendTo(feedContainer);
			
			//PARTH: Commented Previous code
			/*$.each(aauMobile.campusFeed.feedData, function(index, item){
				//console.log('Feed Item: '+JSON.stringify(item));
				if(index < 20){
					feedTemplate.tmpl({feedTitle: item.title, feedDate: item.eventdate, feedId: item.guid}).appendTo(feedContainer);			
				}else{
					return;
				}
			});*/
		}else{
			$("#no-rss-feed-template").tmpl().appendTo(feedContainer);
		}
		if($(feedContainer).hasClass('ui-listview')){
			$(feedContainer).listview('refresh');
		}
		if($($.mobile.activePage).attr('id') == 'feed-list'){
			//Hide loading message.
			//$.mobile.hidePageLoadingMsg();
			//$('.ui-loader').css('display', 'none');
			//Resize the container so the device can scroll.
			if(aauMobile.isAndroid()){
				$(window).trigger('orientationchange');
			}
		}
	  $(feedContainer).css('margin', '0px');
	  /* PARTH : Hide Spinner */
	  //hideProgress();
	  //dataInitComplete('feed-list');
	  aauMobile.campusFeed.onComplete();
	},

	showFeedDetails: function(feedId) {
		var feedContainer = $('#feed-detail-container').empty();
		
		//find Feed in the feedData
		var item ;
		for(var index=0; index<aauMobile.campusFeed.feedData.length; index++){
			item = aauMobile.campusFeed.feedData[index];
			if(item.guid == feedId){
				console.log('Opening Feed: ' + JSON.stringify(item));
				//create instance of template for feed Details
				var feedTemplate = $('#feed-detail-template');
				
				feedTemplate.tmpl({feedTitle: item.title, feedOrigin: item.origin, feedDate: item.eventdate, feedDescription: item.description, linkUrl: item.link}).appendTo(feedContainer);
				break;
			}
			
		}
		//PARTH: commented prev code
		/*$.each(aauMobile.campusFeed.feedData, function(index, item){
			if(item.guid == feedId){
				console.log('Opening Feed: ' + JSON.stringify(item));
				//create instance of template for feed Details
				var feedTemplate = $('#feed-detail-template');
				
				feedTemplate.tmpl({feedTitle: item.title, feedOrigin: item.origin, feedDate: item.eventdate, feedDescription: item.description, linkUrl: item.link}).appendTo(feedContainer);
			}
		});
		*/
		if($(feedContainer).hasClass('ui-listview')){
			$(feedContainer).listview('refresh');
		}
		//do page transition to detail screen
		$.mobile.changePage('#feed-detail', {transition: 'slide', changeHash: true});
	}

},

rssEvent: {
	feedData: [],
	/* PARTH: key for local storage */
	dataKey : 'rssEventData',
	/* PARTH: This method clears data in the local storage */
	clearLocalStorage: function(){
		aauMobile.clearLocalStorage(aauMobile.rssEvent.dataKey);
		
	},
	isRefreshEvent : false,
	onComplete: function(){},
	init: function(callback) {
		aauMobile.rssEvent.feedData = [];
	    aauMobile.rssEvent.onComplete = callback; 
		
		/* PARTH: If local Data exists, use it 
		 * else get fresh data  */
		var eventData = aauMobile.getLocalStorage(aauMobile.rssEvent.dataKey);
		
		if(aauMobile.rssEvent.isRefreshEvent || eventData == null || eventData.length < 1 || eventData.channel.item[0].title == null){
			console.log('rssEvent : NO LOCAL DATA - LOADING FRESH DATA');
			var rssUrl = 'http://www.artuathletics.com/services/calendar.ashx/calendar.rss';
			RestDataPlugin.getData(aauMobile.rssEvent.processFreshData, aauMobile.rssEvent.initFailure, rssUrl, false, "GET", "xml");
		}else{
			//Load existing data
			console.log('rssEvent : FOUND LOCAL  DATA - LOADING EXISTING DATA');
			aauMobile.rssEvent.buildEvents(eventData);
			
		}

	},
	
	/* PARTH: this methods saves fresh results to the local storage 
	 * and  builds the Events feed */
	processFreshData : function(result){
		result = $.xml2json(result);
		aauMobile.setLocalStorage(aauMobile.rssEvent.dataKey,JSON.stringify(result));
		aauMobile.rssEvent.isRefreshEvent = false;
		aauMobile.rssEvent.buildEvents(result);
		
	}, 
	

	buildEvents: function(result) {
		/* PARTH : Commented out this method as this conversion is done the process fresh data method */
		//result = $.xml2json(result);
		//console.log('RSS Feed Success! ' + result.channel.title);
		
		result.channel.item.sort(function(a,b){
			//return a.title.localeCompare(b.title);
			return a.localstartdate.localeCompare(b.localstartdate);
		});
		
		var feedTemplate = $("#event-template");
		var feedContainer = $("#event-ul");
		var jsonList = [];
		$(feedContainer).empty();
		if(result.channel.item[0].title != null){
				var itemCount = 0;
				var currDate = new Date();
				currDate.setHours(0);
				currDate.setMinutes(0);
				currDate.setSeconds(0);

			$.each(result.channel.item, function(index, item){
				//console.log('Event Item: ' + JSON.stringify(item));
				//stDate is in format '2012-10-20T19:00:00.0000000'
				var stDate = new Date(item.localstartdate.split('T')[0].replace(/-/g,'/'));
				//var stDate2 = new Date(item.startdate.replace(/-/g,'/'));

				//alert(JSON.stringify(item.localstartdate));
				//alert(stDate+' : '+currDate);

				if(itemCount < 20 && stDate > currDate ){
					//feedTemplate.tmpl({eventTitle: item.title, eventOrigin: result.channel.title}).appendTo(feedContainer);	
					jsonList.push({eventTitle: item.title, eventOrigin: result.channel.title});		
					itemCount++;
				}else if(itemCount >= 20){
					return false;
				}
	
			});
			feedTemplate.tmpl(jsonList).appendTo(feedContainer);
		} else{
			$("#no-event-template").tmpl().appendTo(feedContainer);
		}
		
		//If jQuery has initialized it, refresh.
		if($(feedContainer).hasClass('ui-listview')){
			$(feedContainer).listview('refresh');
		}
		if($($.mobile.activePage).attr('id') == 'event-list'){
			//Hide loading message.
			//$.mobile.hidePageLoadingMsg();
			//$('.ui-loader').css('display', 'none');
			//Resize the container so the device can scroll.
			if(aauMobile.isAndroid()){
				$(window).trigger('orientationchange');
			}
		}
		$(feedContainer).css('margin','0px');
		/* PARTH : hide spinner */
		//hideProgress();
		//dataInitComplete('event-list');
		aauMobile.rssEvent.onComplete();
	},

	initFailure: function(result) {
		console.log('RSS Feed Failure. ' + result);
		aauMobile.rssEvent.isRefreshEvent = false;
		var eventContainer = $("#event-ul");
		var eventData = aauMobile.getLocalStorage(aauMobile.rssEvent.dataKey);
		
		if( eventData == null || eventData.length < 1 || eventData.channel.item[0].title == null){
			$(eventContainer).empty();
			$('#no-event-template').tmpl().appendTo(eventContainer);
			//If jQuery has initialized it, refresh.
			if($(eventContainer).hasClass('ui-listview')){
				$(eventContainer).listview('refresh');
			}
		}else{
			
			aauMobile.rssEvent.buildEvents(eventData);
		}
		
		if($($.mobile.activePage).attr('id') == 'event-list'){
			//Hide loading message.
			//$.mobile.hidePageLoadingMsg();
			//$('.ui-loader').css('display', 'none');
			//Resize the container so the device can scroll.
			if(aauMobile.isAndroid()){
				$(window).trigger('orientationchange');
			}
		}
		$(eventContainer).css('margin','0px');
		/* PARTH: hide spinner*/
		//hideProgress();
		//dataInitComplete('event-list');
		aauMobile.rssEvent.onComplete();
		if(result==""){ return;}
		if(result.indexOf("Unable to resolve host")>=0){
			alert("Due to slow or no connection, this action has been canceled. Please try again later.");
		}else{
			alert('We have encountered an error.  Please try again later.');
		}
	}
},

externalLinks: {
	linkData: [],
	/* PARTH: key for local storage */
	dataKey: 'externalLinksData',
	/* PARTH: clears data from local storage */
	clearLocalStorage: function(){
		aauMobile.clearLocalStorage(aauMobile.externalLinks.dataKey);
		
	},
	isRefreshEvent : false,
	onComplete: function(){},
	init: function(callback){
		aauMobile.externalLinks.onComplete = callback;
		aauMobile.externalLinks.linkData = [];
		/* PARTH: If local Data exists, use it else 
		 * get fresh data */
		var linksData = aauMobile.getLocalStorage(aauMobile.externalLinks.dataKey);
		
		if(aauMobile.externalLinks.isRefreshEvent || linksData == null || linksData.length < 1 || linksData[0].linkName == null){
			console.log('externalLinks : NO LOCAL DATA - LOADING FRESH DATA');
			//make REST call to RestDataPlugin.getData(); 
			var restPath = "/ExternalLinks";
			RestDataPlugin.getData(aauMobile.externalLinks.processFreshData, aauMobile.externalLinks.initFailure, restPath, true, "GET", "json");
		}else{
			//Load existing data
			console.log('externalLinks : FOUND LOCAL  DATA - LOADING EXISTING DATA');
			aauMobile.externalLinks.buildLinks(linksData);
			
		}
		
	},
	
	/* PARTH: save fresh results to local storage and then build link feed */
	processFreshData : function(result){
		aauMobile.setLocalStorage(aauMobile.externalLinks.dataKey,JSON.stringify(result));
		aauMobile.externalLinks.isRefreshEvent = false;
		aauMobile.externalLinks.buildLinks(result);
		
	}, 
	
	//this is the successCallback from the rest call in init
	buildLinks: function(result){
		aauMobile.externalLinks.linkData = result;
		//loop through results and use a template to create each item and add to the ul 
		//console.log('external Links  Success result ! ' + JSON.stringify(result));
		var linkTemplate = $("#link-template");
		var linkContainer = $("#link-ul");
		var jsonList = [];
		$(linkContainer).empty();
		if(result[0].linkName != null){
			$.each(result, function(index, item){
				//console.log('Link Item: ' + JSON.stringify(item));
				if(index < 20){
					//linkTemplate.tmpl({linkName: item.linkName, linkUrl: item.linkUrl}).appendTo(linkContainer);
					jsonList.push({linkName: item.linkName, linkUrl: item.linkUrl});			
				}else{
					return;
				}
			});
			linkTemplate.tmpl(jsonList).appendTo(linkContainer);
		} else{
			$('#no-link-template').tmpl().appendTo(linkContainer);
		}
		
		//If jQuery has initialized it, refresh.
		if($(linkContainer).hasClass('ui-listview')){
			$(linkContainer).listview('refresh');
		}
		if($($.mobile.activePage).attr('id') == 'link-list'){
			//Hide loading message.
			//$.mobile.hidePageLoadingMsg();
			//$('.ui-loader').css('display', 'none');
			//Resize the container so the device can scroll.
			if(aauMobile.isAndroid()){
				$(window).trigger('orientationchange');
			}
		}
		$(linkContainer).css('margin','0px');
		/* PARTH: hide spinner */
		//hideProgress();
		//dataInitComplete('link-list');
		aauMobile.externalLinks.onComplete();
	},
	initFailure: function(result) {
		console.log('buildLinks Failure. ' + result);
		aauMobile.externalLinks.isRefreshEvent = false;
	    var linkContainer = $("#link-ul");
	    var linksData = aauMobile.getLocalStorage(aauMobile.externalLinks.dataKey);
		
		if( linksData == null || linksData.length < 1 || linksData[0].linkName == null){
			$(linkContainer).empty();
			$('#no-link-template').tmpl().appendTo(linkContainer);
			//If jQuery has initialized it, refresh.
			if($(linkContainer).hasClass('ui-listview')){
				$(linkContainer).listview('refresh');
			}
		}else{
			
			aauMobile.externalLinks.buildLinks(linksData);
		}
		
		if($($.mobile.activePage).attr('id') == 'link-list'){
			//Hide loading message.
			//$.mobile.hidePageLoadingMsg();
			//$('.ui-loader').css('display', 'none');
			//Resize the container so the device can scroll.
			if(aauMobile.isAndroid()){
				$(window).trigger('orientationchange');
			}
		}
		$(linkContainer).css('margin','0px');
		/* PARTH : Hide spinner */
		//hideProgress();
		//dataInitComplete('link-list');
		aauMobile.externalLinks.onComplete();
		if(result==""){ return;}
		if(result.indexOf("Unable to resolve host")>=0){
			alert("Due to slow or no connection, this action has been canceled. Please try again later.");
		}else{
			alert('We have encountered an error.  Please try again later.');
		}
	}
},

///////////////////////
//Chatter Feed
chatterFeed: {
	data: [],
	//data: {},
    dataKey : 'chatterData', /* PARTH: Key to identify this data in localStorage*/
	
	/* PARTH: This method clears the browser local storage  */   
    clearLocalStorage: function(){
		aauMobile.clearLocalStorage(aauMobile.chatterFeed.dataKey);
	},
	isRefreshEvent : false,
	onComplete: function(){},
	
	init: function(callback){
	    aauMobile.chatterFeed.onComplete = callback; 
		aauMobile.chatterFeed.data = [];
		/* PARTH:  
		 * Get Data from local storage
		 * If local Data exists, use it else get fresh data */
		var localData = aauMobile.getLocalStorage(aauMobile.chatterFeed.dataKey);
	
		if(aauMobile.chatterFeed.isRefreshEvent || localData == null || localData.length < 1 || localData.startDate == null){
			//Load Fresh Data
			console.log('chatterFeed: NO LOCAL DATA FOUND - FETCHING FRESH DATA');
			
			var restPath = '/services/data/v26.0/chatter/feeds/news/me/feed-items';
			
			//RestDataPlugin.getAJAXRestFeed(aauMobile.chatterFeed.processFreshData, aauMobile.chatterFeed.initFailure, restPath, true, "GET", "json");
			RestDataPlugin.getData(aauMobile.chatterFeed.processFreshData, aauMobile.chatterFeed.initFailure, restPath, false, "GET", "json");
		}
		else{
			//Load existing data
			console.log('FOUND LOCAL DATA FOUND - LOADING EXISTING DATA');
			aauMobile.chatterFeed.buildFeedList(localData);
			//aauMobile.chatterFeed.onComplete();
			
		}
		
	},
	/* PARTH: This method saves the fresh results to database and then builds the DOM */
	processFreshData : function(result){
		console.log('full Feed : '+ JSON.stringify(result));
		aauMobile.setLocalStorage(aauMobile.chatterFeed.dataKey,JSON.stringify(result));
		aauMobile.chatterFeed.isRefreshEvent = false;
		aauMobile.chatterFeed.buildFeedList(result);
		aauMobile.chatterFeed.onComplete();
		
		
	}, 
	
	buildFeedList: function(result){
		
		//alert("chatterFeed Result: "+ JSON.stringify(result));
		aauMobile.chatterFeed.data = result;
		
		//alert(result.items[0]);
		//alert(result.items[0].parent.name);
		var index =0;	
		var listItems = [];
		var currDay = -1;
		
		$.each(result.items, function(index, item) {
			if(index>19){
				return false;
			}
			var stDate = new Date(item.createdDate);
			
		    var localeDate = appirioUtils.formatDate(stDate);		
			if(stDate.getDay() != currDay){
				currDay = stDate.getDay();
				listItems.push({isDivider: true, CreatedDayAndDay: localeDate});
			}
		     listItems.push({
		     					isDivider: false,
								title:(item.body.text.length>45)?(item.body.text.substring(0,45) + "..."):item.body.text,
								body:item.body.text,
								actor:item.actor.name,
								createdDate:item.createdDate,
								CreatedDayAndDay:localeDate,
								parent:(item.parent.type == "CollaborationGroup")?item.parent.name:"",
								parentType:item.parent.type,
								feedId:item.id
				});
				index++;
			
			
		});
		
		//alert( JSON.stringify(listItems));
		
		var blockTemplate = $("#chatter-feed-template");
		var feedContainer = $("#chatter-feed-ul").empty();
		
		
		if(listItems[0] == null){
			$('#no-chatter-feed-template').tmpl({noneFound:'none-found'}).appendTo(feedContainer);
		}else{
			
			$(blockTemplate).tmpl(listItems).appendTo(feedContainer);
			 
		}

		if(feedContainer.hasClass('ui-listview')){
			feedContainer.listview('refresh'); 
		}  
		feedContainer.css("margin","0px");
		
		if($($.mobile.activePage).attr('id') == 'chatter-list'){
			//Hide loading message.
			//Resize the container so the device can scroll.
			if(aauMobile.isAndroid()){
				$(window).trigger('orientationchange');
			}
		}
		
		//PARTH: Hide Spinner
		aauMobile.chatterFeed.onComplete();
		
	},

	initFailure: function(result) {
		
		console.log("failureCallback Result: "+ JSON.stringify(result));
		aauMobile.chatterFeed.isRefreshEvent = false;
		/*PARTH: Hide Spinner*/
		//hideProgress();
		//dataInitComplete('student-home');
		var blockTemplate = $("#chatter-feed-template");
		var feedContainer = $("#chatter-feed-ul").empty();
		
		var localData = aauMobile.getLocalStorage(aauMobile.chatterFeed.dataKey);
	
		if( localData == null || localData.length < 1 || localData.startDate == null){
			$('#no-chatter-feed-template').tmpl({noneFound:'none-found'}).appendTo(feedContainer);
		}else{
			aauMobile.chatterFeed.buildFeedList(localData);
			 
		}

		if(feedContainer.hasClass('ui-listview')){
			feedContainer.listview('refresh'); 
		}  
		feedContainer.css("margin","0px");
		
		if($($.mobile.activePage).attr('id') == 'chatter-list'){
			//Hide loading message.
			//Resize the container so the device can scroll.
			if(aauMobile.isAndroid()){
				$(window).trigger('orientationchange');
			}
		}
		aauMobile.chatterFeed.onComplete();
		if(result==""){ return;}
		if(result.indexOf("Unable to resolve host")>=0){
			alert("Due to slow or no connection, this action has been canceled. Please try again later.");
		}else{
			alert('We have encountered an error.  Please try again later.');
		}
	},
    
    showChatterDetails: function(feedId) { 
   		var chatterDetail;
   		 
   		for(all  in aauMobile.chatterFeed.data.items){
   			if(aauMobile.chatterFeed.data.items[all].id == feedId ){
   				chatterDetail = aauMobile.chatterFeed.data.items[all];
   				break;
   			}
   		}
   		//console.log('chatterDetail: '+JSON.stringify(chatterDetail));

		//alert('chatterDetail: '+JSON.stringify(chatterDetail));    
		 	
		//Change the Page to Show the details of Selected chatterpost
		$.mobile.changePage("#chatter-detail", {transition: 'slide', changeHash: true});
		
		//Make empty to the components to add selected contents 
		$('#chatter-ulDlId').empty();
		//$('#chatter-NameDv').empty();
		$('#chatter-DescrDv').empty();

		$("<h3>"+ chatterDetail.body.text +"</h3>").appendTo('#chatter-DescrDv');
        
		var blockTemplate = $("#chatterDetail-template");
		var detailContent = $("#chatter-ulDlId");
        
       	var stDate = new Date(chatterDetail.createdDate);
			
		var localeDate = appirioUtils.formatDate(stDate);	
		var detailBlock = blockTemplate.tmpl({
								title:(chatterDetail.body.text.length>80)?chatterDetail.body.text:chatterDetail.body.text.substring(0,80),
								body:chatterDetail.body.text,
								actor:chatterDetail.actor.name,
								createdDate:chatterDetail.createdDate,
								CreatedDayAndDay:localeDate,
								parent:(chatterDetail.parent.type == "CollaborationGroup")?chatterDetail.parent.name:"",
								parentType:chatterDetail.parent.type,
								feedId:chatterDetail.id
		});

		detailBlock.appendTo(detailContent);  
		if(detailContent.hasClass('ui-listview')){
			detailContent.listview('refresh');
		}
		//Resize the container so the device can scroll.
		if(aauMobile.isAndroid() && $($.mobile.activePage).attr('id') == 'chatter-detail'){
			$(window).trigger('orientationchange');
		}
		detailContent.css("margin","0px");
    }
   
},

///////////////////////
//Travel Route
tripPlanner: {
	data: [],
	//data: {},
    dataKey : 'travelPlan', /* PARTH: Key to identify this data in localStorage*/
	dataKey2 : 'travelParams',
	
	/* PARTH: This method clears the browser local storage  */   
    clearLocalStorage: function(){
		aauMobile.clearLocalStorage(aauMobile.tripPlanner.dataKey);
		aauMobile.clearLocalStorage(aauMobile.tripPlanner.dataKey2);
	},
	isRefreshEvent : false,
	onComplete: function(){},
	
	tripStart:'',
	tripEnd:'',
	tripStartId:'',
	tripEndId:'',
	tripTime:'',
	weekdayOption:'',
	
	init: function(callback){
	//alert('start = ' + aauMobile.tripPlanner.tripStartId);
	//alert('end = ' + aauMobile.tripPlanner.tripEndId);
	//alert('time = ' + aauMobile.tripPlanner.tripTime);
	//alert('weekdayOption = ' + aauMobile.tripPlanner.weekdayOption);
	
	
	var selTemplate = $("#trip-selection-template");
	var selContainer = $("#ul-trip-planner-selection").empty();
	var selDetailsContainer = $("#ul-trip-details-selection").empty();
	
	var selectedItems = [];
	 selectedItems.push({
		     					startTrip: aauMobile.tripPlanner.tripStart,
								endTrip: aauMobile.tripPlanner.tripEnd });
	
		$(selTemplate).tmpl(selectedItems).appendTo(selContainer);
		$(selTemplate).tmpl(selectedItems).appendTo(selDetailsContainer);
		
		if(selContainer.hasClass('ui-listview')){
			selContainer.listview('refresh'); 
		}  
		selContainer.css("margin","0px");
		
		if(selDetailsContainer.hasClass('ui-listview')){
			selDetailsContainer.listview('refresh'); 
		}  
		selDetailsContainer.css("margin","0px");
		
	    aauMobile.tripPlanner.onComplete = callback; 
		aauMobile.tripPlanner.data = [];
		/* PARTH:  
		 * Get Data from local storage
		 * If local Data exists, use it else get fresh data */
		var localData = aauMobile.getLocalStorage(aauMobile.tripPlanner.dataKey);
	
		if(aauMobile.tripPlanner.isRefreshEvent || localData == null || localData.length < 1 || localData.startDate == null){
			//Load Fresh Data
			console.log('tripPlanner: NO LOCAL DATA FOUND - FETCHING FRESH DATA');
			
			var fromId = aauMobile.tripPlanner.tripStartId;
			var toId = aauMobile.tripPlanner.tripEndId;
			var startTime = aauMobile.tripPlanner.tripTime.replace(':','.');
			
			var restPath = "/tripplanner?toId=" + toId + "&fromId=" + fromId + "&startTime="+ startTime;
			RestDataPlugin.getData(aauMobile.tripPlanner.processFreshData, aauMobile.tripPlanner.initFailure, restPath, true, "GET", "json");
		
		}
		else{
			//Load existing data
			console.log('FOUND LOCAL DATA FOUND - LOADING EXISTING DATA');
			aauMobile.tripPlanner.buildTripList(localData);
			//aauMobile.tripPlanner.onComplete();
			
		}
		
	},
	/* PARTH: This method saves the fresh results to database and then builds the DOM */
	processFreshData : function(result){
		//alert(JSON.stringify(result))
		//console.log('full routes : '+ JSON.stringify(result));
		console.log('full routes : '+ JSON.stringify(result.routes));
		aauMobile.setLocalStorage(aauMobile.tripPlanner.dataKey,JSON.stringify(result));
		aauMobile.tripPlanner.isRefreshEvent = false;
		aauMobile.tripPlanner.buildTripList(result);
		aauMobile.tripPlanner.onComplete();
		
		
	}, 
	
	buildTripList: function(result){
		
		//alert("chatterFeed Result: "+ JSON.stringify(result));
		aauMobile.tripPlanner.data = result.routes;
		
		//alert(JSON.stringify(result.routes));
		
		var unsortedItems = [];
		var listItems = [];
		
		//if(result != null && result.lstRoutes != null && result.lstRoutes[0] != null){
		if(result != null && result.routes != null){
			console.log('WOOT - Has TripPlanner Result Data');

			$.each(result.routes, function(index, route) {
			//alert(JSON.stringify(route[0]));
				console.log('WOOT Route: '+JSON.stringify(route));
			
				var hasMore = true;
				var i=0;
				var routeData = {};
				var startTime ;
				var endTime ;
				var trans =0;
				for( i=0; hasMore == true ;i++){
					if(route[i] == null){
						hasMore = false;
						break;
					}
					//alert(JSON.stringify(route[i]));
					if(route[i].type == 'TRANS'){
						trans++;
					}
					if(route[i].type == 'START'){
						startTime = route[i].fromTime;
						routeData = {
									routecolor: '',
									routename: route[i].fromRoute,
									nextBusIn: '',
									arrivalTime: aauMobile.tripPlanner.get12HrTime(route[i].fromTime), //route[i].fromTime.replace('.',':'),
									deptTime: aauMobile.tripPlanner.get12HrTime(route[i].fromTime), //route[i].fromTime.replace('.',':'),
									travelTime: '',
									tripId: index,
									showNextIcon : true,
									transfers:0,
									destTime:'',
									rawDestTime: '',
									isClickable: true
									};
						index++;			
					}
					else if(route[i].type == 'END'){
						routeData.rawDestTime = route[i].toTime;	//use this to sort later
						routeData.destTime = aauMobile.tripPlanner.get12HrTime(route[i].toTime);
						endTime = route[i].toTime;
						var endT = new Date(0,0,0,parseInt(endTime.split('.')[0]),parseInt(endTime.split('.')[1]),0,0);
						var startT =  new Date(0,0,0,parseInt(startTime.split('.')[0]),parseInt(startTime.split('.')[1]),0,0);
						
						var diff = Math.floor((endT-startT)/1000/60);
						
						routeData.travelTime = diff +' mins';
						
						//console.log('TIME: '+aauMobile.tripPlanner.tripTime);
						var nowTime = aauMobile.tripPlanner.tripTime.split(':');

						//var nowDt = new Date(aauMobile.tripPlanner.tripTime);
						//console.log('TIME: '+nowDt);
						//var nowT = new Date(0,0,0,nowDt.getHours(),nowDt.getMinutes(),0);
						var nowT = new Date(0,0,0,nowTime[0],nowTime[1],0);
						//console.log('TIME: '+nowT);
						//var nowT = aauMobile.tripPlanner.tripTime;
						routeData.nextBusIn = Math.floor((startT - nowT)/1000/60) ;
						//console.log('TIME: '+routeData.nextBusIn);

						/*if(routeData.nextBusIn < 0){
							routeData.nextBusIn = routeData.nextBusIn * -1;
						}*/
						//alert('startT = ' + startT + ' nowT = ' + nowT + ' diff = ' + (nowT - startT)/1000/60);
					}
				}
			
				var routesAndColors ;
				if(!hasNativeMap){
					routesAndColors = teletracManager.getRouteNamesAndColors();
				}else{
					routesAndColors = aauMobile.tripPlanner.routeNamesAndColors;
				}
				
				$.each(routesAndColors, function(index, color){
					if(color.routeName == routeData.routename){
						routeData.routecolor = color.routeColor;
						return false;
					}
				});
				
				routeData.transfers = trans;
				listItems.push(routeData);

			});

			listItems.sort(function(a,b){
				return a.destTime.localeCompare(b.destTime);
			});
		}
				
		var blockTemplate = $("#trip-options-template");
		var feedContainer = $("#trip-options-list").empty();
		
		if(listItems[0] == null){
			$('#trip-no-options-template').tmpl({noneFound:'none-found'}).appendTo(feedContainer);
		}else{
			$(blockTemplate).tmpl(listItems).appendTo(feedContainer);
		}

		if(feedContainer.hasClass('ui-listview')){
			feedContainer.listview('refresh'); 
		}  
		feedContainer.css("margin","0px");
		
		if($($.mobile.activePage).attr('id') == 'trip-options'){
			//Hide loading message.
			//Resize the container so the device can scroll.
			if(aauMobile.isAndroid()){
				$(window).trigger('orientationchange');
			}
		}
		
		//PARTH: Hide Spinner
		aauMobile.tripPlanner.onComplete();
		
	},
	get12HrTime : function(tim){
		var hr = parseInt(tim.split('.')[0]);
		var min = parseInt(tim.split('.')[1]);
		var strMin =''+ min;
		var strHr='';
		var ampm=' AM';
		if(min<10){
			strMin = '0' + min;
		}
		
		if(hr>12){
			hr = hr-12;
			strHr = '' + hr;
			ampm = ' PM';
			if(hr<10){
				strHr = '0' +  hr ;
			}
			
		}else{
			strHr = '' + hr;
			ampm = ' AM';
			if(hr<10){
				strHr = '0' +  hr ;
			}
			
		}
		return strHr + ':' + strMin + ampm ;
	},
	
	initFailure: function(result) {
		
		console.log("failureCallback Result: "+ JSON.stringify(result));
		aauMobile.tripPlanner.isRefreshEvent = false;
		/*PARTH: Hide Spinner*/
		var blockTemplate = $("#trip-options-template");
		var feedContainer = $("#trip-options-list").empty();
		
		var localData = aauMobile.getLocalStorage(aauMobile.tripPlanner.dataKey);
	
		
		
		if( localData == null || localData.length < 1 ){
			$('#trip-no-options-template').tmpl({noneFound:'none-found'}).appendTo(feedContainer);
		}else{
			//aauMobile.tripPlanner.buildTripList(localData);
			 
		}

		if(feedContainer.hasClass('ui-listview')){
			feedContainer.listview('refresh'); 
		}  
		feedContainer.css("margin","0px");
		
		if($($.mobile.activePage).attr('id') == 'trip-options'){
			//Hide loading message.
			//Resize the container so the device can scroll.
			if(aauMobile.isAndroid()){
				$(window).trigger('orientationchange');
			}
		}
		aauMobile.tripPlanner.onComplete();
		if(result==""){ return;}
		if(result.indexOf("Unable to resolve host")>=0){
			alert("Due to slow or no connection, this action has been canceled. Please try again later.");
		}else{
			alert('We have encountered an error.  Please try again later.');
		}
	},
    
    showTripDetails: function(callback,tripId) { 
    	aauMobile.tripPlanner.onComplete = callback; 
   		var tripDetail;
   		//alert(JSON.stringify(aauMobile.tripPlanner.data.lstRoutes));
   		var route = aauMobile.tripPlanner.data[tripId];
   		//alert(JSON.stringify(route));
   		var tripHeaderData = [];
   		var tripDetailsData = [];
   		//Change the Page to Show the details of Selected chatterpost
		$.mobile.changePage("#trip-details", {transition: 'slide', changeHash: true});
			var hasMore = true;
			var i=0;
			var routeData = {};
			var routeDetailsData = {};
			var startTime ;
			var endTime ;
			var trans = 0;
			for( i=0; hasMore == true ;i++){
				//alert(JSON.stringify(route[i]));
				
				if(route[i] == null){
						hasMore = false;
						break;
					}
					
					//alert(JSON.stringify(route[i]));
					if(route[i].type == 'TRANS'){
							trans++;
						}
					if(route[i].type == 'START'){
						startTime = route[i].fromTime;
						routeData = {
			     					routecolor: '',
									routename: route[i].fromRoute,
									nextBusIn: '',
									arrivalTime: aauMobile.tripPlanner.get12HrTime(route[i].fromTime), //route[i].fromTime.replace('.',':'),
									deptTime: aauMobile.tripPlanner.get12HrTime(route[i].fromTime), //route[i].fromTime.replace('.',':'),
									travelTime: '',
									//tripId: index,
									showNextIcon : false,
									transfers: 0,
									destTime:'',
									isClickable: false
									};
					}
					else if(route[i].type == 'END'){
						routeData.destTime = aauMobile.tripPlanner.get12HrTime(route[i].toTime);
						endTime = route[i].toTime;
						var endT = new Date(0,0,0,parseInt(endTime.split('.')[0]),parseInt(endTime.split('.')[1]),0,0);
						var startT =  new Date(0,0,0,parseInt(startTime.split('.')[0]),parseInt(startTime.split('.')[1]),0,0);
						
						var diff = Math.floor((endT-startT)/1000/60);
    					
						routeData.travelTime = diff +' mins';
						
						var nowTime = aauMobile.tripPlanner.tripTime.split(':');
						//var nowDt = new Date();
						//var nowT = new Date(0,0,0,nowDt.getHours(),nowDt.getMinutes(),0);
						var nowT = new Date(0,0,0,nowTime[0],nowTime[1],0);
						routeData.nextBusIn = Math.floor((startT - nowT)/1000/60) ;
						
					}
					
		      		
		      		routeDetailsData = {
									routecolor: '',
									nextroutecolor:'',
									routename: route[i].fromRoute,
									arrivalTime: aauMobile.tripPlanner.get12HrTime(route[i].fromTime), //route[i].fromTime.replace('.',':'),
									deptTime: aauMobile.tripPlanner.get12HrTime(route[i].toTime), //route[i].toTime.replace('.',':'),
									stopname: route[i].stop,
									transferto:route[i].toRoute,
									stoptype: route[i].type,
									routecrosses:'' 
									
					
					}
					var routesAndColours ;
					if(!hasNativeMap){
						routesAndColours = teletracManager.getRouteNamesAndColors();
					}
		      		else{
		      			routesAndColours = aauMobile.tripPlanner.routeNamesAndColors;
		      		}
					//$.each(teletracManager.getRouteNamesAndColors(), function(index, color){
					$.each(routesAndColours, function(index, color){
		      			if(color.routeName == routeData.routename){
		      				routeData.routecolor = color.routeColor;
		      				
		      			}
		      			if(color.routeName == routeDetailsData.routename){
		      				routeDetailsData.routecolor = color.routeColor;
		      				
		      			}
		      			if(color.routeName == routeDetailsData.transferto){
		      				routeDetailsData.nextroutecolor = color.routeColor;
		      				
		      			}
		      		});
		      		
		      		
		      		//Get the comma separated list of Routes hat cross this stop
		      		var busStopRoutes = mapManager.busStopDetails;
		      		//alert(JSON.stringify(busStopRoutes));
		      		for(var ind=0;  true; ind++){
		      			//alert(JSON.stringify(busStopRoutes[ind]));
		      			if(busStopRoutes[ind] == null){break;}
		      			var stop = busStopRoutes[ind];
		      			if(stop.busStopTitle == routeDetailsData.stopname){
		      				routeDetailsData.routecrosses = stop.busStopRoutes;
		      				break;
		      			}
		      		}
		      		
		      		
					tripDetailsData.push(routeDetailsData);		
				
			}
			routeData.transfers = trans;
			tripHeaderData.push(routeData);
		
		
		
		//alert( JSON.stringify(listItems));
		
		var blockTemplate = $("#trip-options-template");
		var feedContainer = $("#trip-detail-option-list").empty();
		
		
		if(tripHeaderData[0] == null){
			//$('#no-chatter-feed-template').tmpl({noneFound:'none-found'}).appendTo(feedContainer);
		}else{
			$(blockTemplate).tmpl(tripHeaderData).appendTo(feedContainer);
		}

		if(feedContainer.hasClass('ui-listview')){
			feedContainer.listview('refresh'); 
		}  
		feedContainer.css("margin","0px");
		
		
		var chartTemplate = $("#trip-chart-template");
		var chartContainer = $("#div-route-chart").empty();
		$(chartTemplate).tmpl(tripDetailsData).appendTo(chartContainer);
		
		//alert( JSON.stringify(tripDetailsData));
		var planTemplate = $("#trip-plan-template");
		var planContainer = $("#div-trip-plan").empty();
		$(planTemplate).tmpl(tripDetailsData).appendTo(planContainer);
		
		
		
		if($($.mobile.activePage).attr('id') == 'trip-details'){
			//Hide loading message.
			//Resize the container so the device can scroll.
			if(aauMobile.isAndroid()){
				$(window).trigger('orientationchange');
			}
		}
		
		
		//PARTH: Hide Spinner
		aauMobile.tripPlanner.onComplete();
    },
    
    setClosestStartBusStop_fireEvent: function(){
    	appirioUtils.fireEvent(aauMobile.tripPlanner.setClosestStartBusStop, null, null); 
    },
    setClosestStartBusStop: function(callback){
    	aauMobile.tripPlanner.onComplete = callback;
    	mapManager.getClosestStop(function(stopId) {
    		//alert(stopId);
    		$('#startStop-select :selected').removeAttr("selected");
    		//alert($("#startStop-select option[value='"+ stopId +"']"));
    		
    		$("#startStop-select option[value='"+ stopId +"']").attr("selected", "selected");
    		$("#startStop-select").selectmenu('refresh',true);
    		 showStartStop(stopId);
    		aauMobile.tripPlanner.onComplete();
    		
		
    	});
    },
     setClosestEndBusStop_fireEvent: function(){
    	appirioUtils.fireEvent(aauMobile.tripPlanner.setClosestEndBusStop, null, null); 
    },
    setClosestEndBusStop: function(callback){
    	aauMobile.tripPlanner.onComplete = callback;
    	mapManager.getClosestStop(function(stopId) {
    		//alert(stopId);
    		$("#endStop-select option[value='"+ stopId +"']").attr("selected", "selected");
    		$("#endStop-select").selectmenu('refresh',true);
    		showFinishStop(stopId);
    		aauMobile.tripPlanner.onComplete();
    		
    	});
    },
    
    //// Changes for Trip Planner Stop list/////
    //Moved code from Transit Manager//
    busStops : [],
	busStopNames : [],
	routeNamesAndColors :[],
	//Bus Routes with Stops
	routes : {},
	    
	 // Bus stops with all routes that run through it
	 stopNamesWithRoutes :{},
	    
	    
	getBusStopsFromSFDC: function(callback) {
    	//alert('getBusStopsFromSFDC');
		var myRoutes = localStorage.getItem('busStopData'); 
		//PARTH: Check Last refresh date 
		// If time elapsed since last update is more than the time out then refresh the data
		var str_lastRefreshDate = localStorage.getItem('lastRefreshDate');
		
		if(str_lastRefreshDate == null || str_lastRefreshDate == 'null' || str_lastRefreshDate == '' || myRoutes == null || myRoutes == 'null' || myRoutes == ''){
			myRoutes = null;
			localStorage.setItem('busStopData', null);
		}else{
			var LastRefresh_milis = Number(str_lastRefreshDate);
			var now_milis = Date.now().valueOf();
			if( (now_milis - LastRefresh_milis) > (str_cacheTimeoutDays * 86400000)){
				//clear local storage
				//alert('ClearData');
				myRoutes = null;
				localStorage.setItem('busStopData', null);
				
			}
		}
		
		//console.log('WOOOOOT: '+myRoutes);
		//routes = JSON.parse(myRoutes);
		try{
		  	routes = JSON.parse(myRoutes);
		}
		catch(err){ 
		  routes = null;
		  console.log('Error while parsing data for : routeData' );
	  	}
		//alert(routes);
		//alert(routes[0].routeName);
		if(myRoutes == null || myRoutes == 'null'  || routes == null || routes.length < 1 || routes[0].routeName == null || routes[0].routeName == 'null'  || routes[0].routeName == ''){
			var restPath = "/BusStops/"; 
			RestDataPlugin.getData(function(result){
								//appirioUtils.log('Success REST service bus routes:'+JSON.stringify(result));
								//alert('getBusStopsFromSFDC: Success REST service bus routes:'+JSON.stringify(result));
								aauMobile.tripPlanner.parseStops(result, callback);
								aauMobile.tripPlanner.parseRouteNamesAndColors(result);
								routes = result;
								localStorage.setItem('busStopData', JSON.stringify(result));
								//PARTH: Set last refresh date 
								localStorage.setItem('lastRefreshDate', Date.now().valueOf());
								return result;
							   },
							   function(){
							   //alert('FAILURE REST service bus routes:'+JSON.stringify(result));
							   	appirioUtils.log('Failure REST service bus routes:');
							   }, 
							   restPath, 
							   true, 
							   "GET", 
							   "json");
		}else{
			//alert('3');
			console.log('WOOT localStorage: '+routes);
			aauMobile.tripPlanner.parseStops(routes, callback);
			aauMobile.tripPlanner.parseRouteNamesAndColors(routes);
		}
	},
	
	// Private function to parse bus stops to plot on gmap from response form SFDC
    // using an array to hold stop names to compare against to prevent dup stops
    // Function also creates an associative array of stopName: [route] in stopNamesWtihRoutes
    parseStops: function (results, callback){
    	//alert('1');
    	//alert(results);
    	//alert(results[0]);
    	if (typeof results === 'string' ){return ;}
		//alert(routes);
		
    	$(results).each( function(){
    	   
    	   var that = this;
    	   
    		$(this.stops).each( function(){
    		  var routeNameArray = aauMobile.tripPlanner.stopNamesWithRoutes[this.stopName];
    		  if(!routeNameArray) {
    		    routeNameArray = [];
    		  }
    		  routeNameArray.push(that.routeName);
    		  aauMobile.tripPlanner.stopNamesWithRoutes[this.stopName] = routeNameArray;  
    			
    			if(($.inArray(this.stopName, aauMobile.tripPlanner.busStopNames)) == -1 && this.active == true){
    				aauMobile.tripPlanner.busStopNames.push(this.stopName);
    				aauMobile.tripPlanner.busStops.push(this);
    			}
    		});
    	});
    	//alert('2');
    	callback(aauMobile.tripPlanner.busStops);
    },
    
    // Private function to create array with routes and colors together for route
    // drawing. Then create appropriate check box on shuffle popover
    parseRouteNamesAndColors: function (results){
      //Stort routes Alphabetically 
  		results.sort(function(a,b){
  			return a.routeName.localeCompare(b.routeName);
  		});
  		
  		
    	$(results).each(function () {
    		aauMobile.tripPlanner.routeNamesAndColors.push({"routeName": this.routeName, "routeColor": this.stops[0].color});
    		
    	});
    	
    },
   
},

 

//Mobile Sliding Menu component. 
//Displays as a side-bar that slides out and pushes content to the side.
slideMenu: {
	
	lastSlide: new Date().getTime(),
	//Slides the menu out, and pushes the active page to the right.
	show: function(callback, event){
	    event.preventDefault();
	    console.log('MENU BUTTON CLICKED');
		$('.mob-header').css('position','absolute');
		aauMobile.slideMenu.lastSlide = new Date().getTime();
		
		$('#menu-header').html($($.mobile.activePage).find('.mob-header').html());
		$('#menu-header .menu-btn').removeClass('menu-btn');
		$('#menu-page').removeClass('hidden');
		
		//Prevent ugly slide behavior on transit-map
		//$('#result-container').css('position','absolute');
		
		//Activate the sliding.
		$('#menu-page').addClass('slide-out');
		$('.page-container').addClass('slide-out');
		
		//setTimeout(callback(), 3000);
		callback(null);
		//OLD METHOD
		//$('#slide-menu').animate({marginLeft:'0px'},250, function(){$('#slide-menu').css('position','fixed');});
		//$($.mobile.activePage).animate({marginLeft:'180px'},250);
	},

	//Removes the slide-out class, causing the active page and 
	hide: function(callback, event){
		var curTime = new Date().getTime();
		var timeDiff = curTime - aauMobile.slideMenu.lastSlide;
		console.log('curTime - lastSlide = ' + timeDiff);
		
		//Android vClick bug solution.
		if(timeDiff > 400){		
			console.log('Tapped on the content. Closing Menu.');
			if(aauMobile.isAndroid()){
				$('#menu-page').css('position','absolute');
			}
			$('#menu-page').removeClass('slide-out');
			
			$('.page-container').removeClass('slide-out');
			
			aauMobile.slideMenu.lastSlide = new Date().getTime();
		}
		callback(null);
		
		//OLD METHOD
		//$('#slide-menu').animate({marginLeft:'-180px'},250, function(){$('#menu-page').css('display','none');});
		//$($.mobile.activePage).animate({marginLeft:'0px'},250, function(){$('.mob-header').css('position','fixed');});
	},

	//Changes the active page and slides the menu back into hiding.
	linkClicked: function(event){
		event.stopPropagation();
		event.preventDefault();
		
		var curTime = new Date().getTime();
		var timeDiff = curTime - aauMobile.slideMenu.lastSlide;
		console.log('curTime - lastSlide = ' + timeDiff);
		
		//Android vClick bug solution.
		if(timeDiff > 400){		
			var pageLink = $(this).attr('href');
			if(pageLink.length <= 1){
				//jQuery Mobile has hijacked our link to prevent the address bar from showing.
				pageLink = $(this).data('href');
			}
			console.log('Link clicked. Target Name  = ' + pageLink);
			
			//Logout if logout link clicked.
			//Otherwise go to page.
			if($(this).attr('id') == 'logout-link'){
				console.log('Logging out 2');

				//TODO: Change this to be a native plugin instead of phonegap.resource call
				$.mobile.changePage('#student-home', {changeHash: true});
				if(aauMobile.isAndroid()){
					$('#menu-page').css('position','absolute');
				}
				$('#menu-page').removeClass('slide-out');
				$('.page-container').removeClass('slide-out');
				
				SalesforceOAuthPlugin.logout();
			}
			else{
			   console.log('Link clicked. Else  Target Name  = ' + pageLink);
				appirioUtils.log("")
			
				$('#menu-header').html($(pageLink).find('.mob-header').html());
				$.mobile.changePage(pageLink, {changeHash: true});
				$('#menu-page').css('height',$(window).height());
				$('#slide-menu').css('height',$(window).height());
				
				//Remove the fixed so that Android 2.3 doesn't freak.
				if(aauMobile.isAndroid()){
					$('#menu-page').css('position','absolute');
				}
				
				//Slide the page and the menu back to starting position.
				$('#menu-page').removeClass('slide-out');
				$('.page-container').removeClass('slide-out');
				
				aauMobile.slideMenu.lastSlide = new Date().getTime();

				/*****  START: Standardize the Spinner for all page loads  ****
				if(pageLink == '#student-home' & aauMobile.classSchedule.data.length < 1){
					$.mobile.showPageLoadingMsg("b", "Loading...", false);
				}
				if(pageLink == '#feed-list' & !aauMobile.campusFeed.feedData){
					$.mobile.showPageLoadingMsg("b", "Loading...", false);
				}
				console.log('Campus Events: '+aauMobile.campusFeed.feedCount);
				if(pageLink == '#campus-event-list' & aauMobile.campusEvents.feedCount < 3){
					console.log('Go Spinny Go!');
					$.mobile.showPageLoadingMsg("b", "Loading...", false);
				}
				if(pageLink == '#event-list' & !aauMobile.rssEvent.feedData){
					$.mobile.showPageLoadingMsg("b", "Loading...", false);
				}
				if(pageLink == '#link-list' & !aauMobile.externalLinks.linkData){
					$.mobile.showPageLoadingMsg("b", "Loading...", false);
				}
				if(pageLink == '#transit-map' & !aauMobile.campusEvents.feedData){
					$.mobile.showPageLoadingMsg("b", "Loading...", false);
				}
				/*****  END: Standardize the Spinner for all page loads  ****/

				
				//Old Method
				//$('#slide-menu').animate({marginLeft:'-180px'},250, function(){$('#menu-page').css('display','none');});
				//$(pageLink).animate({marginLeft:'0px'},250, function(){$('.mob-header').css('position','fixed');});
			}
		}
	},
        toggleMenu: function(){
		aauMobile.nativeAdapter.exec(function (){}, function(){}, "com.appirio.mobile.menu", "toggleMenu", []);
	},
	nativeSetup: function(){
		/* 
		UNUSED NATIVE MENU ITEMS 
		{"title":"Transit Map", "id" : "transit-map-link", "icon":"iconsprite_grey.png", "imageRect":{ "x": 0, "y": 31, "width": 38, "height": 31}, "action":"$.mobile.changePage('#transit-map'); $(window).trigger('orientationchange');"},
		{"title":"SF Events", "id" : "events-link", "icon":"iconsprite_grey.png", "imageRect":{ "x": 0, "y": 63, "width": 38, "height": 22}, "action":"$.mobile.changePage('#event-list');"} */
		
		var transitMap = {"title":"Transit Map", "id" : "transit-map-link", "icon":"iconsprite_grey.png", "nonsprite":"transit.png", "imageRect":{ "x": 0, "y": 31, "width": 38, "height": 31}, "action":"$.mobile.changePage('#transit-map'); $(window).trigger('orientationchange');", "actionType" : "js"};
		if(hasNativeMap){
			transitMap = {"title":"Transit Map", "id" : "native-transit-map-link", "icon":"iconsprite_grey.png", "nonsprite":"transit.png", "imageRect":{ "x": 0, "y": 31, "width": 38, "height": 31}, "action":"aauMobile.nativeAdapter.exec(null, null, 'com.appirio.mobile.map', 'showMap', []);", "actionType":"native"}
		}
		
		aauMobile.nativeAdapter.exec(function(){}, function(){}, "com.appirio.mobile.menu", "populateMenu", [{buttons: [
										{"title":"Class Schedule", "id" : "schedule-link", "icon":"iconsprite_grey.png","nonsprite":"calendar.png", "imageRect":{ "x": 0, "y": 0, "width": 38, "height": 31}, "action":"$.mobile.changePage('#student-home');", "actionType":"js"},
										{"title":"Class History", "id" : "history-link", "icon":"iconsprite_grey.png","nonsprite":"calendar.png", "imageRect":{ "x": 0, "y": 0, "width": 38, "height": 31}, "action":"$.mobile.changePage('#class-history');", "actionType":"js"},
										{"title":"Trip Planner", "id" : "trip-planner-link", "icon":"iconsprite_grey.png","nonsprite":"transit.png", "imageRect":{ "x": 0, "y": 31, "width": 38, "height": 31}, "action":"$.mobile.changePage('#trip-planner'); $(window).trigger('orientationchange');", "actionType":"js"},
										transitMap,
										{"title":"Message Center", "id" : "chatter-link", "icon":"iconsprite_grey.png","nonsprite":"agenda.png", "imageRect":{ "x": 0, "y": 63, "width": 38, "height": 22}, "action":"$.mobile.changePage('#chatter-list');", "actionType":"js"},
										{"title":"Campus News", "id" : "campus-news-link", "icon":"iconsprite_grey.png","nonsprite":"agenda.png", "imageRect":{ "x": 0, "y": 63, "width": 38, "height": 22}, "action":"$.mobile.changePage('#feed-list');", "actionType":"js"},
										{"title":"Campus Events", "id" : "campus-events-link", "icon":"iconsprite_grey.png","nonsprite":"agenda.png", "imageRect":{ "x": 0, "y": 63, "width": 38, "height": 22}, "action":"$.mobile.changePage('#campus-event-list');", "actionType":"js"},
										{"title":"Sports", "id" : "sports-link", "icon":"iconsprite_grey.png","nonsprite":"aaulogo.png", "imageRect":{ "x": 0, "y": 118, "width": 38, "height": 31}, "action":"$.mobile.changePage('#event-list');", "actionType":"js"},
										{"title":"Helpful Links", "id" : "links-link", "icon":"iconsprite_grey.png","nonsprite":"contact.png", "imageRect":{ "x": 0, "y": 86, "width": 38, "height": 33}, "action":"$.mobile.changePage('#link-list');", "actionType":"js"},
										{"title":"Logout", "id" : "logout-link", "icon":"iconsprite_grey.png","nonsprite":"gear.png", "imageRect":{ "x": 0, "y": 149, "width": 38, "height": 31}, "action":"SalesforceOAuthPlugin.logout();", "actionType":"js"}
										]}
									]);
	},
	nativeInit: function(){
		aauMobile.slideMenu.nativeSetup();
		
		$('.menu-btn').on(aauMobile.clickEvent, aauMobile.slideMenu.toggleMenu); 
		
		if(navigator.splashscreen && (aauMobile.isAndroid() || aauMobile.isIOS())){
	   		navigator.splashscreen.hide();
	   	} else if(aauMobile.isAndroid() || aauMobile.isIOS()){
	   		aauMobile.nativeAdapter.exec(null, null, "SplashScreen", "hide", []);
	   	}
	},	
	//Initializes the menu, and relevant events.
	init: function(){
		
		console.log('Start Initialize Menu');
		//We don't want the menu visible by default, we want to show the schedule or the current hash.
		$.mobile.changePage('#student-home', {changeHash: true});
		appirioUtils.log('aauMobile.slideMenu.init called');
		console.log('aauMobile.slideMenu.init called');
		
		//$('#menu-page').on(aauMobile.clickEvent, aauMobile.slideMenu.hide);
		$('#menu-page').on(aauMobile.clickEvent, function(event){
			appirioUtils.fireEvent(aauMobile.slideMenu.hide, event, null);
		});
		
		//The UL needs to stretch the entire length of the page, and not allow the 
		//underlying part of the page to fire the close event.
		$('#slide-menu').on(aauMobile.clickEvent, function(event){
			event.stopPropagation();
			console.log('Tapped on the menu.');
		});
	
		$('#slide-menu li a').on(aauMobile.clickEvent, aauMobile.slideMenu.linkClicked);
		/*
		$('#slide-menu li a').on(aauMobile.clickEvent, function(event){
			appirioUtils.fireEvent(aauMobile.slideMenu.linkClicked, event, null);
		});
		$('.menu-btn').on(aauMobile.clickEvent, aauMobile.slideMenu.show);
		$('.menu-btn').on(aauMobile.clickEvent, appirioUtils.fireEvent(aauMobile.slideMenu.show, event, null));
		*/
		$('.menu-btn').on(aauMobile.clickEvent, function(event){
			
			appirioUtils.fireEvent(aauMobile.slideMenu.show, event, null);
		});
	
		//Android pre-3.0 devices aren't fully responsive to click.
		if(aauMobile.isAndroid()) {
			$('#menu-page').addClass('android-menu');
			$('.page-container').addClass('android-menu');
		}else{
			$('#menu-page').addClass('standard-menu');
			$('.page-container').addClass('standard-menu');
			}
	   	
	   	
	   	//Occurs when the menu finishes sliding.
	    $('#menu-page').on('webkitTransitionEnd', function(){
	    	console.log('Menu Transition End');
	    	if($(this).hasClass('slide-out')){
	    		$(this).css('position','fixed');
	    		$('#slide-menu').css('height',$(window).height());
	    	} else{
	    		$(this).addClass('hidden');
	    		$(document).width($(window).width());
	    	}
	    });
	    
	    //When the current page finishes sliding, this will occur.
	    $('.page-container').on('webkitTransitionEnd', function(){
			console.log('Page Transition End');
			if($(this).attr('id') == "transit-map" && $.mobile.urlHistory.getPrev().pageUrl != 'bus-detail'){
				//mapManager.triggerResize();
				$(window).trigger('orientationchange');
			}

			if(!$(this).hasClass('slide-out')){
				$('.mob-header').css('position','fixed');
				//$('#result-container').css('position','fixed');
			}
	   	});
	   	
	   	if(navigator.splashscreen){
	   		navigator.splashscreen.hide();
	   	} else{
	   		aauMobile.nativeAdapter.exec(null, null, "SplashScreen", "hide", []);
	   	}
	}
},

getAndroidVersion: function(){
var ua = navigator.userAgent.toLowerCase();
	if(ua && ua.indexOf("android") >-1){
		var androidversion = ua.slice(ua.indexOf("android")+15);
		 androidversion = androidversion.substr(0, androidversion.indexOf(" "));
		 androidversion = parseFloat(androidversion);
		 return androidversion;
	}else{
		return -1;
	}
},

isAndroid: function(){
	var ua = navigator.userAgent.toLowerCase();
	if(ua && ua.indexOf("android") >-1){
			return true;
	}else{
		return false;
	}
},


isIOS: function(){
	var ua = navigator.userAgent.toLowerCase();
	return (ua.indexOf('iphone') > -1 || ua.indexOf('ipod') > -1 || ua.indexOf('ipad') > -1);
},

dateSort: function(date1, date2) {

  if (date1 > date2) return -1;
  if (date1 < date2) return 1;
  return 0;
},

//Sorts time strings. Pushes late night times to be considered late day.
scheduleSort: function(a,b){
	if(!a && !b){
		return 0;
	} else if(!a && b){
		return -1;
	} else if(a && !b){
		return 1;
	}
	//Turn the string into an array. t[0] hour, t[1] minutes, t[2] AM/PM
	var temp = a.split(':');
	var ta = temp[1].split(" ");
	ta.unshift(temp[0]);
	
	temp = b.split(':');
	var tb = temp[1].split(" ");
	tb.unshift(temp[0]);
	
	//Convert to integers.
	ta[0] = parseInt(ta[0]);
	tb[0] = parseInt(tb[0]);
	ta[1] = parseInt(ta[1]);
	tb[1] = parseInt(tb[1]);
	
	//Add additional hours if PM.
	ta[0] = (ta[2] == "PM" && ta[0] != 12)? ta[0] + 12 : ta[0];
	tb[0] = (tb[2] == "PM" && tb[0] != 12)? tb[0] + 12 : tb[0];	
	
	//Midnight is the 0 hour.
	if(ta[2] == "AM" && ta[0] == 12){
		ta[0] = 24;
	}
	if(tb[2] == "AM" && tb[0] == 12){
		tb[0] = 24;
	}
	
	//Return sort value.
	if(ta[0] == tb[0]){
		return ta[1] - tb[1];
	}else{
		return ta[0] - tb[0];
	}
}, //scheduleSort

init: {
	appActivation: function(){
		appirioUtils.log('aauMobile.init.appActivation has been called.');
		//alert("Returned from Background");
		//studentDataInit();
	},

	resetApplication: function() {
		window.location = '/apex/mob_studenthome';
	}
}
 
};
var AppirioUtils = function() {
    // Determines if loggin is enabled, if false calls to utils.log will not
    // output to the console (ideal for production release). Use true while developing
    var loggingEnabled = true;
    var android = null;
    var iOS = null;
	var eventInProgress = false;
    
    return {
        isAndroid: function() {
          if(android == null) {
            var ua = navigator.userAgent.toLowerCase();
	        android = ua.indexOf("android") > -1;
          }
          
          return android;
        },
        isGingerbreadOrBelow: function(){
        	var ua = navigator.userAgent.toLowerCase();
        	var isAndroid = /android/i.test(ua);
        	var isHoneycombOrNewer = /android [3-9]/i.test(ua);
			return (isAndroid && !isHoneycombOrNewer);
        },
        isIOS: function(){
        	if(iOS == null){
        		var ua = navigator.userAgent.toLowerCase();
        		iOS = (ua.indexOf("iphone") > -1 || ua.indexOf("ipod") > -1 || ua.indexOf("ipad") >-1);
        	}
        	
        	return iOS;
        },
        // Logs an object to the console if the console is available and if logging is enabled
        log: function(value) {
            if(loggingEnabled) {
                if(console) {
                    console.log(value);
                }
            }
            return true;
        },

		formatDate: function(myDate){
			var dayList = new Array ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
			var monthList = new Array('January','February','March','April','May','June','July','August','September','October','November','December');

			return dayList[myDate.getDay()]+', '+monthList[myDate.getMonth()]+' '+myDate.getDate();
		},

		fireEvent: function(mainFunction, params, onSuccess){ //, params){
			console.log('fireEvent: Start, eventInProgress: '+eventInProgress);
			if(eventInProgress){ 
				console.log('fireEvent: Event In Progress: '+eventInProgress);
				return null;
			}
			eventInProgress = true;
			//$('div.ui-loader','#container').css('display', '');
			$.mobile.showPageLoadingMsg("b", "Loading...", false);
			//alert('woot');

			//setTimeout(appirioUtils.handleError('Load Timeout.'), 8000);

			//callback(params, function(results){
			mainFunction(function(results){
			//var results = callback();
			//function(results){
			//setTimeout(function(){
			//alert('end fire');
				$.mobile.hidePageLoadingMsg();
				eventInProgress = false;
				console.log('fireEvent: End, eventInProgress is now '+eventInProgress);
				//alert('fireEvent End, eventInProgress: '+eventInProgress);
				//$.mobile.loading('hide');
				if(onSuccess){
					onSuccess(results);
				}
			//},2000);
			//});
			}, params);
    	},

		handleError: function(err){
			if(eventInProgress){
				alert('Error in processing data. ' + err.message + '. Line #' + err.lineNumber)
				$.mobile.hidePageLoadingMsg();
				eventInProgress = false;
			}
		}
    	
    	
    	
	}
};
//Initializes Class Schedule and RSS Data
function studentDataInit() {
	if(!$($.mobile.activePage).attr('id') == 'transit-map'){
		//$.mobile.showPageLoadingMsg("b", "Loading...", false);
  		//$('.ui-loader').css('display', 'block');
  	}
  	aauMobile.classSchedule.init(null);
	aauMobile.campusFeed.init(null);
	aauMobile.campusEvents.init(null);
	aauMobile.rssEvent.init(null);
	aauMobile.externalLinks.init(null);
}

//var myInitMethod = new function() {
/* PARTH: No longer required */
/*function myInitMethod(callback){
	aauMobile.classSchedule.init();
	aauMobile.campusFeed.init();
	aauMobile.campusEvents.init();
	aauMobile.rssEvent.init();
	aauMobile.externalLinks.init();
	callback();
};*/

var focusIsBound = false;

//function bindEvents(callback) {
function bindEvents() {
	
	console.log('bindEvents method called');
  $.mobile.pageContainer = $('#container');
  //Disable page transitions. With the way the menu works, we have to use our own.
  $.mobile.defaultPageTransition = 'none';	
  
    $("#transit-settings").live(aauMobile.clickEvent, function(){ 
	        $('#result-container').toggle(); 
	}); 
	$('#result-list li.settings-route').live(aauMobile.clickEvent, function(){
		mapManager.toggleRoute(this, $(this).attr('name'));
	});
	
   /* PARTH===========
   //Commented this as we now have separate Page for stops and Map
   $('#transit-map-navbar div').live(aauMobile.clickEvent, function(){
		if($(this).hasClass("transit-map-navbar-map")){
		//alert('transit-map-navbar-map');
		   $('#map-content').toggle(true);
		   $(this).toggleClass('navbar-active', true);
		   $('.transit-map-navbar-list').toggleClass('navbar-active', false);
		   $('#bus-stop-container').toggle(false);
		   $('.transit-settings').css('visibility', "visible");
		}else if($(this).hasClass("transit-map-navbar-list")){
		   $('#map-content').toggle(false);
		   $(this).toggleClass('navbar-active', true);
		   $('.transit-map-navbar-map').toggleClass('navbar-active', false);
		   $('#bus-stop-container').toggle(true); 
		   $('.transit-settings').css('visibility', "hidden");
		}
	});*/
	
  //Special changes to make the Android version function/appear correctly.
  if(appirioUtils.isAndroid()) {
  
  	if(!focusIsBound) {
	  $('#plantime').unbind();
  	  focusIsBound = true;
	    $('#plantime').on("touchstart", function(event) {
	        var currentField = $(this);
	        var time = currentField.val();
	        var myNewTime = new Date();
	        
	        console.log(time);
	
	        myNewTime.setHours(time.substr(0, 2));
	        myNewTime.setMinutes(time.substr(3, 2));
	
	        // Same handling for iPhone and Android
	        plugins.datePicker.show({
	            date : myNewTime,
	            mode : 'time', // date or time or blank for both
	            allowOldDates : true
	        }, function(returnDate) {
	          // returnDate is generated by .toLocaleString() in Java so it will be relative to the current time zone
	            var newDate = new Date(returnDate);
	            currentField.val((newDate.getHours() < 10 ? "0" + newDate.getHours() : newDate.getHours()) + ":" + (newDate.getMinutes() < 10 ? "0" + newDate.getMinutes() : newDate.getMinutes()));

	            currentField.blur();
	        });
	    });
	 }
  
  
  
  
  	//alert('android');
  	$("#container").css("position", "relative");
  	//Don't display Back button on Android devices.
  	
  	 $('.mob-back-button').css('display','none');
  	
  	//Replace CSS for fixed and transformed items.
  	$('#result-list').removeClass('result-ul').addClass('result-ul-android');
  	$('#result-arrow').removeClass('result-arrow').addClass('result-arrow-android');
  	//alert($('#result-list.result-ul').length);
  	$(document).on('backbutton', function(){
  		var index = $.mobile.urlHistory.activeIndex - 1;
		if(index >= 1){
			$.mobile.changePage("#" + $.mobile.urlHistory.getPrev().pageUrl);
			$.mobile.urlHistory.activeIndex = index;
			$.mobile.urlHistory.clearForward();
			event.preventDefault();
		} else{
			aauMobile.nativeAdapter.exec(function (){}, function(){}, "com.appirio.mobile.closeactivity", "close", []);
		}
  	});
  	$('.page-container').live('pageshow', function(){
  		if($(this).height() > $(window).height()){
  			$('#container').css('height', ($(this).height() + 50) + "px");
  		}else{
  			$('#container').css('height', '100%');
  		}
  	});
  	$(window).on('orientationchange', function(){
		//Size map properly for Andriod
  		var pageHeight = $($.mobile.activePage).height();
  		if(pageHeight > $(window).height()){
  			$('#container').css('height', (pageHeight + 50) + "px");
  		}else{
  			$('#container').css('height', '100%');
  		}
	});
	if(appirioUtils.isGingerbreadOrBelow()){
		$(".mob-content").css("position", "relative !important");
		$(".mob-content").css("top", "0px");
		$(".mob-header").css("position", "relative !important");
	}
  }

  $(window).on('orientationchange', function(){
	//Size the map properly for iPads
	$('#map-content').css('height', ($(window).height() - 50) + "px");
	if(mapManager){
		mapManager.triggerResize();
	}
  });
  
  
	//alert('uncomment  this code!!');
/*
	$('#bus-detail').live('pageshow', function(){
  		console.log('BUS DETAIL IS SHOWING');
  		if(!aauMobile.isAndroid()){
	  		var element = $('<span class="mob-back-button">Back</span>');
	  		$(this).find('.mob-back-button').remove();
	  		
	  		
	  		console.log('BACK BUTTON HAS BEEN REMOVED');
	  		$(element).prependTo($(this).find('.mob-header'));
	  		$(element).on(aauMobile.clickEvent, function(e){
	  			event.preventDefault();
	  			
	  			$.mobile.changePage('#transit-map',{transition: 'slide', reverse: true});
	  			
	  		});
	  		console.log('BACK BUTTON HAS BEEN RE-ADDED');
  		}
	});
*/

  if(!hasNativeMenu){
	  //iOS loads before an event can be triggered. Have to check and see if we're initialized.
	  if($('#menu-page').hasClass('ui-page')){
		console.log('iOS load slideMenu');
	  	aauMobile.slideMenu.init();
	  }else{
		//DONT CHANGE BELOW CODE!  THIS ONLY FIRES FOR BROWSER WHEN USING 'LIVE'
	  	$('#menu-page').live('pagecreate', function(){
			console.log('non iOS load slideMenu');
			$.mobile.showPageLoadingMsg("b", "Loading...", false);
			aauMobile.slideMenu.init();
		});
	  }
  } else{
  	aauMobile.slideMenu.nativeInit();
  } 
 //callback();
}

function map_BackButtonClick(){
	//alert('aaa');
	$.mobile.changePage('#transit-map',{transition: 'slide', reverse: true});
	//callback();
}

var deviceReady = false;
var jqueryReady = false;
var pluginReady = false;
var appInitialized = false;

var appirioUtils = new AppirioUtils();

function initApp(){
	//alert('initApp deviceReady=' + deviceReady + ' jqueryReady='+jqueryReady + 'appInitialized=' +appInitialized);
	if((deviceReady && jqueryReady) && !appInitialized){
		appInitialized = true;
		
		//Initialize Teletrac creds from SF
		//console.log('Calling init getData');
		//RestDataPlugin.getData(function(res){}, function(res){}, 'www.google.com', false, "GET", "xml");	
		//aauMobile.nativeAdapter.exec(null, null, "com.appirio.mobile.webservice", "getRestData", [""]);
		//console.log('Just Called init getData');
		
		/*For backward compatibility. Sets the nativeAdapter for native calls*/
		if(typeof cordova != 'undefined'){
			aauMobile.nativeAdapter = cordova;
		} else if(typeof PhoneGap != 'undefined'){
			aauMobile.nativeAdapter = PhoneGap;
		}
		bindEvents();
		/* PARTH: Commented this out for Lazy loading
		 * The data is filled on demand when the user clicks on the Links inside the menu
		 * The data is loaded the first time only
		 */
		//studentDataInit();
		/*appirioUtils.fireEvent(myInitMethod,null,function(){
			appirioUtils.fireEvent(bindEvents,null,function(){
				console.log('App Initialized');
			});
		});*/
		aauMobile.campusFeed.init(function(){$.mobile.hidePageLoadingMsg();});
		mapInit();
		TripPlannerInit() ;
	}
}

/*function dataInitComplete(pageComplete){
	//PARTH: check if $.mobile.activePage is initialized
	// $.mobile.activePage is unavailable in pageinit 
	if($.mobile.activePage){
		if(pageComplete == $.mobile.activePage.attr('id')){
			console.log('Data Complete: '+pageComplete);
			//$.mobile.hidePageLoadingMsg();
			hideProgress();
		}
	} else{
		//PARTH: Use hideProgress to hide spinner and set eventInProgress to false 
		//$.mobile.hidePageLoadingMsg();
		hideProgress();
	}
	
}*/

/*if(!navigator.userAgent.match(/(iPhone|iPod|iPad|Android|BlackBerry)/)) {
	deviceReady = true;
	console.log('kicking off init');
	aauMobile.clickEvent = 'click';
	initApp();
}
*/
	document.addEventListener("deviceready", function() {
		deviceReady = true;
		//alert('device ready');
		initApp();
	}, false);

	$(document).bind('pageinit', function() {
		jqueryReady = true;
		if(!appirioUtils.isAndroid() && !appirioUtils.isIOS()){
			deviceReady = true;
			aauMobile.clickEvent = 'click';
		}
		//alert('page init');
		initApp();
	});

	

 /* PARTH : this method Shows the Spinner */
 function showProgress(){ 
   			//console.log('fireEvent: Start, eventInProgress: '+ appirioUtils.eventInProgresseventInProgress);
			/*if(appirioUtils.eventInProgress){ 
				console.log('fireEvent: Event In Progress: '+ appirioUtils.eventInProgresseventInProgress);
				return null;
			}
			appirioUtils.eventInProgress = true;*/
			
			$.mobile.showPageLoadingMsg("b", "This is only a test", false);
			return true;
			
    	
	}
 
  /* PARTH : this method hides the Spinner */
 function hideProgress(){ 
   			$.mobile.hidePageLoadingMsg();
			//appirioUtils.eventInProgress = false;
				
    	
	}

	function openWebpage(url){
		showProgress();
		WebViewer.showWebView(url);
		hideProgress();
	}	
 /* PARTH : this method fetches fresh data for Class Schedule */
 function RefreshStudentDataJS(){ 
		
	console.log('RE-INITIALIZE :RefreshStudentDataJS');
	//aauMobile.classSchedule.clearLocalStorage();
	aauMobile.classSchedule.isRefreshEvent = true; 
 	appirioUtils.fireEvent(aauMobile.classSchedule.init, null, null);
}

 /* PARTH : this method fetches fresh data for Campus News */
	function RefreshCampusFeedJS(){ 
		console.log('RE-INITIALIZE :RefreshCampusFeedJS');
		//aauMobile.campusFeed.clearLocalStorage();
		aauMobile.campusFeed.isRefreshEvent = true; 
		appirioUtils.fireEvent(aauMobile.campusFeed.init, null, null);	 	
		
	}
	
	 /* PARTH : this method fetches fresh data for Campus Events */
	function RefreshCampusEventsJS(){ 
		console.log('RE-INITIALIZE :RefreshCampusEventsJS');
		//aauMobile.campusEvents.clearLocalStorage();
		aauMobile.campusEvents.isRefreshEvent = true; 
		appirioUtils.fireEvent(aauMobile.campusEvents.init, null, null);
		
	}
	
	 /* PARTH : this method fetches fresh data for Sportds Events */
	function RefreshRSSEventsJS(){ 
		console.log('RE-INITIALIZE :RefreshRSSEventsJS');
		//aauMobile.rssEvent.clearLocalStorage();
		aauMobile.rssEvent.isRefreshEvent = true; 
		appirioUtils.fireEvent(aauMobile.rssEvent.init, null, null);
		
	}
	
	/* PARTH : this method fetches fresh data for External Links */
	function RefreshExtLinksJS(){ 
		
		console.log('RE-INITIALIZE :RefreshExtLinksJS');
		//aauMobile.externalLinks.clearLocalStorage();
		aauMobile.externalLinks.isRefreshEvent = true;
		appirioUtils.fireEvent(aauMobile.externalLinks.init, null, null);	 	
		
	}
	
	/* PARTH : this method fetches fresh data for External Links */
	function RefreshChatterFeedJS(){ 
		
		console.log('RE-INITIALIZE :RefreshChatterFeedJS');
		//aauMobile.chatterFeed.clearLocalStorage();
		aauMobile.chatterFeed.isRefreshEvent = true;
		appirioUtils.fireEvent(aauMobile.chatterFeed.init, null, null);	 	
		
	}
	
	/* PARTH : this method fetches fresh data for Trip Planner */
	function RefreshTripOptionsFeedJS(){ 
		
		console.log('RE-INITIALIZE :RefreshTripOptionsFeedJS');
		aauMobile.tripPlanner.isRefreshEvent = true;
		appirioUtils.fireEvent(aauMobile.tripPlanner.init, null, null); 	
		
	}
	/* TONY : this method fetches fresh data for Class History */
	function RefreshClassHistory(){ 
		
		console.log('RE-INITIALIZE :RefreshClassHistory');
		aauMobile.classHistory.isRefreshEvent = true;
		appirioUtils.fireEvent(aauMobile.classHistory.init, null, null); 	
		
	}
		

$(document).bind('pageshow', function(event, data) {
		$.mobile.zoom.disable(true);
		$.extend($.mobile.zoom, {locked:true,enabled:false});
		
	 	var prevUser = localStorage.getItem("studentId");
        if(currentUserId != prevUser){
        	//alert('user change');
        	localStorage.setItem("studentId",currentUserId);
        	aauMobile.classSchedule.isRefreshEvent = true;
        	aauMobile.classSchedule.data = [];
        	aauMobile.campusFeed.isRefreshEvent = true; 
        	aauMobile.campusFeed.feedData = [];
        	aauMobile.campusEvents.isRefreshEvent = true;
        	 aauMobile.campusEvents.feedCount = 0;
        	aauMobile.rssEvent.isRefreshEvent = true; 
        	aauMobile.rssEvent.feedData = [];
        	aauMobile.externalLinks.isRefreshEvent = true;
        	aauMobile.externalLinks.linkData = [];
        	aauMobile.chatterFeed.isRefreshEvent = true;
        	aauMobile.chatterFeed.data = [];
        }
        
	//$.mobile.hidePageLoadingMsg();
	var currPage = $.mobile.activePage.attr('id');
	$.mobile.loadingMessage = 'Loading...';

	/*****  START: Standardize the Spinner for all page loads  ****/
	console.log('Class Schedule: ' + aauMobile.classSchedule.data);
	console.log('Campus Feed: ' + aauMobile.campusFeed.feedData);
	console.log('Campus Events: ' + aauMobile.campusEvents.feedCount);
	console.log('Athletic Events: ' + aauMobile.rssEvent.feedData);
	console.log('External Links: ' + aauMobile.externalLinks.linkData);
	
	//Parth: Track Event	
	console.log('Current Page ::'+currPage);
	
	trackEvent(currPage);
	
	if(currPage == 'student-home' && aauMobile.classSchedule.data.length === 0){
		//console.log('Go Spinny Go!');
		/* Parth: Load Student Data */
		appirioUtils.fireEvent(aauMobile.classSchedule.init, null, null);
	}
	if(currPage == 'class-history' && aauMobile.classHistory.data.length === 0){
		console.log('Go Spinny Go Class History :::');
		/* Parth: Load Student Data */
		appirioUtils.fireEvent(aauMobile.classHistory.init, null, null);
	}
	if(currPage == 'feed-list' && aauMobile.campusFeed.feedData.length === 0){
		//console.log('Go Spinny Go!');
		/* Parth: Load Campus Feed Data */ 
		appirioUtils.fireEvent(aauMobile.campusFeed.init, null, null);
	}
	if(currPage == 'campus-event-list' && aauMobile.campusEvents.feedCount < 3){
		console.log('Go Spinny Go!');
		/* Parth: Load Campus Events Data */
		 appirioUtils.fireEvent(aauMobile.campusEvents.init, null, null);
	}
	if(currPage == 'event-list' && aauMobile.rssEvent.feedData.length === 0){
		console.log('Go Spinny Go!');
		/* Parth: Load Events List Data */
		appirioUtils.fireEvent(aauMobile.rssEvent.init, null, null);
	}
	if(currPage == 'link-list' && aauMobile.externalLinks.linkData.length === 0){
		console.log('Go Spinny Go!');
		/* Parth: Load External links Data */
		appirioUtils.fireEvent(aauMobile.externalLinks.init, null, null);
	}
	if(currPage == 'chatter-list' && aauMobile.chatterFeed.data.length === 0){
		console.log('Go Spinny Go!');
		/* Parth: Load External links Data */
		appirioUtils.fireEvent(aauMobile.chatterFeed.init, null, null);
	}
	if(currPage == 'trip-options' ){
		console.log('Go Spinny Go!');
		
		if((aauMobile.tripPlanner.tripStartId != $('#startStop-select :selected').val()) 
			|| (aauMobile.tripPlanner.tripEndId != $('#endStop-select :selected').val()) 
			|| (aauMobile.tripPlanner.tripTime != $('#plantime').val()) 
			|| (aauMobile.tripPlanner.weekdayOption != $('#day-select :selected').val() )){
				
				if($('#startStop-select :selected').val() == '0' || $('#endStop-select :selected').val()=='0' || $('#plantime').val() == ''){
					$.mobile.changePage('#trip-planner',{transition: 'slide', reverse: true});
					alert('Please select a pickup/drop off point and time');
					return false;
				}
				$("#trip-options-list").empty();
				
				/* Parth: Load Trip plans*/
				aauMobile.tripPlanner.tripStart = $('#startStop-select :selected').text();
				aauMobile.tripPlanner.tripEnd = $('#endStop-select :selected').text();
				aauMobile.tripPlanner.tripStartId = $('#startStop-select :selected').val();
				aauMobile.tripPlanner.tripEndId = $('#endStop-select :selected').val();
				aauMobile.tripPlanner.tripTime = $('#plantime').val();
				aauMobile.tripPlanner.weekdayOption = $('#day-select :selected').val() ;
				appirioUtils.fireEvent(aauMobile.tripPlanner.init, null, null);
		}
	}
	
	/*if(currPage == 'transit-map'){
		//console.log('Go Spinny Go!');
		//$.mobile.showPageLoadingMsg("a", "Loading...", false);
		//fireEvent(mapLoad, 
	}*/
		
	/*****  END: Standardize the Spinner for all page loads  ****/
});

function searchTripOptions(){
	if($('#startStop-select :selected').val() == '0' || $('#endStop-select :selected').val()=='0' || $('#plantime').val() == ''){
			
			alert('Please select a pickup/drop off point and time');
			return false;
		}
	else{
		if($('#startStop-select :selected').val() ==  $('#endStop-select :selected').val()){
			alert('Pickup and drop off point should be different.');
			return false;
		}else{
			$.mobile.changePage('#trip-options',{transition: 'slide', reverse: true});
			return true;
		}
	}
}
