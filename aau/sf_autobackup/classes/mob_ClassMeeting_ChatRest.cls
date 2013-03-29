@RestResource(urlMapping='/classMeetingChat/*')
global without sharing class mob_ClassMeeting_ChatRest {
    
    
    @HttpGet
    global static List<ClassMeetingChat> getClassMeetingChatters() {
        RestRequest req = RestContext.request;
        String classMeetingId =  req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<ClassMeetingChat> classMeetingFeeds = new List<ClassMeetingChat>();
        List<String> typeNotIn = new List<String>();
        typeNotIn.add('Poll');
        typeNotIn.add('Attached Article');
        for(FeedItem meetingFeed:[Select Type,ParentId, CreatedById, CreatedBy.Name, CreatedDate, Body From FeedItem  where parentId =:classMeetingId and type not in:typeNotIn
                                  ORDER BY CreatedDate DESC limit 100 ]){
            ClassMeetingChat meetingChat = new ClassMeetingChat();
            meetingChat.classMeetingId = meetingFeed.ParentId;
            meetingChat.userId = meetingFeed.CreatedById;
            meetingChat.userName = meetingFeed.CreatedBy.Name;
            meetingChat.meetingNote = meetingFeed.Body;
            meetingChat.postDate = meetingFeed.CreatedDate.format('MM/dd/yyyy HH:mm:ss');
            classMeetingFeeds.add(meetingChat);
        }  
        return classMeetingFeeds;
    }
    
    global class ClassMeetingChat {
        global String classMeetingId;
        global String userId;
        global String meetingNote;
        global String userName;
        global String postDate;
    }
    
}