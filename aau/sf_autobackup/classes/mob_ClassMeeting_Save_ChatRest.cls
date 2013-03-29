@RestResource(urlMapping='/createClassMeetingChat/*')
global with sharing class mob_ClassMeeting_Save_ChatRest {
    
    @HttpGet
    global static String   saveMeetingChatterRecord() {
    	RestRequest req = RestContext.request;
    	Map<String,String> qryParams =  req.params;
    	
    	ClassMeetingChat meetingChat = new ClassMeetingChat(); 
    	
    	if(qryParams.containsKey('classMeetingId'))
    	    meetingChat.classMeetingId = qryParams.get('classMeetingId');

        if(qryParams.containsKey('meetingNote'))    	    
    	    meetingChat.meetingNote = EncodingUtil.urlDecode(qryParams.get('meetingNote'), 'UTF-8');
    	
    	
    	
        return createNewChatterRecord(meetingChat);
    }
    
    
    private static String createNewChatterRecord(ClassMeetingChat meetingChat){
    	try{
	    	FeedItem fItem = new FeedItem();
			fItem.Type = 'TextPost';
			fItem.ParentId = meetingChat.classMeetingId;
			//fItem.InsertedById = meetingChat.userId;
			fItem.Body = meetingChat.meetingNote;
			insert fItem;
    	}catch(Exception ex){
    	  return ex.getMessage();	
    	}
    	return 'Meeting chat record created' ;
    }
    
    global class ClassMeetingChat {
        global String classMeetingId;
        global String userId;
        global String meetingNote;
    }
}