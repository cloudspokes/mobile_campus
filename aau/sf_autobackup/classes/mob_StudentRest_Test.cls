@isTest
private class mob_StudentRest_Test {
	
	static testmethod void testStudentRest() {
		User sysAdmin = TestUtil.makeUser('System Administrator');
    User aaUStudent = TestUtil.makeUser('AAU Student - Platform');
    User aaUStudentUser = TestUtil.makeUser('AAU Student - Platform');
    User aaUStudentUser1 = TestUtil.makeUser('AAU Student - Platform');
    System.runAs(sysAdmin) {
			
				Contact lead = TestUtil.makeLead('Test', 'ContactShare');
				lead.student_user__c = aaUStudentUser.Id;
				update lead;
				
				//Create Contact Share record using Trigger 
				ContactShare conShare = [Select id,ContactId,UserorGroupId from ContactShare where contactId=:lead.Id and UserorGroupId =:aaUStudentUser.Id  and  rowCause='Manual' limit 1];
				System.assertEquals(lead.student_user__c,conShare.UserorGroupId);
				
				lead.student_user__c = aaUStudentUser1.Id;
				update lead;
				
				conShare = [Select id,ContactId,UserorGroupId from ContactShare where contactId=:lead.Id and UserorGroupId =:aaUStudentUser1.Id  and  rowCause='Manual' limit 1];
				System.assertEquals(aaUStudentUser1.Id,conShare.UserorGroupId);
				
				Contact contact = new Contact(LastName = 'lName', FirstName = 'fName', Recruiting_Status__c = 'Applicant',student_user__c=aaUStudentUser1.Id);
				insert contact;
				
				
				ps_Term__c pTerm = TestUtil.createNewTerm('T01', 'Test Term1');
				ps_Class__c pClass= TestUtil.createClass(pTerm.Id, 'SFDC 401','Work', 'A11','A12', 'Workles', 'Field', 'ext11');
				ps_Class_Meeting__c  pClassMeeting= TestUtil.createClassMeeting(pClass.Id, 'First Meeting', 1,'M21');
				ps_Enrollment__c pEnrollment = TestUtil.createEnrollment(pClass.Id, 'EName', lead.Id);
				
				RestRequest req = new RestRequest(); 
    			RestResponse res = new RestResponse();
                req.addParameter('id',lead.id);
                // pass the req and resp objects to the method		 
                req.requestURI = 'https://aau--dev6.cs12.my.salesforce.com/services/apexrest/classSchedule';  
                req.httpMethod = 'GET';
    			mob_StudentRest.getEnrollments(req,res);
		}
	}
}