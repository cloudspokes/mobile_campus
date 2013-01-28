@RestResource(urlMapping='/MobileEvents')
global with sharing class mob_EventsREST {
    
    @HttpGet
    global static List<MobileEvent> getMobileEvents() {
        List<MobileEvent> events = new List<MobileEvent>();
        for(Mobile_Post__c event:[SELECT Id,
										Title__c,
										Location__c,
										Bus_Stop__r.Name,
										Category__c,
										Subcategory__c,
										Description__c,
										Event_Start__c,
										Event_End__c,
										Link__c,
										Link_Text__c,
										CreatedDate
									FROM Mobile_Post__c 
									WHERE Event_Start__c >= TODAY 
									ORDER BY Event_Start__c NULLS LAST 
									LIMIT 20]){

            MobileEvent mEvent = new MobileEvent();
            mEvent.id = event.Id;
            mEvent.title = event.Title__c;
            mEvent.category = event.Category__c;
            mEvent.description = event.Description__c;
            mEvent.link = event.Link__c;
            mEvent.createddate = event.CreatedDate;

			//format to show on screen properly if blank
			if(event.Link__c != null && event.Link__c != ''){
				mEvent.linktext = event.Link_Text__c;
			}else{
				mEvent.linktext = '';
			}
			if(event.Subcategory__c != null){
				mEvent.subcategory = event.Subcategory__c;
			}else{
				mEvent.subcategory = '';
			}
			if(event.Location__c != null){
				mEvent.location = event.Location__c;
			}else{
				mEvent.location = '';
			}
			if(event.Bus_Stop__r.Name != null){
				mEvent.locationstop = event.Bus_Stop__r.Name;
			}else{
				mEvent.locationstop = '';
			}
				
			//format for different uses in UX
			if(event.Event_Start__c != null){
				mEvent.startdate = event.Event_Start__c.format('M/d/yy');
				mEvent.starttime = event.Event_Start__c.format('h:mm a');
			}
			if(event.Event_End__c != null){
				mEvent.enddate = event.Event_End__c.format('M/d/yy');
				mEvent.endtime = event.Event_End__c.format('h:mm a');
			}

			//format to show on screen properly if blank
			if(mEvent.startdate == null){ mEvent.startdate = '';}
			if(mEvent.starttime == null){ mEvent.starttime = '';}
			if(mEvent.enddate == null){ mEvent.enddate = '';}
			if(mEvent.endtime == null){ mEvent.endtime = '';}

            events.add(mEvent);
        }
        return events;
    }
    
    global class MobileEvent{
        public String id {get;set;}
        public String title {get;set;}
        public String location {get;set;}
        public String locationstop {get;set;}
        public String category {get;set;}
        public String subcategory {get;set;}
        public String description {get;set;}
        public String startdate {get;set;}
        public String starttime {get;set;}
        public String enddate {get;set;}
        public String endtime {get;set;}
        public String link {get;set;}
        public String linktext {get;set;}
        public Datetime createddate {get;set;}
    }

}