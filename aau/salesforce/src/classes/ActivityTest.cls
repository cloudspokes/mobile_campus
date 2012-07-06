public with sharing class ActivityTest {

	static testmethod void testTaskDeleteTrigger() {
		User u1 = [select Id from User where alias='NOADVIS'];
        System.RunAs(u1) {
			Task t = [select Id from Task where OwnerId = :u1.Id limit 1];
			try {
        		delete t;
			} catch (Exception e ) { 
				// pass
			}
        }
	}


     static testMethod void testTaskOnContact() {
		User rep = [select ID from User where alias='telemktr'];
		Contact c = [select ID from Contact where OwnerId = :rep.Id limit 1];
		
        System.RunAs(rep) {
	        Task t = new Task(WhoId = c.Id,Subject='Test', Status='Completed',OwnerId=rep.Id);
    	    insert t;
        }
        
        Contact l = [select OwnerLastActivityDate__c from Contact where Id=:c.Id];
        System.assert(l.OwnerLastActivityDate__c!=null,'Last_Activity_Datetime__c on Contact should be filled');
    }	
}