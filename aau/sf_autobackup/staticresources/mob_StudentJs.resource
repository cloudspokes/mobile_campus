var aauMobile = aauMobile || {

studentId: currentUserId,
 
classSchedule: {
	data: {},
    
	init: function(){
		
		var restPath = "/classSchedule?id=" + aauMobile.studentId;
		RestDataPlugin.getData(aauMobile.classSchedule.buildSchedule, aauMobile.classSchedule.initFailure, restPath, true, "GET", "json");
	},
	
	buildSchedule: function(result){

		//console.log("ClassSchedule Result: "+ JSON.stringify(result));
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
		$(detailContent).empty();

		for(var dayCount = 0; stDate < enDate && dayCount < 7; stDate.setDate(stDate.getDate() + 1)){
			//console.log('::Date :: >>>>'+stDate.toLocaleDateString());
			var hasClassMeetings = false;
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
						
						if(!hasClassMeetings){
							var localeDate = stDate.toLocaleDateString();
							localeDate = localeDate.substring(0,localeDate.length-6);
							var dBlock = blockDivider.tmpl({MeetingDayAndDay:localeDate});
							dBlock.appendTo(detailContent);
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
						var block = blockTemplate.tmpl({
							topic:topicName,
							className:className,
							meetingLocation:mLocation,
							stTime:startTime,
							edTime:endTime,
							meetingId:mId
						});

						block.appendTo(detailContent);              	               
					} 
				}
			});
			if(hasClassMeetings){
				dayCount++;
			}
		}
		
		if($('#ulId').hasClass('ui-listview')){
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
		$.mobile.changePage("#student-detail", {transition: 'slide', changeHash: true});
		
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
		if($('#ulDlId').hasClass('ui-listview')){
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
		//RestDataPlugin.getData(aauMobile.rssFeed.buildFeed, aauMobile.rssFeed.initFailure, rssUrl, false, "GET", "xml");

		rssUrl = 'https://spreadsheets.google.com/feeds/list/0AvROhDzo3UybdDQ5aEFzVDZqSzFDdVVENTRxTXdXcHc/od6/public/basic?alt=rss';
		//RestDataPlugin.getData(aauMobile.rssFeed.buildFeed, aauMobile.rssFeed.initFailure, rssUrl, false, "GET", "xml");

		rssUrl = 'https://spreadsheets.google.com/feeds/list/0AvROhDzo3UybdHF3Q3FiZnNibk1qV2xpRVFMTUM2NXc/od6/public/basic?alt=rss';
		RestDataPlugin.getData(aauMobile.rssFeed.buildFeed, aauMobile.rssFeed.initFailure, rssUrl, false, "GET", "xml");

		rssUrl = 'https://spreadsheets.google.com/feeds/list/0AvROhDzo3UybdHVSWFVwczdOekJlWjNVRmtpLU5scWc/od6/public/basic?alt=rss';
		//RestDataPlugin.getData(aauMobile.rssFeed.buildFeed, aauMobile.rssFeed.initFailure, rssUrl, false, "GET", "xml");

	},

	buildFeed: function(result) {

		/*console.log('Result:: '+result);
		console.log('Date '+$(result).find('eventdate').get(0));
		console.log('Date '+eval(result));
		console.log('Date '+result.toString());
		console.log('Date '+$(result).html());
		console.log('Date '+$(result).text());*/

		result = $.xml2json(result);


		console.log('RSS Feed Success! ' + result.channel.title);
		//console.log('Result: ' + JSON.stringify(result));
		
		$.each(result.channel.item, function(index, item){

			//TODO: you may want to move where this is happening (before the conversion to JSON maybe...)
			item = aauMobile.rssFeed.processItem(item);
            //console.log('Date >>'+item.eventdate);
			item.origin = result.channel.title;
			aauMobile.rssFeed.feedData.push(item);
		});
		
		aauMobile.rssFeed.feedData.sort(function(a,b){
			return a.title.localeCompare(b.title);
		});
		
		//Increment the feed count
		aauMobile.rssFeed.feedCount++;
		console.log('::Feed Count ::'+aauMobile.rssFeed.feedCount);
		//TODO :: Remove this. It only to test  
		aauMobile.rssFeed.showFeed();

		//If all feeds have returned or failed, display.
		if(aauMobile.rssFeed.feedCount >3){
			aauMobile.rssFeed.showFeed();
		}
	},

	processItem: function(item){
		//TODO: put all the logic here
        //console.log('Process Item  >> '+JSON.stringify(item.description.split(",")));
		return item;
	},

	initFailure: function(result) {
		console.log('RSS Feed Failure. ' + result);
		
		//Increment so we can still display what didn't fail.
		aauMobile.rssFeed.feedCount++;
		
		//If all feeds have returned or failed, display.
		if(aauMobile.rssFeed.feedCount >3){
			aauMobile.rssFeed.showFeed();
		}
	},
	
	showFeed: function(){
		var feedTemplate = $("#rss-feed-template");
		var feedContainer = $("#feed-ul");
		$(feedContainer).empty();
		$.each(aauMobile.rssFeed.feedData, function(index, item){
				//console.log('Feed Item: '+JSON.stringify(item));
				if(index < 20){
					feedTemplate.tmpl({feedTitle: item.title, feedOrigin: item.origin, feedId: item.guid}).appendTo(feedContainer);			
				}else{
					return;
				}
			});
		
		//If jQuery has initialized it, refresh.
		if($(feedContainer).hasClass('ui-listview')){
			$(feedContainer).listview('refresh');
		}
		$(feedContainer).css('margin','0px');
		$.mobile.hidePageLoadingMsg;
	},

	showFeedDetails: function(feedId) {
		//rssUrl = 'https://www.academyart.edu//news/school/making-a-difference-through-photography.html';
		//RestDataPlugin.getData(aauMobile.rssFeed.buildFeedDetail, aauMobile.rssFeed.initFailure, rssUrl, false, "GET", "text");

		//find Feed in the feedData
		$.each(aauMobile.rssFeed.feedData, function(index, item){
			if(item.guid == feedId){
				console.log('Opening Feed: ' + JSON.stringify(item));
				//parse through feed for anchortag and replace with call to appirioPlugin.webViewer
				//parse and format description
				//var desc = $.parseJSON(item.description);
				//create instance of template for feed Details
				var feedTemplate = $('#feed-detail-template');
				var feedContainer = $('#feed-detail-container').empty();
				
				eventDate = '';
				eventDescription = '';
				console.log('Description ::: '+item.description);
				if(item.description && item.description.split(",")!= null){
				  eventItem = item.description.split(",");
				  eventDate = eventItem[0].replace("eventdate:","");
				  eventDescription = eventItem[1].replace("eventdescription:","");
				}
				
				feedTemplate.tmpl({feedTitle: item.title, feedOrigin: item.origin, feedEventDate:eventDate, feedDescription: eventDescription}).appendTo(feedContainer);
			}
		});
		//do page transition to detail screen
		$.mobile.changePage('#feed-detail', {transition: 'slide', changeHash: true});
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
		var feedContainer = $("#event-ul");
		$(feedContainer).empty();
		
		$.each(result.channel.item, function(index, item){
			//console.log('Event Item: ' + JSON.stringify(item));

			if(index < 20){
				feedTemplate.tmpl({eventTitle: item.title, eventOrigin: result.channel.title}).appendTo(feedContainer);			
			}else{
				return;
			}

		});
		
		//If jQuery has initialized it, refresh.
		if($(feedContainer).hasClass('ui-listview')){
			$(feedContainer).listview('refresh');
		}
		$(feedContainer).css('margin','0px');
	},

	initFailure: function(result) {
		console.log('RSS Feed Failure. ' + result);
	}
},

