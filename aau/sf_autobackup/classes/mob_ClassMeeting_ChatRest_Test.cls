@isTest
private class mob_ClassMeeting_ChatRest_Test {
	
	public static Contact leadContact;
	public static  User sysAdmin;
	
	static{
		 sysAdmin =  mob_TestUtil.makeUser('System Administrator');
    	 leadContact = new Contact(LastName = 'lName', FirstName = 'fName',student_user__c=sysAdmin.Id);
		 insert leadContact;
	}
	static testmethod void testClassMeetingChatRest() {
	 System.runAs(sysAdmin) {
			
				ps_Term__c pTerm = mob_TestUtil.createNewTerm('T01', 'Test Term1');
			
				ps_Class__c pClass= mob_TestUtil.createClass(pTerm.Id, 'SFDC 401','Work', 'A11','A12', 'Workles', 'Field', 'ext11');
				ps_Class_Meeting__c  pClassMeeting= mob_TestUtil.createClassMeeting(pClass.Id, 'First Meeting', 1,'M21');
				ps_Enrollment__c pEnrollment = mob_TestUtil.createEnrollment(pClass.Id, 'EName', leadContact.Id);
				
				/*
				  create new FeedItem using the Get Rest Request
				*/
    			RestRequest req = new RestRequest(); 
				RestResponse res = new RestResponse();
		        
		        req.requestURI = 'https://aau--dev6.cs12.my.salesforce.com/services/apexrest/createClassMeetingChat';  
				req.httpMethod = 'GET';
				
				req.addParameter('classMeetingId',pClassMeeting.Id);
				req.addParameter('meetingNote','Test Feed Item rest Text');
				
				RestContext.request = req;
				RestContext.response = res;
				String feedMessage = mob_ClassMeeting_Save_ChatRest.saveMeetingChatterRecord();
				System.assertEquals(feedMessage,'Meeting chat record created');
		        
		        
		        /*
		           Insert Chatter feed exception coverage code 
		        */
		        
		     	req.addParameter('classMeetingId','Fake Id');
				req.addParameter('meetingNote','Test Feed Item rest Text');
			
				feedMessage = mob_ClassMeeting_Save_ChatRest.saveMeetingChatterRecord();
				System.assert(feedMessage.contains('Invalid id'));
				
				
		        /*
		          Rest Service get FeedItem method Call
		        */
		        req.requestURI = 'https://aau--dev6.cs12.my.salesforce.com/services/apexrest/classMeetingChat/'+pClassMeeting.Id;  
				req.httpMethod = 'GET';
				
				RestContext.request = req;
				RestContext.response = res;
				List<mob_ClassMeeting_ChatRest.ClassMeetingChat> classMeetingFeeds = mob_ClassMeeting_ChatRest.getClassMeetingChatters();
				System.assertEquals(classMeetingFeeds.size(),1);
				
				System.assertEquals(classMeetingFeeds.get(0).classMeetingId,pClassMeeting.Id);
				
				System.assertEquals(classMeetingFeeds.get(0).meetingNote,'Test Feed Item rest Text');
		}
	}

}