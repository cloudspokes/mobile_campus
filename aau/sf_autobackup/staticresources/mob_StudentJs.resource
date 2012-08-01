var aauMobile = aauMobile || {

studentId: '',
 
classSchedule: {
	data: {},
    
	init: function(){
		
		var restPath = "/classSchedule?id=" + aauMobile.studentId;
		RestDataPlugin.getData(aauMobile.classSchedule.buildSchedule, aauMobile.classSchedule.initFailure, restPath, true, "GET", "json");
	},
	
	buildSchedule: function(result){

		console.log("ClassSchedule Result: "+ JSON.stringify(result));
		aauMobile.classSchedule.data = result;
		var classData = {
			enrollments:result.mobStudentsEnrolled,
			classMeetings:result.classMeetings,
			startDate:result.startDate,
			lastDate:result.lastDate
		}
		//console.log('full ClassMeetings : '+JSON.stringify(classData.classMeetings));

		var stDate =new Date(classData.startDate.replace(/-/g,'/'));
		var enDate =new Date(classData.lastDate.replace(/-/g,'/'));
		  
		var blockTemplate = $("#student-schedule-template");
		var blockDivider = $("#student-scheduleDivider-template");
		var detailContent = $("#ulId");
		var isClassMeeting = true;

		for(; stDate < enDate; stDate.setDate(stDate.getDate() + 1)){
			console.log('::Date :: >>>>'+stDate.toLocaleDateString());
			if(isClassMeeting){
				var localeDate = stDate.toLocaleDateString();
				localeDate = localeDate.substring(0,localeDate.length-6);
				var dBlock = blockDivider.tmpl({MeetingDayAndDay:localeDate});
				dBlock.appendTo(detailContent);
			}

			isClassMeeting = false;
			$.each(classData.classMeetings, function(index, classMeeting) {
				//console.log(JSON.stringify(classMeeting));

				var meetingSTDate = new Date(classMeeting.startDate.replace(/-/g,'/'));
				var meetingENDate = new Date(classMeeting.endDate.replace(/-/g,'/'));
				//console.log('looping through class meeting records.');

				if(stDate >= meetingSTDate && stDate<=meetingENDate){
					//console.log('meeting fits timeframe.');

					if((stDate.getDay()== 0 && classMeeting.isSunday) || 
						(stDate.getDay()== 1 && classMeeting.isMonday) || 
						(stDate.getDay()== 2 && classMeeting.isTuesday) || 
						(stDate.getDay()== 3 && classMeeting.isWednesday) || 
						(stDate.getDay()== 4 && classMeeting.isThursday) || 
						(stDate.getDay()== 5 && classMeeting.isFriday) || 
						(stDate.getDay()== 6 && classMeeting.isSaturday)){
						
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
						var block = blockTemplate.tmpl({
							topic:topicName,
							className:className,
							meetingLocation:mLocation,
							stTime:startTime,
							edTime:endTime,
							meetingId:mId
						});

						block.appendTo(detailContent);        
						isClassMeeting = true;       	               
					} 
				}
			});
		}
		
		if($($.mobile.activePage).attr('id') == 'student-home'){
			$("#ulId").listview('refresh');
		}  
		$("#ulId").css("margin","0px");

	},

	initFailure: function(result) {
		console.log("failureCallback Result: "+ JSON.stringify(result));
	},

    showClassDetails: function(meetingId) {
        //get Class detail and Enrollment Details for the selected Class Meeting
        classMeetingDetail = aauMobile.classSchedule.data.classMeetings[meetingId];
        enrolledClass = aauMobile.classSchedule.data.mobStudentsEnrolled[classMeetingDetail.classSection];
        
		
		//Change the Page to Show the details of Selected Class meeting
		$.mobile.changePage("#student-detail");
		
		//Make empty to the components to add selected contents 
		$('#ulDlId').empty();
		$('#classNameDv').empty();
		$('#classDescrDv').empty();

		$("<h2>"+enrolledClass.className+"</h2>").appendTo('#classNameDv');
		$("<h3>"+enrolledClass.classDescription+"</h3>").appendTo('#classDescrDv');
        
		var blockTemplate = $("#student-classDetail-template");
		var detailContent = $("#ulDlId");
        
        meetTime = classMeetingDetail.startTime+' to '+classMeetingDetail.endTime;
        topic =  classMeetingDetail.specialTopic;
        instructor = classMeetingDetail.instructorName;
        mLocation = classMeetingDetail.location;
        
		if(instructor == '' ||instructor ==null ) instructor = 'SFDC Admin'; 
		if(topic == '' || topic ==null)	topic = 'Topic';  

		var detailBlock = blockTemplate.tmpl({
			meetingTime:meetTime,
			meetingTopic:topic ,
			meetingInstruction:instructor,
			mLocation:mLocation
		});

		detailBlock.appendTo(detailContent);  
		if($($.mobile.activePage).attr('id') == 'student-detail'){
			$("#ulDlId").listview('refresh');
		}   
		$("#ulDlId").css("margin","0px");
    }
},

rssFeed: {
	feedData: [],
	
	feedCount: 0,

	init: function() {
		
		aauMobile.rssFeed.feedCount = 0;
		aauMobile.rssFeed.feedData = [];
		
		var rssUrl = 'https://www.academyart.edu/news.rss';
		RestDataPlugin.getData(aauMobile.rssFeed.buildFeed, aauMobile.rssFeed.initFailure, rssUrl, false, "GET", "xml");

		rssUrl = 'https://spreadsheets.google.com/feeds/list/0AvROhDzo3UybdDQ5aEFzVDZqSzFDdVVENTRxTXdXcHc/od6/public/basic?alt=rss';
		RestDataPlugin.getData(aauMobile.rssFeed.buildFeed, aauMobile.rssFeed.initFailure, rssUrl, false, "GET", "xml");

		rssUrl = 'https://spreadsheets.google.com/feeds/list/0AvROhDzo3UybdHF3Q3FiZnNibk1qV2xpRVFMTUM2NXc/od6/public/basic?alt=rss';
		RestDataPlugin.getData(aauMobile.rssFeed.buildFeed, aauMobile.rssFeed.initFailure, rssUrl, false, "GET", "xml");

		rssUrl = 'https://spreadsheets.google.com/feeds/list/0AvROhDzo3UybdHVSWFVwczdOekJlWjNVRmtpLU5scWc/od6/public/basic?alt=rss';
		RestDataPlugin.getData(aauMobile.rssFeed.buildFeed, aauMobile.rssFeed.initFailure, rssUrl, false, "GET", "xml");

	},

	buildFeed: function(result) {

		result = $.xml2json(result);
		//console.log('RSS Feed Success! ' + result.channel.title);
		//console.log('Result: ' + JSON.stringify(result));
		
		$.each(result.channel.item, function(index, item){
			item.origin = result.channel.title;
			aauMobile.rssFeed.feedData.push(item);
		});
		
		aauMobile.rssFeed.feedData.sort(function(a,b){
			return a.title.localeCompare(b.title);
		});
		aauMobile.rssFeed.feedCount++;
		
		var feedTemplate = $("#rss-feed-template");
		var feedContainer = $("#feed-ul"); //.empty();
		if(aauMobile.rssFeed.feedCount > 3){
			$.each(aauMobile.rssFeed.feedData, function(index, item){
					feedTemplate.tmpl({feedTitle: item.title, feedOrigin: item.origin}).appendTo(feedContainer);			
			});
		}
		if($($.mobile.activePage).attr('id') == 'feed-list'){
			$(feedContainer).listview('refresh');
		}
		$.mobile.hidePageLoadingMsg;
	},

	initFailure: function(result) {
		console.log('RSS Feed Failure. ' + result);
	},

	showFeedDetails: function() {
		rssUrl = 'https://www.academyart.edu//news/school/making-a-difference-through-photography.html';
		RestDataPlugin.getData(aauMobile.rssFeed.buildFeedDetail, aauMobile.rssFeed.initFailure, rssUrl, false, "GET", "text");
	},

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

rssEvent: {

	init: function() {
		rssUrl = 'http://www.artuathletics.com/services/calendar.ashx/calendar.rss';
		RestDataPlugin.getData(aauMobile.rssEvent.buildEvents, aauMobile.rssEvent.initFailure, rssUrl, false, "GET", "xml");
	},

	buildEvents: function(result) {
		result = $.xml2json(result);
		//console.log('RSS Feed Success! ' + result.channel.title);
		
		result.channel.item.sort(function(a,b){
			//return a.title.localeCompare(b.title);
			return a.localstartdate.localeCompare(b.localstartdate);
		});
		
		var feedTemplate = $("#event-template");
		var feedContainer = $("#event-ul"); //.empty();
		
		$.each(result.channel.item, function(index, item){
			//console.log('Event Item: ' + JSON.stringify(item));

				feedTemplate.tmpl({eventTitle: item.title, eventOrigin: result.channel.title}).appendTo(feedContainer);			
			if(index < 20){
			}else{
				//return;
			}

		});
		
		if($($.mobile.activePage).attr('id') == 'event-list'){
			$(feedContainer).listview('refresh');
		}

	},

	initFailure: function(result) {
		console.log('RSS Feed Failure. ' + result);
	}
}
};

function studentHomePageInit() {
		
    // init Class Schedule data
	aauMobile.classSchedule.init();
	aauMobile.rssFeed.init();
	aauMobile.rssEvent.init();
	
	//Detect if using an Android phone.
	var ua = navigator.userAgent.toLowerCase();
	var isAndroid = ua.indexOf("android") > -1;
	if(isAndroid) {
  		//Don't display Back button on Android devices.
  		$('.mob-back-button').css('display','none');
  		//Replace CSS for fixed and transformed items.
  		$('#result-list').removeClass('result-ul').addClass('result-ul-android');
  		$('#result-arrow').removeClass('result-arrow').addClass('result-arrow-android');
	}
	

    
    //Bind listview refreshes to respective page-before-show methods.
    $('#student-home').on('pagebeforeshow',function(){
    	$('#ulId').listview('refresh');
    }); 
    $('#student-detail').on('pagebeforeshow',function(){
    	$('#ulDlId').listview('refresh');
    }); 
    $('#feed-list').on('pagebeforeshow',function(){
    	$('#feed-ul').listview('refresh');
    }); 
    $('#event-list').on('pagebeforeshow',function(){
    	$('#event-ul').listview('refresh');
    }); 
    $('#transit-map').on('pagebeforeshow',function(){
    	$('#result-list').listview('refresh');
    }); 
}

function feedListPageCreate() {
    //init RSS Feed data
	//$.mobile.showPageLoadingMsg
	//aauMobile.rssFeed.init();
}

function feedDetailPageCreate() {
	aauMobile.rssFeed.showFeedDetails();
}

function activateSlideMenu(){
	//We don't want the menu visible by default, we want to show the schedule.
	$.mobile.changePage('#student-home', {changeHash: true});
	
	//When clicking on the menu page(which is transparent over the current page),
	//We want to close the menu and return the user to the current content.
	$('#menu-page').on('click', function(event){
		console.log('Tapped on the content. Closing Menu.');
		$('#menu-page').css('position','absolute');
		
		$('#menu-page').removeClass('slide-out');
		$($.mobile.activePage).removeClass('slide-out');
		//OLD METHOD
		//$('#slide-menu').animate({marginLeft:'-180px'},250, function(){$('#menu-page').css('display','none');});
		//$($.mobile.activePage).animate({marginLeft:'0px'},250, function(){$('.mob-header').css('position','fixed');});
	});
	
	//The UL needs to stretch the entire length of the page, and not allow the 
	//underlying part of the page to fire the close event.
	$('#slide-menu').on('click', function(event){
		event.stopPropagation();
		console.log('Tapped on the menu.');
	});
	
	//We want to close the menu, and slide in the new page when a link is clicked.
	$('#slide-menu li a').on('click', function(event){
		event.stopPropagation();
		event.preventDefault();
		
		var pageLink = $(this).attr('href');
		if(pageLink.length <= 1){
			//jQuery Mobile has hijacked our link to prevent the address bar from showing.
			pageLink = $(this).data('href');
		}
		console.log('Link clicked. Target = ' + pageLink);
		
		//Logout if logout link clicked.
		//Otherwise go to page.
		if($(this).attr('id') == 'logout-link'){
			console.log('Logging out');
			SalesforceAuth.Logout();
		}
		else{
		
			//Align it with the menu before displaying.
			$(pageLink).addClass('slide-out');
			
			$.mobile.changePage(pageLink, {changeHash: true});
			
			//Remove the fixed so that Android 2.3 doesn't freak.
			$('#menu-page').css('position','absolute');
			
			//Slide the page and the menu back to starting position.
			$('#menu-page').removeClass('slide-out');
			$(pageLink).removeClass('slide-out');
			
			//Old Method
			//$('#slide-menu').animate({marginLeft:'-180px'},250, function(){$('#menu-page').css('display','none');});
			//$(pageLink).animate({marginLeft:'0px'},250, function(){$('.mob-header').css('position','fixed');});
		}
	});
	
	$('.menu-btn').live('click',function(){
	    console.log('MENU BUTTON CLICKED');
		//Bring the menu-page to the forefront. And give headers the ability to move.
		$('.mob-header').css('position', 'absolute');
		
		//Activate the sliding.
		$('#menu-page').addClass('slide-out');
		$($.mobile.activePage).addClass('slide-out');
		
		//OLD METHOD
		//$('#slide-menu').animate({marginLeft:'0px'},250, function(){$('#slide-menu').css('position','fixed');});
		//$($.mobile.activePage).animate({marginLeft:'180px'},250);
		
    });
    
    $('#menu-page').on('webkitTransitionEnd', function(){
    	if($(this).hasClass('slide-out')){
    		$(this).css('position','fixed');
    	}
    });
    $('.ui-page').on('webkitTransitionEnd', function(){
    	if(!$(this).hasClass('slide-out')){
    		$('.mob_header').css('position','fixed');
    		}
    });
}

function bindEvents() {
  //Disable page transitions. With the way the menu works, we have to use our own.
  $.mobile.defaultPageTransition = 'none';	
  
  //iOS loads before an event can be triggered. Have to check and see if we're initialized.
  if($('#menu-page').hasClass('ui-page')){
  	activateSlideMenu();
  }else{
  	$('#menu-page').live('pageinit', activateSlideMenu);
  }
  
  $("#student-home").live("pagecreate", studentHomePageInit);
  $("#feed-list").live("pagecreate", feedListPageCreate);
  $("#feed-detail").live("pagecreate", feedDetailPageCreate);
  $("#transit-map").live("pagecreate", getVehicleInfo);
}

if(!navigator.userAgent.match(/(iPhone|iPod|iPad|Android|BlackBerry)/)) {
  bindEvents();
} else {
  document.addEventListener("deviceready", function() {
    studentHomePageInit();
    feedListPageCreate();
    feedDetailPageCreate();
    bindEvents();
  }, false);
}