//Mobile Sliding Menu component. 
//Displays as a side-bar that slides out and pushes content to the side.
slideMenu: {
	//Slides the menu out, and pushes the active page to the right.
	show: function(event){
	    event.preventDefault();
	    console.log('MENU BUTTON CLICKED');
		//Bring the menu-page to the forefront. And give headers the ability to move.
		//$('.mob-header').css('position', 'absolute');
		
		$('#menu-page').data('lastSlide', new Date().getTime());
		
		$('#menu-header').html($($.mobile.activePage).find('.mob-header').html());
		$('#menu-header .menu-btn').removeClass('menu-btn');
		$('#menu-page').removeClass('hidden');
		
		//Prevent ugly slide behavior on transit-map
		$('#result-container').css('position','absolute');
		
		//Activate the sliding.
		$('#menu-page').addClass('slide-out');
		$('.page-container').addClass('slide-out');
		
		//OLD METHOD
		//$('#slide-menu').animate({marginLeft:'0px'},250, function(){$('#slide-menu').css('position','fixed');});
		//$($.mobile.activePage).animate({marginLeft:'180px'},250);
	},

	//Removes the slide-out class, causing the active page and 
	hide: function(event){
		var lastSlide = new Date($(this).data('lastSlide')).getTime();
		var curTime = new Date().getTime();
		var timeDiff = curTime - lastSlide;
		console.log('curTime - lastSlide = ' + timeDiff);
		
		//Android vClick bug solution.
		if(timeDiff > 400){		
			console.log('Tapped on the content. Closing Menu.');
			$('#menu-page').css('position','absolute');
			
			$('#menu-page').removeClass('slide-out');
			
			$('.page-container').removeClass('slide-out');
		}
		
		//OLD METHOD
		//$('#slide-menu').animate({marginLeft:'-180px'},250, function(){$('#menu-page').css('display','none');});
		//$($.mobile.activePage).animate({marginLeft:'0px'},250, function(){$('.mob-header').css('position','fixed');});
	},

	//Changes the active page and slides the menu back into hiding.
	linkClicked: function(event){
		event.stopPropagation();
		event.preventDefault();
		
		var lastSlide = new Date($('#menu-page').data('lastSlide')).getTime();
		var curTime = new Date().getTime();
		var timeDiff = curTime - lastSlide;
		console.log('curTime - lastSlide = ' + timeDiff);
		
		//Android vClick bug solution.
		if(timeDiff > 400){		
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
				$('#menu-header').html($(pageLink).find('.mob-header').html());
				$('#menu-header .menu-btn').removeClass('menu-btn');
				$.mobile.changePage(pageLink, {changeHash: true});
				
				//Remove the fixed so that Android 2.3 doesn't freak.
				$('#menu-page').css('position','absolute');
				
				//Slide the page and the menu back to starting position.
				$('#menu-page').removeClass('slide-out');
				$('.page-container').removeClass('slide-out');
				
				//Old Method
				//$('#slide-menu').animate({marginLeft:'-180px'},250, function(){$('#menu-page').css('display','none');});
				//$(pageLink).animate({marginLeft:'0px'},250, function(){$('.mob-header').css('position','fixed');});
			}
		}
	},
	
	//Initializes the menu, and relevant events.
	init: function(){
		//We don't want the menu visible by default, we want to show the schedule or the current hash.
		if(window.location.hash.length > 1){
			$.mobile.changePage(window.location.hash, {changeHash: false});
		}
		else{
			$.mobile.changePage('#student-home', {changeHash: true});
		}
		
		$('#menu-page').on('click', aauMobile.slideMenu.hide);
		
		//The UL needs to stretch the entire length of the page, and not allow the 
		//underlying part of the page to fire the close event.
		$('#slide-menu').on('click', function(event){
			event.stopPropagation();
			console.log('Tapped on the menu.');
		});
		
		$('#slide-menu li a').on('click', aauMobile.slideMenu.linkClicked);
		
		//Android pre-3.0 devices aren't fully responsive to click.
		if(aauMobile.isAndroid) {
			$('.menu-btn').live('vclick', aauMobile.slideMenu.show);
		}else{
			$('.menu-btn').live('click', aauMobile.slideMenu.show);
		}
	   	
	   	//Occurs when the menu finishes sliding.
	    $('#menu-page').on('webkitTransitionEnd', function(){
	    	if($(this).hasClass('slide-out')){
	    		$(this).css('position','fixed');
	    		$('#slide-menu').css('height',$(window).height());
	    	} else{
	    		$(this).addClass('hidden');
	    	}
	    });
	    
	    //When the current page finishes sliding, this will occur.
	    $('.ui-page').on('webkitTransitionEnd', function(){
			if($(this).attr('id') == "transit-map"){
				mapManager.triggerResize();
			}
			if(!$(this).hasClass('slide-out')){
				$('#result-container').css('position','fixed');
			}
	   	});
	}
},

