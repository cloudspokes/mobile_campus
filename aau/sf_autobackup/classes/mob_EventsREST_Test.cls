@isTest
private class mob_EventsREST_Test {
	
  static testmethod void testMobilePost() {
    User aaUStudent = mob_TestUtil.makeUser('AAU Student - Platform');
    System.runAs(aaUStudent) {
          Double lat =  37.788008;
          Double longitute = -122.400682;
          Bus_Stop__c busStop = mob_TestUtil.createBusStop('First', lat, longitute);
          
          Mobile_Post__c  mobilePost = new Mobile_Post__c();
          
          mobilePost.Title__c = 'Test Mobile Post';
          mobilePost.Event_Start__c = System.today().addDays(1);
          mobilePost.Event_End__c = System.today().addDays(5);  
          mobilePost.Bus_Stop__c = busStop.id;
          mobilePost.Description__c='Test Mobile Description';
          mobilePost.Category__c ='Campus Recreation';
          mobilePost.Subcategory__c = 'Event';
          mobilePost.Link_Text__c = 'Test Link Text';
          mobilePost.Link__c = 'http://aaurecreationwellness.blogspot.com';
          insert mobilePost; 
        
          mob_EventsREST.getMobileEvents();
    }
  }    

}