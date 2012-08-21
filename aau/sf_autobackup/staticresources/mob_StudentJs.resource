var aauMobile = aauMobile || {

studentId: currentUserId,
 
classSchedule: {
	data: {},
    
	init: function(){
		
		var restPath = "/classSchedule?id=" + aauMobile.studentId;
		RestDataPlugin.getData(aauMobile.classSchedule.buildSchedule, aauMobile.classSchedule.initFailure, restPath, true, "GET", "json");
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

		var stDate =new Date(classData.startDate.replace(/-/g,'/'));
		var enDate =new Date(classData.lastDate.replace(/-/g,'/'));
		
		var blockTemplate = $("#student-schedule-each-template");
		//var blockDivider = $("#student-scheduleDivider-template");
		var classContainer = $("#ulId").empty();
		var listItems = [];
		//console.time('scheduleAppend');
		//alert('woot'); 
		for(var dayCount = 0; stDate < enDate && dayCount < 7; stDate.setDate(stDate.getDate() + 1)){
			//alert('::Date :: >>>>'+stDate.toLocaleDateString());

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
						/*var block = blockTemplate.tmpl({
							topic:topicName,
							className:className,
							meetingLocation:mLocation,
							stTime:startTime,
							edTime:endTime,
							meetingId:mId
						});

						block.appendTo(detailContent);  */            	               
					} 
				}
			});
			if(hasClassMeetings){
				dayCount++;
			}
		}
		console.log(listItems);
		//alert('appending classes');
		$(blockTemplate).tmpl(listItems).appendTo(classContainer);
		if(classContainer.hasClass('ui-listview')){
			classContainer.listview('refresh');
		}  
		//console.timeEnd('scheduleAppend');
		classContainer.css("margin","0px");
		$.mobile.hidePageLoadingMsg();
		$('.ui-loader').css('display', 'none');
	},

	initFailure: function(result) {
		console.log("failureCallback Result: "+ JSON.stringify(result));
	},

    showClassDetails: function(meetingId) {
        //get Class detail and Enrollment Details for the selected Class Meeting
        classMeetingDetail = aauMobile.classSchedule.data.classMeetings[meetingId];
		console.log('ClassMeetingDetail: '+JSON.stringify(classMeetingDetail));
        enrolledClass = aauMobile.classSchedule.data.mobStudentsEnrolled[classMeetingDetail.classSection];
        
		
		//Change the Page to Show the details of Selected Class meeting
		$.mobile.changePage("#student-detail", {transition: 'slide', changeHash: true});
		
		//Make empty to the components to add selected contents 
		$('#ulDlId').empty();
		$('#classNameDv').empty();
		$('#classDescrDv').empty();

		$("<span class='section-details'>"+enrolledClass.classSubject+"&nbsp;"+enrolledClass.classCatalogNbr+"."+enrolledClass.classSection+"</span>").appendTo('#classNameDv');
		$("<h2>"+enrolledClass.className+"</h2>").appendTo('#classNameDv');
		$("<h3>"+enrolledClass.classDescription+"</h3>").appendTo('#classDescrDv');
        
		var blockTemplate = $("#student-classDetail-template");
		var detailContent = $("#ulDlId");
        
        meetTime = classMeetingDetail.startTime+' to '+classMeetingDetail.endTime;
        //topic =  classMeetingDetail.specialTopic;
        instructor = classMeetingDetail.instructorName;
        mLocation = classMeetingDetail.location;
        
		if(instructor == '' ||instructor ==null ) instructor = 'SFDC Admin'; 
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
		$("#ulDlId").css("margin","0px");
    }
},