isAndroid: (navigator.userAgent.toLowerCase().indexOf("android") >-1),

init: {
	appActivation: function(){

	}
}
 
};

//Initializes Class Schedule and RSS Data
function studentDataInit() {
	aauMobile.classSchedule.init();
	aauMobile.rssFeed.init();
	aauMobile.rssEvent.init();
}

function bindEvents() {
  //Disable page transitions. With the way the menu works, we have to use our own.
  $.mobile.defaultPageTransition = 'none';	
 
  //iOS loads before an event can be triggered. Have to check and see if we're initialized.
  if($('#menu-page').hasClass('ui-page')){
  	aauMobile.slideMenu.init();
  }else{
  	$('#menu-page').live('pageinit', aauMobile.slideMenu.init);
  }
  //Force the menu to be initialized if we're not on it or it's not been touched by jQuery.
/*	if($($.mobile.activePage).attr('id') != 'menu-page' && !$('#menu-page').hasClass('ui-page')){
		$.mobile.changePage('#menu-page', {changeHash: false});
	}*/
		
  
  $(document).on('pagechangefailed', function(){
  	$.mobile.changePage('#student-home', {changeHash: true});
  });
  //Special changes to make the Android version function/appear correctly.
  if(aauMobile.isAndroid) {
  	//Don't display Back button on Android devices.
  	$('.mob-back-button').css('display','none');
  	//Replace CSS for fixed and transformed items.
  	$('#result-list').removeClass('result-ul').addClass('result-ul-android');
  	$('#result-arrow').removeClass('result-arrow').addClass('result-arrow-android');
  	$(document).on('backbutton', function(){
  		var index = $.mobile.urlHistory.activeIndex - 1;
		if(index > 1){
			event.preventDefault();
			$.mobile.changePage("#" + $.mobile.urlHistory.getPrev().pageUrl);
			$.mobile.urlHistory.activeIndex = index;
			$.mobile.urlHistory.clearForward();
		} else{
			PhoneGap.exec(function (){}, function(){}, "com.appirio.mobile.closeactivity", "close", []);
		}
  	});
  }
}

if(!navigator.userAgent.match(/(iPhone|iPod|iPad|Android|BlackBerry)/)) {
  studentDataInit();
  bindEvents();
} else {
  document.addEventListener("deviceready", function() {
    studentDataInit();
    bindEvents();
  }, false);
}
