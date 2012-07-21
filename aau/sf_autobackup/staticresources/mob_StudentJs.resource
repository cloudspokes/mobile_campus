var aauMobile = aauMobile || {

studentId: '',
 
classSchedule: {
	data: {},
    
	init: function(){

		var restPath = "/classSchedule/" + aauMobile.studentId;
		RestDataPlugin.getData(aauMobile.classSchedule.buildSchedule, aauMobile.classSchedule.initFailure, restPath, true, "GET", "json");
	},
	
	buildSchedule: function(result){

		//console.log("successCallback Result: "+ JSON.stringify(result));
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

		$("#ulId").listview("refresh");     
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
        
        meetTime = classMeetingDetail.startTime+' - '+classMeetingDetail.endTime;
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
		$("#ulDlId").listview("refresh");      
		$("#ulDlId").css("margin","0px");
    }
},

rssFeed: {
	feedData: {},

	init: function() {
		var rssUrl = 'https://www.academyart.edu/news.rss';
		RestDataPlugin.getData(aauMobile.rssFeed.buildFeed, aauMobile.rssFeed.initFailure, rssUrl, false, "GET", "xml");

		rssUrl = 'http://www.artuathletics.com/services/calendar.ashx/calendar.rss';
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
		console.log('RSS Feed Success! ' + result.channel.title);
		//console.log('Result: ' + JSON.stringify(result));

		var feedTemplate = $("#rss-feed-template");
		var feedContainer = $("#feed-ul"); //.empty();

		$.each(result.channel.item, function(index, item){

			if(index < 3){
				feedTemplate.tmpl({feedTitle: item.title, feedOrigin: result.channel.title}).appendTo(feedContainer);			
			}else{
				//return;
			}

		});

		$(feedContainer).trigger('create');
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
}

};

$("#student-home").live("pageinit", function(event) {
    // init Class Schedule data
	aauMobile.classSchedule.init();

    $('#menuButton').bind('click',function(){
	     $.mobile.changePage('#menu-page');
    });
});

$("#feed-list").live("pagecreate", function(event) {
    // init RSS Feed data
	$.mobile.showPageLoadingMsg
	aauMobile.rssFeed.init();
});

$("#feed-detail").live("pagecreate", function(event) {
	aauMobile.rssFeed.showFeedDetails();

});