campusEvents: {
	feedData: [],
	
	feedCount: 0,

	init: function() {
		
		aauMobile.campusEvents.feedCount = 0;
		aauMobile.campusEvents.feedData = [];

		var rssUrl = 'https://spreadsheets.google.com/feeds/list/0AvROhDzo3UybdDQ5aEFzVDZqSzFDdVVENTRxTXdXcHc/od6/public/basic?alt=rss';
		RestDataPlugin.getData(aauMobile.campusEvents.buildFeed, aauMobile.campusEvents.initFailure, rssUrl, false, "GET", "xml");

		rssUrl = 'https://spreadsheets.google.com/feeds/list/0AvROhDzo3UybdHF3Q3FiZnNibk1qV2xpRVFMTUM2NXc/od6/public/basic?alt=rss';
		RestDataPlugin.getData(aauMobile.campusEvents.buildFeed, aauMobile.campusEvents.initFailure, rssUrl, false, "GET", "xml");

		rssUrl = 'https://spreadsheets.google.com/feeds/list/0AvROhDzo3UybdHVSWFVwczdOekJlWjNVRmtpLU5scWc/od6/public/basic?alt=rss';
		RestDataPlugin.getData(aauMobile.campusEvents.buildFeed, aauMobile.campusEvents.initFailure, rssUrl, false, "GET", "xml");

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
		var currentDate = new Date();
		$.each(result.channel.item, function(index, item){
			//TODO: you may want to move where this is happening (before the conversion to JSON maybe...)
			//item = aauMobile.campusEvents.processItem(item);
			item.origin = result.channel.title;

			//console.log('Description ::: '+item.description);
			if(item.description && item.description.split(",")!= null){
			
				var eventItem = item.description.split(",");
				item.raweventdate = new Date(eventItem[0].replace("eventdate:",""));
				//make sure its a real date entered into the field
				if (item.raweventdate.toString() == "NaN" || item.raweventdate.toString() == "Invalid Date") {
					console.log('Date Error in Feed: ' + item.description);
					item.raweventdate = null;
				} else {
					item.eventdate = item.raweventdate.toLocaleDateString();
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
			console.log('Campus Event Item: '+JSON.stringify(item));
            //We should also not show any records that are in the past
            if(item.raweventdate >= currentDate){ 
			  aauMobile.campusEvents.feedData.push(item);
			}
		});
		
		aauMobile.campusEvents.feedData.sort(function(a,b){
			//return a.raweventdate.localeCompare(b.raweventdate);
			//return a.eventdate.localeCompare(b.raweventdate);
			//console.log('::: Event Date::'+ a.raweventdate);
			return a.raweventdate-b.raweventdate;
		});
		
		//Increment the feed count
		aauMobile.campusEvents.feedCount++;

		//If all feeds have returned or failed, display.
		if(aauMobile.campusEvents.feedCount >2){
			aauMobile.campusEvents.showFeed();
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
		aauMobile.campusEvents.feedCount++;
		
		//If all feeds have returned or failed, display.
		if(aauMobile.campusEvents.feedCount >3){
			aauMobile.campusEvents.showFeed();
		}
	},
	
	showFeed: function(){
		var feedTemplate = $("#campus-events-template");
		var feedContainer = $("#campus-event-ul");
		$(feedContainer).empty();
		$.each(aauMobile.campusEvents.feedData, function(index, item){
			if(index < 20){
				feedTemplate.tmpl({feedTitle: item.title, feedDate: item.shortdate, feedOrigin: item.origin, feedId: item.guid}).appendTo(feedContainer);			
			}else{
				return;
			}
		});
		
		//If jQuery has initialized it, refresh.
		if($(feedContainer).hasClass('ui-listview')){
			$(feedContainer).listview('refresh');
		}
		$(feedContainer).css('margin','0px');
		//$.mobile.hidePageLoadingMsg;
	},

	showFeedDetails: function(feedId) {
		//rssUrl = 'https://www.academyart.edu//news/school/making-a-difference-through-photography.html';
		//RestDataPlugin.getData(aauMobile.campusEvents.buildFeedDetail, aauMobile.campusEvents.initFailure, rssUrl, false, "GET", "text");

		//find Feed in the feedData
		$.each(aauMobile.campusEvents.feedData, function(index, item){
			if(item.guid == feedId){
				//console.log('Opening Feed: ' + JSON.stringify(item));
				//create instance of template for campus Details
				var feedTemplate = $('#campus-detail-template');
				var feedContainer = $('#campus-detail-container').empty();
				feedTemplate.tmpl({feedTitle: item.title, feedOrigin: item.origin, feedEventDate:item.eventdate, feedDescription: item.eventdescription}).appendTo(feedContainer);
			}
		});
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

//this is the real RSS Feed! TODO: change the names, so this loads under 'Campus News'
campusFeed: {
	feedData: [],
	
	init: function() {
		aauMobile.campusFeed.feedData = [];

		var rssUrl = 'https://www.academyart.edu/news.rss';
		RestDataPlugin.getData(aauMobile.campusFeed.buildFeed, aauMobile.campusFeed.initFailure, rssUrl, false, "GET", "xml");

	},
	
	buildFeed: function(result) {
		result = $.xml2json(result);
		//aauMobile.campusFeed.feedData = result;

		console.log('RSS Feed Success! ' + result.channel.title);
		//console.log('Result: ' + JSON.stringify(result));
		
		$.each(result.channel.item, function(index, item){

			item.origin = result.channel.title;
			//console.log('Campus News Item: '+JSON.stringify(item));

			var raweventdate = new Date(item.pubDate);
			item.eventdate = raweventdate.toLocaleDateString();

			aauMobile.campusFeed.feedData.push(item);
		});
		
		/*aauMobile.campusFeed.feedData.sort(function(a,b){
			return a.title.localeCompare(b.title);
		});*/
		
		var feedTemplate = $("#rss-feed-template");
		var feedContainer = $("#feed-ul");
		$(feedContainer).empty();
		$.each(aauMobile.campusFeed.feedData, function(index, item){
			//console.log('Feed Item: '+JSON.stringify(item));
			if(index < 20){
				feedTemplate.tmpl({feedTitle: item.title, feedDate: item.eventdate, feedId: item.guid}).appendTo(feedContainer);			
			}else{
				return;
			}
		});
		if($(feedContainer).hasClass('ui-listview')){
			$(feedContainer).listview('refresh');
		}
	  $(feedContainer).css('margin', '0px');
	},

	showFeedDetails: function(feedId) {
		var feedContainer = $('#feed-detail-container').empty();
		
		//find Feed in the feedData
		$.each(aauMobile.campusFeed.feedData, function(index, item){
			if(item.guid == feedId){
				console.log('Opening Feed: ' + JSON.stringify(item));
				//create instance of template for feed Details
				var feedTemplate = $('#feed-detail-template');
				
				feedTemplate.tmpl({feedTitle: item.title, feedOrigin: item.origin, feedDate: item.eventdate, feedDescription: item.description, linkUrl: item.link}).appendTo(feedContainer);
			}
		});
		if($(feedContainer).hasClass('ui-listview')){
			$(feedContainer).listview('refresh');
		}
		//do page transition to detail screen
		$.mobile.changePage('#feed-detail', {transition: 'slide', changeHash: true});
	},

},

rssEvent: {

	init: function() {

		var rssUrl = 'http://www.artuathletics.com/services/calendar.ashx/calendar.rss';
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

externalLinks: {
	init: function(){
		//make REST call to RestDataPlugin.getData(); 
		var restPath = "/ExternalLinks";
		RestDataPlugin.getData(aauMobile.externalLinks.buildLinks, aauMobile.externalLinks.initFailure, restPath, true, "GET", "json");
	},

	//this is the successCallback from the rest call in init
	buildLinks: function(result){
		//loop through results and use a template to create each item and add to the ul 
		//console.log('external Links  Success result ! ' + JSON.stringify(result));
		var linkTemplate = $("#link-template");
		var linkContainer = $("#link-ul");
		$(linkContainer).empty();
		$.each(result, function(index, item){
			//console.log('Link Item: ' + JSON.stringify(item));
			if(index < 20){
				linkTemplate.tmpl({linkName: item.linkName, linkUrl: item.linkUrl}).appendTo(linkContainer);			
			}else{
				return;
			}

		});
		//If jQuery has initialized it, refresh.
		if($(linkContainer).hasClass('ui-listview')){
			$(linkContainer).listview('refresh');
		}
		$(linkContainer).css('margin','0px');
	},
	initFailure: function(result) {
		console.log('buildLinks Failure. ' + result);
	}
},

//Mobile Sliding Menu component. 
//Displays as a side-bar that slides out and pushes content to the side.
slideMenu: {
	lastSlide: new Date().getTime(),
	//Slides the menu out, and pushes the active page to the right.
	show: function(event){
	    event.preventDefault();
	    console.log('MENU BUTTON CLICKED');
		$('.mob-header').css('position','absolute');
		aauMobile.slideMenu.lastSlide = new Date().getTime();
		
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
			console.log('Link clicked. Target = ' + pageLink);
			
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
				utils.log("")
			
				$('#menu-header').html($(pageLink).find('.mob-header').html());
				$('#menu-header .menu-btn').removeClass('menu-btn');
				$.mobile.changePage(pageLink, {changeHash: true});
				
				//Remove the fixed so that Android 2.3 doesn't freak.
				if(aauMobile.isAndroid()){
					$('#menu-page').css('position','absolute');
				}
				
				//Slide the page and the menu back to starting position.
				$('#menu-page').removeClass('slide-out');
				$('.page-container').removeClass('slide-out');
				
				aauMobile.slideMenu.lastSlide = new Date().getTime();
				
				//Old Method
				//$('#slide-menu').animate({marginLeft:'-180px'},250, function(){$('#menu-page').css('display','none');});
				//$(pageLink).animate({marginLeft:'0px'},250, function(){$('.mob-header').css('position','fixed');});
			}
		}
	},
	
	//Initializes the menu, and relevant events.
	init: function(){
		console.log('Start Initialize Menu');
		//We don't want the menu visible by default, we want to show the schedule or the current hash.
		$.mobile.changePage('#student-home', {changeHash: true});
		utils.log('aauMobile.slideMenu.init called');
		console.log('aauMobile.slideMenu.init called');
		$('#menu-page').on('click', aauMobile.slideMenu.hide);
		
		//The UL needs to stretch the entire length of the page, and not allow the 
		//underlying part of the page to fire the close event.
		$('#slide-menu').on('click', function(event){
			event.stopPropagation();
			console.log('Tapped on the menu.');
		});
		
		$('#slide-menu li a').on('click', aauMobile.slideMenu.linkClicked);
		
	
		//Android pre-3.0 devices aren't fully responsive to click.
		if(aauMobile.isAndroid()) {
			$('.menu-btn').on('vclick', aauMobile.slideMenu.show);
			$('#menu-page').addClass('android-menu');
			$('.page-container').addClass('android-menu');
		}else{
			$('.menu-btn').on('click', aauMobile.slideMenu.show);
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
			if($(this).attr('id') == "transit-map"){
				mapManager.triggerResize();
			}
			if(!$(this).hasClass('slide-out')){
				$('.mob-header').css('position','fixed');
				$('#result-container').css('position','fixed');
			}
	   	});
	}
},

isAndroid: function(){
	var ua = navigator.userAgent.toLowerCase();
	if(ua && ua.indexOf("android") >-1){
		/*var androidversion = ua.slice(ua.indexOf("android")+15);
		 androidversion = androidversion.substr(0, androidversion.indexOf(" "));
		 androidversion = parseFloat(androidversion);
		if(androidversion < 3.0){
			//This is a version of Android that we need to build around.*/
			return true;
		/*}
		else{
			return false;
		}*/
	}else{
		return false;
	}
},

isIOS: function(){
	var ua = navigator.userAgent.toLowerCase();
	return (ua.indexOf('iphone') > -1 || ua.indexOf('ipod') > -1 || ua.indexOf('ipad') > -1);
},

init: {
	appActivation: function(){
		utils.log('aauMobile.init.appActivation has been called.');
		//alert("Returned from Background");
		studentDataInit();
	},

	resetApplication: function() {
		window.location = '/apex/mob_studenthome';
	}
}
 
};

//Initializes Class Schedule and RSS Data
function studentDataInit() {
	$.mobile.showPageLoadingMsg("b", "Loading...", false);
  	$('.ui-loader').css('display', 'block');
	aauMobile.classSchedule.init();
	aauMobile.campusFeed.init();
	aauMobile.campusEvents.init();
	aauMobile.rssEvent.init();
	aauMobile.externalLinks.init();
}

function bindEvents() {
	console.log('bindEvents method called');
  //Disable page transitions. With the way the menu works, we have to use our own.
  $.mobile.defaultPageTransition = 'none';	
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
		//TransitUtil.init();
	});
  }
  $('#result-list li.settings-route').live('click', function(){
  							var checkbox = $(this).find(':checkbox'); 
  							checkbox.prop('checked', !checkbox[0].checked).trigger('change');
  					});
  
  //$(document).on('deviceready', mapInit);

  //$('#transit-map').live('pagebeforeshow', TransitUtil.pageWillShow);
  //$('#transit-map').live('pagebeforehide', TransitUtil.pageWillHide);	
  //Special changes to make the Android version function/appear correctly.
  
  if(aauMobile.isAndroid()) {
  	//Don't display Back button on Android devices.
  	$('.mob-back-button').css('display','none');
  	//Replace CSS for fixed and transformed items.
  	$('#result-list').removeClass('result-ul').addClass('result-ul-android');
  	$('#result-arrow').removeClass('result-arrow').addClass('result-arrow-android');
  	$(document).on('backbutton', function(){
  		var index = $.mobile.urlHistory.activeIndex - 1;
		if(index >= 1){
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
  console.log('kicking off init');
  studentDataInit();
  bindEvents();
}else {
  document.addEventListener("deviceready", function() {
    studentDataInit();
    bindEvents();
    mapInit();
  }, false);
}
